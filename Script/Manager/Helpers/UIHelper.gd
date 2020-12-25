extends Reference
class_name UIHelper

var parent: Node
var pop_notice_path = "res://SceneComponent/Interface/Notifications/PopupNotice.tscn"

func _init(_parent) -> void:
	parent = _parent

func show_notice(message: String = "") -> void:
	var notice = load(pop_notice_path).instance()
	notice.set_text(message)
	parent.call_deferred("add_child", notice)
