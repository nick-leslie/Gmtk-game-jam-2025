extends Enemy

@export var number_of_dashes: int = 4
@export var dash_cone_degrees: int = 60

var dash_timer := 0.0
var previous_dash_number = 0

var dash_speed = max_speed * dash_mult
var current_dash_direction: Vector2 = Vector2.ZERO

#Transistion functions
func idleTransition(delta: float) -> State: # Default transition strucuture for only on transition option
	var random_next_state = randi_range(1, 3)
	var next_state = State.IDLE
	
	if idle_elapsed_time < idle_state_time:
		idle_elapsed_time += delta
		return next_state
	else:
		match random_next_state:
			1:
				next_state = State.TELEGRAPH
			2:
				next_state = State.WINDUP
			3:
				next_state = State.DASHWINDUP
		idle_elapsed_time = 0.0
		return next_state

func telegraphTransition(delta: float) -> State:
	if telegraph_elapsed_time < telegraph_state_time:
		telegraph_elapsed_time += delta
		return State.TELEGRAPH
	else:
		telegraph_elapsed_time = 0.0
		return State.MOVE

func moveTransition(delta: float) -> State:
	var random_next_state = randi_range(1, 4)
	var next_state = State.MOVE
	
	if move_elapsed_time < move_state_time:
		move_elapsed_time += delta
		return next_state
	else:
		match random_next_state:
			1:
				next_state = State.TELEGRAPH
			2:
				next_state = State.WINDUP
			3:
				next_state = State.DASHWINDUP
			4:
				next_state = State.IDLE
		move_elapsed_time = 0.0
		return next_state

func windupTransition(delta: float) -> State:
	if windup_elapsed_time < windup_state_time:
		windup_elapsed_time += delta
		return State.WINDUP
	else:
		windup_elapsed_time = 0.0
		return State.ATTACK

func attackTransition(delta: float) -> State:
	var random_next_state = randi_range(1, 4)
	var next_state = State.ATTACK
	
	if attack_elapsed_time < attack_state_time:
		attack_elapsed_time += delta
		return next_state
	else:
		match random_next_state:
			1:
				next_state = State.TELEGRAPH
			2:
				next_state = State.WINDUP
			3:
				next_state = State.DASHWINDUP
			4:
				next_state = State.IDLE
		attack_elapsed_time = 0.0
		return next_state

func runAndGunTransition(delta: float) -> State:
	return State.IDLE
	pass

func dashWindupTransition(delta: float) -> State:
	if dash_windup_elapsed_time < dash_windup_state_time:
		dash_windup_elapsed_time += delta
		#print("In dash windup state")
		return State.DASHWINDUP
	else:
		dash_windup_elapsed_time = 0.0
		print("Entering dash state")
		return State.DASH

func dashTransition(delta: float) -> State:
	var random_next_state = randi_range(1, 3)
	var next_state = State.DASH
	
	if dash_elapsed_time < dash_state_time:
		dash_elapsed_time += delta
		return next_state
	else:
		match random_next_state:
			1:
				next_state = State.TELEGRAPH
			2:
				next_state = State.WINDUP
			3:
				next_state = State.IDLE
		dash_elapsed_time = 0.0
		return next_state
		
	
func dashState(delta: float):
	var dash_period = dash_state_time / number_of_dashes
	var dash_phase = int(dash_elapsed_time / dash_period)
	dash_speed = max_speed * dash_mult

	if dash_phase != previous_dash_number and dash_phase < number_of_dashes:
		previous_dash_number = dash_phase
		#current_dash_direction = change_direction()
		direction = change_direction()
	moveInDirection(direction, dash_speed)
	screenClamp()
	
func change_direction() -> Vector2:
	# Calculate the opposite direction
	var opposite_direction = -direction.normalized()
	var base_angle = opposite_direction.angle()
	
	# Adding random variation
	var half_cone_rad = deg_to_rad(dash_cone_degrees / 2.0)
	var random_angle_offset = randf_range(-half_cone_rad, half_cone_rad)
	
	var final_angle = base_angle + random_angle_offset
	
	var varied_direction = Vector2.RIGHT.rotated(final_angle)
	return varied_direction
	
