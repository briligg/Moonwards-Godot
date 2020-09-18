extends Node

signal scene_changed

### Temporary, until proper scene management is implemented.
var world_scene: String = "res://_tests/NewDemo/TestScene.tscn"
#var world_scene: String = "res://Tree/World/Moon_Town_Main.tscn"
#var world_scene: String = "res://_tests/Display/BaseDisplayTest.tscn"
#var world_scene: String = "res://Tree/World/Moon_Town_Main.tscn"
#var world_scene: String = "res://_tests/RoverTest.tscn"
var main_menu: String = "res://Tree/Interface/MainMenu/MainMenu.tscn"
const PLAYER_SCENE: PackedScene = preload("res://Tree/Actor/Player/HumanPlayer.tscn")
#const PLAYER_SCENE: PackedScene = preload("res://Tree/Actor/Vehicle/AthleteRover/AthleteRover.tscn")
const LOADING_SCREEN: PackedScene = preload("res://Tree/Interface/Hud/LoadingScreen/LoadingScreen.tscn")

# Returns the instanced scene after it's added to the `SceneTree`
func change_scene_to_async(path: String) -> Node:
	_change_scene(LOADING_SCREEN.instance())
	var loader = ResourceThreadedLoader.new(path)
	loader.connect("finished_loading", self, "_on_scene_ready")
	loader.load_async()
	return self

func _on_scene_ready(scene: PackedScene) -> void:
	var inst = scene.instance()
	_change_scene(inst)
	emit_signal("scene_changed", inst)

func _change_scene(scene: Node):
	var old = get_tree().current_scene
	
	get_node("/root").add_child(scene)
	get_tree().current_scene = scene

	get_node("/root").remove_child(old)
	old.queue_free()
