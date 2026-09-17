extends Node2D

@export var map_resource: MapResource
@export var victory_scene_path: String = "res://Scenes/UIScenes/victory_screen.tscn"
@export var defeat_scene_path: String = "res://Scenes/UIScenes/defeat_screen.tscn"

var money: int = 0
var current_wave: int = 0
var enemies_in_wave: int = 0
var active_enemies_count: int = 0

var max_waves: int:
	get:
		return map_resource.max_waves if map_resource else 10

var wave_reward: int:
	get:
		return map_resource.wave_reward if map_resource else 50

var map_node: Node2D 
var build_mode: bool = false
var build_valid: bool = false 
var build_tile: Vector2i
var build_location: Vector2
var build_type: String 

@onready var wave_label: Label = get_node_or_null("UI/HUD/InfoBar/WaveLabel")
@onready var money_label: Label = get_node_or_null("UI/HUD/InfoBar/Money")

func _ready() -> void:
	if map_resource:
		money = map_resource.starting_money
	else:
		money = 100
	
	map_node = get_node_or_null("Map1")

	if not money_label:
		money_label = find_child("Money", true, false)
		
	_update_money_ui()
	_update_wave_ui()
	_setup_tower_button_costs()
	
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.pressed.connect(initiate_build_mode.bind(i.name))

func _process(_delta: float) -> void:
	if build_mode:
		update_tower_preview()

func _unhandled_input(event: InputEvent) -> void:
	if build_mode:
		if event.is_action_released("ui_cancel") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed):
			cancel_build_mode()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			verify_and_build()

func _setup_tower_button_costs() -> void:
	var build_bar = get_node_or_null("UI/HUD/BuildBar")
	if not build_bar:
		return

	for button in build_bar.get_children():
		var tower_key = button.name + "T1"
		var res: TowerResource = GameData.tower_data.get(tower_key)
		
		if res:
			var cost_label = button.get_node_or_null("Label")
			if cost_label:
				var cost_value = res.cost if "cost" in res else 100
				cost_label.text = "$" + str(cost_value)

func initiate_build_mode(tower_type: String) -> void:
	if build_mode:
		cancel_build_mode()
		
	build_type = tower_type + "T1"
	build_mode = true 
	
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())
	update_tower_preview()

func update_tower_preview() -> void:
	if not map_node:
		return
		
	var exclusion_layer: TileMapLayer = map_node.get_node_or_null("TowerExclusion")
	
	if not exclusion_layer:
		print("ERRO: Camada 'TowerExclusion' não encontrada no Map!")
		return

	var mouse_global_pos = get_global_mouse_position()
	var mouse_local_pos = exclusion_layer.to_local(mouse_global_pos)
	
	build_tile = exclusion_layer.local_to_map(mouse_local_pos)
	
	var snapped_local_pos = exclusion_layer.map_to_local(build_tile)
	build_location = exclusion_layer.to_global(snapped_local_pos)

	var cell_id = exclusion_layer.get_cell_source_id(build_tile)
	
	if cell_id == -1:
		get_node("UI").update_tower_preview(build_location, "00FF00")
		build_valid = true 
	else:
		get_node("UI").update_tower_preview(build_location, "FF0000")
		build_valid = false

func cancel_build_mode() -> void:
	build_mode = false 
	build_valid = false 
	
	var preview = get_node_or_null("UI/HUD/TowerPreview") 
	if preview == null:
		preview = get_node_or_null("UI/TowerPreview")
		
	if preview:
		preview.queue_free()

func verify_and_build() -> void:
	if build_valid:
		var res: TowerResource = GameData.tower_data.get(build_type)
		if res:
			var tower_cost = res.cost if "cost" in res else 100
			
			if spend_money(tower_cost):
				var tower_scene = load("res://Scenes/Turrets/" + build_type + ".tscn")
				var new_tower = tower_scene.instantiate()
				
				new_tower.global_position = build_location
				new_tower.tower_resource = res
				new_tower.built = true
				
				map_node.get_node("Turrets").add_child(new_tower, true)
				map_node.get_node("TowerExclusion").set_cell(build_tile, 0, Vector2i(0, 0))
				
				cancel_build_mode()
			else:
				print("Dinheiro insuficiente!")

func add_money(amount: int) -> void:
	money += amount
	_update_money_ui()

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		_update_money_ui()
		return true
	return false

func upgrade_tower(tower_node: Node, upgrade_cost: int, new_resource: TowerResource) -> void:
	if upgrade_cost == 0 or spend_money(upgrade_cost):
		tower_node.tower_resource = new_resource

func sell_tower(tower_node: Node, sell_price: int, tile_position: Vector2i) -> void:
	add_money(sell_price)
	map_node.get_node("TowerExclusion").erase_cell(tile_position)
	tower_node.queue_free()

func _update_money_ui() -> void:
	if not money_label:
		money_label = find_child("Money", true, false)
		
	if money_label:
		money_label.text = str(money)

# --- SISTEMA DE ONDAS (WAVES) ---

func start_next_wave() -> void:
	if current_wave == 0:
		current_wave = 1

	if current_wave > max_waves:
		_game_won()
		return

	_update_wave_ui()
	var wave_data = retrieve_wave_data()
	await spawn_enemies(wave_data)

func retrieve_wave_data() -> Array:
	var wave_data = []
	var active_wave = max(1, current_wave)
	var enemy_count = 1 + (active_wave * 2)
	
	for i in range(enemy_count):
		var spawn_delay = randf_range(0.8, 1.5)
		wave_data.append(["blue_tank", spawn_delay])
		
	enemies_in_wave = wave_data.size()
	active_enemies_count = 0
	return wave_data

func spawn_enemies(wave_data: Array) -> void:
	var paths = []
	
	if map_resource and map_resource.path_node_names.size() > 0:
		for path_name in map_resource.path_node_names:
			var p = map_node.get_node_or_null(path_name)
			if p:
				paths.append(p)
	else:
		var p1 = map_node.get_node_or_null("Path1")
		var p2 = map_node.get_node_or_null("Path2")
		if p1: paths.append(p1)
		if p2: paths.append(p2)

	for i in wave_data:
		var enemy_type = i[0]
		var res: EnemyResource = GameData.enemy_data.get(enemy_type)
		
		var enemy_scene = load("res://Scenes/Enemies/" + enemy_type + ".tscn")
		var new_enemy = enemy_scene.instantiate()
		
		if "enemy_resource" in new_enemy:
			new_enemy.enemy_resource = res
			
		active_enemies_count += 1
			
		if paths.size() > 0:
			var chosen_path = paths.pick_random()
			chosen_path.add_child(new_enemy, true)
		else:
			map_node.add_child(new_enemy, true)
		
		await get_tree().create_timer(i[1]).timeout

func on_enemy_removed() -> void:
	active_enemies_count -= 1
	
	if active_enemies_count <= 0:
		print("Wave ", current_wave, " concluída!")
		add_money(wave_reward)
		
		current_wave += 1
		_update_wave_ui()
		
		if current_wave > max_waves:
			_game_won()
		else:
			get_tree().paused = true

func _update_wave_ui() -> void:
	if not wave_label:
		wave_label = find_child("NumberWave", true, false)
		
	if wave_label:
		var wave_display = max(1, current_wave)
		wave_label.text = str(wave_display)

func _game_won() -> void:
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file(victory_scene_path)
	
func _game_over() -> void:
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file(defeat_scene_path)
