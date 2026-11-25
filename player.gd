extends CharacterBody2D

@export var speed := 200.0
@export var acceleration := 8.0
@export var jump_velocity := -600.0

var attacking = false

func _ready():
	pass

func _physics_process(delta):
	get_input()
	apply_gravity(delta)

func get_input():
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x += direction * speed / acceleration
	else:
		if velocity.x < 0:
			velocity.x += speed / acceleration
			velocity.x = clamp(velocity.x, -speed, 0)
		elif velocity.x > 0:
			velocity.x -= speed / acceleration
			velocity.x = clamp(velocity.x, 0, speed)
	
	velocity.x = clamp(velocity.x, -speed, speed)
	
	move_and_slide()
	
func apply_gravity(delta : float):
	if not is_on_floor():
		velocity += get_gravity() * delta
