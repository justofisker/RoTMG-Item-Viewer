extends Node

var json_data

var map_objects: ImageTexture
var ground_tiles: ImageTexture 

@onready var grid_container: HFlowContainer = $"../VBoxContainer/SmoothScrollContainer/MarginContainer/GridContainer"

func _ready() -> void:
	var map_objects_img := Image.new()
	map_objects_img.load("res://atlases/mapObjects.png")
	map_objects = ImageTexture.create_from_image(map_objects_img)
	var ground_tiles_img := Image.new()
	ground_tiles_img.load("res://atlases/groundTiles.png")
	ground_tiles = ImageTexture.create_from_image(map_objects_img)
	
	var json := JSON.new()
	var json_file := FileAccess.open("res://atlases/spritesheet.json", FileAccess.READ)
	if json.parse(json_file.get_as_text()) != OK:
		print("Error whilst parsing spritesheets.json: ", json.get_error_message(), " on line ", json.get_error_line(), ".")
	
	json_data = json.data
	
	var dir = DirAccess.open("res://xml/")
	for fname in dir.get_files():
		if fname != "equip.xml":
			continue
		parse_equip_xml("res://xml/" + fname)

var loaded_sheets := {}

func _create_texture_fallback(sheet_name: String, index: int):
	var path := "res://sheets/" + sheet_name + ".png"
	print("using fallback for " + sheet_name)
	var texture_size := Vector2i(8, 8)
	if sheet_name.ends_with("8x8"):
		pass
	elif sheet_name.ends_with("16x16"):
		texture_size = Vector2i(16, 16)
	elif sheet_name.ends_with("32x32"):
		texture_size = Vector2i(32, 32)
	elif sheet_name.ends_with("64x64"):
		texture_size = Vector2i(64, 64)
	
	if FileAccess.file_exists(path):
		var sheet_texture: Texture2D
		if loaded_sheets.has(sheet_name):
			sheet_texture = loaded_sheets[sheet_name]
		else:
			var sheet_img := Image.new()
			sheet_img.load(path)
			sheet_texture = ImageTexture.create_from_image(sheet_img)
			loaded_sheets[sheet_name] = sheet_texture
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet_texture
		var width := sheet_texture.get_width()
		atlas.region.position = Vector2(texture_size.x % width, texture_size.x / width)
		atlas.region.size = Vector2(texture_size)
		return atlas
	return null

func create_texture(sheet_name: String, index: int, margin: bool = true) -> AtlasTexture:
	for sheet in json_data["sprites"]:
		if sheet["spriteSheetName"] != sheet_name:
			continue
		var element = null
		for e in sheet["elements"]:
			if e["index"] == index:
				element = e
		if element == null:
			#push_warning("Cannot find ", sheet_name, " with index ", index)
			return null
			#return _create_texture_fallback(sheet_name, index)
		assert(element["index"] == index)
		var atlas := AtlasTexture.new()
		match int(sheet["atlasId"]):
			4:
				atlas.atlas = map_objects
			1:
				atlas.atlas = ground_tiles
		var pos = element["position"]
		atlas.region = Rect2(pos["x"], pos["y"], pos["w"], pos["h"])
		if margin:
			atlas.region.position.x -= 1
			atlas.region.position.y -= 1
			atlas.region.size.x += 2
			atlas.region.size.y += 2
		return atlas
	return null

var p: XMLParser

func read() -> void:
	assert(p.read() != ERR_FILE_EOF)
	while !(p.get_node_type() == XMLParser.NODE_ELEMENT || p.get_node_type() == XMLParser.NODE_ELEMENT_END):
		assert(p.read() != ERR_FILE_EOF)

func read_whitespace() -> void:
	assert(p.read() != ERR_FILE_EOF)
	while !(p.get_node_type() == XMLParser.NODE_ELEMENT || p.get_node_type() == XMLParser.NODE_ELEMENT_END || p.get_node_type() == XMLParser.NODE_TEXT):
		assert(p.read() != ERR_FILE_EOF)

