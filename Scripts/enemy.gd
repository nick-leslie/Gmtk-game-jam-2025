# Enemy.gd
extends Node2D
class_name Enemy

#@export var enemy_stats: Resource #use .tres

@export var max_speed: float
@export var dash_mult: float
@export var ray_count:int = 10
@export var ray_length:float =10000
@export_flags_2d_physics var collision_mask: int = 1
@onready var debug_line = Line2D.new()



@export var capture_threashold: float
@export var decay_duration:float # duration for decay in seconds
var currrent_decay_duration:float
@export var decay_rate:Curve # decay rate curve that we sample
@onready var decay_start_timer:Timer = Timer.new()
@export var decay_wait_time:float # time we have till decay begins on capture progress
var capture_health:float = 0.0
var is_decaying:bool = false

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
	get_parent().add_child(debug_line)
	EventBus.LoopCreated.connect(check_circled)
	EventBus.ComboIncreased.connect(take_damage)
	add_child(decay_start_timer)
	decay_start_timer.timeout.connect(start_decay)
	decay_start_timer.autostart = true
	reset_timer()
	pass

func _process(delta: float) -> void: #loop
	state_logic()
	current_state = get_transition(delta)
	print(capture_health)
	if is_decaying:
		currrent_decay_duration+=delta
		var normalized_decay = get_normalized_value(currrent_decay_duration,0,decay_duration)
		capture_health -= decay_rate.sample(normalized_decay)
		if capture_health > capture_threashold:
			print("we have been captured")
	if capture_health < 0:
		capture_health = 0
		is_decaying = false
		decay_start_timer.stop()



func start_decay():
	is_decaying=true
	pass

func take_damage(combo:int):
	capture_health += combo
	if capture_health > capture_threashold:
		print("captureded")
	print(capture_health)
	reset_timer()

func reset_timer():
	decay_start_timer.stop()
	decay_start_timer.wait_time = decay_wait_time
	decay_start_timer.start()
	is_decaying=false

func check_circled() -> void:
	print("gaming????")
	var looped = check_line_col()
	print(looped)
	if looped:
		EventBus.EnemeyCircled.emit()
	pass # Replace with function body.

func get_normalized_value(current: float, min_value: float, max_value: float) -> float:
	if max_value == min_value:
		return 0.0 # Avoid division by zero
	return clamp((current - min_value) / (max_value - min_value), 0.0, 1.0)

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
		if hit.size() == 0:
			return false
	return true

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
