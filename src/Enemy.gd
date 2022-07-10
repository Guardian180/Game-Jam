extends Actor

export var acc: = 30.0
export var direction = 1 # right for 1, -1 for left 

func _ready():
	_health = 10
	$AnimatedSprite.play("idle")
	

func _physics_process(delta: float):
	if is_on_wall():
		direction = -direction

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
