class_name TowerResource
extends Resource

@export var tower_name: String = ""
@export var damage: int = 20
@export var rof: float = 0.3
@export var range_radius: float = 350.0
@export_enum("Projectile", "Missile") var category: String = "Projectile"
@export var tower_scene: PackedScene

@export var icon: Texture2D
@export var cost: int = 100
@export var sell_value: int = 50
@export var upgrade_cost: int = 150
@export var next_upgrade: TowerResource
