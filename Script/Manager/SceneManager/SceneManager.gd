extends Node

### Temporary, until proper scene management is implemented.
var world_scene: String = "res://_tests/NewDemo/TestScene.tscn"
var main_menu: String = "res://Tree/Interface/MainMenu/MainMenu.tscn"
const PLAYER_SCENE: PackedScene = preload("res://Tree/Actor/Player/TestPlayer.tscn")

func change_scene_to_instance(path: String, _loading_screen: bool = false) -> Node:
	
	#### show loading screen...
	
	var instance = load(path).instance()
	var old = get_tree().current_scene

	get_node("/root").add_child(instance)
	get_tree().current_scene = instance

	get_node("/root").remove_child(old)
	old.queue_free()

	return instance
