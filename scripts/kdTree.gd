extends Object
# port of https://github.com/ubilabs/kd-tree-javascript


var dimensions ##array of axis
var root
var metric

func metric_vector(a,b):
# 	print("metric: ", a, " ", b)
	var dist2
	if a.has("location") and b.has("location"):
		dist2 = a.location.distance_squared_to(b.location)
	else:
		dist2 = 0
		for i in range(dimensions.size()):
			dist2 += pow(a[dimensions[i]] - b[dimensions[i]], 2)
	return dist2

func vec3point(v, data = null):
	return {x = v.x, y = v.y, z = v.z, location = v, data = data}

func Node(obj, dimension, parent):
	var node = {
		obj = obj,
		left = null,
		right = null,
		parent = null,
		dimension = dimension
	}
	return node

var dim
func sortPoints(a, b):
	if a[dimensions[dim]] < b[dimensions[dim]]:
		return true
	return false
	
func slice(array, from, to=null):
	#print("slice1: %s, %s" % [from, to])
	if array.size() == 0:
		return []
	if from + 1 > array.size():
		return []
	if from < 0:
		from = array.size() + from - 1
	if from < 0:
		return []
	if to == null:
		to = array.size() - 1
	elif to <= 0:
		to = array.size() + to - 1
	else:
		to -= 1
	#print("slice2: %s, %s" % [from, to])
	if to < from:
		return []
	if from == to:
		return [array[from]]
	
	var a = array.duplicate()
	a.resize(to+1)
	for i in range(from):
		a.pop_front()
	
	#print(a)
	return a

func buildTree(points, depth, parent):
	dim = depth % dimensions.size() #global, for custom sorting
	if points.size() == 0:
		return null
	if points.size() == 1:
		return Node(points[0], dim, parent)

	points.sort_custom(self, "sortPoints")
	var median = floor(points.size() / 2);
	var node = Node(points[median], dim, parent);
	
	#print("BT1slice %s %s" % [depth, points.size()])
	node.left = buildTree(slice(points, 0, median), depth + 1, node);
	#print("BT2slice %s %s" % [depth, points.size()])
	node.right = buildTree(slice(points, median + 1), depth + 1, node);

	return node

func innerSearch(point, node, parent):
	if node == null:
		return parent
	var dimension = dimensions[node.dimension]
	if point[dimension] < node.obj[dimension]:
		return innerSearch(point, node.left, node)
	return innerSearch(point, node.right, node)

func insert(point):
	var insertPosition = innerSearch(point, root, null)
	
	if insertPosition == null:
		root = Node(point, 0, null)
		return

	var newNode = Node(point, (insertPosition.dimension + 1) % dimensions.length, insertPosition)
	var dimension = dimensions[insertPosition.dimension]

	if point[dimension] < insertPosition.obj[dimension]:
		insertPosition.left = newNode
	insertPosition.right = newNode

func nodeSearch(node, point):
	if node == null:
		return null
	if node.obj == point:
		return node
	
	var dimension = dimensions[node.dimension]
	if point[dimension] < node.obj[dimension]:
		return nodeSearch(node.left, node)
	return nodeSearch(node.right, node)


func findMin(node, dim):
	if node == null:
		return null
	
	var dimension = dimensions[dim]
	
	if node.dimension == dim:
		if node.left != null:
			return findMin(node.left, dim)
		return node

	var own = node.obj[dimension]
	var left = findMin(node.left, dim)
	var right = findMin(node.right, dim)
	var nmin = node

	if left != null and left.obj[dimension] < own:
		nmin = left;
	if right != null and right.obj[dimension] < nmin.obj[dimension]:
		nmin = right;
	return nmin;

func removeNode(node):
	var nextNode
	var nextObj

	if node.left == null and node.right == null:
		if node.parent == null:
			root = null
			return

		var pDimension = dimensions[node.parent.dimension];

		if node.obj[pDimension] < node.parent.obj[pDimension]:
			node.parent.left = null
		else:
			node.parent.right = null
		return

	# If the right subtree is not empty, swap with the minimum element on the
	# node's dimension. If it is empty, we swap the left and right subtrees and
	# do the same.
	if node.right != null:
		nextNode = findMin(node.right, node.dimension)
		nextObj = nextNode.obj
		removeNode(nextNode)
		node.obj = nextObj
	else:
		nextNode = findMin(node.left, node.dimension)
		nextObj = nextNode.obj
		removeNode(nextNode)
		node.right = node.left
		node.left = null
		node.obj = nextObj

func remove(point):
	var node = nodeSearch(root, point)
	if node == null:
		return
	removeNode(node)

var bestNodes
func saveNode(node, distance):
	bestNodes.push([node, distance])
	if bestNodes.size() > maxNodes:
		bestNodes.pop()

