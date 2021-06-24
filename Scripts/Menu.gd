class_name Menu
extends CanvasLayer


#------------------
# Exports
#------------------
const PokemonPartyScreen = preload("res://Scenes/PokemonPartyScreen.tscn")

#------------------
# On ready variables
#------------------
onready var select_arrow: TextureRect = $Control/NinePatchRect/TextureRect
onready var menu: Control = $Control

#------------------
# Local variables
#------------------
var screen_loaded = ScreenLoaded.NOTHING
var selected_option: int = 0
var pokemon_party_screen: Node2D = null

#------------------
# Enumerators
#------------------
enum ScreenLoaded {
	NOTHING,
	JUST_MENU,
	PARTY_SCREEN
}

func _ready() -> void:
	menu.visible = false
	select_arrow.rect_position.y = 6 + (selected_option % 6) * 14

func _unhandled_input(event: InputEvent) -> void:
	match screen_loaded:
		ScreenLoaded.NOTHING:
			if event.is_action_pressed("menu"):
				var player: Player = get_parent().get_node("CurrentScene").get_children().back().find_node("Player")
				
				if !player.is_moving:
					player.set_physics_process(false)
					menu.visible = true
					screen_loaded = ScreenLoaded.JUST_MENU
				
		ScreenLoaded.JUST_MENU:
			if event.is_action_pressed("menu") or event.is_action_pressed("x"):
				var player: Player = get_parent().get_node("CurrentScene").get_children().back().find_node("Player")
				player.set_physics_process(true)
				
				menu.visible = false
				screen_loaded = ScreenLoaded.NOTHING
				
			elif event.is_action_pressed("ui_down"):
				selected_option += 1
				select_arrow.rect_position.y = 6 + (selected_option % 6) * 14
				
			elif event.is_action_pressed("ui_up"):
				if selected_option == 0:
					selected_option = 5
				else:
					selected_option -= 1
				select_arrow.rect_position.y = 6 + (selected_option % 6) * 14
				
			elif event.is_action_pressed("z"):
				get_parent().transition_to_party_screen()
				
		ScreenLoaded.PARTY_SCREEN:
			if event.is_action_pressed("x"):
				get_parent().transition_exit_party_screen()

func load_party_screen() -> void:
	menu.visible = false
	screen_loaded = ScreenLoaded.PARTY_SCREEN
	pokemon_party_screen = PokemonPartyScreen.instance()
	add_child(pokemon_party_screen)
	
func unload_party_screen() -> void:
	menu.visible = true
	screen_loaded = ScreenLoaded.JUST_MENU
	remove_child(pokemon_party_screen)
