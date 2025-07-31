# Enemy.gd
extends Node2D
class_name Enemy

#@export var enemy_stats: Resource #use .tres
@export var health: int
@export var speed: float
@export var dash_mult: float
@export var ray_count:int
@export var ray_length:float
@export var collision_mask: int = 1
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
	pass

# we need to move
func check_line_col():
	var space = get_world_2d().direct_space_state
	for i in ray_count:
		var angle = TAU * i / ray_count
		var dir = Vector2(cos(angle), sin(angle))
		var to = position + dir * ray_length
		var query = PhysicsRayQueryParameters2D.create(position, to)
		query.exclude = [self]
		query.collision_mask = 1
		var hit = space.intersect_ray(query)
		# hit will be {} if no collision, otherwise a dictionary with keys:
		#   position (Vector2), normal (Vector2), collider, etc.
		if hit.size() == 0:
			print("one of the rays hasnt collided with the line")
			return


	pass

func get_transition() -> State:
	match current_state:
		State.IDLE:
			idleTransition()
		State.MOVE:
			moveTransition()
		State.ATTACK:
			attackTransition()
		State.WINDUP:
			windupTransition()
		State.RUNANDGUN:
			runAndGunTransition()
		State.DASH:
			dashTransition()
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
func idleTransition():
	pass

func moveTransition():
	pass

func windupTransition():
	pass

func attackTransition():
	pass

func runAndGunTransition():
	pass

func dashTransition():
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
