extends Resource
class_name MapResource

@export var map_name: String = "Mapa 1"
@export var map_scene_path: String = "res://Scenes/Maps/Map1.tscn"
@export var starting_money: int = 100
@export var max_waves: int = 10
@export var wave_reward: int = 50

@export var path_node_names: Array[String] = ["Path1", "Path2"]
