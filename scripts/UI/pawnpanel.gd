extends Panel

@export var tower_scene: PackedScene
@export var board_layer: int = 1                  # layer chứa bàn cờ (0-based)
@export var place_offset: Vector2 = Vector2.ZERO  # tinh chỉnh thêm (vd (0,1))
@export var snap_to_pixel: bool = true            # làm tròn về pixel cho pixel-art

@onready var board: TileMap = get_tree().get_root().get_node_or_null("Main/Board")
@onready var towers_parent: Node = get_tree().get_root().get_node_or_null("Main/Tower")

var dragging: bool = false
var ghost: Node2D = null
var hover_cell: Vector2i = Vector2i.ZERO
var can_place: bool = false
var occupied: Dictionary = {}                     # { Vector2i : Node }

func _ready() -> void:
	if board == null:
		push_error("Pawnpanel: Không tìm thấy Main/Board")
	if towers_parent == null:
		push_error("Pawnpanel: Không tìm thấy Main/Tower")

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_start_drag()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_finish_drag()
	elif event is InputEventMouseMotion and dragging:
		_update_ghost()

func _start_drag() -> void:
	if ghost != null or towers_parent == null:
		return
	ghost = tower_scene.instantiate()
	ghost.process_mode = Node.PROCESS_MODE_DISABLED
	if ghost.has_node("Area"):
		ghost.get_node("Area").visible = true
	towers_parent.add_child(ghost)
	dragging = true
	_update_ghost()

func _finish_drag() -> void:
	if not dragging:
		return
	dragging = false

	if ghost != null and can_place:
		ghost.process_mode = Node.PROCESS_MODE_INHERIT
		if ghost.has_node("Area"):
			ghost.get_node("Area").visible = false
		occupied[hover_cell] = ghost
		ghost = null
	elif ghost != null:
		ghost.queue_free()
		ghost = null

func _update_ghost() -> void:
	if ghost == null or board == null:
		return

	# 1) Ô dưới chuột
	var mouse_world: Vector2 = ghost.get_global_mouse_position()
	var cell: Vector2i = board.local_to_map(board.to_local(mouse_world))
	hover_cell = cell

	# 2) Snap vào TÂM ô (độc lập Tile Origin)
	ghost.global_position = _cell_center_world(cell)

	# 3) Chỉ cho đặt nếu: trong used rect, layer này có tile, và ô chưa bị chiếm
	var in_used: bool = board.get_used_rect().has_point(cell)
	var src_id: int = board.get_cell_source_id(board_layer, cell)
	var has_tile: bool = (src_id != -1)
	var free: bool = not occupied.has(cell)
	can_place = in_used and has_tile and free

	# 4) Màu preview
	ghost.modulate = Color(1, 1, 1, 1) if can_place else Color(1, 0.5, 0.5, 0.6)
	if ghost.has_node("Area"):
		var area := ghost.get_node("Area")
		if area is CanvasItem:
			(area as CanvasItem).modulate = Color(1, 1, 1, 0.25) if can_place else Color(1, 0, 0, 0.25)

# ---- Tính tâm ô bền vững: trung điểm giữa cell và cell+(1,1) ----
func _cell_center_world(cell: Vector2i) -> Vector2:
	var p0: Vector2 = board.map_to_local(cell)
	var p1: Vector2 = board.map_to_local(cell + Vector2i.ONE)
	var center_local: Vector2 = (p0 + p1) * 0.5
	var world: Vector2 = board.to_global(center_local) + place_offset
	return world.round() if snap_to_pixel else world
