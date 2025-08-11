@tool
extends Path2D

@export var color: Color = Color(0.6, 1.0, 0.6, 0.25) # vàng nhạt, mờ
@export var width: float = 2.0
@export var closed: bool = false    # nối kín hay không
@export var show_in_game := true
@export var show_in_editor := true

var line: Line2D

func _ready() -> void:
	# luôn ở trên cùng các tile
	z_index = 1000
	z_as_relative = false
	
	# tạo Line2D để hiển thị
	line = Line2D.new()
	line.width = width
	line.default_color = color
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	add_child(line)

	_rebuild()
	if curve:
		curve.changed.connect(_rebuild)  # tự cập nhật khi chỉnh path

func _process(_dt: float) -> void:
	if (Engine.is_editor_hint() and show_in_editor) or (not Engine.is_editor_hint() and show_in_game):
		# cập nhật khi di chuyển Path2D trong editor/game
		_rebuild()

func _rebuild() -> void:
	if curve == null or line == null:
		return
	var pts := curve.get_baked_points()
	line.points = pts
	line.width = width
	line.default_color = color
	line.visible = (Engine.is_editor_hint() and show_in_editor) or (not Engine.is_editor_hint() and show_in_game)
