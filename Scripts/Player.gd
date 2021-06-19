extends KinematicBody2D

#------------------
# Signals
#------------------
signal player_moving_signal
signal player_stopped_signal

#------------------
# Exports
#------------------
export var walk_speed: float = 4.0

#------------------
# Constants
#------------------
const TILE_SIZE: int = 16

#------------------
# On ready variables
#------------------
onready var animation_tree: AnimationTree = $AnimationTree
onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
onready var raycast: RayCast2D = $RayCast2D

#------------------
# Enums
#------------------

enum PlayerState { IDLE, TURNING, WALKING }
enum FacingDirection { LEFT, RIGHT, UP, DOWN }

#------------------
# Local variables
#------------------
var initial_position: Vector2 = Vector2.ZERO
var input_direction: Vector2 = Vector2.ZERO
var is_moving: bool = false
var percent_moved_to_next_tile: float = 0.0
var player_state = PlayerState.IDLE
var facing_direction = FacingDirection.DOWN

#------------------
# Private functions
#------------------

func _ready() -> void:
	initial_position = position
	animation_tree.active = true

func _physics_process(delta: float) -> void:
	
	if player_state == PlayerState.TURNING:
		return
	elif is_moving == false:
		_process_player_input()
	elif input_direction != Vector2.ZERO:
		animation_state.travel("Walk")
		_move_player(delta)
	else:
		animation_state.travel("Idle")
		is_moving = false
		
func _process_player_input() -> void:
	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))

	if input_direction != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", input_direction)
		animation_tree.set("parameters/Walk/blend_position", input_direction)
		animation_tree.set("parameters/Turn/blend_position", input_direction)
		
		if _need_to_turn():
			player_state = PlayerState.TURNING
			animation_state.travel("Turn")
		else:
			initial_position = position
			is_moving = true
	else:
		animation_state.travel("Idle")
		
func _move_player(delta: float) -> void:
	var desired_step: Vector2 = input_direction * TILE_SIZE / 2
	
	raycast.cast_to = desired_step
	raycast.force_raycast_update()
	
	if !raycast.is_colliding():
		if percent_moved_to_next_tile == 0:
			emit_signal("player_moving_signal")
			
		percent_moved_to_next_tile += walk_speed * delta
		
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (TILE_SIZE * input_direction)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			emit_signal("player_stopped_signal")
		else:
			position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)
	else:
		is_moving = false

func _need_to_turn() -> bool:
	var new_facing_direction
	
	if input_direction.x < 0:
		new_facing_direction = FacingDirection.LEFT
	elif input_direction.x > 0:
		new_facing_direction = FacingDirection.RIGHT
	elif input_direction.y < 0:
		new_facing_direction = FacingDirection.UP
	elif input_direction.y > 0:
		new_facing_direction = FacingDirection.DOWN

	if facing_direction != new_facing_direction:
		facing_direction = new_facing_direction
		return true
	
	facing_direction = new_facing_direction
	return false
	
func _finished_turning():
	player_state = PlayerState.IDLE
