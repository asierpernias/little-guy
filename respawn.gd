
extends CanvasLayer

signal respawn_started
signal player_teleported
signal respawn_finished

var fade_in = 0.4
var wait_time = 0.3
var fade_out = 0.4

var checkpoint = Vector2.ZERO
var has_checkpoint = false
var respawning = false

var rect

func _ready():
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	rect = ColorRect.new()
	rect.color = Color(0, 0, 0, 0)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player != null and not has_checkpoint:
		checkpoint = player.global_position
		has_checkpoint = true

func set_checkpoint(pos):
	checkpoint = pos
	has_checkpoint = true

func respawn_player(player, color = Color.BLACK):
	if respawning or player == null or not has_checkpoint:
		return
	respawning = true
	respawn_started.emit()
	var old_mode = player.process_mode
	player.process_mode = Node.PROCESS_MODE_DISABLED
	rect.color = Color(color.r, color.g, color.b, 0)
	var tween = create_tween()
	tween.tween_property(rect, "color:a", 1.0, fade_in)
	await tween.finished
	player.global_position = checkpoint
	if player is CharacterBody2D:
		player.velocity = Vector2.ZERO
	player_teleported.emit()
	await get_tree().create_timer(wait_time).timeout
	player.process_mode = old_mode
	tween = create_tween()
	tween.tween_property(rect, "color:a", 0.0, fade_out)
	await tween.finished
	respawning = false
	respawn_finished.emit()
