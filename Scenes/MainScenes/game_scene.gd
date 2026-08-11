extends Node2D

var map_node 

var build_mode = false
var build_valid = false 
var build_tile
var build_location
var build_type 

func _ready():
	map_node = get_node("Map1")
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.pressed.connect(initiate_build_mode.bind(i.name))
	
func _process(_delta):
	if build_mode:
		update_tower_preview()
	
func _unhandled_input(event):
	if build_mode:
		if event.is_action_released("ui_cancel") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed == false):
			cancel_build_mode()
			
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:
			verify_and_build()
	
func initiate_build_mode(tower_type):
	if build_mode:
		cancel_build_mode()
		
	build_type = tower_type + "T1"
	build_mode = true 
	
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())
	
	update_tower_preview()

func update_tower_preview():
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

func cancel_build_mode():
	build_mode = false 
	build_valid = false 
	
	var preview = get_node_or_null("UI/HUD/TowerPreview") 
	if preview == null:
		preview = get_node_or_null("UI/TowerPreview")
		
	if preview:
		preview.queue_free()
	
func verify_and_build():
	if build_valid:
		var new_tower = load("res://Scenes/Turrets/" + build_type + ".tscn").instantiate()
		new_tower.position = build_location
		map_node.get_node("Turrets").add_child(new_tower, true)
		

		map_node.get_node("TowerExclusion").set_cell(build_tile, 0, Vector2i(0, 0))
		
		cancel_build_mode()
