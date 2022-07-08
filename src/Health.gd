extends Control

export var MaxHealth = 100

var health = 0
var format = "%d / %d"



func _on_Player_health_update(maxh, curh):
	$Label.text = format % [curh, maxh]
