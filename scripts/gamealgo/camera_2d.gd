extends Camera2D

@export var speed: float = 300.0
@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0

var dragging := false
var last_mouse_pos: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	var v := Vector2(
		int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left")),
		int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	)
	if v != Vector2.ZERO:
		position += v.normalized() * speed * delta

func _input(event: InputEvent) -> void:
	# Zoom
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_zoom(zoom.x * (1.0 + zoom_step))
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_zoom(zoom.x * (1.0 - zoom_step))
			get_viewport().set_input_as_handled()

		# Bắt đầu kéo bằng chuột giữa
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			dragging = true
			last_mouse_pos = get_viewport().get_mouse_position()
			get_viewport().set_input_as_handled()

	# Nhả chuột giữa
	if event is InputEventMouseButton and (not event.pressed) and event.button_index == MOUSE_BUTTON_MIDDLE:
		dragging = false
		get_viewport().set_input_as_handled()

	# Kéo khi giữ chuột giữa
	if event is InputEventMouseMotion and dragging:
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		var delta_pos: Vector2 = (last_mouse_pos - mouse_pos) / max(0.0001, zoom.x)
		position += delta_pos
		last_mouse_pos = mouse_pos
		get_viewport().set_input_as_handled()

func _set_zoom(z: float) -> void:
	z = clamp(z, min_zoom, max_zoom)
	zoom = Vector2(z, z)
