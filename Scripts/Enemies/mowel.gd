extends Enemy

@export var number_of_projectile_waves: int = 1
@export var projectile_cone: int = 60

var current_wave =  0

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
				next_state = State.WINDUP
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
			3, 4, 5, 6:
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
			1, 2:
				next_state = State.TELEGRAPH
			3:
				next_state = State.WINDUP
			4, 5, 6:
				next_state = State.IDLE
		attack_elapsed_time = 0.0
		return next_state

func runAndGunTransition(delta: float) -> State:
	return State.IDLE
	pass

func dashWindupTransition(delta: float) -> State:
	return State.DASHWINDUP
	pass

func dashTransition(delta: float) -> State:
	return State.IDLE
	pass



func attackState(delta: float):
	var mat = $EnemySprite.material as ShaderMaterial
	mat.set_shader_parameter("active", false)
	
	#Do the first time the state is entered
	if attack_elapsed_time == 0.0:
		#projectile_direction = Utils.random_direction()
		#projectile_direction = generate_direction()
		projectile_timer = 0.0
		current_projectiles = 0
		current_wave = 0
		
	
	var projectile_period = attack_state_time / number_of_projectiles
	
	if current_wave < number_of_projectile_waves:
		projectile_timer += delta
		if projectile_timer >= projectile_period:
			projectile_timer -= projectile_period
			fire_projectile_spread(projectile_direction)
			current_wave += 1
			
			
func fire_projectile_spread(base_direction: Vector2):
	var spread = deg_to_rad(projectile_cone)
	var step = 0.0
	if number_of_projectiles > 1:
		step = spread / (number_of_projectiles - 1)
	var start_angle = -spread / 2

	for i in number_of_projectiles:
		var angle = start_angle + i * step
		var direction = base_direction.rotated(angle)
		var projectile = projectile_scene.instantiate()
		projectile.global_position = global_position
		projectile.set_direction(direction)
		get_tree().current_scene.add_child(projectile)
