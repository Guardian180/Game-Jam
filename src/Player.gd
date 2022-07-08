extends KinematicBody2D
var vel: = Vector2.ZERO

signal health_update(maxh, curh)

export var acc: = 30.0

export var jump_height: = 30.0

export var max_health = 100
var _health

var _platform = null

# Various states
var is_jumping: = false
var is_attacking = false
var is_facing_right = true
var is_dj_ready = true

# Ability costs
var blood_jump_cost = 5
var platform_make_cost = 5
var platform_drain_cost = 2

var _plat_drain_timer = 0.0;
var _plat_drain_timer_limit = 1.0

var rng = RandomNumberGenerator.new()
func _ready():
	_health = max_health
	emit_signal("health_update", max_health, _health)
	rng.randomize()

var Hitbox = preload("res://src/Hitbox.tscn")
var Platform = preload("res://src/Platform.tscn")

func _process(delta):
	if _platform != null:
		_plat_drain_timer += delta
		if _plat_drain_timer > _plat_drain_timer_limit:
			_plat_drain_timer -= _plat_drain_timer_limit
			if _health <= platform_drain_cost:
				remove_platform()
			else:
				add_or_remove_health(2)

func _physics_process(delta: float):
	# calling helper functions
	update_vel()
	
	handle_input()
	
	vel = move_and_slide(vel, Vector2.UP)
	
	# updating variables
	if vel.y >= 0:
		is_jumping = false

	if is_on_floor():
		is_dj_ready = true

func add_or_remove_health(amount):
	_health -= amount
	if _health < 0:
		#dead
		pass
	_health = min(_health, max_health)
	emit_signal("health_update", max_health, _health)

func update_vel():
	vel.x *= get_parent().friction
	vel.y += get_parent().gravity

func create_platform():
	_platform = Platform.instance()
	_platform.position = to_global(Vector2(0, $CollisionShape2D.shape.get_extents().y))
	get_parent().add_child(_platform)
	_plat_drain_timer = 0

func remove_platform():
	_platform.queue_free()
	_platform = null

func create_hitbox(size, rel_pos):
	var hitbox = Hitbox.instance()
	# Subscribe to get health!
	hitbox.get_node("Collision").shape.set_extents(size)
	hitbox.position = to_global(rel_pos)
	hitbox.damage = 5
	hitbox.collision_layer = 1 << 2
	hitbox.collision_mask = 1 << 3
	get_parent().add_child(hitbox)
	hitbox.connect("area_entered", self, "_on_Hitbox_area_entered")
	yield(get_tree().create_timer(0.2), "timeout")
	is_attacking = false
	hitbox.queue_free()

func can_jump():
	return is_on_floor() || (is_dj_ready && _health > blood_jump_cost);

func handle_input():
	
	var pressed_left = Input.is_action_pressed("MoveLeft")
	var pressed_right = Input.is_action_pressed("MoveRight")
	var pressed_up = Input.is_action_pressed("Up")
	var pressed_down = Input.is_action_pressed("Down")

	if pressed_left:
		vel.x -= acc

	if pressed_right:
		vel.x += acc

	is_facing_right = (not pressed_left and pressed_right) or \
					  (not pressed_left and is_facing_right) or \
					  (pressed_left and pressed_right and is_facing_right)

	if Input.is_action_just_pressed("Jump") && can_jump():
		if !is_on_floor():
			is_dj_ready = false
			add_or_remove_health(blood_jump_cost)
		vel.y = -jump_height
		is_jumping = true

	if Input.is_action_just_released("Jump") and is_jumping:
		vel.y *= 0.5
		is_jumping = false

	if Input.is_action_just_pressed("Attack") && !is_attacking:
		is_attacking = true
		var size = Vector2(1.0, 2.0) if pressed_up || pressed_down else Vector2(2.0, 1.0)
		var rel_pos = Vector2(0, -3 if pressed_up else 3) if pressed_up || pressed_down else Vector2(2 if is_facing_right else -3, 0)
		create_hitbox(size, rel_pos)

	if Input.is_action_just_pressed("Ouch"):
		add_or_remove_health(-max_health)

	if Input.is_action_just_pressed("Platform"):
		if _platform != null:
			remove_platform()
		elif !(_health <= platform_make_cost) && !is_on_floor():
			create_platform()
			add_or_remove_health(5)

func _on_Hitbox_area_entered(area):
	add_or_remove_health(-(max_health / 100))
	print (area.get_node("CollisionShape2D").position, position)
	if area.get_node("CollisionShape2D").position.y > position.y + $CollisionShape2D.shape.get_extents().y:
		vel.y = -jump_height /1.25
