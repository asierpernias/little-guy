
extends Camera2D

@export var player: Node2D
@export var speed = 6.0
@export var mirar = 0.0

var extra = Vector2.ZERO

func _ready():
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("The player couldnt be found")
		set_physics_process(false)
		return
	global_position = player.global_position + offset
	make_current()
func _physics_process(delta):
	var pos = player.global_position + offset
	if mirar > 0 and player is CharacterBody2D:
		var dir = player.velocity.normalized()
		extra = dir * mirar
		pos += extra
	global_position = pos
