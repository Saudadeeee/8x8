extends CharacterBody2D

@export var speed: float = 500.0
@export var hit_radius: float = 10.0     # bán kính coi như đã chạm mục tiêu
@export var lifetime: float = 5.0        # để đạn không sống vô hạn

var target: Node2D
var bulletDamage: int = 5

var last_target_pos: Vector2
var life := 0.0

func _ready() -> void:
	if is_instance_valid(target):
		last_target_pos = target.global_position
	else:
		last_target_pos = global_position

func _physics_process(delta: float) -> void:
	life += delta
	if life > lifetime:
		queue_free()
		return

	# nếu target còn, cập nhật vị trí bám theo
	if is_instance_valid(target):
		last_target_pos = target.global_position

	var dir := last_target_pos - global_position
	if dir.length() <= hit_radius:
		_hit_or_retire()
		return

	velocity = dir.normalized() * speed
	look_at(last_target_pos)
	rotation += deg_to_rad(90) # nếu sprite mặc định hướng lên
	move_and_slide()

func _hit_or_retire() -> void:
	# Ưu tiên trúng chính target nếu còn tồn tại
	if is_instance_valid(target) and _is_enemy(target):
		_deal_damage(target)
		queue_free()
		return

	# Nếu target mất, thử "bắt" enemy gần điểm nổ
	var e := _find_enemy_near(last_target_pos, hit_radius)
	if e:
		_deal_damage(e)
	queue_free()

func _deal_damage(body: Object) -> void:
	if body.has_method("apply_damage"):
		body.apply_damage(bulletDamage)
		return
	# fallback: giảm trực tiếp thuộc tính 'health' nếu có
	var hp = body.get("health")
	if typeof(hp) != TYPE_NIL:
		body.set("health", hp - bulletDamage)

func _is_enemy(n: Object) -> bool:
	return n is Node2D and (n.is_in_group("enemy") or (n as Node).name.contains("Solder"))

func _find_enemy_near(p: Vector2, radius: float) -> Node2D:
	var best: Node2D
	var best_d := radius
	for e in get_tree().get_nodes_in_group("enemy"):
		if e is Node2D:
			var d = (e.global_position - p).length()
			if d < best_d:
				best_d = d
				best = e
	return best

func _on_area_2d_body_entered(body: Node) -> void:
	if _is_enemy(body):
		_deal_damage(body)
		queue_free()
