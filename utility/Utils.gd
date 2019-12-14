class_name Utilities


static func array_add(a : Array, b : Array) -> Array:
	for i in b:
		a.append(i)
	return a

static func obj_has_groups(obj : Object, groups : Array):
	var has = false
	for grp in groups:
		if obj.get_groups().has(grp):
			has = true
			break
	return has

static func obj_has_property(obj : Object, pstr : String):
	var has = false
	if obj == null:
		return has
	
	var plist = obj.get_property_list()
	var pnames = []
	for pl in plist:
		pnames.append(pl.name)
	
	has = pnames.has(pstr)
	return has

static func get_nodes(root : Node , recurent : bool = false):
	var nodes = []
	var objects = root.get_children()
	while objects.size():
		var obj = objects.pop_front()
		if obj.filename:
			if recurent:
				array_add(objects, obj.get_children())
		else:
			array_add(objects, obj.get_children())
		nodes.append(root.get_path_to(obj))
	return nodes

static func get_nodes_type(root : Node, type : String, recurent : bool = false):
	var nodes = get_nodes(root, recurent)
	var result = []
	for path in nodes:
		if root.get_node(path).get_class() == type :
			result.append(path)
	return result

static func get_cs_list(root : Node):
	var cs_options = {
	cs_skip_branch = ["cs_none" ],
	cs_skip = [ "cs_manual" ],
	cs_groups = [ "cs", "cs_convex", "floor", "wall"],
	cs_convex = ["cs_convex"],
	cs_trimesh = ["cs", "floor", "wall"],
	bakedlight = {path = "lightmaps", ext = "_bldata.res" },
	material_dir = "res://materials",
	mesh_dir = "meshes",
	cs_dir = "cshapes",
	
	hide_protect = ["floor", "wall"]
}

	var meshes = {
			convex = [],
			trimesh = []
		}
	var objects = root.get_children()
	while objects.size():
		var obj = objects.pop_front()
		if obj_has_groups(obj, cs_options.cs_skip_branch):
			continue
		if obj.get_child_count():
			array_add(objects, obj.get_children())
		if obj_has_groups(obj, cs_options.cs_skip):
			continue
		if obj_has_groups(obj, cs_options.cs_convex):
			meshes.convex.append(root.get_path_to(obj))
		elif obj_has_groups(obj, cs_options.cs_trimesh):
			meshes.trimesh.append(root.get_path_to(obj))
	return meshes

static func get_cs_list_cs(root : Node):
	# get collision nodes of meshes marked by us for collision, exclude areas and all that stuff
	# important for saving of those meshes
	
	var meshes = get_cs_list(root)
	var paths = []
	array_add(paths, meshes.convex)
	array_add(paths, meshes.trimesh)
	var nodes = []
	for path in paths:
		var obj = root.get_node(path)
		var css = get_nodes_type(obj, 'CollisionShape')
		for cspath in css:
			var o = obj.get_node(cspath)
			nodes.append(root.get_path_to(o))
	return nodes


static func file_mtime(fname):
	var cache_flist = {}
	# by default handle path's like that 
	# res://_tests/scene_mp/multiplayer_test_scene.tscn::7
	var path = fname.rsplit("::")[0]
	if not cache_flist.has(path):
		var ff = File.new()
		if ff.file_exists(path):
			cache_flist[path] = { mtime = ff.get_modified_time(path) }
		else:
			#printd("attempt to get mtime of non existing file '%s'" % path)
			cache_flist[path] = { mtime = "nofile" }
	return cache_flist[path].mtime
	
static func get_node_file(node):
	node = NodeUtilities.get_node_root(node)
	var filename
	if node:
		filename = node.filename
	return filename

static func get_name() -> String:
	var list : Array = [
	"Kenny Cristobal",
	"Van Escovedo",
	"Gaylord Faler",
	"Keith Tannehill",
	"Carlo Most",
	"Greg Reno",
	"Tuan Scalia",
	"Eduardo Vasko",
	"Todd Eckel",
	"Rocky Bevilacqua",
	"Marty Webre",
	"Tommie Desantis",
	"Hong Lundquist",
	"Joan Prowell",
	"Brian Morman",
	"Wally Buskey",
	"Agustin Shires",
	"Desmond Mouser",
	"Trenton Harpole",
	"Barney Narron",
	"Gary Mossman",
	"Boyd Dragon",
	"Benjamin Brunner",
	"Hung Deckard",
	"Jack Crutcher",
	"Son Icenhour",
	"Columbus Mcgirt",
	"Scot Burley",
	"Damian Sanabria",
	"Hilario Molyneux",
	"Reinaldo Hursh",
	"Genaro Debnam",
	"Ryan Winfree",
	"Hershel Panos",
	"Lyman Gadberry",
	"Erick Emmanuel",
	"Thomas Sayegh",
	"Faustino Truss",
	"Tristan Campanella",
	"Cletus Mastrangelo",
	"Theodore Dunford",
	"Toney Shafer",
	"Rudolf Costas",
	"Seth Rideout",
	"Mikel Oman",
	"Evan Escoto",
	"Jake Farber",
	"Josef Owusu",
	"Bobbie Pappan",
	"Harry Kravetz",
	"Reba Nord",
	"Glenna Philippe",
	"Glennis Mahmood",
	"Charlotte Sliger",
	"Daine Barrette",
	"Jeanne Cupps",
	"Carmel Nair",
	"Thao Bartow",
	"Nora Godina",
	"Tiffiny Charleston",
	"Kati Crupi",
	"Alison Lockhart",
	"Vinnie Privett",
	"Jerica Fennessey",
	"Jeanene Weakley",
	"Dorotha Borgmeyer",
	"Treena Thomason",
	"Michelle Swain",
	"Mahalia Brocato",
	"Debroah Kazmierczak",
	"Verlene Gant",
	"Luann Steinhauer",
	"Dung Veselka",
	"Nisha Strawser",
	"Nicki Casado",
	"Dianna Holden",
	"Jennefer Delozier",
	"Adrianna Pellegren",
	"Carley Stander",
	"Velma Clardy",
	"Kelsi Heitkamp",
	"Krysta Mauney",
	"Erinn Holdman",
	"Nannie Reese",
	"Deetta Burghardt",
	"Kathey Stutzman",
	"Arianna Vogelsang",
	"Katherine Kriner",
	"Sarah Mcmurry",
	"Susanna Furby",
	"Bonnie Diblasi",
	"Holley Carrara",
	"Sade Paul",
	"Dani Cobian",
	"Bridgette Ziemer",
	"Elayne Baldon",
	"Hilda Carboni",
	"Crysta Emmer",
	"Sirena Galicia",
	"Kizzy Ungar"
]
	randomize()
	var index = randi() % list.size()
	return list[index]
	
static func get_safe_bool(obj, propetry):
	if obj_has_property(obj, propetry):
		return obj.get(propetry)
	else:
		return false

#########################
