extends Area2D

#------------------
# Exports
#------------------
export(String, FILE) var next_scene_path = ""

#------------------
# On ready variables
#------------------
onready var sprite: Sprite = $Sprite
onready var animation_player: AnimationPlayer = $AnimationPlayer

#------------------
# Local variables
#------------------

func _ready() -> void:
	sprite.visible = false
	var player = find_parent("CurrentScene").get_children().back().find_node("Player")
	player.connect("player_entering_door_signal", self, "enter_door")
	player.connect("player_entered_door_signal", self, "close_door")

func enter_door() -> void:
	animation_player.play("OpenDoor")
	
func close_door() -> void:
	animation_player.play("CloseDoor")

func door_closed() -> void:
	get_node(NodePath("/root/SceneManager")).transition_to_scene(next_scene_path)
