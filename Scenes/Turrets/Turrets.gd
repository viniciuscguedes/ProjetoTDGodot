extends Node2D

var enemy_array = []
@export var tower_type: String = "GunT1"
var built = false
var enemy = null
var can_fire = true
var category: String

@onready var turret: Node2D = get_node_or_null("Turret")

func _ready() -> void:
	if built:
		if GameData.tower_data.has(tower_type):
			category = GameData.tower_data[tower_type].get("category", "")
			
			if has_node("Range/CollisionShape2D"):
				var range_shape = $Range/CollisionShape2D.shape.duplicate()
				range_shape.radius = 0.5 * GameData.tower_data[tower_type]["range"]
				$Range/CollisionShape2D.shape = range_shape

func _physics_process(_delta: float) -> void:
	if enemy_array.size() != 0 and built:
		select_enemy()
		turn()
		if can_fire:
			fire()
	else:
		enemy = null

func turn() -> void:
	if is_instance_valid(enemy) and turret:
		turret.look_at(enemy.global_position)

func select_enemy() -> void:
	var enemy_progress_array = []
	
	for i in enemy_array:
		if is_instance_valid(i):
			enemy_progress_array.append(i.progress)
	
	if enemy_progress_array.size() > 0:
		var max_progress = enemy_progress_array.max()
		var enemy_index = enemy_progress_array.find(max_progress)
		enemy = enemy_array[enemy_index]

func fire() -> void:
	can_fire = false
	
	if is_instance_valid(enemy):
		enemy.on_hit(GameData.tower_data[tower_type]["damage"])
		
	await get_tree().create_timer(GameData.tower_data[tower_type]["rof"]).timeout
	can_fire = true

func _on_range_body_entered(body: Node2D) -> void:
	var enemy_node = body.get_parent()
	if enemy_node and not enemy_node in enemy_array:
		enemy_array.append(enemy_node)

func _on_range_body_exited(body: Node2D) -> void:
	var enemy_node = body.get_parent()
	if enemy_node in enemy_array:
		enemy_array.erase(enemy_node)
