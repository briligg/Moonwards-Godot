extends Resource
class_name NpcDefinitions

#Class ID will be assigned from 27 and on, in the order classes are declared
func _init():
	var expr = Expression.new()
	var inputs = ["output"]
	var long_input = ["input_data", "weight_1", "weight_2", "weight_3"]
	var long_string = """
	if max(max(weight_1,weight_2),weight_3) == weight_1:
		print(1, input_data)
	elif max(max(weight_1,weight_2),weight_3) == weight_2:
		print(2, input_data)
	elif max(max(weight_1,weight_2),weight_3) == weight_3:
		print(3, input_data)
"""
	var try_with = [24, 11,2,3]
	
	expr.parse(long_string, long_input)
	expr.execute(try_with, self)
	
	
func misc(ind):
	print("Parsed!", ind)
	pass 
	
var CLASS_MISC = {
	"_color" : Color(.5,.5,.1,1),
	"_object_type" : "Any",
	"_variables":{
		"Character" : "CLASS_CHARACTER",
		"Projectile" : "CLASS_PROJECTILE"
	}
}

var CLASS_PROJECTILE = {
	"_color" : Color(.1, .3,.5,1),
	"_object_type" : "Projectile",
	"_variables" : {
		"Owner" : "CLASS_CHARACTER",
		"Damage" : TYPE_REAL,
		"Target" : "CLASS_CHARACTER"
	}
}

var CLASS_CHARACTER =  {
	"_color" : Color(.5,.5,.1,1),
	"_object_type" : "Character",
	"_variables" : {
		"team" : TYPE_INT,
		"translation" : TYPE_VECTOR3,
		"type" : TYPE_STRING,
		"health" : TYPE_REAL,
		"shield" : TYPE_REAL,
		"target_location" : TYPE_VECTOR3}
	}
#Do not use spaces or symbols in function defintions. 
#_s_ prefix indicates the label would be replaced with a special component
#This prefix only works in the input label.
var _functions = {
	"property_check" : {
		"_category" : "inhibitors",
		"_code" : "FuncRef?", #This hasn't been implemented yet
		"_input_ports" : [
			{"_label_title":"Object input", "_type" : TYPE_OBJECT},
			{"_label_title":"_s_prop_dropdown_CHARACTER", "_type" : TYPE_NIL}
		],
		"_output_ports" : [
			{"_label_title" : "Property content", "_type" : Nodes.TYPE_ANY},
		]
	},
	"match" : {
		"_category" : "inhibitors",
		"_code" : "FuncRef?", #This hasn't been implemented yet
		"_input_ports" : [
			{"_label_title":"String input", "_type" : TYPE_STRING},
			{"_label_title":"_s_text_edit", "_type" : TYPE_NIL}
		],
		"_output_ports" : [
			{"_label_title" : "Does Match", "_type" : TYPE_BOOL },
		]
	},
	"tri_v_decision" : {
		"_category" : "inhibitors",
		"_code" : "FuncRef?", #This hasn't been implemented yet
		"_input_ports" : [
			{"_label_title":"Value", "_type" : Nodes.TYPE_ANY},
			{"_label_title":"Weight 1", "_type" : TYPE_REAL},
			{"_label_title":"Weight 2", "_type" : TYPE_REAL},
			{"_label_title":"Weight 3", "_type" : TYPE_REAL}
		],
		"_output_ports" : [
			{"_label_title" : "", "_type" : TYPE_NIL },
			{"_label_title" : "Output 1", "_type" : Nodes.TYPE_ANY },
			{"_label_title" : "Output 2", "_type" : Nodes.TYPE_ANY },
			{"_label_title" : "Output 3", "_type" : Nodes.TYPE_ANY }
		]
	},
	"filter" : {
		"_category" : "misc",
		"_code" : "<actual code>",
		"_input_ports" : [
			{"_label_title":"title","_type":TYPE_NIL},
			{"_label_title":"title2","_type":TYPE_NIL}
			],
		"_output_ports" : [
			{"_label_title":"title","_type":TYPE_NIL},
			{"_label_title":"title2","_type":TYPE_NIL}
			]
	}, 
	"set_objective" : {
		"_category" : "actions",
		"_code" : "<actual code>",
		"_input_ports" : [
			{"_label_title":"Objective position","_type":TYPE_VECTOR3},
			],
		"_output_ports" : [
			{"_label_title":"","_type":TYPE_NIL},
			]
	},
	"force_next_state" : {
		"_category" : "actions",
		"_code" : "<actual code>",
		"_input_ports" : [
			{"_label_title":"Trigger","_type":Nodes.TYPE_ANY},
			],
		"_output_ports" : [
			{"_label_title":"","_type":TYPE_NIL},
			]
	} 
}

var _stimulus = {
	"hear" :{
		"_output_name": "Emmiter Data",
		"_output_type": TYPE_OBJECT,
	},
	"user_input" :{
		"_output_name": "Action Name",
		"_output_type": TYPE_STRING,
	},
	"see" :{
		"_output_name": "Object seen",
		"_output_type": TYPE_OBJECT,
	}
}
