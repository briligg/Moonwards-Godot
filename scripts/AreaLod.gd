extends Area
var id = "AreaLod"

export(NodePath) var RootNode
export(bool) var enabled = false
export(String) var showhide = "interior"
export(String) var hideshow = "exterior"
export(String) var bygroup = "player"

var root
var nodes_sh
var nodes_hs
var id_path

func printd(s):
	logg.print_filtered_message(id, s)

func array_add(a, b):
	for i in b:
		a.append(i)
	return a

func obj_has_groups(obj, groups):
	var has = false
	for grp in groups:
		if obj.get_groups().has(grp):
			has = true
			break
	return has

func get_node_list(root, groups):
	var match_obj = []
	var objects = []
	if obj_has_groups(root, groups):
		objects.append(root)
	else:
		objects = root.get_children()
	while objects.size():
		var obj = objects.pop_front()
		if obj.get_child_count():
			array_add(objects, obj.get_children())
		if obj_has_groups(obj, groups):
			match_obj.append(obj)
	return match_obj

func _ready():
	if not enabled:
		printd("AreaLod disabled at %s %s" % [get_path(), utils.get_node_root(self)])
		return
	init_all()

func init_all():
	if not RootNode :
		root = self.get_parent()
	else:
		root = self.get_node(RootNode)
	nodes_sh = get_node_list(root, [showhide])
	nodes_hs = get_node_list(root, [hideshow])
# 	connect("area_entered", self, "_on_Area_area_entered")
# 	connect("area_exited", self, "_on_Area_area_exited")
	connect("body_exited", self, "_on_body_exit")
	connect("body_entered", self, "_on_body_enter")
	id_path = get_path()
	printd("Area ready: %s" % id_path)
	area_exit("on ready")
	
func _on_body_enter(body):
	printd("body_enter %s" % body)

func _on_body_exit(body):
	printd("body_exit %s" % body)

func _on_Area_area_entered(area):
	if not bygroup in area.get_groups():
		return
	printd("Area enter: %s" % id_path)
	for obj in nodes_sh:
		obj.visible = true
	for obj in nodes_hs:
		obj.visible = false

func area_exit(s=""):
	if s != "on ready":
		printd("Area exit: %s" % id_path)
	for obj in nodes_sh:
		obj.visible = false
	for obj in nodes_hs:
		obj.visible = true

func _on_Area_area_exited(area):
	if not bygroup in area.get_groups():
		return
	area_exit()
