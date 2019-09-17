extends Node
"""
	Log
"""

#verbose levels - -3:-1 errors, 0 - info, 1-3 - verbose info, 4-6 - debug
export(int, -1, 6) var _dd_verbosity: int = 4

const DD_FILTER: Dictionary = {
	"options.gd" : [
		{ vl = 9, enabled = true, key = "options set TreeManagerCache"},
		{ vl = 9, enabled = true, key = "get: TreeManagerCache"},
		{ vl = 0, enabled = true, key = "load options and settings"},
		{ vl = 1, enabled = true, key = "options loaded from"},
		{ vl = 4, enabled = true, key = "get"},
		{ vl = 4, enabled = true, key = "options set"},
		{ vl = 1, enabled = true, key = "options saved"},
		{ vl = 4, enabled = true, key = "options del_stat"},
		{ vl = 9, enabled = true, key = ""},
		{ vl = 9, enabled = true, key = ""},
		],
	"gamestate" : [
		{ vl = 4, enabled = true, key = "log_all_signals"},
		{ vl = 5, enabled = true, key = "net_tree_connect"},
		{ vl = 4, enabled = true, key = "=========="},
		{ vl = 4, enabled = true, key = "gamestate log"},
		{ vl = 4, enabled = true, key = "player_apply_opt"},
		{ vl = 4, enabled = true, key = "create_player"},
		{ vl = 4, enabled = true, key = "------instance avatars"},
		{ vl = 4, enabled = true, key = "------net_client"},
		{ vl = 4, enabled = true, key = "------net_down"},
		{ vl = 4, enabled = true, key = "------net_up"},
		{ vl = 6, enabled = true, key = "cp set_network"},
		{ vl = 9, enabled = true, key = ""},
		{ vl = 9, enabled = true, key = ""},
		],
	"debug.gd" : [
		{ vl = 4, enabled = true, key = "OS::"},
		{ vl = 0, enabled = true, key = "Apply options to new player scene"},
		{ vl = 0, enabled = true, key = "debug set FPS"},
		{ vl = 0, enabled = true, key = "Look for existing TreeManager"},
		{ vl = 0, enabled = true, key = "found TreeManager"},
		{ vl = 4, enabled = true, key = "end search for LodManager"},
		{ vl = -1, enabled = true, key = "set_lod_manager, attempt to disable"},
		{ vl = 0, enabled = true, key = "Load TreeManager"},
		{ vl = 6, enabled = true, key = "added node"},
		{ vl = 6, enabled = true, key = "node removed"},
		{ vl = -1, enabled = true, key = "e_collision_shape"},
		{ vl = 2, enabled = true, key = "set cursor to visible"},
		{ vl = 9, enabled = true, key = ""},
		{ vl = 9, enabled = true, key = ""},
		],
	"LodManager" : [
		{ vl = 5, enabled = true, key = "lod_enable"},
		{ vl = 5, enabled = true, key = "Disable LodManager"},
		{ vl = 5, enabled = true, key = "Enable LodManager"},
		{ vl = 5, enabled = true, key = "reset"},
		{ vl = 4, enabled = true, key = "_ready, enabled"},
		{ vl = -1, enabled = true, key = "init_scene, no camera found"},
		{ vl = 0, enabled = true, key = "init_scene"},
		{ vl = 4, enabled = true, key = "force UpdateLOD"},
		{ vl = 4, enabled = true, key = "LM"},
		{ vl = 9, enabled = true, key = ""},
		],
	"TreeManager" : [
		{ vl = 4, enabled = true, key = "_ready, enabled"},
		{ vl = 1, enabled = true, key = "TreeManager update lod_aspect_ratio"},
		{ vl = 4, enabled = true, key = "Tree manager tm_enable"},
		{ vl = 1, enabled = true, key = "Init Tree manager"},
		{ vl = 5, enabled = true, key = "tree set to"},
		{ vl = 9, enabled = true, key = "=tree"},
		{ vl = 1, enabled = true, key = "Init meshtool and treestats scripts"},
		{ vl = 2, enabled = true, key = "TM TreeManagment enable"},
		{ vl = 3, enabled = true, key = "TM start hboxsetlod"},
		{ vl = 3, enabled = true, key = "hboxsetlod get cache"},
		{ vl = -2, enabled = true, key = "lodelement, lod_element_group(LODElement) not found in tree"},
		{ vl = 3, enabled = true, key = "hboxsetlod save cache"},
		{ vl = 1, enabled = true, key = "found LodManager"},
		{ vl = 5, enabled = true, key = "TM track_changes"},
		{ vl = 5, enabled = true, key = "track_node_added, ignore, part of control"},
		{ vl = 9, enabled = true, key = ""},
		{ vl = 9, enabled = true, key = ""},
		{ vl = 9, enabled = false, key = "whom ../" },
		{ vl = 9, enabled = false, key = "loe /" },
		{ vl = 9, enabled = false, key = "[MeshInstance:" },
		{ vl = 9, enabled = false, key = "fix child lod " },
		],
	"MeshTool" : [
		{ vl = 5, enabled = true, key = "init"},
		{ vl = 5, enabled = true, key = "set_mesh"},
		{ vl = 4, enabled = true, key = "id_mesh, mesh is null"},
# 		{ vl = 9, enabled = true, key = "id_mesh"},
		{ vl = 9, enabled = true, key = "id_mesh nofile"}, ##TODO investigate
		{ vl = -1, enabled = true, key = "id_mesh, mesh is null in"},
		{ vl = -1, enabled = true, key = "get_hitbox mesh is null"},
		{ vl = 9, enabled = true, key = ""},
		],
	"LODElement" : [
		{ vl = 6, enabled = true, key = "hide"},
		{ vl = 6, enabled = true, key = "show"},
		{ vl = 5, enabled = true, key = "LOD substitute"},
		],
	"AreaLod" : [
		{ vl = 5, enabled = true, key = "AreaLod disabled at"},
		{ vl = 6, enabled = true, key = "body_enter"},
		{ vl = 6, enabled = true, key = "body_exit"},
		{ vl = 6, enabled = true, key = "Area exit"},
		{ vl = 6, enabled = true, key = "Area enter"},
		],
	"CameraControl" : [
		{ vl = 5, enabled = true, key = "camera"}
		],
	"utils.gd" : [
		{ vl = -1, enabled = true, key = "attempt to get mtime of non existing file"},
		],
	"Player2.gd" : [
		{ vl = 4, enabled = true, key = "remove avatar"},
		{ vl = 4, enabled = true, key = "add avatar"},
		{ vl = -2, enabled = true, key = "UpdateNetworking: not a remote player"},
		],
	"UpdaterServer": [
		{ vl = 9, enabled = true, key = "skip"},
		{ vl = 9, enabled = true, key = "res://"},
		{ vl = 8, enabled = true, key = "GetMD5FromDirectory"},
		{ vl = 1, enabled = true, key = "Create server"},
		{ vl = 0, enabled = true, key = "Getting MD5 List"},
		{ vl = 2, enabled = true, key = "GetMD5List total"},
		{ vl = 2, enabled = true, key = "get md5id, dict"},
		{ vl = 0, enabled = true, key = "Done"},
		{ vl = 0, enabled = true, key = ""}
		],
	"UpdaterClient": [
		{ vl = 9, enabled = true, key = "skip"},
		{ vl = 9, enabled = true, key = "res://"},
		{ vl = 8, enabled = true, key = "GetMD5FromDirectory"},
		{ vl = 5, enabled = true, key = "Found File"},
		{ vl = 3, enabled = true, key = "Loading File"},
		{ vl = 3, enabled = true, key = "Update files FILTER list"},
		{ vl = 0, enabled = true, key = "Get tree checksum"},
		{ vl = 4, enabled = true, key = "ClientReceiveUpdate"},
		{ vl = 4, enabled = true, key = "chain_"},
		{ vl = 5, enabled = true, key = "GetState:"},
		{ vl = 0, enabled = true, key = ""}
		],
	"Updater": [
		{ vl = 0, enabled = true, key = ""}
		],
	"Main Menu": [
		{ vl = 4, enabled = true, key = "end gathering"},
		{ vl = 0, enabled = true, key = ""}
		],
	"UpdaterUI": [
		{ vl = 4, enabled = true, key = "disconnect"},
		{ vl = 4, enabled = true, key = "connect"},
		{ vl = 0, enabled = true, key = ""},
		]
	}


	# TODO: Type and rename these vars
