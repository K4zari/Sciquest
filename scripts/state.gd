extends Node
class_name State

@export var accepted_commands : Array[Sciquest.Commands]

var previous_state : State
var is_current : bool = false

signal transition(new_state : int)

var actor : CharacterBody2D
var animator : AnimationPlayer
var pivot : Marker2D

@onready var state_machine : FiniteStateMachine = get_parent()

func enter_state(_prev_state : State) -> void:
	pass
	
func exit_state() -> void:
	pass
	
func frame_update(_delta : float) -> void:
	pass
	
func physics_update(_delta : float) -> void:
	pass

func animation_finished() -> void:
	pass

func execute_command(command : Sciquest.Commands) -> bool:
	if command == Sciquest.Commands.RELEASE:
		return true
	return false
