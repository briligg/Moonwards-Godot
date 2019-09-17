extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$Panel/LineEdit/OptionButton.connect("item_selected", self, "set_host")
	var list = $Panel/LineEdit/OptionButton
	$Panel/LineEdit.text = list.get_item_text(list.selected)
	$Label.text = "network id: %s" % get_tree().get_network_unique_id()
	pass

func set_host(id):
	$Panel/LineEdit.text = $Panel/LineEdit/OptionButton.get_item_text(id)
	print(id)

func _on_Button_pressed():
	print($Panel/LineEdit.text)
	$Panel/LineEdit/Label.text = IP.resolve_hostname($Panel/LineEdit.text)
	print($Panel/LineEdit/Label.text)
