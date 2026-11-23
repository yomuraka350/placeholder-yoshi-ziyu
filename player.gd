extends CharacterBody2D

@export var speed = 150.0
@onready var anim = $AnimatedSprite2D

var attacking = false

func _ready():
	anim.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	anim.play("movement")

func _physics_process(delta):
	if attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	move_and_slide()

	# 左右翻转
	if dir.x != 0:
		anim.flip_h = dir.x < 0

	# 移动时播放 movement，不动时停在第一帧
	if dir != Vector2.ZERO:
		if anim.animation != "movement" or not anim.is_playing():
			anim.play("movement")
	else:
		anim.stop()
		anim.frame = 0

func _input(event):
	if event.is_action_pressed("attack") and not attacking:
		attacking = true
		anim.play("attack")

func _on_animated_sprite_2d_animation_finished():
	if anim.animation == "attack":
		attacking = false
		anim.play("movement")
