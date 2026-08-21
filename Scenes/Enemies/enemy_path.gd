extends PathFollow2D

var speed: float = 150.0
var hp: int = 50

@onready var health_bar: TextureProgressBar = $HealthBar

func _ready() -> void:
	health_bar.max_value = hp
	health_bar.value = hp
	health_bar.top_level = true

func _physics_process(delta: float) -> void:
	move(delta)

func move(delta: float) -> void:
	progress += speed * delta
	health_bar.position = position - Vector2(30, 30)

func on_hit(damage: int) -> void:
	hp -= damage
	health_bar.value = hp
	if hp <= 0:
		on_destroy()

func on_destroy() -> void:
	if is_instance_valid(health_bar):
		health_bar.queue_free()
	queue_free()
