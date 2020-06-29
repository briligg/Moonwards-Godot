extends Control

# A variable to hold the Editor_Controller node.
var editor_controller;

func _ready():
	# Get the Editor_Contoller node and assign it to editor_controller.
	# 
	# NOTE: using get_parent assumes that the parent of this node is Editor_Controller.
	# Depending on your project, this may or may not be a safe assumption.
	editor_controller = get_parent();
	
	# Connect the "pressed" signals from the four gizmo buttons to the on_mode_button_pressed function. We pass in a additional
	# argument along with the signal, which is the name of the mode we want to change to.
	get_node("Gizmo_Selection/HBoxContainer/Button_Select").connect("pressed", self, "on_mode_button_pressed", ["SELECT"]);
	get_node("Gizmo_Selection/HBoxContainer/Button_Translate").connect("pressed", self, "on_mode_button_pressed", ["TRANSLATE"]);
	get_node("Gizmo_Selection/HBoxContainer/Button_Rotate").connect("pressed", self, "on_mode_button_pressed", ["ROTATE"]);
	get_node("Gizmo_Selection/HBoxContainer/Button_Scale").connect("pressed", self, "on_mode_button_pressed", ["SCALE"]);

func on_mode_button_pressed(new_mode):
	# Tell editor_controller to change the mode.
	editor_controller.change_editor_mode(new_mode);
