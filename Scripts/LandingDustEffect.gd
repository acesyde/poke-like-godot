extends AnimatedSprite

func _ready() -> void:
	frame = 0
	playing = true


func _on_LandingDustEffect_animation_finished() -> void:
	queue_free()
