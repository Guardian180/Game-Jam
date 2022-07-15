extends Area2D

var is_damaging = false
var player = null
# This assumes that there's only player to damage

func _process(delta):
	if is_damaging:
		if player.is_invuln():
			return
		var x = player.position.x < self.get_parent().position.x
		var knock_power = Vector2(-200 if x else 200, -100)
		player.take_damage(knock_power, 5)
		player.set_iframes()

func _on_BodyHitbox_area_entered(area):
	player = area.get_parent()
	is_damaging = true

func _on_BodyHitbox_area_exited(area):
	is_damaging = false
