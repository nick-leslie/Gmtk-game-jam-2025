extends Enemy



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
	var random_next_state = randi_range(1, 6)
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
			4, 5, 6:
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
	var random_next_state = randi_range(1, 6)
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
			4, 5, 6:
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
	var random_next_state = randi_range(1, 6)
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
			3, 4, 5, 6:
				next_state = State.IDLE
		dash_elapsed_time = 0.0
		return next_state
		
	
	

	
