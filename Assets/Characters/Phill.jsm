[node_routes]

WorkingBusy="res://addons/joyeux_npc_editor/src/NPCs/DefaultBehaviors/WorkingBusy.jbt"
WorkingBusy2="res://addons/joyeux_npc_editor/src/NPCs/DefaultBehaviors/WorkingBusy.jbt"

[config]

filtered_connections=[ {
"from": "WorkingBusy",
"from_port": 0,
"to": "WorkingBusy2",
"to_port": 0
} ]

[variables]

initial_state="WorkingBusy"
character_name="Phill"
shirt_color=Color( 1, 0, 0, 1 )
pants_color=Color( 0, 0.566406, 0.526581, 1 )
hair_color=Color( 0.312896, 0.808594, 0.296906, 1 )
skin_color=Color( 0.96875, 0.948174, 0.87793, 1 )
shoes_color=Color( 0, 0, 0, 1 )

[offsets]

WorkingBusy=Vector2( -880, -280 )
WorkingBusy2=Vector2( -440, -200 )
