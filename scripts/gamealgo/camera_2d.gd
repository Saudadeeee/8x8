extends Camera2D

@export var speed: float = 300.0
@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0

var dragging: bool = false
var last_mouse_pos: Vector2

func _process(delta: float) -> void:
	# Di chuyển bằng WASD
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1

	if input_vector != Vector2.ZERO:
		position += input_vector.normalized() * speed * delta

func _unhandled_input(event: InputEvent) -> void:
	# Zoom bằng con lăn chuột
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom += Vector2(zoom_step, zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom -= Vector2(zoom_step, zoom_step)

		# Giới hạn zoom
		zoom.x = clamp(zoom.x, min_zoom, max_zoom)
		zoom.y = clamp(zoom.y, min_zoom, max_zoom)

		# Kéo bằng chuột giữa
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				dragging = true
				last_mouse_pos = get_viewport().get_mouse_position()
			else:
				dragging = false

	# Kéo camera khi giữ chuột giữa (đã fix tốc độ)
	if event is InputEventMouseMotion and dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		var delta_pos = (last_mouse_pos - mouse_pos) * (1.0 / zoom.x)
		position += delta_pos
		last_mouse_pos = mouse_pos
