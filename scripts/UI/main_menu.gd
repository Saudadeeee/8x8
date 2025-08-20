extends Control

@export var game_scene_path: String = "res://scenes/main.tscn"

func _ready() -> void:
	if has_node("%StartButton"):
		%StartButton.grab_focus()

# --- Handlers CHUẨN (CamelCase) ---
func _on_StartButton_pressed() -> void:
	if game_scene_path != "" and ResourceLoader.exists(game_scene_path):
		get_tree().change_scene_to_file(game_scene_path)
	else:
		push_warning("game_scene_path không hợp lệ: %s" % game_scene_path)

func _on_QuitButton_pressed() -> void:
	get_tree().quit()

func _on_SettingsButton_pressed() -> void:
	# Sẽ làm sau
	pass

# --- Handlers DỰ PHÒNG (snake_case) nếu lỡ connect nhầm ---
func _on_start_button_pressed() -> void:
	_on_StartButton_pressed()

func _on_quit_button_pressed() -> void:
	_on_QuitButton_pressed()

func _on_setting_button_pressed() -> void:
	_on_SettingsButton_pressed()
