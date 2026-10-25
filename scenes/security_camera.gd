extends Node2D

signal player_detected
signal player_lost

@export_group("Surveillance")
@export var frame_duration: float = 1.0

@export_group("Position correction (sprite)")
@export var frame_0_offset: Vector2 = Vector2.ZERO
@export var frame_1_offset: Vector2 = Vector2.ZERO
@export var frame_2_offset: Vector2 = Vector2.ZERO
@export var frame_3_offset: Vector2 = Vector2.ZERO

@export_group("Collision offset")
@export var collision_0_offset: Vector2 = Vector2.ZERO
@export var collision_1_offset: Vector2 = Vector2.ZERO
@export var collision_2_offset: Vector2 = Vector2.ZERO
@export var collision_3_offset: Vector2 = Vector2.ZERO

@export_group("Frames with active detection")
@export var detect_in_frame_0: bool = true
@export var detect_in_frame_1: bool = false
@export var detect_in_frame_2: bool = true
@export var detect_in_frame_3: bool = false

var sprite: AnimatedSprite2D
var detection_area: Area2D
var collision_node: Node2D

var current_frame: int = 0
var timer: float = 0.0
var collision_base_position: Vector2 = Vector2.ZERO

var player_inside: bool = false
var is_detected: bool = false


func _ready() -> void:
	sprite = get_node_or_null("Sprite2D") as AnimatedSprite2D
	detection_area = get_node_or_null("DetectionArea") as Area2D

	if sprite == null:
		print("security_camera ERROR: 'Sprite2D' does not exist or is not an AnimatedSprite2D")
		return

	sprite.stop()
	sprite.animation = "default"

	if detection_area == null:
		print("security_camera WARNING: 'DetectionArea' not found")
	else:
		for child in detection_area.get_children():
			if child is CollisionShape2D or child is CollisionPolygon2D:
				collision_node = child
				break
		if collision_node == null:
			print("security_camera WARNING: 'DetectionArea' has no CollisionShape2D or CollisionPolygon2D")
		else:
			collision_base_position = collision_node.position

		if not detection_area.body_entered.is_connected(_on_detection_area_body_entered):
			detection_area.body_entered.connect(_on_detection_area_body_entered)
		if not detection_area.body_exited.is_connected(_on_detection_area_body_exited):
			detection_area.body_exited.connect(_on_detection_area_body_exited)

	timer = frame_duration
	update_frame()


func _process(delta: float) -> void:
	if sprite == null:
		return

	timer -= delta

	if timer <= 0.0:
		current_frame = (current_frame + 1) % 4
		update_frame()
		timer = frame_duration


func get_sprite_offset(frame: int) -> Vector2:
	match frame:
		0: return frame_0_offset
		1: return frame_1_offset
		2: return frame_2_offset
		3: return frame_3_offset
	return Vector2.ZERO


func get_collision_offset(frame: int) -> Vector2:
	match frame:
		0: return collision_0_offset
		1: return collision_1_offset
		2: return collision_2_offset
		3: return collision_3_offset
	return Vector2.ZERO


func is_detecting_in_frame(frame: int) -> bool:
	match frame:
		0: return detect_in_frame_0
		1: return detect_in_frame_1
		2: return detect_in_frame_2
		3: return detect_in_frame_3
	return false


func update_frame() -> void:
	sprite.set_frame_and_progress(current_frame, 0.0)
	sprite.position = get_sprite_offset(current_frame)

	if collision_node != null:
		collision_node.position = collision_base_position + get_collision_offset(current_frame)

	refresh_detection()


func refresh_detection() -> void:
	var now_detected: bool = player_inside and is_detecting_in_frame(current_frame)

	if now_detected == is_detected:
		return

	is_detected = now_detected

	if is_detected:
		print("The camera has detected the player!")
		player_detected.emit()
	else:
		print("The camera has lost sight of the player.")
		player_lost.emit()


func _is_player(body: Node2D) -> bool:
	return body is CharacterBody2D and (
		body.is_in_group("player") or body.name.to_lower() == "player"
	)


func _on_detection_area_body_entered(body: Node2D) -> void:
	if _is_player(body):
		player_inside = true
		refresh_detection()


func _on_detection_area_body_exited(body: Node2D) -> void:
	if _is_player(body):
		player_inside = false
		refresh_detection()
