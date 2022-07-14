extends Control

export var MaxHealth = 100

var health = MaxHealth
var format = "%d / %d"


func _on_Player_health_update(maxh, curh):
	$Label.text = format % [curh, maxh]
	# this will update the heart sprite depending on health value. it could probably be simplified
	# using an equation but this will work.
	var hearts = $Hearts
	if curh == maxh:
		hearts.frame = 0
	elif curh >= maxh * 0.9 and curh < maxh:
		hearts.frame = 1
	elif curh >= maxh * 0.8 and curh < maxh * 0.9:
		hearts.frame = 2
	elif curh >= maxh * 0.7 and curh < maxh * 0.8:
		hearts.frame = 3
	elif curh >= maxh * 0.6 and curh < maxh * 0.7:
		hearts.frame = 4
	elif curh >= maxh * 0.5 and curh < maxh * 0.6:
		hearts.frame = 5
	elif curh >= maxh * 0.4 and curh < maxh * 0.5:
		hearts.frame = 6
	elif curh >= maxh * 0.3 and curh < maxh * 0.4:
		hearts.frame = 7
	elif curh >= maxh * 0.2 and curh < maxh * 0.3:
		hearts.frame = 8
	elif curh >= maxh * 0.1 and curh < maxh * 0.2:
		hearts.frame = 9
	else:
		hearts.frame = 10
	print(str(hearts.frame)) #debug
