class_name ItemInformation extends Resource

var CollectionIcon := {
	1: "ST1",
	2: "ST2",
	3: "ST3",
	11: "Fungal Cavern",
	12: "Crystal Cavern",
	13: "Nest",
	14: "The Shatters",
	15: "Lost Halls",
	16: "Cultist Hideout",
	17: "The Void",
	18: "Oryx Sanctuary",
	19: "Kogbolds Steamworks",
	94: "Moonlight Village",
}

var BagType := {
	1: "Brown",
	2: "Pink",
	4: "Purple",
	5: "ST",
	6: "White",
	7: "Gold",
	8: "ST",
	9: "Red",
}

const TITLE_ICON = preload("res://item_preview/TitleIcon.png")

func get_collection_icon() -> AtlasTexture:
	if collection_icon == 0:
		return null
	
	const COLLECTION_ICON_SIZE : int = 16
	var atlas_width := TITLE_ICON.get_width()
	var atlas = AtlasTexture.new()
	atlas.atlas = TITLE_ICON
	atlas.region.position = Vector2((collection_icon - 1) * COLLECTION_ICON_SIZE % atlas_width, (collection_icon - 1) * COLLECTION_ICON_SIZE / atlas_width * COLLECTION_ICON_SIZE)
	atlas.region.size = Vector2(COLLECTION_ICON_SIZE, COLLECTION_ICON_SIZE)
	
	return atlas

var id: String
var collection_icon: int
var name: String
var tier: int = -1
var soulbound: bool = false
var description: String
# [ {"name": ..., "description" : ...} ]
var extra_tooltip_data: Array[Dictionary]
# [ {"active": ..., "attribs": {...}} ]
var on_equip: Array[Dictionary]
# [ {"active": ..., "attribs": {...}} ]
var on_use: Array[Dictionary]
var num_projectiles: int = 1
var mp_cost: int
var feedpower: int
var labels: PackedStringArray
var texture: Texture2D
var xp_bonus: int
var sub_attacks: Array[SubAttack]
var projectiles: Array[Projectile]
var slot_type: int
var rate_of_fire: float

func get_applicable_classes() -> String:
	match slot_type:
		1:
			return "Warrior, Knight, Paladin"
		2:
			return "Rogue, Assassin Trickster"
		3:
			return "Archer, Huntress, Bard"
		4:
			return "Priest"
		5:
			return "Knight"
		6:
			return "Rogue, Archer, Assassin, Huntress, Trickster, Ninja"
		7:
			return "Warrior, Knight, Paladin, Samurai, Kensei"
		8:
			return "Priest, Sorcerer, Summoner"
		9:
			return ""
		10:
			return ""
		11:
			return "Wizard"
		12:
			return "Paladin"
		13:
			return "Rogue"
		14:
			return "Wizard, Priest, Necromancer, Mystic, Sorcerer, Bard, Summoner"
		15:
			return "Archer"
		16:
			return "Warrior"
		17:
			return "Wizard, Necromancer, Mystic"
		18:
			return "Assassin"
		19:
			return "Necromancer"
		20:
			return "Huntress"
		21:
			return "Mystic"
		22:
			return "Trickster"
		23:
			return "Sorcerer"
		24:
			return "Ninja, Samurai, Kensei"
		25:
			return "Ninja"
		27:
			return "Samurai"
		28:
			return "Bard"
		29:
			return "Summoner"
		30:
			return "Kensei"
	return ""

func get_display_name() -> String:
	return name if name != "" else id

class SubAttack:
	var num_projectiles: int
	var rate_of_fire: float
	var projectile_id: int

class Projectile:
	var id: int
	var min_damage: int
	var max_damage: int
	var lifetime_ms: int
	var speed: int
	var multi_hit: bool
	var passes_cover: bool
	var armor_piercing: bool
	var boomerang: bool
	# "effect": duration
	var condition_effects: Dictionary
	
	func get_range() -> float:
		if speed == 0:
			return 0.0
		var range := lifetime_ms * speed / 10000.0
		if boomerang:
			range /= 2.0
		return range
	
