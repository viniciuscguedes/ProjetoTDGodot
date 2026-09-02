class_name TowerResource
extends Resource

@export var tower_name: String = ""
@export var damage: int = 20
@export var rof: float = 0.3
@export var range_radius: float = 350.0
@export_enum("Projectile", "Missile") var category: String = "Projectile"
@export var tower_scene: PackedScene
