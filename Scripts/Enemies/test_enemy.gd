extends Enemy

@export var projectile_scene: PackedScene

var projectile_direction := Vector2.ZERO
var projectile_timer := 0.0

#Transistion functions
func idleTransition(delta: float):
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
				next_state = State.ATTACK
				print("Entering attack state")
		idle_elapsed_time = 0.0
		return next_state
	
func telegraphTransition(delta: float) -> State:
	if telegraph_elapsed_time < telegraph_state_time:
		telegraph_elapsed_time += delta
		return State.TELEGRAPH
	else:
		telegraph_elapsed_time = 0.0
		return State.MOVE
	
	
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
	if attack_elapsed_time < attack_state_time:
		attack_elapsed_time += delta
		return State.ATTACK
	else:
		attack_elapsed_time = 0.0
		print("Exiting attack state")
		return State.IDLE
	
func runAndGunTransition(delta: float):
	pass	
	
func dashTransition(delta: float):
	pass
	
func attackState(delta: float):
	#Do the first time the state is entered
	if attack_elapsed_time == 0.0:
		print("First time in attack state")
		projectile_direction = Utils.random_direction()
		projectile_timer = 0.0
		current_projectiles = 0
		
	
	var projectile_period = attack_state_time / number_of_projectiles
	
	if current_projectiles < number_of_projectiles:
		projectile_timer += delta
		if projectile_timer >= projectile_period:
			projectile_timer -= projectile_period
			var projectile = projectile_scene.instantiate()
			projectile.set_direction(projectile_direction)
			get_tree().current_scene.add_child(projectile)
			projectile.global_position = global_position
			current_projectiles += 1
	
