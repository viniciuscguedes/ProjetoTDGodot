extends Node2D

var enemy_array = []
@export var tower_type: String = "GunT1"
var built = false
var enemy = null

func _ready() -> void:
	if built:
		if GameData.tower_data.has(tower_type):
			var range_shape = $Range/CollisionShape2D.shape.duplicate()
			range_shape.radius = 0.5 * GameData.tower_data[tower_type]["range"]
			$Range/CollisionShape2D.shape = range_shape
		else:
			print("⚠️ Tipo de torre não encontrado no GameData: ", tower_type)

func _physics_process(_delta):
	if enemy_array.size() != 0 and built:
		select_enemy()
		turn()
	else:
		enemy = null
		
func turn():
	if is_instance_valid(enemy):
		get_node("Turret").look_at(enemy.global_position)
	
func select_enemy():
	var enemy_progress_array = []
	
	for i in enemy_array:
		if is_instance_valid(i):
			enemy_progress_array.append(i.progress)
	
	if enemy_progress_array.size() > 0:
		var max_progress = enemy_progress_array.max()
		var enemy_index = enemy_progress_array.find(max_progress)
		enemy = enemy_array[enemy_index]

func _on_range_body_entered(body: Node2D) -> void:
	enemy_array.append(body.get_parent())
	
func _on_range_body_exited(body: Node2D) -> void:
	var enemy_node = body.get_parent()
	if enemy_node in enemy_array:
		enemy_array.erase(enemy_node)