func test_fd(id, s) -> int:
	var found: int = 1
	
	if DD_FILTER.has(id):
		
		var FILTER = DD_FILTER[id]
		
		if FILTER.size() > 0:
			found = 2
			
			for dl in FILTER:
				
				if s.begins_with(dl.key):
					
					if dl.enabled and dl.vl <= _dd_verbosity:
						found = 3
					else:
						found = -1
					
					break
	
	return found


	# TODO: Type and rename these vars
func print_fd(id, s):
	var pp = test_fd(id, s)
	
	match pp:
		1:
		
			print("*=*", id, "***", s)
		2:
		
			print(id, "***", s)
		
		3:
			print("%-12s:: " % id, s)
		
#		-1:
# 			pass #found but no need to print for enabled/verbosity level reasons


	# TODO: Is this code dead? If so, remove it.
# func print_fd(id, s):
# 	if not debug:
# 		return
# 	if DD_FILTER.has(id):
# 		var FILTER = DD_FILTER[id]
# 		if FILTER.size() > 0:
# 			var found = false
# 			for dl in FILTER:
# 				if s.begins_with(dl.key):
# 					if dl.enabled and dl.vl <= _dd_verbosity:
# 						print("%-12s:: " % id, s)
# 					found = true
# 					break
# 			if not found:
# 				print(id, "***", s)
# 	else:
# 		print("*=*", id, "***", s)
