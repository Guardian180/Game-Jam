extends Control

export var MaxHealth = 100

var health = MaxHealth
var format = "%d / %d"


func _on_Player_health_update(maxh, curh):
	# this will update the heart sprite depending on health value. it could probably be simplified
	# using an equation but this will work.
	var hearts = $Hearts
	hearts.frame = maxh / 10 - curh / 10
	print(str(hearts.frame)) #debug
