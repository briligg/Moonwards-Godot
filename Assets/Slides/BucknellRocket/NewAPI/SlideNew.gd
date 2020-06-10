extends Node

func _ready():
	var slideshow = {
		"Slide01": [
			{
				"comp": "path/to/res",
				"action": "show"
			},
			{
				"comp": "path/to/res",
				"action": "play"
			}
		],
		"Slide02": [
			{
				"comp": "path/to/res",
				"action": "play"
			},
			{
				"comp": "path/to/res",
				"action": "hide"
			}
		]
	}
