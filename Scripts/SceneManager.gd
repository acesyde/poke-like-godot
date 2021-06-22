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
var player_location: Vector2 = Vector2.ZERO
var player_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	pass 

func transition_to_scene(scene_name: String, spawn_location: Vector2, spawn_direction: Vector2) -> void:
	next_scene_name = scene_name
	player_location = spawn_location
	player_direction = spawn_direction
	screen_transition_anim_player.play("FadeToBlack")

func finished_fading() -> void:
	current_scene.get_child(0).queue_free()
	current_scene.add_child(load(next_scene_name).instance())
	
	var player = current_scene.get_children().back().find_node("Player")
	player.set_spawn(player_location, player_direction)
	
	screen_transition_anim_player.play("FadeToNormal")
