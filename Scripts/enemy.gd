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
	current_state = get_transition(delta)
	

func get_transition(delta: float) -> State:
	match current_state:
		State.IDLE:
			return idleTransition(delta)
		State.MOVE:
			return moveTransition(delta)
		State.ATTACK:
			return attackTransition(delta)
		State.WINDUP:
			return windupTransition(delta)
		State.RUNANDGUN:
			return runAndGunTransition(delta)
		State.DASH:
			return dashTransition(delta)
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
func idleTransition(delta: float) -> State:
	return State.IDLE
	pass
	
func moveTransition(delta: float) -> State:
	return State.IDLE
	pass
	
func windupTransition(delta: float) -> State:
	return State.IDLE
	pass
	
func attackTransition(delta: float) -> State:
	return State.IDLE
	pass
	
func runAndGunTransition(delta: float) -> State:
	return State.IDLE
	pass	
	
func dashTransition(delta: float) -> State:
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
