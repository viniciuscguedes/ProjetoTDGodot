extends CanvasLayer


func set_tower_preview(tower_type: String, _mouse_position: Vector2) -> void:
	var old_preview = get_node_or_null("TowerPreview")
	if old_preview == null:
		old_preview = get_node_or_null("HUD/TowerPreview")
	if old_preview:
		old_preview.free()
		
	var tower_scene = load("res://Scenes/Turrets/" + tower_type + ".tscn")
	var drag_tower = tower_scene.instantiate()
	drag_tower.name = "DragTower"
	drag_tower.position = Vector2.ZERO 
	
	var range_texture = Sprite2D.new()
	range_texture.name = "RangeOverlay"
	range_texture.position = Vector2.ZERO
	
	var scaling = GameData.tower_data[tower_type]["range"] / 700.0
	range_texture.scale = Vector2(scaling, scaling)
	range_texture.texture = load("res://Assets/UI/range_overlay.png")
	range_texture.modulate = Color("45454556")
	
	var control = Control.new()
	control.name = "TowerPreview"
	

	control.add_child(range_texture)
	control.add_child(drag_tower)
	
	control.position = get_viewport().get_mouse_position()
	
	add_child(control)
	move_child(control, 0)

func update_tower_preview(_new_position, color):
	var tower_preview = get_node_or_null("TowerPreview")
	if tower_preview == null:
		tower_preview = get_node_or_null("HUD/TowerPreview")
	
	if tower_preview:
		tower_preview.position = get_viewport().get_mouse_position()
		
		var drag_tower = tower_preview.get_node_or_null("DragTower")
		if drag_tower:
			drag_tower.modulate = Color(color)
			
		var range_sprite = tower_preview.get_node_or_null("RangeOverlay")
		if range_sprite:
			range_sprite.modulate = Color(color)


func _on_pause_play_pressed() -> void:
	if get_parent().build_mode:
		get_parent().cancel_build_mode()
	if get_tree().is_paused():
		get_tree().paused = false
	elif get_parent().current_wave == 0:
		get_parent().current_wave += 1
		get_parent().start_next_wave()
	else:
		get_tree().paused = true
		
func _on_speed_up_pressed() -> void:
	if Engine.time_scale == 2.0:
		Engine.time_scale = 1.0
	else:
		Engine.time_scale = 2.0
