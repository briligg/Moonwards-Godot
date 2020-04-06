extends Node
"""
	UserOptions Singleton Script
	Provides an easy to use interface for local UserOptions management.
	Use get_option(category, name) to retrieve a setting
	Use set_option(category, name) to store a setting
	option_changed will be emitted when set_option is called
	This lets other parts of the Application react to changes in a global fashion
	Say if you have two instances of an Options Menu, sharing properties
	By subscribing to the option_changed signal you can keep both in sync
	
	Default options can be loaded from UserOptions.ini
"""
signal option_changed(category, option, value)

export(String, FILE, "*.ini") var DEFAULT_OPTIONS_PATH: String = ".Addons/UserOptions/UserOptions.ini" #Next to this file.
export(String, FILE, "*.ini") var USER_OPTIONS_PATH: String = "user://UserOptions.ini"

var _cfg: ConfigFile = ConfigFile.new()


func _init() -> void:
	load_defaults()
	load_useroptions()


func load_defaults() -> void:
	var err: int = _cfg.load(DEFAULT_OPTIONS_PATH)
	if not err == OK:
		print("_UserOptions: load_defaults() could not load defaults. Error Code: %s Path: %s" % [err, DEFAULT_OPTIONS_PATH])


func load_useroptions() -> void:
	var f: File = File.new()
	if not f.file_exists(USER_OPTIONS_PATH):
		print("_UserOptions: load_useroptions() could not find user options file at path %s" % USER_OPTIONS_PATH)
		return
	
	var err: int = _cfg.load(USER_OPTIONS_PATH)
	if not err == OK:
		print("_UserOptions: load_defaults() could not load user options. Error Code: %s Path: %s" % [err, USER_OPTIONS_PATH])


func set_option(category: String, option: String, value) -> void:
	
	if not _cfg.has_section(category):
		print("_UserOptions: set_option() could not find category. Creating category: %s." % category)
	
	if not _cfg.has_section_key(category, option):
		print("_UserOptions: set_option() could not find option. Creating option: %s %s." % [option, value])
	
	_cfg.set_value(category, option, value)
	_cfg.save(USER_OPTIONS_PATH)
	
	emit_signal("option_changed", category, option, value)


func get_option(category: String, option: String, fallback_value = null): # -> variant
	
	if not _cfg.has_section(category):
		print("_UserOptions: get_option() could not find option. Returning fallback: %s" % fallback_value)
		return fallback_value
	
	if not _cfg.has_section_key(category, option):
		print("_UserOptions: get_option() could not find option. Returning fallback." % fallback_value)
		return fallback_value
	
	return _cfg.get_value(category, option)
