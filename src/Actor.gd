extends KinematicBody2D
class_name Actor

var Hitbox = preload("res://src/Hitbox.tscn")

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

func is_invuln():
	pass

func create_hitbox(size, rel_pos, damage):
	var hitbox = Hitbox.instance()
	var shape = RectangleShape2D.new()
	shape.set_extents(size)
	var collision = CollisionShape2D.new()
	collision.set_shape(shape)
	hitbox.add_child(collision)
	hitbox.position = to_global(rel_pos)
	hitbox.damage = damage
	get_parent().add_child(hitbox)
	return hitbox

func take_damage(knockback, amount):
	_knockback = knockback
	add_or_remove_health(amount)

func update_vel():
	vel.x *= get_parent().friction
	vel.y += get_parent().gravity
