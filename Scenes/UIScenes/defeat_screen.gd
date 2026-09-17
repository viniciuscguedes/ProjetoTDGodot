extends Control

@export var game_scene_path: String = "res://Scenes/MainScenes/game_scene.tscn"
@export var main_menu_path: String = "res://Scenes/UIScenes/main_menu.tscn"

func _ready() -> void:
	var restart_button: Button = find_child("RestartButton", true, false) as Button
	if not restart_button:
		restart_button = find_child("*Jogar*", true, false) as Button

	var exit_button: Button = find_child("ExitButton", true, false) as Button
	if not exit_button:
		exit_button = find_child("*Sair*", true, false) as Button

	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)

func _on_restart_pressed() -> void:
	if ResourceLoader.exists(game_scene_path):
		get_tree().change_scene_to_file(game_scene_path)
	else:
		print("ERRO: O caminho da cena não foi encontrado: ", game_scene_path)

func _on_exit_pressed() -> void:
	if ResourceLoader.exists(main_menu_path):
		get_tree().change_scene_to_file(main_menu_path)
	else:
		print("ERRO: O caminho do menu não foi encontrado: ", main_menu_path)
