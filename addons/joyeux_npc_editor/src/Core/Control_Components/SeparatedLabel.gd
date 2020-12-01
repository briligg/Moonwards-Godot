tool
extends HBoxContainer
class_name DoubleLabel

func get_class_dropdown(classname : String) -> Control:
	if not Nodes.custom_types.has(classname):
		return null
	var Menu = DropDown.new()
	var dropdown = Menu.get_popup()
	for variant in Nodes.custom_types.get(classname):
		if Nodes.custom_types.get(classname).get(variant) is String or Nodes.custom_types.get(classname).get(variant) is int:
			dropdown.add_item(variant)
			Menu.set_meta(variant, Nodes.custom_types.get(classname).get(variant))
	return Menu

func get_class_enum_dropdown(variable_classname : String) -> Control:
	var variable_name = variable_classname.split("_", false)[0]
	var classname = variable_classname.split("_", false)[1]
	if not Nodes.custom_types.has(classname):
		return null
	if not Nodes.custom_types.get(classname).has(variable_name):
		return null
	var Menu = EnumDropDown.new()
	var dropdown = Menu.get_popup()
	for enumcomp in Nodes.custom_types.get(classname).get(variable_name):
		dropdown.add_item(enumcomp)
	return Menu

func filter_input_label(input : String) -> void:
	var Label1 : Control
	var processed : String
	if input.begins_with("_s_prop_dropdown_"):
		processed = input.trim_prefix("_s_prop_dropdown_")
		input = input.trim_suffix(processed)
	elif input.begins_with("_s_enum_dropdown"):
		processed = input.trim_prefix("_s_enum_dropdown_")
		input = input.trim_suffix(processed)
	elif input.begins_with("_s_file:"):
		processed = input.trim_prefix("_s_file:")
		input = input.trim_suffix(processed)
	match input:
		"_s_file:":
			Label1 = FileLabel.new(processed)
		"_s_text_edit":
			Label1 = LineEdit.new() 
		"_s_enum_dropdown_":
			Label1 = get_class_enum_dropdown(processed)
		"_s_prop_dropdown_":
			Label1 = get_class_dropdown(processed)
		"_s_int":
			Label1 = SpinBox.new()
			Label1.allow_greater = true
			Label1.allow_lesser = true
		"_s_float":
			Label1 = SpinBox.new()
			Label1.allow_greater = true
			Label1.allow_lesser = true
			Label1.step = 0
		"_s_percent":
			Label1 = SpinBox.new()
		_:
			Label1 = Label.new()
			Label1.text = input
	if Label1 == null:
		return
	Label1.rect_min_size = Vector2(50,20)
	Label1.name = "L_Label"
	add_child(Label1, true)

func _init(left_title : String = "", right_title : String = ""):
	filter_input_label(left_title)
	var Label2 = Label.new()
	Label2.name = "R_Label"
	Label2.text = right_title
	add_child(Label2)

func _ready():
	get_node("R_Label").size_flags_horizontal = SIZE_EXPAND_FILL
	get_node("L_Label").align= Label.ALIGN_LEFT
	get_node("L_Label").size_flags_horizontal = SIZE_EXPAND_FILL

func add_owners(ownr : Node):
	set_owner(ownr)
	for child in get_children():
		child.set_owner(ownr)
		if child.get_child_count()>0:
			for sub_child in child.get_children():
				sub_child.set_owner(ownr)
