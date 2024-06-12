extends Control

@onready var tier_label: Label = $MarginContainer/PanelContainer/VBoxContainer/TopBar/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/SpriteContainer/ItemSprite/TierLabel
@onready var item_name_label: Label = $MarginContainer/PanelContainer/VBoxContainer/TopBar/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/ItemNameLabel
@onready var collection_icon: TextureRect = $MarginContainer/PanelContainer/VBoxContainer/TopBar/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/CollectionIcon
@onready var tier_label_big: Label = $MarginContainer/PanelContainer/VBoxContainer/TopBar/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/TierLabelBig
@onready var damage_label: Label = $MarginContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/DamageLabel
@onready var damage_number_label: Label = $MarginContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/DamageNumberLabel
@onready var soulbound_label: Label = $MarginContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/SoulboundLabel
@onready var description_label: Label = $MarginContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/DescriptionLabel
@onready var red_forge_icon: TextureRect = $MarginContainer/PanelContainer/VBoxContainer/BottomBar/HBoxContainer/RedForgeIcon
@onready var red_forge_amt: Label = $MarginContainer/PanelContainer/VBoxContainer/BottomBar/HBoxContainer/RedForgeAmt
@onready var gold_forge_icon: TextureRect = $MarginContainer/PanelContainer/VBoxContainer/BottomBar/HBoxContainer/GoldForgeIcon
@onready var gold_forge_amt: Label = $MarginContainer/PanelContainer/VBoxContainer/BottomBar/HBoxContainer/GoldForgeAmt
@onready var silver_forge_icon: TextureRect = $MarginContainer/PanelContainer/VBoxContainer/BottomBar/HBoxContainer/SilverForgeIcon
@onready var silver_forge_amt: Label = $MarginContainer/PanelContainer/VBoxContainer/BottomBar/HBoxContainer/SilverForgeAmt
@onready var st_forge_icon: TextureRect = $MarginContainer/PanelContainer/VBoxContainer/BottomBar/HBoxContainer/StForgeIcon
@onready var st_forge_amt: Label = $MarginContainer/PanelContainer/VBoxContainer/BottomBar/HBoxContainer/StForgeAmt
@onready var item_sprite: TextureRect = $MarginContainer/PanelContainer/VBoxContainer/TopBar/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/SpriteContainer/ItemSprite
@onready var class_label: Label = $MarginContainer/PanelContainer/VBoxContainer/TopBar/VBoxContainer/ClassLabel
@onready var rich_description: RichTextLabel = $MarginContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/RichDescription
@onready var feedpower_label: Label = $MarginContainer/PanelContainer/VBoxContainer/BottomBar/HBoxContainer/FeedpowerLabel
@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var h_bar_2: ColorRect = $MarginContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBar2
@onready var h_bar: ColorRect = $MarginContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/HBar
@onready var bottom_bar: PanelContainer = $MarginContainer/PanelContainer/VBoxContainer/BottomBar


var item: ItemInformation

