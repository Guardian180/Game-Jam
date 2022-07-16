extends Actor

export var acc: = 30.0
export var direction = 1 # right for 1, -1 for left 

var is_attacking = false
var saved_acc

#timers
var _player_detect_timer = 1.5
var _melee_delay = 0.1
var _player_detect_attack = 0.2
var _player_detect_delay = 1.5

func _ready():
	_health = 10
	$AnimatedSprite.play("idle")
	
func _process(delta):
	_player_detect_timer = min(_player_detect_delay, _player_detect_timer+delta)
	if is_attacking && _player_detect_delay == _player_detect_timer:
		_player_detect_timer = 0.0
		do_melee_attack(Vector2(2, 2), 10)
		

func _physics_process(delta: float):
	if is_on_wall():
		direction = -direction
		$AttackDetector.position.x = -$AttackDetector.position.x

	update_animation()

func update_animation():
	$AnimatedSprite.play("move")
	$AnimatedSprite.flip_h = direction < 0
	
func process_movement_inputs():
	vel.x += acc * direction
	
func add_or_remove_health(amount):
	_health -= amount
	if _health <= 0:
		queue_free()

func do_melee_attack(size, damage):
	yield(get_tree().create_timer(_player_detect_attack), "timeout")
	var rel_pos = Vector2.ZERO
	rel_pos.x = 3 if direction > 0 else -3
	var hitbox = create_hitbox(size, rel_pos, damage)
	hitbox.collision_layer = 1 << 4
	hitbox.collision_mask = 1 << 1
	var knockback = Vector2(200 if direction > 0 else -200, -100)
	hitbox.knock_power = knockback
	
	hitbox.show_enemy_sword()
	yield(get_tree().create_timer(_melee_delay), "timeout")
	hitbox.queue_free()


func _on_AttackDetector_area_entered(area):
	saved_acc = acc
	acc = 0
	is_attacking = true


func _on_AttackDetector_area_exited(area):
	acc = saved_acc
	is_attacking = false
