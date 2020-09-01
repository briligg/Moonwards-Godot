extends Node
"""This node should be child of a KinematicBody"""
var Agent = GSAIKinematicBody3DAgent.new(get_parent())
var current_target : GSAIAgentLocation = GSAIAgentLocation.new() 
var personal_space : float = 1.5
func _enter_tree():
	var check = load("res://addons/com.gdquest.godot-steering-ai-framework/GSAISteeringAgent.gd")
	if not check is Resource:
		print_debug("This node depends on Steering AI Framework")
	#This is just a small explaination that should popup if used as tool
	#you would notice something's wrong when you try to use this node and errors 
	#pop up

func initiate():
	# First, we setup our NPCs personal space, so they don't hit each other
	# and get hard feelings 
	var Proximity : GSAIRadiusProximity = GSAIRadiusProximity.new(Agent, get_tree().get_nodes_in_group("NPC"), personal_space)
	
	# NOTE: From now on, steering behaviors are relative to the target point
	
	# NPCs avoid each other, but just a bit, enough to keep walking space between them
	var Avoid : GSAIAvoidCollisions = GSAIAvoidCollisions.new(Agent, Proximity)
	
	# Fleeing a particular place can be used in emergency simulacrum emergencies
	var Flee : GSAISteeringBehavior = GSAIFlee.new(Agent, current_target)
	
	var Seek : GSAISteeringBehavior = GSAISeek.new(Agent, current_target)
	
	# Facing is more of an educated gesture towards someone you're listening to 
	var Face : GSAISteeringBehavior = GSAIFace.new(Agent, current_target)
	
	# NPCs may evade their problems, may evade you, or may evade another NPC 
	# (the only limit is your imagination :D) 
	var Evade : GSAISteeringBehavior = GSAIEvade.new(Agent, current_target)
	
	# As you pursue your dreams, NPCs pursue whatever their target is
	var Pursue : GSAISteeringBehavior = GSAIPursue.new(Agent, current_target)



func update_target(pos : Vector3):
	# Remember to update the target of the NPCs! Otherwise they could run away 
	# to their workstation instead of following your character (just an example)
	current_target.position = pos
