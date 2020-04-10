tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("HSVPickerButton", "Button", preload("HSVPickerButton.gd"), preload("icon_button_smol.png"))

func _exit_tree() -> void:
	remove_custom_type("HuePicker")
