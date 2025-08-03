extends Enemy

#Transistion functions
func idleTransition(delta: float) -> State: # Default transition strucuture for only on transition option
	var random_next_state = randi_range(1, 2)
	var next_state = State.IDLE
	
	if idle_elapsed_time < idle_state_time:
		idle_elapsed_time += delta
		return next_state
	else:
		match random_next_state:
			1:
				next_state = State.TELEGRAPH
			2:
				next_state = State.DASHWINDUP
		idle_elapsed_time = 0.0
		return next_state

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
			2, 3, 4, 5, 6:
				next_state = State.IDLE
		move_elapsed_time = 0.0
		return next_state


func dashTransition(delta: float) -> State:
	
	if dash_elapsed_time < dash_state_time:
		dash_elapsed_time += delta
		return State.DASH
	else:
		dash_elapsed_time = 0.0
		return State.IDLE
