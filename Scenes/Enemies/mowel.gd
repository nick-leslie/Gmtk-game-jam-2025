extends Enemy

@export var number_of_projectile_waves: int = 1
@export var projectile_cone: int = 60

var current_wave =  0

#Transistion functions
func idleTransition(delta: float) -> State: # Default transition strucuture for only on transition option
	if idle_elapsed_time < idle_state_time:
		idle_elapsed_time += delta
		return State.IDLE
	else:
		idle_elapsed_time = 0.0
		return State.ATTACK

func telegraphTransition(delta: float) -> State:
	return State.TELEGRAPH
	pass

func moveTransition(delta: float) -> State:
	return State.IDLE
	pass

func windupTransition(delta: float) -> State:
	return State.IDLE
	pass

func attackTransition(delta: float) -> State:
	if attack_elapsed_time < attack_state_time:
		attack_elapsed_time += delta
		return State.ATTACK
	else:
		attack_elapsed_time = 0.0
		return State.IDLE

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
		projectile_direction = generate_direction()
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
			
	
	#if current_projectiles < number_of_projectiles:
		#projectile_timer += delta
		#if projectile_timer >= projectile_period:
			#projectile_timer -= projectile_period
			#var projectile = projectile_scene.instantiate()
			#projectile.set_direction(projectile_direction)
			#get_tree().current_scene.add_child(projectile)
			#projectile.global_position = global_position
			#current_projectiles += 1
			
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