func read_possible_end() -> bool:
	if p.read() == ERR_FILE_EOF:
		return false
	while !(p.get_node_type() == XMLParser.NODE_ELEMENT || p.get_node_type() == XMLParser.NODE_ELEMENT_END):
		if p.read() == ERR_FILE_EOF:
			return false
	return true

func parse_equip_xml(path: String):
	p = XMLParser.new()
	p.open(path)
	
	read()
	assert(p.get_node_type() == XMLParser.NODE_ELEMENT)
	if p.get_node_name() != "Objects":
		return
	assert(p.get_node_name() == "Objects")
	
	if !read_possible_end():
		return
	
	while p.get_node_type() != XMLParser.NODE_ELEMENT_END:
		var item_name: String
		var collection_icon: int = 0
		for idx in p.get_attribute_count():
			match p.get_attribute_name(idx):
				"id":
					item_name = p.get_attribute_value(idx)
				"collectionIcon":
					collection_icon = p.get_attribute_value(idx).to_int()
		
		read()
		
		var offset := p.get_node_offset()
		var object_class: String
		
		while p.get_node_type() != XMLParser.NODE_ELEMENT_END:
			if p.get_node_name() == "Class":
				read_whitespace()
				object_class = p.get_node_data()
				break
			p.skip_section()
			read()
		p.seek(offset)
		
		if object_class != "Equipment":
			read()
			p.skip_section()
			if !read_possible_end():
				break
			continue
		
		var display_name: String = ""
		var description: String = ""
		
		var item := ItemInformation.new()
		item.id = item_name
		item.collection_icon = collection_icon
		
		while p.get_node_type() != XMLParser.NODE_ELEMENT_END:
			match p.get_node_name():
				"Class":
					read_whitespace()
					assert(p.get_node_data() == "Equipment")
				"Description":
					read_whitespace()
					item.description = p.get_node_data()
				"DisplayId":
					read_whitespace()
					item.name = p.get_node_data()
				"Texture":
					var object_texture = parse_texture()
					if object_texture != null:
						item.texture = create_texture(object_texture.file, object_texture.index)
				"feedPower":
					read_whitespace()
					item.feedpower = p.get_node_data().to_float()
				"Tier":
					read_whitespace()
					item.tier = p.get_node_data().to_int()
				"NumProjectiles":
					read_whitespace()
					item.num_projectiles = p.get_node_data().to_int()
				"SlotType":
					read_whitespace()
					item.slot_type = p.get_node_data().to_int()
				"Soulbound":
					item.soulbound = true
				"XPBonus":
					read_whitespace()
					item.xp_bonus = p.get_node_data().to_int()
				"MpCost":
					read_whitespace()
					item.mp_cost = p.get_node_data().to_int()
				"Subattack":
					offset = p.get_node_offset()
					var sub_attack := ItemInformation.SubAttack.new()
					for idx in p.get_attribute_count():
						if p.get_attribute_name(idx) == "projectileId":
							sub_attack.projectile_id = p.get_attribute_value(idx).to_int()
					read()
					while p.get_node_type() != XMLParser.NODE_ELEMENT_END:
						match p.get_node_name():
							"NumProjectiles":
								read_whitespace()
								sub_attack.num_projectiles = p.get_node_data().to_int()
							"RateOfFire":
								read_whitespace()
								sub_attack.rate_of_fire = p.get_node_data().to_float()
						p.skip_section()
						read()
					p.seek(offset)
					item.sub_attacks.append(sub_attack)
				"Projectile":
					var proj := ItemInformation.Projectile.new()
					offset = p.get_node_offset()
					var projectile_id : int = 0
					for idx in p.get_attribute_count():
						if p.get_attribute_name(idx) == "id":
							proj.id = p.get_attribute_value(idx).to_int()
					read()
					while p.get_node_type() != XMLParser.NODE_ELEMENT_END:
						match p.get_node_name():
							"MinDamage":
								read_whitespace()
								proj.min_damage = p.get_node_data().to_int()
							"MaxDamage":
								read_whitespace()
								proj.max_damage = p.get_node_data().to_int()
							"MultiHit":
								proj.multi_hit = true
							"PassesCover":
								proj.passes_cover = true
							"ArmorPiercing":
								proj.armor_piercing = true
							"Boomerang":
								proj.boomerang = true
							"Speed":
								read_whitespace()
								proj.speed = p.get_node_data().to_int()
							"LifetimeMS":
								read_whitespace()
								proj.lifetime_ms = p.get_node_data().to_int()
							"ConditionEffect":
								var duration: float
								for idx in p.get_attribute_count():
									if p.get_attribute_name(idx) == "duration":
										duration = p.get_attribute_value(idx).to_float()
								read_whitespace()
								proj.condition_effects[p.get_node_data()] = duration
						p.skip_section()
						read()
					p.seek(offset)
					item.projectiles.append(proj)
				"BagType":
					read_whitespace()
					var bag_type = p.get_node_data().to_int()
				"Labels":
					read_whitespace()
					item.labels = p.get_node_data().split(",")
				"ExtraTooltipData":
					offset = p.get_node_offset()
					read()
					while p.get_node_type() != XMLParser.NODE_ELEMENT_END:
						match p.get_node_name():
							"EffectInfo":
								var effect_description: String
								var effect_name: String
								for idx in p.get_attribute_count():
									match p.get_attribute_name(idx):
										"description":
											effect_description = p.get_attribute_value(idx)
										"name":
											effect_name = p.get_attribute_value(idx)
								item.extra_tooltip_data.append({"name": effect_name, "description": effect_description})
						p.skip_section()
						read()
					p.seek(offset)
				"ActivateOnEquip":
					var attribs := {}
					for idx in p.get_attribute_count():
						attribs[p.get_attribute_name(idx)] = p.get_attribute_value(idx)
					read_whitespace()
					item.on_equip.append({"active": p.get_node_data(), "attribs": attribs })
				"Activate":
					var attribs := {}
					for idx in p.get_attribute_count():
						attribs[p.get_attribute_name(idx)] = p.get_attribute_value(idx)
					read_whitespace()
					item.on_use.append({"active": p.get_node_data(), "attribs": attribs })
				"RateOfFire":
					read_whitespace()
					item.rate_of_fire = p.get_node_data().to_float()
			p.skip_section()
			read()
		
		var trect = TextureRect.new()
		var size: = Vector2(8, 8) * 5.0
		trect.texture = item.texture
		if trect.texture == null:
			trect.texture = preload("res://item_preview/missing_texture.png")
		trect.custom_minimum_size = trect.texture.get_size() * 5.0
		trect.material = preload("res://item_preview/item_outline.tres")
		trect.tooltip_text = item_name + " " + item.name + " " + " ".join(item.labels)
		trect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		trect.size_flags_vertical = Control.SIZE_SHRINK_END
		trect.set_script(preload("res://item_preview/item_texture.gd"))
		trect.item = item
		grid_container.add_child(trect)
		
		if !read_possible_end():
			break

class ObjectTexture:
	var animated: bool
	var file: String
	var index: int

func parse_texture() -> ObjectTexture:
	var t = ObjectTexture.new()
	
	# There is some off by 1 read error going on here and I'm unsure how to fix it
	# Hence, this hacky solution
	var offset := p.get_node_offset()
	
	t.animated = p.get_node_name() == "AnimatedTexture"
	
	read()
	while p.get_node_type() != XMLParser.NODE_ELEMENT_END:
		if p.get_node_type() == XMLParser.NODE_ELEMENT:
			match p.get_node_name():
				"File":
					read_whitespace()
					t.file = p.get_node_data()
				"Index":
					read_whitespace()
					var index_string := p.get_node_data()
					if index_string.begins_with("0x"):
						t.index = p.get_node_data().hex_to_int()
					else:
						t.index = p.get_node_data().to_int()
			p.skip_section()
		read()
	
	p.seek(offset)
	return t
