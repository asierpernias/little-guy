
extends CharacterBody2D

@export var speed: float = 65.0
@export var gravity: float = 500.0
@export var jump_force: float = -120.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var facing_right: bool = true

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed

	if direction > 0:
		facing_right = true
	elif direction < 0:
		facing_right = false

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force

	update_animation(direction)
	move_and_slide()


func update_animation(direction: float) -> void:
	if direction < 0:
		animated_sprite.play("walk_left")
	elif direction > 0:
		animated_sprite.play("walk_right")
	elif facing_right:
		animated_sprite.play("stand_right")
	else:
		animated_sprite.play("stand_left")
