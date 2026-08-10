extends Node

func _ready():
	get_node("MainMenu/B/M/VB/NewGame").pressed.connect(_on_new_game_pressed)
	get_node("MainMenu/B/M/VB/Quit").pressed.connect(_on_quit_pressed)

func _on_new_game_pressed():
	get_node("MainMenu").queue_free()
	var game_scene = load("res://Scenes/MainScenes/game_scene.tscn").instantiate()
	add_child(game_scene)

func _on_quit_pressed():
	get_tree().quit()
