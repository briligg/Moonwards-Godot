extends AComponent
"""This node should be child of a KinematicBody"""
# Holds extra information and our character
var Agent : GSAIKinematicBody3DAgent 
export (float, 0, 100, 5) var linear_speed_max := 10.0
export (float, 0, 100, 0.1) var linear_acceleration_max := 1.0 
export (float, 0, 50, 0.1) var arrival_tolerance := 0.7
export (float, 0, 50, 0.1) var deceleration_radius := 1.0
export (int, 0, 1080, 10) var angular_speed_max := 270 
export (int, 0, 2048, 10) var angular_accel_max := 45 
export (int, 0, 178, 2) var align_tolerance := 5 
export (int, 0, 180, 2) var angular_deceleration_radius := 45 
# Holds the linear and angular components calculated by our steering behaviors.
onready var acceleration := GSAITargetAcceleration.new()
var world_ref : WorldNavigator = null
var path : Array = []
var current_target : GSAIAgentLocation = GSAIAgentLocation.new() 
var special_target : GSAISteeringAgent = GSAISteeringAgent.new()
var current_path : GSAIPath = GSAIPath.new([Vector3(1,1,1), Vector3(2,2,5)])
var personal_space : float = 1.5

# First, we setup our NPCs personal space, so they don't hit each other
# and get hard feelings 
var Proximity : GSAIRadiusProximity 

# NOTE: From now on, steering behaviors are relative to the target point

# NPCs avoid each other, but just a bit, enough to keep walking space between them
var Avoid : GSAIAvoidCollisions 

# Fleeing a particular place can be used in emergency simulacrum emergencies
var FleeTarget : GSAIFlee

var Seek : GSAISeek

# Facing is more of an educated gesture towards someone you're listening to 
var Face : GSAIFace 

# NPCs may evade their problems, may evade you, or may evade another NPC 
# (the only limit is your imagination :D) 
var Evade : GSAIEvade 

# As you pursue your dreams, NPCs pursue whatever their target is
var Pursue : GSAIPursue 

#This behavior sets the NPC in an specific path that it will follow
var Follow : GSAIFollowPath

# Takes away the cost of looking towards a specific thing and just 
# makes the NPC look where it's going to
var LookAhead : GSAILookWhereYouGo 
# The name is too long for me...

# Behavior mixing occurs ahead, for the previous behaviors to work, this is
# necessary

onready var PathBlend : GSAIBlend = GSAIBlend.new(Agent)

onready var FollowBlend : GSAIBlend = GSAIBlend.new(Agent)

onready var FleeBlend : GSAIBlend = GSAIBlend.new(Agent)

# This one is important, as will tell the NPC what to do first when various
# movement options are present
onready var Priority : GSAIPriority = GSAIPriority.new(Agent)

func _enter_tree():
	var check = load("res://addons/com.gdquest.godot-steering-ai-framework/GSAISteeringAgent.gd")
	if not check is Resource:
		print_debug("This node depends on Steering AI Framework")
	#This is just a small explaination that should popup if used as tool
	#you would notice something's wrong when you try to use this node and errors 
	#pop up
	var world = get_tree().get_nodes_in_group("Navigator")
	if world.size() > 0:
		world_ref = world [0] 
	Agent = GSAIKinematicBody3DAgent.new(get_parent())
	var NPCAgents = []
	for node in get_tree().get_nodes_in_group("NPC"):
		if node.get("Agent"):
			NPCAgents.append(node.Agent)
	Proximity = GSAIRadiusProximity.new(Agent, NPCAgents, personal_space)
	Avoid =  GSAIAvoidCollisions.new(Agent, Proximity)
	FleeTarget = GSAIFlee.new(Agent, current_target)
	Seek  = GSAISeek.new(Agent, current_target)
	Face =  GSAIFace.new(Agent, current_target, true)
	Evade = GSAIEvade.new(Agent, special_target)
	Pursue = GSAIPursue.new(Agent, special_target)
	Follow = GSAIFollowPath.new(Agent, current_path)
	LookAhead = GSAILookWhereYouGo.new(Agent, true)

func _init().("NPCInput", false):
	pass

func _ready():
	Agent.linear_speed_max = linear_speed_max
	Agent.linear_acceleration_max = linear_acceleration_max
	Agent.linear_drag_percentage = 0.05
	Agent.angular_acceleration_max = angular_accel_max
	Agent.angular_speed_max = angular_speed_max
	Agent.angular_drag_percentage = 0.1
	FleeBlend.add(Evade, 1)
	FleeBlend.add(FleeTarget, 1)
	FleeBlend.add(Avoid, 1) #Avoid is added everywhere, to get better consistency 
	
	FollowBlend.add(Seek, 1)
	FollowBlend.add(Face, 1)
	FollowBlend.add(Avoid, 1)
	
#	PathBlend.add(Follow, 1)
	PathBlend.add(LookAhead, 1)
	PathBlend.add(Avoid, 1) 
	PathBlend.is_enabled = true
	# The order these are added has importance so the NPC behaves like this:
#	Priority.add(Face)
	Priority.add(FollowBlend)#Priority 1: Follow who I am supposed to (if i am supposed to)
	Priority.add(FleeBlend)#2: Run away if i am supposed to
	Priority.add(PathBlend) #3 : Follow a path
	
	get_navpath(entity.translation)
	

func _process_server(delta):
	if PathBlend and FollowBlend and FleeBlend and Priority:
		if (current_target.position - entity.translation).length() < arrival_tolerance:
			var temp = path.pop_front()
			if temp != null:
				update_target(temp)
			else:
				entity.input = Vector3.ZERO
		else:
			print("distance: ",(current_target.position - entity.translation).length(), "tolerance: ", arrival_tolerance)
			Priority.calculate_steering(acceleration)
			
			_handle_npc_input(acceleration, delta)
		
func _handle_npc_input(acceleration : GSAITargetAcceleration, delta : float):
	update_agent(acceleration.linear, acceleration.angular)
#	Agent._apply_steering(acceleration, delta)
	entity.look_dir = entity.global_transform.origin-acceleration.linear
	entity.input.z = acceleration.linear.length()
	entity.input.y = acceleration.linear.y

func _process_client(delta):
	entity.global_transform.origin = entity.srv_pos


func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("use"):
			get_navpath(get_tree().get_nodes_in_group("Navigator")[0].get_nearest_workstation(entity.translation).translation)

func update_target(pos : Vector3):
	# Remember to update the target of the NPCs! Otherwise they could run away 
	# to their workstation instead of following your character (just an example)
	current_target.position = pos
	special_target.position = pos

func get_navpath(to : Vector3):
	path = Array(world_ref.get_navmesh_path(entity.translation, to))
#	print(path)
	current_path.create_path(path)
	var temp = path.pop_front()
	if temp != null:
		update_target(temp)
		
	
func update_agent(velocity : Vector3, angular_velocity : float):
	Agent.position = get_parent().translation
	Agent.orientation = entity.rotation_degrees.y
	Agent.linear_velocity = velocity
	Agent.angular_velocity = angular_velocity
