[node_routes]

Help_me2="res://addons/joyeux_npc_editor/src/NPCs/DefaultBehaviors/WorkingCycle.jbt"
Help_me="res://addons/joyeux_npc_editor/src/NPCs/DefaultBehaviors/Help_me.jbt"

[offsets]

Help_me=Vector2( -520, 180 )
Help_me2=Vector2( -380, 80 )

[config]

filtered_connections=[ {
"from": "Help_me",
"from_port": 0,
"to": "Help_me2",
"to_port": 0
} ]

[variables]

initial_state="Help_me"
character_name="Steve"
shirt_color=Color( 0, 0.687866, 0.898438, 1 )
pants_color=Color( 0, 0.00842285, 0.539063, 1 )
hair_color=Color( 0.265625, 0.192993, 0, 1 )
skin_color=Color( 0.53125, 0.444092, 0.332031, 1 )
shoes_color=Color( 0.351563, 0.351563, 0.351563, 1 )
gender=0
