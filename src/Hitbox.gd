extends Area2D

export var damage = 0
export var speed = Vector2(0.0, 0.0)
export var projectile = false
export var knock_power = Vector2(0.0, 0.0)
export var should_bump = false

func _process(delta):
	position += delta * speed

func _on_Hitbox_area_entered(area):
	area.get_parent().take_damage(knock_power, damage)
	print("Deal Damage: " + str(damage))
	if projectile:
		queue_free()

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()
