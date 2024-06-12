extends TextureRect

var item: ItemInformation
var tooltip : Control

const ITEM_TOOLTIP = preload("res://item_preview/item_tooltip.tscn")

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	tooltip = ITEM_TOOLTIP.instantiate()
	tooltip.item = item
	add_child(tooltip)
	remove_child.call_deferred(tooltip)
	
func _on_mouse_exited():
	if tooltip != null:
		tooltip.queue_free()
		tooltip = null

func _make_custom_tooltip(_for_text: String) -> Object:
	return tooltip
