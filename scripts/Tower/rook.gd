extends StaticBody2D

@export var bullet_scene: PackedScene
@export var bullet_damage := 10
@export var fire_cooldown := 2  
@onready var detection: Area2D = $"Tower"
@onready var aim: Node2D = $"Aim"
@onready var bullet_container: Node = $"BulletContainer"

var cooldown := 0.0

func _physics_process(delta: float) -> void:
	cooldown -= delta
	if cooldown <= 0.0:
		var target := _pick_best_target()
		if target:
			_shoot(target)
			cooldown = fire_cooldown

func _pick_best_target() -> Node2D:
	var bodies := detection.get_overlapping_bodies()
	var best_enemy: Node2D
	var best_pf: PathFollow2D
	var best_prog := -INF

	for b in bodies:
		if not (b is Node2D):
			continue
		if not (b.is_in_group("enemy") or b.name.contains("Solder")):
			continue
		var pf := _find_pf(b)
		if pf and pf.progress > best_prog:
			best_prog = pf.progress
			best_enemy = b
			best_pf = pf

	return best_enemy

func _shoot(target: Node2D) -> void:
	if bullet_scene == null or aim == null or bullet_container == null:
		return
	var bullet = bullet_scene.instantiate()
	bullet.global_position = aim.global_position
	bullet.target = target
	bullet.bulletDamage = bullet_damage
	bullet_container.add_child(bullet)

func _find_pf(n: Node) -> PathFollow2D:
	var p := n
	while p:
		if p is PathFollow2D:
			return p
		p = p.get_parent()
	return null
