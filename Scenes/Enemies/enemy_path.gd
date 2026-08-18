extends PathFollow2D

@export var speed: float = 150.0

func _process(delta: float) -> void:
	progress += speed * delta
	
	if progress_ratio >= 1.0:
		queue_free()
