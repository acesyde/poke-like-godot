extends KinematicBody2D

#------------------
# Exports
#------------------
export var walk_speed: float = 4.0

#------------------
# Constants
#------------------
const TILE_SIZE: int = 16

#------------------
# Local variables
#------------------
var initial_position: Vector2 = Vector2.ZERO
var input_direction: Vector2 = Vector2.ZERO
var is_moving: bool = false
var percent_moved_to_next_tile: float = 0.0

#------------------
# Private functions
#------------------

func _ready() -> void:
	initial_position = position

func _physics_process(delta: float) -> void:
	if is_moving == false:
		_process_player_input()
	elif input_direction != Vector2.ZERO:
		_move_player(delta)
	else:
		is_moving = false
		
func _process_player_input() -> void:
	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))

	if input_direction != Vector2.ZERO:
		initial_position = position
		is_moving = true
		
func _move_player(delta: float) -> void:
	percent_moved_to_next_tile += walk_speed * delta
	
	if percent_moved_to_next_tile >= 1.0:
		position = initial_position + (TILE_SIZE * input_direction)
		percent_moved_to_next_tile = 0.0
		is_moving = false
	else:
		position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)	
