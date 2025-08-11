extends CharacterBody2D

@export var speed =100
var health=10


func _physics_process(delta):
	get_parent().set_progress(get_parent().get_progress() + speed*delta)
	
	if get_parent().get_progress_ratio() == 1:
		death()
		
	if health <= 0:
		death()
	
func death():
	get_parent().get_parent().queue_free()
