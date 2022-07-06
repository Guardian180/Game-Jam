extends KinematicBody2D
var vel: = Vector2.ZERO

export var acc: = 30.0

export var jump_height: = 30.0
var is_jumping: = false

func _physics_process(delta: float):
	# calling helper functions
	update_vel()
	
	handle_input()
	
	vel = move_and_slide(vel, Vector2.UP)
	
	# updating variables
	if vel.y >= 0:
		is_jumping = false
	
func update_vel():
	vel.x *= get_parent().friction
	vel.y += get_parent().gravity
	
func handle_input():
	if Input.is_action_pressed("MoveLeft"):
		vel.x -= acc
	
	if Input.is_action_pressed("MoveRight"):
		vel.x += acc
		
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		vel.y = -jump_height
		
		is_jumping = true
		
	if Input.is_action_just_released("Jump") and is_jumping:
		vel.y *= 0.5
		
		is_jumping = false
