extends Node2D

#------------------
# On ready variables
#------------------
onready var screen_transition_anim_player: AnimationPlayer = $ScreenTransition/AnimationPlayer
onready var current_scene: Node2D = $CurrentScene

#------------------
# Local variables
#------------------
var next_scene_name: String

func _ready() -> void:
	pass 

func transition_to_scene(scene_name: String) -> void:
	next_scene_name = scene_name
	screen_transition_anim_player.play("FadeToBlack")

func finished_fading() -> void:
	current_scene.get_child(0).queue_free()
	current_scene.add_child(load(next_scene_name).instance())
	screen_transition_anim_player.play("FadeToNormal")
