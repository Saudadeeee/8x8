extends CharacterBody2D

@export var Speed := 500
var target: Node2D
var bulletDamage := 5

func _physics_process(_delta):
	if not is_instance_valid(target):
		queue_free()
		return

	var target_pos := target.global_position
	var dir := target_pos - global_position
	if dir.length() == 0:
		queue_free()
		return

	velocity = dir.normalized() * Speed
	look_at(target_pos)
	rotation += deg_to_rad(90) # bù 90° nếu sprite chỉ lên
	move_and_slide()

func _on_area_2d_body_entered(body):
	# Khuyến nghị: cho enemy vào group "enemy"
	if (body.has_method("is_in_group") and body.is_in_group("enemy")) or (body is Node2D and body.name.contains("Solder")):
		# Giả định enemy có biến 'health'
		body.health -= bulletDamage
		queue_free()
