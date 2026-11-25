extends CharacterBody2D

@export var patrol_speed = 40.0       # Patrol speed
@export var chase_speed = 90.0        # Chase speed
@export var patrol_distance = 100.0   # Patrol range (pixels left/right of the start point)
@export var attack_cooldown = 1.0     # Time between attacks (seconds)

@onready var anim = $AnimatedSprite2D
@onready var detection = $DetectionArea
@onready var attack_area = $AttackArea

var start_x = 0.0
var direction = 1
var target = null
var can_attack = true

func _ready():
	start_x = global_position.x
	anim.play("walk")
	detection.body_entered.connect(_on_detection_entered)
	detection.body_exited.connect(_on_detection_exited)

func _physics_process(delta):
	if target != null and is_instance_valid(target):
		_chase()
	else:
		_patrol()

	move_and_slide()
	_update_facing()

func _patrol():
	velocity.y = 0
	velocity.x = direction * patrol_speed
	# Turn around at the patrol edge or when hitting a wall
	if global_position.x > start_x + patrol_distance:
		direction = -1
	elif global_position.x < start_x - patrol_distance:
		direction = 1
	elif is_on_wall():
		direction *= -1

func _chase():
	var to_target = target.global_position - position
	if attack_area.overlaps_body(target):
		velocity = Vector2.ZERO
		_attack()
	else:
		velocity = to_target.normalized() * chase_speed

func _attack():
	if not can_attack:
		return
	can_attack = false
	print("Ant attacks!")   # TODO: damage the frog and play the attack animation here
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _update_facing():
	# Sprite faces right by default: flip_h = true means facing left
	if target != null and is_instance_valid(target):
		var dx = target.global_position.x - global_position.x
		if dx != 0:
			anim.flip_h = dx < 0
	else:
		if velocity.x != 0:
			anim.flip_h = velocity.x < 0

func _on_detection_entered(body):
	print("ENTERED: ", body.name)
	if body.is_in_group("player"):
		target = body

func _on_detection_exited(body):
	print("EXITED: ", body.name)
	if body == target:
		# Wait a moment before giving up, in case the frog re-enters
		await get_tree().create_timer(0.5).timeout
		if not detection.overlaps_body(body):
			target = null
			start_x = global_position.x
