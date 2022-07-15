extends Area2D

func _on_BodyHitbox_area_entered(area):
	var x = area.get_parent().position.x < self.get_parent().position.x
	var knock_power = Vector2(-200 if x else 200, -100)
	area.get_parent().take_damage(knock_power, 5)
