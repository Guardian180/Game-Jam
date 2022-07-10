extends KinematicBody2D
class_name Actor

var vel: = Vector2.ZERO
var _health

var _knockback = null

func _physics_process(delta: float):
	update_vel()
	
	if _knockback == null:
		process_movement_inputs()
	else:
		vel += _knockback
		_knockback = null
		
	vel = move_and_slide(vel, Vector2.UP)

func add_or_remove_health(amount):
	pass

func process_movement_inputs():
	pass

func take_damage(knockback, amount):
	_knockback = knockback
	add_or_remove_health(amount)

func update_vel():
	vel.x *= get_parent().friction
	vel.y += get_parent().gravity
