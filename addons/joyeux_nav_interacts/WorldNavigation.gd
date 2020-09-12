extends Navigation
class_name WorldNavigator

var astar : AStar = AStar.new()


func get_astar_from_paths(parent : Node) -> void:
	var vertices : PoolVector3Array = PoolVector3Array()
	var astar_array : Array = []
	var use_array : bool = false
	if parent.get_child_count() > 1:
		use_array = true

	for node in get_children():
#		if node is Position3D: #We're not checking for positions yet
#			vertices.push_back(node.translation)
		if node is Path:
			for point in node.get_curve().get_baked_points():
				vertices.push_back(point)
		if use_array:
			astar_array.append(Array(vertices))
			vertices.empty()
	if use_array:
		for array in astar_array:
			calculate_astar(array)
	else:
		calculate_astar(Array(vertices))


func calculate_nav_mesh():
	var vertices
	var mesh = ArrayMesh.new()
	var arrays = []
	if vertices.size() >= 0:
		arrays.resize(vertices.size())
		arrays[ArrayMesh.ARRAY_VERTEX] = vertices
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_FAN, arrays)
		mesh.generate_triangle_mesh()
		var NavMesh = NavigationMesh.new()
		var MeshVis = MeshInstance.new()
		MeshVis.mesh = mesh
		NavMesh.create_from_mesh(mesh)
		NavMesh.set_vertices(vertices)
		var NavMeshInstance = NavigationMeshInstance.new()
		NavMeshInstance.navmesh = NavMesh
		add_child(NavMeshInstance)
		add_child(MeshVis)



func find_shortest_path(from: Vector3, to : Vector3):
	var absoulut = get_absolute_path(from, to)
	var navmesh = get_navmesh_path(from, to)
	if min(absoulut.size(), navmesh.size()) == absoulut.size():
		return absoulut
	else:
		if navmesh.size()>1:
			return navmesh 
		else:
			return absoulut


func get_navmesh_path(from: Vector3, to: Vector3):
	to = get_closest_point(to)
	from = get_closest_point(from)
	print(get_node("NavMesh_Test_First_Gallery"))
	var path_points = get_simple_path(from, to, true)
	return path_points


func get_astar_path(from: Vector3, to: Vector3):
	var path_points = astar.get_point_path(astar.get_closest_point(from), astar.get_closest_point(to))
	return path_points


func get_absolute_path(from:Vector3, to:Vector3):
	#First we calculate the Astar path
	var astar_path : Array = get_astar_path(from, to)
	var first_point = astar_path[0]
	#We get the first point of the path
	var last_point = (astar_path.invert()) #The astar path is backwards
	last_point = astar_path[0]
	#astar_path.invert()
	#We get the last point of the path
	
	if (from - first_point).length() > 0: 
		#If the first point is too far from the kinematic, calculates a Navmesh Path
		var Initial_path : Array = get_navmesh_path(from, first_point)
		Initial_path.invert()
		#Then we add the points to the front of the array 
		for points in Initial_path:
			astar_path.push_back(points)
	
	astar_path.invert() #The astarpath is forwards 
	
	if (to - last_point).length() > 0: 
		#If the path is away from the destination, make a Navmesh path to the destination 
		var Final_path : Array = get_navmesh_path(last_point, to)
		#Add the points at the end of the array
		for point in Final_path:
			astar_path.append(point)
			
	#Finally, we return the full path to the given position. 
	return astar_path

func calculate_astar(AstarPath : Array):
	for  x in AstarPath.size(): #Get all points in the Curve 3D
		var Point = AstarPath[x] #Get their positions
		astar.add_point(x, Point) #Add them to the A* calculation
		if x != 0:
			astar.connect_points(x,x-1) #If they are not out of index, connect them
	astar.connect_points(0,astar.get_points()[-1])
