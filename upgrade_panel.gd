extends Control

var current_turret: Node2D = null

@onready var panel_container: Panel = %PanelContainer
@onready var tower_icon: TextureRect = %TowerIcon
@onready var stats_label: Label = %StatsLabel
@onready var upgrade_button: Button = %UpgradeButton
@onready var sell_button: Button = %SellButton

func _ready() -> void:
	visible = false
	sell_button.pressed.connect(_on_sell_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var local_mouse_pos = panel_container.get_local_mouse_position()
		var panel_rect = Rect2(Vector2.ZERO, panel_container.size)
		
		if not panel_rect.has_point(local_mouse_pos):
			close_panel()
			get_viewport().set_input_as_handled()

func open_panel(turret: Node2D) -> void:
	current_turret = turret
	var res: TowerResource = turret.tower_resource
	
	if not res:
		return

	if res.icon:
		tower_icon.texture = res.icon
		
	stats_label.text = "Nome: %s\nDano: %d\nCdT: %.2f\nAlcance: %.0f" % [
		res.tower_name, res.damage, res.rof, res.range_radius
	]
	
	sell_button.text = "Vender ($%d)" % res.sell_value
	
	if res.next_upgrade:
		upgrade_button.text = "Upgrade ($%d)" % res.upgrade_cost
		upgrade_button.disabled = false
	else:
		upgrade_button.text = "Nível Máximo"
		upgrade_button.disabled = true

	var screen_pos = turret.get_global_transform_with_canvas().origin
	var offset = Vector2(60, -50)
	var target_pos = screen_pos + offset
	
	var viewport_size = get_viewport_rect().size
	var panel_size = panel_container.size
	
	target_pos.x = clamp(target_pos.x, 10, viewport_size.x - panel_size.x - 10)
	target_pos.y = clamp(target_pos.y, 10, viewport_size.y - panel_size.y - 10)
	
	panel_container.global_position = target_pos
	visible = true

func close_panel() -> void:
	visible = false
	current_turret = null

func _on_sell_pressed() -> void:
	if is_instance_valid(current_turret):
		current_turret.queue_free()
	close_panel()

func _on_upgrade_pressed() -> void:
	if not is_instance_valid(current_turret) or not current_turret.tower_resource.next_upgrade:
		return
		
	var next_res: TowerResource = current_turret.tower_resource.next_upgrade
	
	if next_res.tower_name == "":
		print("ERRO: O campo 'tower_name' no TowerResource de upgrade está vazio!")
		return

	var parent_node = current_turret.get_parent()
	var old_position = current_turret.global_position
	
	var new_tower_scene_path = "res://Scenes/Turrets/" + next_res.tower_name + ".tscn"
	
	if ResourceLoader.exists(new_tower_scene_path):
		var new_tower_scene = load(new_tower_scene_path)
		var new_turret = new_tower_scene.instantiate()
		
		new_turret.global_position = old_position
		new_turret.tower_resource = next_res
		new_turret.built = true
		
		parent_node.add_child(new_turret, true)
		current_turret.queue_free()
		
		open_panel(new_turret)
	else:
		print("ERRO: A cena não existe no caminho: ", new_tower_scene_path)
