class_name Turret
extends Node2D

var enemy_array: Array = []
@export var tower_resource: TowerResource

var built: bool = false
var enemy: Node2D = null
var can_fire: bool = true

@onready var turret: Node2D = get_node_or_null("Turret")

func _ready() -> void:
	if built and tower_resource:
		update_range_shape()

func _physics_process(_delta: float) -> void:
	if enemy_array.size() != 0 and built:
		select_enemy()
		turn()
		if can_fire:
			fire()
	else:
		enemy = null

func update_range_shape() -> void:
	if has_node("Range/CollisionShape2D") and tower_resource:
		var range_shape = $Range/CollisionShape2D.shape.duplicate()
		range_shape.radius = 0.5 * tower_resource.range_radius
		$Range/CollisionShape2D.shape = range_shape

func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if built and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var canvas_ui = get_tree().root.get_node_or_null("GameScene/UI")
		var upgrade_panel = null
		
		if canvas_ui:
			upgrade_panel = canvas_ui.get_node_or_null("UpgradePanel")
		
		if upgrade_panel == null:
			upgrade_panel = get_tree().root.find_child("UpgradePanel", true, false)
			
		if upgrade_panel and upgrade_panel.has_method("open_panel"):
			upgrade_panel.open_panel(self)
		else:
			print("ERRO: UpgradePanel não foi encontrado dentro da nó UI do GameScene ou não possui o script 'upgrade_panel.gd' anexado.")

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
	if is_instance_valid(enemy) and tower_resource:
		enemy.on_hit(tower_resource.damage)
	await get_tree().create_timer(tower_resource.rof).timeout
	can_fire = true

func _on_range_body_entered(body: Node2D) -> void:
	var enemy_node = body.get_parent()
	if enemy_node and not enemy_node in enemy_array:
		enemy_array.append(enemy_node)

func _on_range_body_exited(body: Node2D) -> void:
	var enemy_node = body.get_parent()
	if enemy_node in enemy_array:
		enemy_array.erase(enemy_node)
