extends Enemy


#Transistion functions
func idleTransition(delta: float):
	if idle_elapsed_time < idle_state_time:
		idle_elapsed_time += delta
		return State.IDLE
	else:
		idle_elapsed_time = 0.0
		return State.TELEGRAPH
	
func telegraphTransition(delta: float) -> State:
	if telegraph_elapsed_time < telegraph_state_time:
		telegraph_elapsed_time += delta
		return State.TELEGRAPH
	else:
		telegraph_elapsed_time = 0.0
		return State.MOVE
	pass
	
func moveTransition(delta: float):
	if move_elapsed_time < move_state_time:
		move_elapsed_time += delta
		return State.MOVE
	else:
		move_elapsed_time = 0.0
		return State.IDLE
	
func windupTransition(delta: float):
	pass
	
func attackTransition(delta: float):
	pass
	
func runAndGunTransition(delta: float):
	pass	
	
func dashTransition(delta: float):
	pass
