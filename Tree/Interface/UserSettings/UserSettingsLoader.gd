extends VBoxContainer


const FILE_NAME : String = "avatar_settings.ini"

#The in game usersettings.
onready var _menu : HBoxContainer = $UserSettings_Sub

var _save_file : ConfigFile = ConfigFile.new()


#Load the player's previous avatar settings.
func _ready() -> void :
	#Don't do anything if the file does not exist.
	var dir : Directory = Directory.new()
	if not dir.file_exists(Helpers.SAVE_FOLDER+FILE_NAME) :
		return
	
	#Load the config file.
	_save_file.load(Helpers.SAVE_FOLDER+FILE_NAME)
	
	#Gender has to be called first or else you will be setting the colors of the wrong model
	var gender : int = _save_file.get_value("GENDER", "gender")
	_menu.call_deferred("set_gender", gender)
	
	var colors : Array = _save_file.get_value("COLORS", "colors")
	_menu.call_deferred("set_colors", colors)
	
	#Emit signals to let the Network know we loaded things.
	Log.trace(self, "_ready", "Avatar Settings successfully loaded")
	
#	Signals.Network.emit_signal(Signals.Network.CLIENT_NAME_CHANGED, username)
	
	#Let Networking know we changed genders.
	Signals.Network.emit_signal(Signals.Network.CLIENT_GENDER_CHANGED, gender)
	
	#Emit the shirt color signals.
	Signals.Network.emit_signal(Signals.Network.CLIENT_COLOR_CHANGED, colors)
	

#Saves the selected options.
func save() -> void :
	_save_file.set_value("COLORS", "colors", _menu.get_colors())
	_save_file.set_value("GENDER", "gender", _menu.gender)
	_save_file.save(Helpers.SAVE_FOLDER+FILE_NAME)
