extends PathFollow2D

@export var enemy_resource: EnemyResource

var current_hp: int
var speed: float

@onready var health_bar: TextureProgressBar = $HealthBar

func _ready() -> void:
	if enemy_resource:
		current_hp = enemy_resource.hp
		speed = enemy_resource.speed
		
		health_bar.max_value = current_hp
		health_bar.value = current_hp
		health_bar.top_level = true

func _physics_process(delta: float) -> void:
	move(delta)

func move(delta: float) -> void:
	progress += speed * delta
	
	if is_instance_valid(health_bar):
		health_bar.position = position - Vector2(30, 30)

	var path_node = get_parent() as Path2D
	var path_length = path_node.curve.get_baked_length() if path_node and path_node.curve else 0.0

	if progress_ratio >= 0.99 or (path_length > 0 and progress >= path_length):
		_reach_base()

func _notify_enemy_removed() -> void:
	var game_scene = get_tree().current_scene
	
	if game_scene and game_scene.has_method("on_enemy_removed"):
		game_scene.on_enemy_removed()
	else:
		var found_node = get_tree().root.find_child("GameScene", true, false)
		if found_node and found_node.has_method("on_enemy_removed"):
			found_node.on_enemy_removed()

func _reach_base() -> void:
	var map = get_tree().current_scene.find_child("Map1", true, false)
	if not map:
		map = get_tree().current_scene

	if map and map.has_method("take_damage") and enemy_resource:
		map.take_damage(enemy_resource.base_dmg)

	_notify_enemy_removed()

	if is_instance_valid(health_bar):
		health_bar.queue_free()
	queue_free()

func on_hit(damage: int) -> void:
	current_hp -= damage
	if is_instance_valid(health_bar):
		health_bar.value = current_hp
	if current_hp <= 0:
		on_destroy()

func on_destroy() -> void:
	var game_scene = get_tree().current_scene
	
	if not game_scene or not game_scene.has_method("add_money"):
		game_scene = get_tree().root.find_child("GameScene", true, false)
	
	if not game_scene or not game_scene.has_method("add_money"):
		game_scene = get_node_or_null("/root/GameScene")

	if game_scene and game_scene.has_method("add_money"):
		var reward_amount: int = 15
		
		if enemy_resource:
			if "gold_reward" in enemy_resource:
				reward_amount = enemy_resource.gold_reward		
		game_scene.add_money(reward_amount)

	_notify_enemy_removed()
	if is_instance_valid(health_bar):
		health_bar.queue_free()
	queue_free()
