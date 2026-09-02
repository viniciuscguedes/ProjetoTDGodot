extends Node

var tower_data: Dictionary = {}
var enemy_data: Dictionary = {}

func _ready() -> void:
	tower_data = {
		"GunT1": load_resource("res://Resources/Data/Towers/GunT1.tres"),
		"MissileT1": load_resource("res://Resources/Data/Towers/MissileT1.tres")
	}
	
	enemy_data = {
		"blue_tank": load_resource("res://Resources/Data/Enemies/BlueTank.tres")
	}

func load_resource(path: String) -> Resource:
	if ResourceLoader.exists(path):
		return load(path)
	push_warning("Recurso não encontrado no caminho: " + path)
	return null