func nearestSearch(node):
	var bestChild
	var dimension = dimensions[node.dimension]
	var ownDistance = metric.call_func(point, node.obj)
	var linearPoint = {}

	for i in range(dimensions.size()):
		if i == node.dimension:
			linearPoint[dimensions[i]] = point[dimensions[i]]
		else:
			linearPoint[dimensions[i]] = node.obj[dimensions[i]]
	
	var linearDistance = metric.call_func(linearPoint, node.obj)

	if node.right == null and node.left == null:
		if bestNodes.size() < maxNodes or ownDistance < bestNodes.peek()[1]:
			saveNode(node, ownDistance)
		return

	if node.right == null:
		bestChild = node.left
	elif node.left == null:
		bestChild = node.right
	else:
		if point[dimension] < node.obj[dimension]:
			bestChild = node.left
		else:
			bestChild = node.right

	nearestSearch(bestChild)

	if bestNodes.size() < maxNodes or ownDistance < bestNodes.peek()[1]:
		saveNode(node, ownDistance)
	
	var otherChild
	if bestNodes.size() < maxNodes or abs(linearDistance) < bestNodes.peek()[1]:
		if bestChild == node.left:
			otherChild = node.right
		else:
			otherChild = node.left
	if otherChild != null:
		nearestSearch(otherChild)

var maxNodes
var maxDistance
var point

func nearest(_point, _maxNodes, _maxDistance = null):
	maxNodes = _maxNodes
	maxDistance = _maxDistance
	point = _point
	bestNodes = BinaryHeap.new() #global
	var result = []

	if maxDistance:
		for i in range(maxNodes):
			bestNodes.push([null, maxDistance])

	if root:
		nearestSearch(root)

	for i in range(min(maxNodes, bestNodes.size())):
		if bestNodes.content[i][0]:
			result.push_back([bestNodes.content[i][0].obj, bestNodes.content[i][1]])
	return result

func height(node):
	if node == null:
		return 0
	return max(height(node.left), height(node.right)) + 1

func count(node):
	if node == null:
		return 0
	
	return count(node.left) + count(node.right) + 1

func count_all():
	return count(root)

func balanceFactor():
	return height(root) / (log(count(root)) / log(2))

func toJSON(src=null):
	if src == null:
		src = root
	var dest = Node(src.obj, src.dimension, null)
	if src.left:
		dest.left = toJSON(src.left)
	if src.right:
		dest.right = toJSON(src.right)
	return dest

func _init(points, dim, _metric=null):
	#print("init kdTree, self(%s)" % self)
	#print("points: ", points)
	#print("dim: ", dim)
	dimensions = dim
	root = buildTree(points, 0, null)
	if _metric:
		metric = _metric
	else:
		metric = funcref(self, "metric_vector")


# Binary heap implementation from:
# http://eloquentjavascript.net/appendix2.html
# from https://github.com/ubilabs/kd-tree-javascript

class BinaryHeap:
	var content
	var scoreFunction
	
	func sf_min(e):
		return e[1]
	
	func sf_max(e):
		return -e[1]
	
	func push(element):
		# Add the new element to the end of the array.
		content.push_back(element)
		# Allow it to bubble up.
		bubbleUp(content.size() - 1)

	func pop():
		# Store the first element so we can return it later.
		var result = content[0];
		# Get the element at the end of the array.
		var end = content.pop_back();
		# If there are any elements left, put the end element at the
		# start, and let it sink down.
		if content.size() > 0:
			content[0] = end
			sinkDown(0)
		return result

	func peek():
		return content[0]

	func remove(node):
		var length = content.size()
		#To remove a value, we must search through the array to find it.
		for i in range(length):
			if content[i] == node:
				# When it is found, the process seen in 'pop' is repeated
				#to fill up the hole.
				var end = content.pop_back()
				if i != length - 1 :
					content[i] = end
				if scoreFunction.call_func(end) < scoreFunction.call_func(node):
					bubbleUp(i)
				else:
					sinkDown(i)
				return

	func size():
		return content.size()

	func bubbleUp(n):
		# Fetch the element that has to be moved.
		var element = content[n];
		# When at 0, an element can not go up any further.
		while n > 0:
			# Compute the parent element's index, and fetch it.
			var parentN = floor((n + 1) / 2) - 1
			var parent = content[parentN]
			# Swap the elements if the parent is greater.
			if scoreFunction.call_func(element) < scoreFunction.call_func(parent):
				content[parentN] = element
				content[n] = parent
				# Update 'n' to continue at the new position.
				n = parentN
			# Found a parent that is less, no need to move it further.
			else:
				break

	func sinkDown(n):
		# Look up the target element and its score.
		var length = content.size()
		var element = content[n]
		var elemScore = scoreFunction.call_func(element)
		
		while true :
			# Compute the indices of the child elements.
			var child2N = (n + 1) * 2
			var child1N = child2N - 1
			# This is used to store the new position of the element, if any.
			var swap = null
			var child1Score
			# If the first child exists (is inside the array)...
			if child1N < length:
				# Look it up and compute its score.
				var child1 = content[child1N]
				child1Score = scoreFunction.call_func(child1)
				# If the score is less than our element's, we need to swap.
				if child1Score < elemScore:
					swap = child1N
			# Do the same checks for the other child.
			if child2N < length:
				var child2 = content[child2N]
				var child2Score = scoreFunction.call_func(child2)
				if swap == null:
					if child2Score < elemScore:
						swap = child2N
				else:
					if child2Score < child1Score:
						swap = child2N

			# If the element needs to be moved, swap it, and continue.
			if swap != null:
				content[n] = content[swap]
				content[swap] = element
				n = swap
			# Otherwise, we are done.
			else:
				break

	func _init(_scoreFunction=null):
		if _scoreFunction == null:
			_scoreFunction = funcref(self, "sf_max")
		scoreFunction = _scoreFunction
		content = []
