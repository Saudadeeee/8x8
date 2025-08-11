extends Panel

@export var tower_scene: PackedScene
@export var board_layer: int = 1                       # layer bàn cờ
@export var subtiles_per_cell: int = 2                 # 1 ô logic = n×n ô con (2 nếu 2×2)
@export var origin_is_center: bool = false             # true nếu TileMap → Rendering → Tile Origin = Center
@export var snap_pivot_path: NodePath = ^"SnapPivot"   # Node2D trong tower đặt ở “bàn chân”
@export var place_offset: Vector2 = Vector2.ZERO
@export var snap_to_pixel: bool = true

@onready var board: TileMap = get_tree().get_root().get_node_or_null("Main/Board")
@onready var towers_parent: Node = get_tree().get_root().get_node_or_null("Main/Tower")

var dragging := false
var ghost: Node2D
var hover_cell: Vector2i = Vector2i.ZERO              # ô LOGIC
var can_place := false
var occupied: Dictionary = {}                         # { Vector2i : Node }

func _ready() -> void:
	if board == null: push_error("Pawnpanel: Không tìm thấy Main/Board")
	if towers_parent == null: push_error("Pawnpanel: Không tìm thấy Main/Tower")
	if subtiles_per_cell < 1: subtiles_per_cell = 1

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_start_drag()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_finish_drag()
	elif event is InputEventMouseMotion and dragging:
		_update_ghost()

func _start_drag() -> void:
	if ghost != null or towers_parent == null: return
	ghost = tower_scene.instantiate()
	ghost.process_mode = Node.PROCESS_MODE_DISABLED
	if ghost.has_node("Area"): ghost.get_node("Area").visible = true
	towers_parent.add_child(ghost)
	dragging = true
	_update_ghost()

func _finish_drag() -> void:
	if not dragging: return
	dragging = false
	if ghost != null and can_place:
		ghost.process_mode = Node.PROCESS_MODE_INHERIT
		if ghost.has_node("Area"): ghost.get_node("Area").visible = false
		occupied[hover_cell] = ghost
		ghost = null
	elif ghost != null:
		ghost.queue_free()
		ghost = null

func _update_ghost() -> void:
	if ghost == null or board == null: return

	# 1) Ô CON dưới chuột
	var mouse_world: Vector2 = ghost.get_global_mouse_position()
	var small_cell: Vector2i = board.local_to_map(board.to_local(mouse_world))

	# 2) Quy về Ô LOGIC bằng floor-division (an toàn khi toạ độ âm)
	var n := subtiles_per_cell
	var big_cell := _to_big_cell(small_cell, n)
	hover_cell = big_cell

	# 3) Snap: đặt pivot của tower đúng TÂM ô logic (độc lập Tile Origin)
	ghost.global_position = _big_cell_center_world(big_cell) - _pivot_local_offset()

	# 4) Hợp lệ: trong used rect, đủ tile ở layer và chưa bị chiếm
	var in_used := _big_cell_in_used(big_cell)
	var has_tiles := _big_cell_has_all_tiles(big_cell)
	var free := not occupied.has(big_cell)
	can_place = in_used and has_tiles and free

	# 5) Màu preview
	ghost.modulate = Color(1,1,1,1) if can_place else Color(1,0.5,0.5,0.6)
	if ghost.has_node("Area"):
		var area := ghost.get_node("Area")
		if area is CanvasItem:
			(area as CanvasItem).modulate = Color(1,1,1,0.25) if can_place else Color(1,0,0,0.25)

# ===== Helpers =====

# floor-division cho Vector2i
func _floor_div_i(a: int, n: int) -> int:
	return int(floor(a / float(n)))

func _to_big_cell(small: Vector2i, n: int) -> Vector2i:
	return Vector2i(_floor_div_i(small.x, n), _floor_div_i(small.y, n))

# Tâm ô LOGIC:
# center = base + 0.5*(step_nx + step_ny)  [Top-Left]
# center = base + 0.5*(step_nx + step_ny) - 0.5*(step_1x + step_1y)  [Center]
func _big_cell_center_world(big: Vector2i) -> Vector2:
	var n := subtiles_per_cell
	var tl_small := big * n

	var base: Vector2 = board.map_to_local(tl_small)                 # tuỳ origin: góc TL hoặc tâm ô con
	var step_nx: Vector2 = board.map_to_local(tl_small + Vector2i(n, 0)) - base
	var step_ny: Vector2 = board.map_to_local(tl_small + Vector2i(0, n)) - base
	var center_local: Vector2 = base + 0.5 * (step_nx + step_ny)

	if origin_is_center:
		var step_1x := step_nx / float(n)
		var step_1y := step_ny / float(n)
		center_local -= 0.5 * (step_1x + step_1y)  # bù nửa ô con theo cả hai trục

	var world: Vector2 = board.to_global(center_local) + place_offset
	return world.round() if snap_to_pixel else world

# Offset LOCAL từ origin ghost đến pivot (Node2D con)
func _pivot_local_offset() -> Vector2:
	if snap_pivot_path.is_empty(): return Vector2.ZERO
	var p := ghost.get_node_or_null(snap_pivot_path)
	return (p as Node2D).position if p is Node2D else Vector2.ZERO

# Phạm vi/đầy đủ tile
func _big_cell_in_used(big: Vector2i) -> bool:
	var n := subtiles_per_cell
	var tl_small := big * n
	return board.get_used_rect().has_point(tl_small)

func _big_cell_has_all_tiles(big: Vector2i) -> bool:
	var n := subtiles_per_cell
	var base := big * n
	for y in range(n):
		for x in range(n):
			var id: int = board.get_cell_source_id(board_layer, base + Vector2i(x, y))
			if id == -1:
				return false
	return true
