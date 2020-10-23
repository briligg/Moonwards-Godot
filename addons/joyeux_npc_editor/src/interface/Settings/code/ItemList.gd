tool
extends VBoxContainer

onready var popup = $Add/FileDialog

func _ready():
	if Nodes.behavior_paths.size() > 2:
		for idx in range(2, Nodes.behavior_paths.size()):
			if not has_node(Nodes.filter_node_name(Nodes.behavior_paths[idx])):
				add_item(Nodes.behavior_paths[idx])


func add_item(path : String) -> void:
	if has_node(Nodes.filter_node_name(path)):
		return
	var cont : HBoxContainer = HBoxContainer.new()
	var title : Label = Label.new()
	var button : Button = Button.new()
	var content : LineEdit = LineEdit.new()
	content.editable = false
	content.text = path
	button.text = "-"
	title.text = "Path: "
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cont.set_meta("name", path)
	cont.name = Nodes.filter_node_name(path)
	button.connect("pressed", self, "delete_item", [cont])
	cont.add_child(title)
	cont.add_child(content)
	cont.add_child(button)
	add_child(cont)
	move_child( get_node("Add"), get_child_count())
	if Nodes.behavior_paths.has(path):
		return
	Nodes.behavior_paths.append(path)

func call_add_item():
	popup.popup_centered()

func delete_item(node):
	Nodes.behavior_paths.erase(node.get_meta("name"))
	node.queue_free()
