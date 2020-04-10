extends Node
class_name Entity
# Entity class, serves as a medium between Components to communicate.

var components: Dictionary = {}

func add_component(_name: String, _comp: Node):
	components[_name] = _comp

func get_component(_name: String):
	return components[_name]
