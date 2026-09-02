extends Node2D

var map_node: Node2D 

var build_mode: bool = false
var build_valid: bool = false 
var build_tile: Vector2i
var build_location: Vector2
var build_type: String 

var current_wave: int = 0
var enemies_in_wave: int = 0

func _ready() -> void:
	map_node = get_node("Map1")
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

func initiate_build_mode(tower_type: String) -> void:
	if build_mode:
		cancel_build_mode()
		
	build_type = tower_type + "T1"
	build_mode = true 
	
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())
	update_tower_preview()

func update_tower_preview() -> void:
	var mouse_position = get_global_mouse_position()
	var current_tile = map_node.get_node("TowerExclusion").local_to_map(mouse_position)
	var title_position = map_node.get_node("TowerExclusion").map_to_local(current_tile)
	
	if map_node.get_node("TowerExclusion").get_cell_source_id(current_tile) == -1:
		get_node("UI").update_tower_preview(title_position, "00FF00")
		build_valid = true 
		build_location = title_position
		build_tile = current_tile
	else:
		get_node("UI").update_tower_preview(title_position, "FF0000")
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
			var tower_scene = load("res://Scenes/Turrets/" + build_type + ".tscn")
			var new_tower = tower_scene.instantiate()
			
			new_tower.global_position = build_location
			new_tower.tower_resource = res
			new_tower.built = true
			
			map_node.get_node("Turrets").add_child(new_tower, true)
			map_node.get_node("TowerExclusion").set_cell(build_tile, 0, Vector2i(0, 0))
			
			cancel_build_mode()

func start_next_wave() -> void:
	var wave_data = retrieve_wave_data()
	await get_tree().create_timer(0.2).timeout
	spawn_enemies(wave_data)

func retrieve_wave_data() -> Array:
	var wave_data = [["blue_tank", 3.0], ["blue_tank", 0.1]]
	current_wave += 1
	enemies_in_wave = wave_data.size()
	return wave_data

func spawn_enemies(wave_data: Array) -> void:
	var path_1 = map_node.get_node("Path1")
	var path_2 = map_node.get_node("Path2")
	var paths = [path_1, path_2]

	for i in wave_data:
		var enemy_type = i[0]
		var res: EnemyResource = GameData.enemy_data.get(enemy_type)
		
		var enemy_scene = load("res://Scenes/Enemies/" + enemy_type + ".tscn")
		var new_enemy = enemy_scene.instantiate()
		
		if "enemy_resource" in new_enemy:
			new_enemy.enemy_resource = res
			
		var chosen_path = paths.pick_random()
		chosen_path.add_child(new_enemy, true)
		
		await get_tree().create_timer(i[1]).timeout
