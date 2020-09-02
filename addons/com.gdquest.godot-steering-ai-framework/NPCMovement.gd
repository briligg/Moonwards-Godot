extends Node
"""This node should be child of a KinematicBody"""
# Holds extra information and our character
var Agent = GSAIKinematicBody3DAgent.new(get_parent())

# Holds the linear and angular components calculated by our steering behaviors.
var acceleration := GSAITargetAcceleration.new()

var current_target : GSAIAgentLocation = GSAIAgentLocation.new() 
var current_path : GSAIPath = GSAIPath.new([])
var personal_space : float = 1.5

# First, we setup our NPCs personal space, so they don't hit each other
# and get hard feelings 
var Proximity : GSAIRadiusProximity = GSAIRadiusProximity.new(Agent, get_tree().get_nodes_in_group("NPC"), personal_space)

# NOTE: From now on, steering behaviors are relative to the target point

# NPCs avoid each other, but just a bit, enough to keep walking space between them
var Avoid : GSAIAvoidCollisions = GSAIAvoidCollisions.new(Agent, Proximity)

# Fleeing a particular place can be used in emergency simulacrum emergencies
var FleeTarget : GSAISteeringBehavior = GSAIFlee.new(Agent, current_target)

var Seek : GSAISteeringBehavior = GSAISeek.new(Agent, current_target)

# Facing is more of an educated gesture towards someone you're listening to 
var Face : GSAISteeringBehavior = GSAIFace.new(Agent, current_target)

# NPCs may evade their problems, may evade you, or may evade another NPC 
# (the only limit is your imagination :D) 
var Evade : GSAISteeringBehavior = GSAIEvade.new(Agent, current_target)

# As you pursue your dreams, NPCs pursue whatever their target is
var Pursue : GSAISteeringBehavior = GSAIPursue.new(Agent, current_target)

#This behavior sets the NPC in an specific path that it will follow
var Follow : GSAIFollowPath = GSAIFollowPath.new(Agent, current_path)

# Takes away the cost of looking towards a specific thing and just 
# makes the NPC look where it's going to
var LookAhead : GSAILookWhereYouGo = GSAILookWhereYouGo.new(Agent)
# The name is too long for me...

# Behavior mixing occurs ahead, for the previous behaviors to work, this is
# necessary

var PathBlend : GSAIBlend = GSAIBlend.new(Agent)

var FollowBlend : GSAIBlend = GSAIBlend.new(Agent)

var FleeBlend : GSAIBlend = GSAIBlend.new(Agent)

# This one is important, as will tell the NPC what to do first when various
# movement options are present
var Priority : GSAIPriority = GSAIPriority.new(Agent)

func _enter_tree():
	var check = load("res://addons/com.gdquest.godot-steering-ai-framework/GSAISteeringAgent.gd")
	if not check is Resource:
		print_debug("This node depends on Steering AI Framework")
	#This is just a small explaination that should popup if used as tool
	#you would notice something's wrong when you try to use this node and errors 
	#pop up

func initiate():
	
	FleeBlend.add(Evade, 1)
	FleeBlend.add(FleeTarget, 1)
	
	FollowBlend.add(Pursue, 1)
	FollowBlend.add(Face, 1)
	
	PathBlend.add(Follow, 1)
	PathBlend.add(LookAhead, 1)
	
	# The order these are added has importance so the NPC behaves like this:
	Priority.add(Avoid)# Priority 1: Not to collide with other people
	Priority.add(FollowBlend)#2: Follow who I am supposed to (if i am supposed to)
	Priority.add(FleeBlend)#3: Run away if i am supposed to
	Priority.add(PathBlend) #4 : Follow a path
	
	

func _physics_process(delta):
	Priority.calculate_steering(acceleration)
	Agent._apply_steering(acceleration, delta)



func update_target(pos : Vector3):
	# Remember to update the target of the NPCs! Otherwise they could run away 
	# to their workstation instead of following your character (just an example)
	current_target.position = pos
