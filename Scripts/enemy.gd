# Enemy.gd
extends Node2D
class_name Enemy

#@export var enemy_stats: Resource #use .tres
@export var health: int
@export var speed: float
@export var dash_mult: float
@export var ray_count:int
@export var ray_length:float
@export_flags_2d_physics var collision_mask: int
@onready var debug_line = Line2D.new()
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
	get_parent().add_child(debug_line)
	pass

func _on_player_loop_complete() -> void: # godot refrence magic?
	var looped = check_line_col()
	print(looped)
	pass # Replace with function body.

# we need to move
func check_line_col():
	var space = get_world_2d().direct_space_state
	for i in ray_count:
		var angle = TAU * i / ray_count
		var dir = Vector2(cos(angle), sin(angle))
		var to = position + dir * ray_length
		# debug_line.add_point(position)
		# debug_line.add_point(to)
		var query = PhysicsRayQueryParameters2D.create(position, to)
		query.exclude = [self]
		query.collision_mask = collision_mask
		query.collide_with_areas = true
		var hit = space.intersect_ray(query)
		# hit will be {} if no collision, otherwise a dictionary with keys:
		#   position (Vector2), normal (Vector2), collider, etc.
		if hit.size() == 0:
			return false
	return true

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
