extends Actor

const knife_attack = preload("res://src/KnifeAnim.tscn") # preloads knife animation as packed scene constant
# see line 217

signal health_update(maxh, curh)

export var acc: = 10.0

export var jump_height: = 10.0

export var max_health = 100

var _platform = null

# Various states
var is_idle = true
var is_jumping: = false
var is_attacking = false
var is_facing_right = true
var is_dj_ready = true
var is_charging = false
var is_still_charging = false

# Ability costs
var blood_jump_cost = 5
var platform_make_cost = 5
var platform_drain_cost = 2
var blood_shot_cost = 10

# Timers
var _plat_drain_timer = 0.0
var _plat_drain_timer_limit = 1.0
var _charge_timer = 0.0
var _charge_timer_limit = 1.0
var _melee_delay = 0.1
var _iframe_timer = 0.0
var _iframe_timer_limit = 1.2

enum attack_direction {right, down, left, up}

var rng = RandomNumberGenerator.new()
func _ready():
	_health = max_health
	emit_signal("health_update", max_health, _health)
	$AnimatedSprite.play("idle")
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
	if is_charging:
		_charge_timer += delta
		if _charge_timer > _charge_timer_limit:
			is_still_charging = false
			is_charging = false
			var size = Vector2(3.0, 3.0)
			var pressed_up = Input.is_action_pressed("Up")
			var pressed_down = Input.is_action_pressed("Down")
			var direction = attack_direction.up if pressed_up else \
							attack_direction.down if pressed_down else \
							attack_direction.right if is_facing_right else \
							attack_direction.left
			do_melee_attack(direction, size, 10, false)
		elif _charge_timer > _melee_delay:
			is_still_charging = true
	_iframe_timer = min(_iframe_timer + delta, _iframe_timer_limit)

func _physics_process(delta: float):
	# updating variables
	if vel.y >= 0:
		is_jumping = false

	update_animation()

	if is_on_floor():
		is_dj_ready = true

func add_or_remove_health(amount):
	_health -= amount
	if _health < 0:
		#dead
		pass
	_health = min(_health, max_health)
	emit_signal("health_update", max_health, _health)

func update_animation():
	if vel.y < 0:
		$AnimatedSprite.play("jump")
	elif vel.y > 0:
		$AnimatedSprite.play("fall")
	elif !is_idle:
		$AnimatedSprite.play("move")
	else:
		$AnimatedSprite.play("idle")
	$AnimatedSprite.flip_h = not is_facing_right


func create_platform():
	_platform = Platform.instance()
	_platform.position = to_global(Vector2(0, $CollisionShape2D.shape.get_extents().y))
	get_parent().add_child(_platform)
	_plat_drain_timer = 0

func remove_platform():
	_platform.queue_free()
	_platform = null

func create_hitbox(size, rel_pos, damage):
	var hitbox = Hitbox.instance()
	var shape = RectangleShape2D.new()
	shape.set_extents(size)
	var collision = CollisionShape2D.new()
	collision.set_shape(shape)
	hitbox.add_child(collision)
	hitbox.position = to_global(rel_pos)
	hitbox.damage = damage
	hitbox.collision_layer = 1 << 2
	hitbox.collision_mask = 1 << 3
	get_parent().add_child(hitbox)
	return hitbox
	
	
func do_melee_attack(direction, size, damage, heals):
	var rel_pos = Vector2.ZERO
	if direction == attack_direction.up || direction == attack_direction.down:
		rel_pos.y = -5 if direction == attack_direction.up else 5
	else:
		rel_pos.x = 3 if direction == attack_direction.right else -3
	var hitbox = create_hitbox(size, rel_pos, 5)
	if direction == attack_direction.down:
		hitbox.should_bump = true
	elif direction != attack_direction.up:
		var knockback = Vector2(200 if direction == attack_direction.right else -200, -100)
		hitbox.knock_power = knockback
	
	hitbox.rotate(direction * PI/2)
	hitbox.show_knife()
	# Subscribe to get health!
	if heals:
		hitbox.connect("area_entered", self, "_on_Hitbox_area_entered", [hitbox])
	yield(get_tree().create_timer(_melee_delay), "timeout")
	is_attacking = false
	hitbox.queue_free()

func do_projectile_attack(size, rel_pos, accel):
	var hitbox = create_hitbox(size, rel_pos, 10)
	hitbox.projectile = true
	hitbox.speed = accel

func can_jump():
	return (is_on_floor() || (is_dj_ready && _health > blood_jump_cost)) && !is_still_charging;
	
func can_shoot():
	return _health > blood_shot_cost

func process_movement_inputs():
	
	var pressed_left = Input.is_action_pressed("MoveLeft")
	var pressed_right = Input.is_action_pressed("MoveRight")
	var pressed_up = Input.is_action_pressed("Up")
	var pressed_down = Input.is_action_pressed("Down")

	is_idle = not ((pressed_left and !pressed_right) or (!pressed_left and pressed_right))

	if !is_still_charging:
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
		_charge_timer = 0.0
		is_charging = true
		is_attacking = true
		var size = Vector2(2.0, 1.0)
		var direction = attack_direction.up if pressed_up else \
							attack_direction.down if pressed_down else \
							attack_direction.right if is_facing_right else \
							attack_direction.left
		do_melee_attack(direction, size, 5, true)
		
	if Input.is_action_just_released("Attack"):
		is_charging = false
		is_still_charging = false
		
	if Input.is_action_just_pressed("Shoot") && can_shoot():
		add_or_remove_health(blood_shot_cost)
		var size = Vector2(1.0, 1.0)
		var rel_pos = Vector2(0, -3 if pressed_up else 3) if pressed_up || pressed_down else Vector2(2 if is_facing_right else -3, 0)
		var speed = 200;
		var accel = Vector2(0,0)
		if not pressed_up and not pressed_down:
			accel = Vector2(speed if is_facing_right else -speed, 0)
		else:
			accel = speed * Vector2(int(pressed_right) - int(pressed_left), int(pressed_down) - int(pressed_up))
		do_projectile_attack (size, rel_pos, accel)

	if Input.is_action_just_pressed("Ouch"):
		add_or_remove_health(-max_health)

	if Input.is_action_just_pressed("Platform"):
		if _platform != null:
			remove_platform()
		elif !(_health <= platform_make_cost) && !is_on_floor():
			create_platform()
			add_or_remove_health(5)

func _on_Hitbox_area_entered(area, hitbox):
	add_or_remove_health(-(max_health / 100))
	if hitbox.should_bump:
		vel.y = -jump_height /1.25

func do_knife_animation():
	var knife_anim = knife_attack.instance() # store instance of packed scene in variable
	get_tree().current_scene.add_child(knife_anim) # add instanced packed scene to current scene tree
	knife_anim.global_position = global_position - Vector2(0, 1) # location of instanced packed scene.
	# end knife attack animation. queue_free is called by animationplayer node within the knife animation scene
	# to remove from scene when animation finishes.

func is_invuln():
	return _iframe_timer <_iframe_timer_limit

func set_iframes():
	_iframe_timer = 0.0
