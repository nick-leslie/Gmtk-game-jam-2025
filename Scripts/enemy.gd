# Enemy.gd
extends Node2D

#@export var enemy_stats: Resource #use .tres
@export var health: int
@export var speed: float
@export var dash_mult: float

enum State {
	IDLE,
	MOVE,
	WINDUP,
	ATTACK,
	RUNANDGUN
}

var current_state = State.IDLE

func _ready(): #setup
	pass
	
func _process(delta: float) -> void: #loop
	pass

func get_transition() -> State:
	match current_state:
		State.IDLE:
			return State.IDLE #Override
	return State.IDLE #Override

#State logic
func update(): 
	match current_state:
		State.IDLE:
			pass
		
	
#func idleState(): #State logic for idle state
	#pass
	#
#func moveState():
	#pass
#
#func windupState():
	#pass
	#
#func attackState():
	#pass
#
#func runAndGunState():
	#pass
