extends Camera2D

@export_group("Target")
@export var target: Node2D

@export_group("Follow")
@export var follow_speed: float = 6.0
@export var offset_from_target: Vector2 = Vector2.ZERO

@export_group("Look ahead")
@export var look_ahead_distance: float = 0.0
@export var look_ahead_speed: float = 4.0

var look_ahead_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	if target == null:
		target = get_tree().get_first_node_in_group("player") as Node2D

	if target == null:
		print("camera_follow ERROR: no target assigned and no node found in group 'player'")
		set_physics_process(false)
		return

	global_position = target.global_position + offset_from_target
	make_current()

	Respawn.player_teleported.connect(_snap_to_target)


func _snap_to_target() -> void:
	look_ahead_offset = Vector2.ZERO
	global_position = target.global_position + offset_from_target


func _physics_process(delta: float) -> void:
	var desired_position: Vector2 = target.global_position + offset_from_target

	if look_ahead_distance > 0.0 and target is CharacterBody2D:
		var move_direction: Vector2 = (target as CharacterBody2D).velocity.normalized()
		var look_weight: float = 1.0 - exp(-look_ahead_speed * delta)
		look_ahead_offset = look_ahead_offset.lerp(move_direction * look_ahead_distance, look_weight)
		desired_position += look_ahead_offset

	var follow_weight: float = 1.0 - exp(-follow_speed * delta)
	global_position = global_position.lerp(desired_position, follow_weight)
