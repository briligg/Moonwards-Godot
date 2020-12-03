[node_routes]

WorkingBusy="res://addons/joyeux_npc_editor/src/NPCs/DefaultBehaviors/WorkingBusy.jbt"
WorkingCycle="res://addons/joyeux_npc_editor/src/NPCs/DefaultBehaviors/WorkingCycle.jbt"


[config]

filtered_connections=[ {
"from": "WorkingCycle",
"from_port": 0,
"to": "WorkingBusy",
"to_port": 0
}, {
"from": "WorkingBusy",
"from_port": 0,
"to": "WorkingCycle",
"to_port": 0
} ]

[variables]

initial_state="WorkingCycle"
character_name="Anto"
shirt_color=Color( 0.222789, 0.17688, 0.628906, 1 )
pants_color=Color( 0.417969, 0.243284, 0.148575, 1 )
hair_color=Color( 0.507813, 0.780823, 1, 1 )
skin_color=Color( 0.574219, 0.488983, 0.488983, 1 )
shoes_color=Color( 1, 1, 1, 1 )

[offsets]

WorkingBusy=Vector2( -660, -340 )
WorkingCycle=Vector2( -660, -260 )
