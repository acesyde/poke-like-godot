extends Node2D

#------------------
# On ready variables
#------------------
onready var screen_transition_anim_player: AnimationPlayer = $ScreenTransition/AnimationPlayer
onready var current_scene: Node2D = $CurrentScene
onready var menu: Menu = $Menu

#------------------
# Local variables
#------------------
var next_scene_name: String
var player_location: Vector2 = Vector2.ZERO
var player_direction: Vector2 = Vector2.ZERO
var transition_type = TransitionType.NEW_SCENE

#------------------
# Enumerators
#------------------
enum TransitionType {
	NEW_SCENE,
	PARTY_SCREEN,
	MENU_ONLY
}

func _ready() -> void:
	pass 

func transition_to_party_screen() -> void:
	screen_transition_anim_player.play("FadeToBlack")
	transition_type = TransitionType.PARTY_SCREEN
	
func transition_exit_party_screen() -> void:
	screen_transition_anim_player.play("FadeToBlack")
	transition_type = TransitionType.MENU_ONLY

func transition_to_scene(scene_name: String, spawn_location: Vector2, spawn_direction: Vector2) -> void:
	next_scene_name = scene_name
	player_location = spawn_location
	player_direction = spawn_direction
	transition_type = TransitionType.NEW_SCENE
	screen_transition_anim_player.play("FadeToBlack")

func finished_fading() -> void:
	match transition_type:
		TransitionType.NEW_SCENE:
			current_scene.get_child(0).queue_free()
			current_scene.add_child(load(next_scene_name).instance())
			
			var player = current_scene.get_children().back().find_node("Player")
			player.set_spawn(player_location, player_direction)
	
		TransitionType.PARTY_SCREEN:
			menu.load_party_screen()
			
		TransitionType.MENU_ONLY:
			menu.unload_party_screen()
	
	screen_transition_anim_player.play("FadeToNormal")
