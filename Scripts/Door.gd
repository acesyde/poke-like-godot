extends Area2D

#------------------
# Exports
#------------------
export(String, FILE) var next_scene_path = ""
export(bool) var is_invisible = false
export(Vector2) var spawn_location = Vector2.ZERO
export(Vector2) var spawn_direction = Vector2.ZERO

#------------------
# On ready variables
#------------------
onready var sprite: Sprite = $Sprite
onready var animation_player: AnimationPlayer = $AnimationPlayer

#------------------
# Local variables
#------------------
var player_entered: bool = false

func _ready() -> void:
	if is_invisible:
		sprite.texture = null
		
	sprite.visible = false
	var player = find_parent("CurrentScene").get_children().back().find_node("Player")
	player.connect("player_entering_door_signal", self, "enter_door")
	player.connect("player_entered_door_signal", self, "close_door")

func enter_door() -> void:
	if player_entered:
		animation_player.play("OpenDoor")
	
func close_door() -> void:
	if player_entered:
		animation_player.play("CloseDoor")

func door_closed() -> void:
	get_node(NodePath("/root/SceneManager")).transition_to_scene(next_scene_path, spawn_location, spawn_direction)


func _on_Door_body_entered(body: Node) -> void:
	player_entered = true


func _on_Door_body_exited(body: Node) -> void:
	player_entered = false
