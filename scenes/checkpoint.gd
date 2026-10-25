
extends Area2D

@export var offset = Vector2.ZERO
@export var color_off = Color(1, 0.5, 0.5)
@export var color_on = Color(0.5, 1, 0.5)
@export var mostrar = true
@export var tamano = Vector2(4, 24)

var forma = null
var usado = false

func _ready():
	modulate = color_off

	for hijo in get_children():
		if hijo is CollisionShape2D or hijo is CollisionPolygon2D:
			forma = hijo
			break

	body_entered.connect(_on_body_entered)
	queue_redraw()

func get_point():
	if forma != null:
		return forma.global_position + offset
	return global_position + offset

func _draw():
	if not mostrar:
		return

	var pos = Vector2.ZERO
	if forma != null:
		pos = forma.position

	draw_rect(Rect2(pos.x - tamano.x / 2, pos.y - tamano.y, tamano.x, tamano.y), Color.WHITE)
	draw_rect(Rect2(pos.x + tamano.x / 2, pos.y - tamano.y, tamano.y / 2, tamano.y * 0.35), Color.WHITE)

func _on_body_entered(body):
	if usado:
		return

	if body is CharacterBody2D and (body.is_in_group("player") or body.name.to_lower() == "player"):
		var respawn = get_node_or_null("/root/Respawn")

		if respawn != null:
			usado = true
			respawn.set_checkpoint(get_point())
			modulate = color_on
		else:
			print("Respwn was not found")
