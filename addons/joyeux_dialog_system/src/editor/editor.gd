tool
extends PanelContainer

onready var CharNameEdit = $VBC/PanelContainer/HBC/HBC/CharName
onready var Graph = $VBC/Graph
onready var FileMenu = $VBC/PanelContainer/HBC/File
onready var Dialog = $VBC/Graph/Dialogs/FileDialog
onready var Warn = $VBC/Graph/Dialogs/AcceptDialog

func _ready():
	FileMenu.get_popup().connect("id_pressed", self, "_on_File_id_pressed")

func _on_File_id_pressed(id : int):
	match id:
		0:
			Dialog.set_open()
			Dialog.popup_centered()
		1:
			if CharNameEdit.text == "":
				warn("Please name your character first")
				return
			Dialog.set_save()
			Dialog.popup_centered()

func _on_FileDialog_file_selected(path):
	match Dialog.mode:
		FileDialog.MODE_SAVE_FILE:
			Graph.save_dialogs(path, CharNameEdit.text)
		FileDialog.MODE_OPEN_FILE:
			Graph.load_dialogs(path)
			

func warn(what : String):
	Warn.dialog_text = what
	Warn.popup_centered()


func _on_AcceptDialog_confirmed():
	CharNameEdit.grab_focus()
