extends Control

const UI_RESOURCE = preload("res://ui/InGameMenuUI.tscn")
var _ui_ref = WeakRef.new()

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and _ui_ref.get_ref() == null:
		var ui = UI_RESOURCE.instance()
		self.add_child(ui)
		_ui_ref = weakref(ui)
		UIManager.register_base_ui(self)
		UIManager.next_ui(ui)
