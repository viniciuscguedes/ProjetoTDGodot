extends Node2D

@export var max_health: int = 200
var current_health: int

var health_bar: TextureProgressBar = null

func _ready() -> void:
	current_health = max_health
	
	health_bar = get_tree().root.find_child("HealthBar", true, false) as TextureProgressBar
	
	if health_bar:
		_update_ui()

func take_damage(amount: int) -> void:
	current_health -= amount
	current_health = max(current_health, 0)
	_update_ui()
	
	if current_health <= 0:
		game_over()

func _update_ui() -> void:
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health

func game_over() -> void:
	get_tree().change_scene_to_file("res://Scenes/UIScenes/main_menu.tscn")

func _on_base_end_area_body_entered(body: Node2D) -> void:
	_handle_enemy_damage(body)

func _on_base_end_area_area_entered(area: Area2D) -> void:
	_handle_enemy_damage(area)

func _handle_enemy_damage(incoming_node: Node) -> void:
	var enemy_resource: EnemyResource = null
	var node_to_free: Node = incoming_node

	if "enemy_resource" in incoming_node and incoming_node.enemy_resource:
		enemy_resource = incoming_node.enemy_resource
	elif incoming_node.get_parent() and "enemy_resource" in incoming_node.get_parent():
		enemy_resource = incoming_node.get_parent().enemy_resource
		node_to_free = incoming_node.get_parent()

	if enemy_resource:
		print("Dano aplicado: ", enemy_resource.base_dmg)
		take_damage(enemy_resource.base_dmg)
		node_to_free.queue_free()
