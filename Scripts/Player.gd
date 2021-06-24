class_name Player
extends KinematicBody2D

#------------------
# Signals
#------------------
signal player_moving_signal
signal player_stopped_signal
signal player_entering_door_signal
signal player_entered_door_signal

#------------------
# Exports
#------------------
export var walk_speed: float = 4.0
export var jump_speed: float = 4.0

#------------------
# Constants
#------------------
const TILE_SIZE: int = 16
const LandingDustEffect = preload("res://Scenes/LandingDustEffect.tscn")

#------------------
# On ready variables
#------------------
onready var animation_tree: AnimationTree = $AnimationTree
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
onready var blocking_raycast: RayCast2D = $BlockingRayCast2D
onready var ledge_raycast: RayCast2D = $LedgeRayCast2D
onready var door_raycast: RayCast2D = $DoorRayCast2D
onready var shadow: Sprite = $Shadow
onready var camera: Camera2D = $Camera2D
onready var sprite: Sprite = $Sprite

#------------------
# Enums
#------------------

enum PlayerState { IDLE, TURNING, WALKING }
enum FacingDirection { LEFT, RIGHT, UP, DOWN }

#------------------
# Local variables
#------------------
var initial_position: Vector2 = Vector2.ZERO
var input_direction: Vector2 = Vector2.DOWN
var is_moving: bool = false
var stop_input: bool = false
var percent_moved_to_next_tile: float = 0.0
var player_state = PlayerState.IDLE
var facing_direction = FacingDirection.DOWN
var jumping_over_ledge: bool = false

#------------------
# Private functions
#------------------

func _ready() -> void:
	sprite.visible = true
	initial_position = position
	animation_tree.active = true
	shadow.visible = false
	animation_tree.set("parameters/Idle/blend_position", input_direction)
	animation_tree.set("parameters/Walk/blend_position", input_direction)
	animation_tree.set("parameters/Turn/blend_position", input_direction)

func _physics_process(delta: float) -> void:
	
	if player_state == PlayerState.TURNING or stop_input:
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
	
	blocking_raycast.cast_to = desired_step
	blocking_raycast.force_raycast_update()
	
	ledge_raycast.cast_to = desired_step
	ledge_raycast.force_raycast_update()
	
	door_raycast.cast_to = desired_step
	door_raycast.force_raycast_update()
	
	if door_raycast.is_colliding():
		if percent_moved_to_next_tile == 0.0:
			emit_signal("player_entering_door_signal")
		percent_moved_to_next_tile += walk_speed * delta
		
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (input_direction * TILE_SIZE)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			stop_input = true
			animation_player.play("Disappear")
			camera.clear_current()
		else:
			position = initial_position + (TILE_SIZE * input_direction * percent_moved_to_next_tile)
			
	elif (ledge_raycast.is_colliding() && input_direction == Vector2.DOWN) || jumping_over_ledge:
		percent_moved_to_next_tile += jump_speed * delta
		
		if percent_moved_to_next_tile >= 2.0:
			position = initial_position + (input_direction * TILE_SIZE * 2)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			jumping_over_ledge = false
			shadow.visible = false
			
			var landing_dust_effect = LandingDustEffect.instance()
			landing_dust_effect.position = position
			get_tree().current_scene.add_child(landing_dust_effect)
		else:
			shadow.visible = true
			jumping_over_ledge = true
			var input = input_direction.y * TILE_SIZE * percent_moved_to_next_tile
			position.y = initial_position.y + (-0.96 - 0.53 * input + 0.05 * pow(input, 2))
			
	elif !blocking_raycast.is_colliding():
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
	
func _entered_door():
	emit_signal("player_entered_door_signal")

func set_spawn(location: Vector2, direction: Vector2) -> void:
	animation_tree.set("parameters/Idle/blend_position", direction)
	animation_tree.set("parameters/Walk/blend_position", direction)
	animation_tree.set("parameters/Turn/blend_position", direction)
	position = location
