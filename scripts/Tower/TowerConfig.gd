# res://scripts/TowerConfig.gd
extends Resource
class_name TowerConfig

# (có ít nhất 1 export để Inspector hiện field)
@export var display_name: StringName = &"Pawn"
@export var bullet_scene: PackedScene
@export var damage: int = 5
@export var fire_cooldown: float = 1.0
@export var range_px: float = 96

enum Targeting { FURTHEST, NEAREST, FIRST_SEEN }
@export var targeting: Targeting = Targeting.FURTHEST
