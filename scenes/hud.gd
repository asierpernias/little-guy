extends CanvasLayer

signal time_up
signal cookies_changed(total: int)

@export_group("Timer")
@export var duration: float = 60.0
@export var autostart: bool = true
@export var pause_during_respawn: bool = true

@export_group("Cookies")
@export var cookie_text: String = "Cookies: %d"
@export var cookie_font_size: int = 24
@export var cookie_color: Color = Color(1.0, 0.8, 0.4)

@export_group("Appearance")
@export var font: Font
@export var font_size: int = 32
@export var normal_color: Color = Color.WHITE
@export var warning_color: Color = Color(1.0, 0.3, 0.3)
@export var warning_time: float = 10.0
@export var outline_size: int = 0
@export var outline_color: Color = Color.BLACK

@export_group("Position")
@export var margin_top: float = 12.0
@export var margin_right: float = 16.0

var time_left: float = 0.0
var running: bool = false
var finished: bool = false
var respawn_paused: bool = false
var cookies: int = 0

var container: VBoxContainer
var timer_label: Label
var cookie_label: Label


func _ready() -> void:
	layer = 10
	add_to_group("hud")

	container = VBoxContainer.new()
	add_child(container)

	timer_label = create_label(font_size, normal_color)
	cookie_label = create_label(cookie_font_size, cookie_color)

	container.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	container.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	container.offset_right = -margin_right
	container.offset_left = -margin_right
	container.offset_top = margin_top

	time_left = duration
	update_timer_label()
	update_cookie_label()

	if pause_during_respawn:
		var respawn_manager = get_node_or_null("/root/Respawn")
		if respawn_manager != null:
			respawn_manager.respawn_started.connect(_on_respawn_started)
			respawn_manager.respawn_finished.connect(_on_respawn_finished)

	if autostart:
		start()


func create_label(size: int, color: Color) -> Label:
	var new_label: Label = Label.new()
	new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if font != null:
		new_label.add_theme_font_override("font", font)
	new_label.add_theme_font_size_override("font_size", size)
	new_label.add_theme_color_override("font_color", color)
	new_label.add_theme_constant_override("outline_size", outline_size)
	new_label.add_theme_color_override("font_outline_color", outline_color)
	container.add_child(new_label)
	return new_label


func _process(delta: float) -> void:
	if not running or respawn_paused:
		return

	time_left -= delta

	if time_left <= 0.0:
		time_left = 0.0
		running = false
		finished = true
		update_timer_label()
		print("HUD timer finished")
		time_up.emit()
		return

	update_timer_label()


func start() -> void:
	if finished:
		return
	running = true


func pause() -> void:
	running = false


func resume() -> void:
	if not finished:
		running = true


func reset(new_duration: float = -1.0) -> void:
	if new_duration > 0.0:
		duration = new_duration
	time_left = duration
	finished = false
	running = true
	update_timer_label()


func add_time(seconds: float) -> void:
	time_left = max(time_left + seconds, 0.0)
	update_timer_label()


func add_cookie(amount: int = 1) -> void:
	cookies += amount
	update_cookie_label()
	cookies_changed.emit(cookies)


func reset_cookies() -> void:
	cookies = 0
	update_cookie_label()
	cookies_changed.emit(cookies)


func update_timer_label() -> void:
	var total_seconds: int = int(ceil(time_left))
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

	var is_warning: bool = time_left <= warning_time
	timer_label.add_theme_color_override("font_color", warning_color if is_warning else normal_color)


func update_cookie_label() -> void:
	cookie_label.text = cookie_text % cookies


func _on_respawn_started() -> void:
	respawn_paused = true


func _on_respawn_finished() -> void:
	respawn_paused = false
