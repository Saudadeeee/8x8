extends Panel

@onready var tower= preload("res://scenes/tower/pawn.tscn")
var currTile


func _on_gui_input(event):
	var tempTower=tower.instantiate()
	print(event)
