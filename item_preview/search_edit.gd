extends LineEdit

@onready var grid_container: HFlowContainer = $"../../SmoothScrollContainer/MarginContainer/GridContainer"

func _on_text_changed(new_text: String) -> void:
	for item in grid_container.get_children():
		item.visible = new_text == "" || item.tooltip_text.to_lower().contains(new_text.to_lower())