func _ready() -> void:
	item_sprite.texture = item.texture
	item_name_label.text = item.get_display_name()
	
	var font = item_name_label.get_theme_font("font")
	var font_size = item_name_label.label_settings.font_size
	while font.get_string_size(item_name_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > 341:
		font_size -= 1
	item_name_label.label_settings = item_name_label.label_settings.duplicate(true)
	item_name_label.label_settings.font_size = font_size
	#print(font_size)
	
	if item.collection_icon != 0:
		collection_icon.texture = item.get_collection_icon()
	else:
		collection_icon.visible = false
	
	var tier: String
	
	if item.tier == -1:
		if item.labels.has("TAB_UT"):
			tier = "UT"
		elif item.labels.has("TAB_ST"):
			tier = "ST"
	else:
		tier = "T" + str(item.tier)
	_set_item_tier(tier)
	
	var classes := item.get_applicable_classes()
	if classes == "":
		class_label.visible = false
	else:
		class_label.text = classes
	
	if item.projectiles.size() == 0:
		damage_label.visible = false
		damage_number_label.visible = false
	else:
		var min_dmg: int = 9999999
		var max_dmg: int = -1
		for projectile in item.projectiles:
			min_dmg = mini(min_dmg, projectile.min_damage)
			max_dmg = maxi(max_dmg, projectile.max_damage)
		
		damage_number_label.text = "%d-%d" % [min_dmg, max_dmg]
	
	soulbound_label.visible = item.soulbound
	
	description_label.text = item.description.replace("\\n", "\n")
	
	rich_description.text = "[color=fdfd8e]"
	
	for extra in item.extra_tooltip_data:
		if extra["name"] != "":
			rich_description.text += "\n[color=b3b3b3]" + extra["name"] + ":[/color] " + extra["description"]
		else:
			rich_description.text += "\n" + extra["description"]
	
	for active in item.on_use:
		match active["active"]:
			"StatBoostSelf":
				var amount : int = active["attribs"]["amount"].to_int()
				var duration := snappedf(active["attribs"]["duration"].to_float(), 0.01)
				var stat := _stat_to_name(active["attribs"]["stat"])
				rich_description.text += "\n"
				if amount > 0:
					rich_description.text += "+"
				rich_description.text += "%d %s [color=b3b3b3]for[/color] %s seconds" % [ amount, stat, str(duration) ]
			"ConditionEffectAura":
				var range := snappedf(active["attribs"]["range"].to_float(), 0.01)
				var effect : String = active["attribs"]["effect"]
				var duration := snappedf(active["attribs"]["duration"].to_float(), 0.01)
				rich_description.text += "\n[color=b3b3b3]Party Effect: Within[/color] %s sqrs %s [color=b3b3b3]for[/color] %s seconds" % [ str(range), effect, str(duration) ]
			"BulletNova":
				pass
			"OpenChest":
				pass
			"PoisonGrenade":
				pass
			"Pet":
				pass
			"MysteryDyes":
				pass
			"Shoot":
				pass
			"Unlock":
				pass
			"ObjectToss":
				pass
			"IncrementStat":
				pass
			"ShurikenAbility":
				pass
			"Magic":
				pass
			"Lightning":
				pass
			"Heal":
				pass
			"ChangeObject":
				pass
			"ConditionEffectSelf":
				pass
			"EffectBlast":
				pass
			"ClearConditionEffectSelf":
				pass
			"RemoveNegativeConditionsSelf":
				pass
			"CreatePortal":
				pass
			"Teleport":
				pass
			"StatBoostAura":
				pass
			"Decoy":
				pass
			"UnlockPetSkin":
				pass
			"BulletCreate":
				pass
			"HealNova":
				pass
			"LevelTwenty":
				pass
			"UnlockForgeBlueprint":
				pass
			"MagicNova":
				pass
			"Create":
				pass
			"StartAccelerator":
				pass
			"GroupTransform":
				pass
			"Create":
				pass
			"Trap":
				pass
			"StasisBlast":
				pass
			"VampireBlast":
				pass
			"BoostRange":
				pass
			"ExpandSeasonalPotion":
				pass
			"CreatePet":
				pass
			"IncreaseDustCap":
				pass
			"UnlockGravestone":
				pass
			"AddDust":
				pass
			"UnlockSkin":
				pass
			"unlockTitle":
				pass
			"Shader":
				pass
			"PermaPet":
				pass
			"Exchange":
				pass
			"GenerateActivate":
				pass
			"SpawnCreep":
				pass
			"ShowInfoPopup":
				pass
			"ChannelDash":
				pass
			"MysteryPortal":
				pass
			"UnlockTitle":
				pass
			"GrantSupporterPoints":
				pass
			"GenericActivate":
				pass
			"CreateObject":
				pass
			"BoostForgeEnergy":
				pass
			_:
				push_warning("Unknown on_use active " + active["active"])
	
	if item.sub_attacks.size() < 2 && item.projectiles.size() > 0:
		var fire_rate: float
		var num_projectiles: int
		if item.sub_attacks.size() == 1:
			var sub_attack : ItemInformation.SubAttack = item.sub_attacks[0]
			fire_rate = sub_attack.rate_of_fire
			num_projectiles = sub_attack.num_projectiles
		else:
			num_projectiles = item.num_projectiles
			fire_rate = item.rate_of_fire
		
		var proj := item.projectiles[0]
		assert(proj != null)
		
		rich_description.text += "\n[color=b3b3b3]Range:[/color] %s" % str(snappedf(proj.get_range(), 0.01))
		if num_projectiles != 1:
			rich_description.text += "\n[color=b3b3b3]Shots:[/color] %d" % num_projectiles
		
		rich_description.text += get_bullet_flags_string(proj)
		
		if fire_rate != 1.0:
			rich_description.text += "\n[color=b3b3b3]Rate of fire:[/color] %d%%" % int(fire_rate * 100)
	elif item.sub_attacks.size() > 1:
		rich_description.text += "\nShoots multiple bullets"
		var bullet_n := 1
		for sub_attack in item.sub_attacks:
			var proj: ItemInformation.Projectile
			for p in item.projectiles:
				if p.id == sub_attack.projectile_id:
					proj = p
					break
			assert(proj != null)
			
			rich_description.text += "\nBullet %d (%d-%d), [color=b3b3b3]Range[/color] %s, [color=b3b3b3]Rate of Fire:[/color] %d%%:" % [bullet_n, proj.min_damage, proj.max_damage, str(snappedf(proj.get_range(), 0.01)), int(100 * sub_attack.rate_of_fire)]
			rich_description.text += get_bullet_flags_string(proj)
			
			bullet_n += 1
	
	if item.on_equip.size() > 0:
		rich_description.text += "\n[color=b3b3b3]On Equip:[/color]"
		for active in item.on_equip:
			match active["active"]:
				"IncrementStat":
					rich_description.text += "\n"
					var amount: int = active["attribs"]["amount"].to_int()
					var stat: String = active["attribs"]["stat"]
					if amount > 0:
						rich_description.text += "[color=00ff00]+"
					else:
						rich_description.text += "[color=ff0000]"
					rich_description.text += str(amount) + " " + _stat_to_name(stat) + "[/color]"
				"AbilityUseDiscount":
					pass
				"IncrementStatRelative":
					pass
				_:
					push_warning("Unknown on_equip active " + active["active"])
	
	if item.mp_cost > 0:
		rich_description.text += "\n[color=b3b3b3]MP Cost:[/color] " + str(item.mp_cost)
	if item.xp_bonus > 0:
		rich_description.text += "\n[color=b3b3b3]XP Bonus:[/color] " + str(item.xp_bonus) + "%"
	
	if item.feedpower > 0:
		feedpower_label.text = "Feed Power: " + str(item.feedpower)
	else:
		feedpower_label.visible = false
		if tier == "":
			bottom_bar.visible = false
	
	
	#var parent: Popup = get_parent()
	#parent.transparent_bg = true
	#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, get_window().get_window_id())
	_shrink.call_deferred()

func _shrink():
	size = Vector2()
	#var parent: Popup = get_parent()
	#get_viewport().transparent_bg = true
	#parent.reset_size()

func get_bullet_flags_string(proj: ItemInformation.Projectile) -> String:
	var text := ""
	if proj.multi_hit:
		text += "\nShots hit multiple targets"
	if proj.passes_cover:
		text += "\nShots pass through obstacles"
	if proj.armor_piercing:
		text += "\nIgnores defense of targets"
	if proj.boomerang:
		text += "\nShots boomerang"
	
	if proj.condition_effects.size() > 0:
		text += "\n[color=b3b3b3]Shot Effect:[/color]"
		for effect in proj.condition_effects.keys():
			text += "\n%s [color=b3b3b3]for[/color] %s [color=b3b3b3]seconds[/color]" %  [ effect, str(snappedf(proj.condition_effects[effect], 0.01)) ]
	
	return text

func _set_item_tier(tier: String) -> void:
	tier_label.text = tier
	tier_label_big.text = tier
	
	var primary: Color
	var secondary: Color
	var hbar: Color
	
	nine_patch_rect.material.set_shader_parameter("no_corner", false)
	if tier.to_lower().begins_with("t"):
		_set_item_forge_amounts(0, 0, 0, 0)
		primary = Color.hex(0xffffffff)
		secondary = Color.hex(0xd4d4d4ff)
		hbar = Color.hex(0x626262ff)
	elif tier == "ST":
		primary = Color.hex(0xff8c00ff)
		secondary = Color.hex(0xd46109ff)
		hbar = Color.hex(0x965d16ff)
		if item.labels.has("POWERTIER_D"):
			_set_item_forge_amounts(0, 0, 0, 5)
		elif item.labels.has("POWERTIER_C"):
			_set_item_forge_amounts(0, 0, 0, 10)
		elif item.labels.has("POWERTIER_B"):
			_set_item_forge_amounts(0, 0, 0, 20)
		elif item.labels.has("POWERTIER_A"):
			_set_item_forge_amounts(0, 0, 0, 40)
		elif item.labels.has("POWERTIER_S") || item.labels.has("POWERTIER_SS"):
			_set_item_forge_amounts(0, 0, 0, 80)
		else:
			_set_item_forge_amounts(0, 0, 0, 0)
	elif tier == "UT":
		primary = Color.hex(0x8514faff)
		secondary = Color.hex(0xbf59ffff)
		hbar = Color.hex(0x592094ff)
		if item.labels.has("POWERTIER_D"):
			_set_item_forge_amounts(0, 0, 15, 0)
		elif item.labels.has("POWERTIER_C"):
			_set_item_forge_amounts(0, 5, 20, 0)
		elif item.labels.has("POWERTIER_B"):
			_set_item_forge_amounts(0, 15, 30, 0)
		elif item.labels.has("POWERTIER_A"):
			_set_item_forge_amounts(0, 30, 40, 0)
		elif item.labels.has("POWERTIER_S") || item.labels.has("POWERTIER_SS"):
			_set_item_forge_amounts(15, 40, 45, 0)
		else:
			_set_item_forge_amounts(0, 0, 0, 0)
	else:
		primary = Color.hex(0x8d8d8dff)
		hbar = Color.hex(0x1f1f1fff)
		nine_patch_rect.material.set_shader_parameter("no_corner", true)
		_set_item_forge_amounts(0, 0, 0, 0 )
		
	nine_patch_rect.material.set_shader_parameter("corner_color", secondary)
	nine_patch_rect.material.set_shader_parameter("border_color", primary)
	h_bar.color = hbar
	h_bar_2.color = hbar
	tier_label.label_settings.font_color = primary
	tier_label_big.label_settings.font_color = primary

func _set_item_forge_amounts(red: int, gold: int, silver: int, st: int) -> void:
	if red != 0:
		red_forge_amt.text = str(red)
	else:
		red_forge_amt.visible = false
		red_forge_icon.visible = false
	if gold != 0:
		gold_forge_amt.text = str(gold)
	else:
		gold_forge_amt.visible = false
		gold_forge_icon.visible = false
	if silver != 0:
		silver_forge_amt.text = str(silver)
	else:
		silver_forge_amt.visible = false
		silver_forge_icon.visible = false
	if st != 0:
		st_forge_amt.text = str(st)
	else:
		st_forge_amt.visible = false
		st_forge_icon.visible = false

func _stat_to_name(abbriv: String) -> String:
	match abbriv.to_upper():
		"ATT":
			return "Attack"
		"DEF":
			return "Defense"
		"SPD":
			return "Speed"
		"DEX":
			return "Dexterity"
		"VIT":
			return "Vitality"
		"WIS":
			return "Wisdom"
		"MAXHP":
			return "Max HP"
		"MAXMP":
			return "Max MP"
	return "Unknown stat abbriv " + abbriv
