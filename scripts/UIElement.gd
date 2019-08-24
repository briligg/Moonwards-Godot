extends Node

export(UIManager.UI_EVENTS) var _ui_event
export(PackedScene) var _resource: PackedScene = null
export(String) var _resource_string: String = ""

func _ready() -> void:
	var node = self
	if node is Button:
		self.connect("pressed", self, "button_pressed")
	elif node is CheckBox:
		self.connect("toggled", self, "check_box_toggled")

func button_pressed() -> void:
	ui_event()

func check_box_toggled(var value) -> void:
	ui_event()

func drop_down_choice(var value) -> void:
	ui_event()

func ui_event() -> void:
	if _resource != null:
		UIManager.ui_event(_ui_event, _resource)
	else:
		UIManager.ui_event(_ui_event, _resource_string)
