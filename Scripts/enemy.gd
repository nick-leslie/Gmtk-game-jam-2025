# Enemy.gd
extends Node2D
class_name Enemy

#@export var enemy_stats: Resource #use .tres
@export var health: int
@export var speed: float
@export var dash_mult: float

enum State {
	IDLE,
	MOVE,
	WINDUP,
	ATTACK,
	RUNANDGUN,
	DASH
}

var current_state = State.IDLE

func _ready(): #setup
	pass
	
func _process(delta: float) -> void: #loop
	state_logic()
	current_state = get_transition()
	

func get_transition() -> State:
	match current_state:
		State.IDLE:
			return idleTransition()
		State.MOVE:
			return moveTransition()
		State.ATTACK:
			return attackTransition()
		State.WINDUP:
			return windupTransition()
		State.RUNANDGUN:
			return runAndGunTransition()
		State.DASH:
			return dashTransition()
	return State.IDLE #default is override

#State logic
func state_logic(): 
	match current_state:
		State.IDLE:
			idleState()
		State.MOVE:
			moveState()
		State.ATTACK:
			attackState()
		State.WINDUP:
			windupState()
		State.RUNANDGUN:
			runAndGunState()
		State.DASH:
			dashState()
		
	
#Transistion functions
func idleTransition() -> State:
	return State.IDLE
	pass
	
func moveTransition() -> State:
	return State.IDLE
	pass
	
func windupTransition() -> State:
	return State.IDLE
	pass
	
func attackTransition() -> State:
	return State.IDLE
	pass
	
func runAndGunTransition() -> State:
	return State.IDLE
	pass	
	
func dashTransition() -> State:
	return State.IDLE
	pass

# State logic functions
func idleState(): #State logic for idle state
	pass
	
func moveState():
	pass

func windupState():
	pass
	
func attackState():
	pass

func runAndGunState():
	pass
	
func dashState():
	pass
