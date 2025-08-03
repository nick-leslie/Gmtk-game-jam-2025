# Enemy.gd
extends Node2D
class_name Enemy

const Utils = preload("res://Scripts/utils.gd")

#@export var enemy_stats: Resource #use .tres

@export_category("Stats")
@export var max_speed: float
@export var dash_mult: float
@export var number_of_projectiles: int
@export var number_of_dashes: int = 4
@export var dash_cone_degrees: int = 60
@export var telegraph_blink_count: int = 3 # How many times you want the telegraph to blink
@export var windup_blink_count : int = 3 # How many times you want the windup to blink
@export var edge_gap: int = 50 # Pixels away it can get to the edge
@export var capture_score:int
var telegraph_blink_counter := 0 # Number of times the telegraph has blinked
var current_projectiles := 0 # Number of projectiles shot

@export var projectile_scene: PackedScene

var projectile_direction := Vector2.ZERO
var projectile_timer := 0.0

@export_group("capture stats")
@export var decay_wait_time:float # time we have till decay begins on capture progress
@export var decay_rate:Curve # decay rate curve that we sample
var capture_health:float = 0.0
var is_decaying:bool = false
var decay_duration:float
@onready var decay_start_timer:Timer = Timer.new()
@onready var capture_bar:ProgressBar = get_node("HeathBar")

@export_category("State Machine")
@export var idle_state_time: float
var idle_elapsed_time := 0.0

@export var telegraph_state_time: float
var telegraph_elapsed_time := 0.0

@export var move_state_time: float
var move_elapsed_time := 0.0

@export var windup_state_time: float
var windup_elapsed_time := 0.0

@export var attack_state_time: float
var attack_elapsed_time := 0.0

@export var run_and_gun_state_time: float
var run_and_gun_elapsed_time := 0.0

@export var dash_windup_state_time: float
var dash_windup_elapsed_time := 0.0

@export var dash_state_time: float
var dash_elapsed_time := 0.0

@export_group("Raycast")
@export var ray_count:int = 10
@export var ray_length:float =10000
@export_flags_2d_physics var collision_mask: int = 1
@onready var debug_line = Line2D.new()

@onready var enemey_colider:Area2D = get_node("EnemyArea")

var dash_timer := 0.0
var previous_dash_number = 0

var dash_speed = max_speed * dash_mult
var current_dash_direction: Vector2 = Vector2.ZERO

enum State {
	IDLE,
	TELEGRAPH, #Before moving
	MOVE,
	WINDUP, #Before attacking
	ATTACK,
	RUNANDGUN,
	DASHWINDUP, #Before dashing
	DASH
}

@onready var capture_sfx:AudioStreamPlayer = get_node("CaptureSFX")
var captured = false
var current_state = State.IDLE
var previous_state = State.IDLE

var direction := Vector2(
		randi_range(-1, 1),
		randi_range(-1,1)
		)
var magnitude := randi_range(1, max_speed)

func _ready(): #setup
	get_parent().add_child(debug_line)
	enemey_colider.area_entered.connect(_on_area_entered)
	EventBus.LoopCreated.connect(check_circled)
	EventBus.ComboIncreased.connect(take_damage)
	add_child(decay_start_timer)
	decay_start_timer.timeout.connect(start_decay)
	decay_start_timer.autostart = true
	capture_bar.max_value = decay_rate.max_value
	EventBus.GameOver.connect(on_game_over)
	capture_sfx.finished.connect(on_capture)
	reset_timer()
	pass

func _process(delta: float) -> void: #loop
	state_logic(delta)
	current_state = get_transition(delta)
	if current_state != previous_state:
		match current_state:
			State.IDLE:
				print("In IDLE state")
			State.TELEGRAPH:
				print("In TELEGRAPH state")
			State.MOVE:
				print("In MOVE state")
			State.WINDUP:
				print("In WINDUP state")
			State.ATTACK:
				print("In ATTACK state")
			State.RUNANDGUN:
				print("In RUNANDGUN state")
			State.DASHWINDUP:
				print("In DASHWINDUP state")
			State.DASH:
				print("In DASH state")
	previous_state = current_state
	if is_decaying:
		decay_duration-=delta
		capture_health = decay_rate.sample(decay_duration)
		# decay_rate.sample(t)

	if capture_health >= decay_rate.max_value:
		if captured == false:
			print("we have been captured")
			capture_sfx.playing=true
			captured = true


	if capture_health < 0:
		capture_health = 0
		is_decaying = false
		decay_start_timer.stop()

	capture_bar.value = capture_health

func on_capture():
	EventBus.UpdateScore.emit(capture_score)
	# todo play death animation and await till done
	queue_free()

func on_game_over():
	queue_free()

func start_decay():
	decay_duration = get_x_from_y(decay_rate,capture_health)
	print(decay_duration)
	is_decaying=true
	decay_start_timer.stop()
	pass

func get_x_from_y(curve: Curve, target_y: float, step: float = 0.1) -> float:
	var closest_x = 0.0
	var closest_diff = INF

	for x in range(0, int(curve.max_domain / step) + 1):
		var sample_x = x * step
		var sample_y = curve.sample(sample_x)
		var diff = abs(sample_y - target_y)
		if diff < closest_diff:
			closest_diff = diff
			closest_x = sample_x
		if closest_diff == 0.0:
			return closest_x

	return closest_x

func _on_area_entered(area) -> void:
	if area.name == "LineCollider" or area.name == "LineColliderBody":
		EventBus.EnemyCollision.emit()
		print("Hit deteceted: " + area.name)
		pass

func take_damage(combo:int):
	capture_health += combo
	if capture_health > decay_rate.max_domain:
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
		State.TELEGRAPH:
			return telegraphTransition(delta)
		State.MOVE:
			return moveTransition(delta)
		State.ATTACK:
			return attackTransition(delta)
		State.WINDUP:
			return windupTransition(delta)
		State.RUNANDGUN:
			return runAndGunTransition(delta)
		State.DASHWINDUP:
			return dashWindupTransition(delta)
		State.DASH:
			return dashTransition(delta)
	return State.IDLE #default is override

#State logic
func state_logic(delta: float):
	match current_state:
		State.IDLE:
			idleState(delta)
		State.TELEGRAPH:
			telegraphState(delta)
		State.MOVE:
			moveState(delta)
		State.ATTACK:
			attackState(delta)
		State.WINDUP:
			windupState(delta)
		State.RUNANDGUN:
			runAndGunState(delta)
		State.DASHWINDUP:
			dashWindupState(delta)
		State.DASH:
			dashState(delta)


#Transistion functions
func idleTransition(delta: float) -> State: # Default transition strucuture for only on transition option
	if idle_elapsed_time < idle_state_time:
		idle_elapsed_time += delta
		return State.IDLE
	else:
		idle_elapsed_time = 0.0
		return State.IDLE

func telegraphTransition(delta: float) -> State:
	if telegraph_elapsed_time < telegraph_state_time:
		telegraph_elapsed_time += delta
		return State.TELEGRAPH
	else:
		telegraph_elapsed_time = 0.0
		return State.MOVE

func moveTransition(delta: float) -> State:
	return State.IDLE
	pass

func windupTransition(delta: float) -> State:
	if windup_elapsed_time < windup_state_time:
		windup_elapsed_time += delta
		return State.WINDUP
	else:
		windup_elapsed_time = 0.0
		return State.ATTACK

func attackTransition(delta: float) -> State:
	return State.IDLE
	pass

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
		return State.DASH

func dashTransition(delta: float) -> State:
	return State.IDLE
	pass

# State logic functions
func idleState(delta: float): #State logic for idle state
	pass

func telegraphState(delta: float):
	var texture_size = $EnemySprite.texture.get_size()
	var sprite_size = texture_size * $EnemySprite.scale
	var enemy_radius = max(sprite_size.x, sprite_size.y) * 0.5

	# First time entering state logic
	if telegraph_elapsed_time == 0:

		#Repel enemy away from edge of screen if too close
		var screen_size = get_viewport_rect().size
		var repel_force := Vector2.ZERO
		var global_pos = global_position

		# Vector from screen center to NPC
		var to_center = (screen_size * 0.5) - global_pos

		# If we're near the edge, repel in the direction of `to_center` the closer to edge, the stronger the repel
		var edge_distance = min(global_pos.x, screen_size.x - global_pos.x,
						global_pos.y, screen_size.y - global_pos.y)

		if edge_distance < edge_gap:
			var repel_strength = (edge_gap - edge_distance) / edge_gap
			repel_force = to_center.normalized() * repel_strength
		else:
			repel_force = Vector2.ZERO

		# Generate random direction vector
		# Determine edge proximity
		var near_left = global_pos.x - enemy_radius < edge_gap
		var near_right = global_pos.x + enemy_radius > screen_size.x - edge_gap
		var near_top = global_pos.y - enemy_radius < edge_gap
		var near_bottom = global_pos.y + enemy_radius > screen_size.y - edge_gap

		# Try to find a safe direction
		var max_attempts = 50
		var found_valid = false

		for i in max_attempts:
			var angle = randf_range(0, TAU)
			var test_direction = Vector2(cos(angle), sin(angle))

			# Check if direction is trying to go toward an edge we’re near
			var invalid = (
				(near_left and test_direction.x < 0.0) or
				(near_right and test_direction.x > 0.0) or
				(near_top and test_direction.y < 0.0) or
				(near_bottom and test_direction.y > 0.0)
			)

			if not invalid:
				direction = test_direction.normalized()
				found_valid = true
				break

		# If no safe direction found, default to something safe (e.g. toward center)
		if not found_valid:
			direction = (global_pos - screen_size * 0.5).normalized()

		# Generate random magnitude
		magnitude = randi_range(1, max_speed)

	#Scale the telegraph sprite

	# Parameters you can tweak to balance visual size
	var base_scale := 0.5  # Minimum scale when magnitude is low
	var scale_range := 0.5 # Additional scale at max speed (total = base + range = 1.0 at max speed)

	# Calculate scale based on speed
	var speed_ratio = clamp(magnitude / max_speed, 0.0, 1.0)
	var desired_scale = base_scale + (scale_range * speed_ratio)

	var telegraph_texture_size = $TelegraphSprite.texture.get_size()

	# Determine the maximum size we want relative to the enemy sprite
	var target_size = sprite_size * desired_scale

	# Calculate uniform scale factor based on the smaller ratio (to fit within bounds)
	var scale_factor = min(
		target_size.x / telegraph_texture_size.x,
		target_size.y / telegraph_texture_size.y
	)
	# Apply uniform scale to preserve aspect ratio
	$TelegraphSprite.scale = Vector2.ONE * scale_factor

	if direction != Vector2.ZERO:

		# Rotate the sprite to the same direction as vector
		var telegraph_direction = direction.normalized()
		$TelegraphSprite.rotation = direction.angle() + deg_to_rad(90)


	# Position the telegraph arrow next to the enemy sprite, in the given direction
	var offset_distance = enemy_radius + 10  # "10" is margin to push it slightly outside
	$TelegraphSprite.position = $EnemySprite.position + direction * offset_distance

	# Dynamically figure out how long to blink for based on delta and telegraph blink counter
	var telegraph_period = (telegraph_state_time / (telegraph_blink_count * 2))

	var blink_phase = int(telegraph_elapsed_time / telegraph_period) % 2
	$TelegraphSprite.visible = blink_phase == 0

func moveState(delta: float): #Default movement behavior
	var screen_size = get_viewport_rect().size
	var texture_size = $EnemySprite.texture.get_size()
	var sprite_size = texture_size * $EnemySprite.scale

	# Disable the telegraph sprite while moving
	$TelegraphSprite.visible = false

	# Move by vector
	var offset = direction * magnitude
	position += offset
	
	#Rotate to match direction
	$EnemySprite.rotation  = direction.angle() + deg_to_rad(180)
	$EnemySprite.flip_v = direction.x > 0

	#Clamping to screen size
	screenClamp()

func windupState(delta: float):
	var mat = $EnemySprite.material as ShaderMaterial
	
	if windup_elapsed_time == 0.0:
		projectile_direction = generate_direction()
		#Rotate to match direction
		$EnemySprite.rotation  = projectile_direction.angle() + deg_to_rad(180)
		$EnemySprite.flip_v = direction.x > 0
	# Dynamically figure out how long to blink for based on delta and windup blink counter
	var windup_period = (windup_state_time / (windup_blink_count * 2))

	var blink_phase = int(windup_elapsed_time / windup_period) % 2

	var flashing = blink_phase == 0

	mat.set_shader_parameter("active", flashing)
	#await get_tree().create_timer(0.1).timeout
	#mat.set_shader_parameter("active", false)

func attackState(delta: float):
	var mat = $EnemySprite.material as ShaderMaterial
	mat.set_shader_parameter("active", false)
	#Do the first time the state is entered
	if attack_elapsed_time == 0.0:
		print("First time in attack state")
		#projectile_direction = Utils.random_direction()
		#projectile_direction = generate_direction()
		projectile_timer = 0.0
		current_projectiles = 0
		
	
	var projectile_period = attack_state_time / number_of_projectiles
	
	if current_projectiles < number_of_projectiles:
		projectile_timer += delta
		if projectile_timer >= projectile_period:
			projectile_timer -= projectile_period
			var projectile = projectile_scene.instantiate()
			projectile.set_direction(projectile_direction)
			#Rotate to match direction
			$EnemySprite.rotation  = projectile_direction.angle() + deg_to_rad(180)
			$EnemySprite.flip_v = direction.x > 0
			get_tree().current_scene.add_child(projectile)
			projectile.global_position = global_position
			current_projectiles += 1

func runAndGunState(delta: float):
	pass

func dashWindupState(delta: float):
	$DashWindupSprite.visible = true
	pass

func dashState(delta: float):
	
	if $DashWindupSprite.visible == true:
		$DashWindupSprite.visible = false
		
	var dash_period = dash_state_time / number_of_dashes
	var dash_phase = int(dash_elapsed_time / dash_period)
	dash_speed = max_speed * dash_mult

	if dash_phase != previous_dash_number and dash_phase < number_of_dashes:
		previous_dash_number = dash_phase
		#current_dash_direction = change_direction()
		direction = change_direction()
	moveInDirection(direction, dash_speed)
	screenClamp()

func screenClamp():
	var screen_size = get_viewport_rect().size
	var texture_size = $EnemySprite.texture.get_size()
	var sprite_size = texture_size * $EnemySprite.scale

	# Clamping to screen size
	var margin = (sprite_size.x / 2) + edge_gap

	if position.x < margin:
		position.x = lerp(position.x, margin, 0.5)
	elif position.x > screen_size.x - margin:
		position.x = lerp(position.x, screen_size.x - margin, 0.5)

	if position.y < margin:
		position.y = lerp(position.y, margin, 0.5)
	elif position.y > screen_size.y - margin:
		position.y = lerp(position.y, screen_size.y - margin, 0.5)

func moveInDirection(new_direction: Vector2, new_magnitude: int):
	var offset = new_direction * new_magnitude
	position += offset
	#Rotate to match direction
	$EnemySprite.rotation  = direction.angle() + deg_to_rad(180)
	$EnemySprite.flip_v = direction.x > 0
	
func generate_direction() -> Vector2:
	var texture_size = $EnemySprite.texture.get_size()
	var sprite_size = texture_size * $EnemySprite.scale
	var enemy_radius = max(sprite_size.x, sprite_size.y) * 0.5
	
	#Repel enemy away from edge of screen if too close
	var screen_size = get_viewport_rect().size
	var repel_force := Vector2.ZERO
	var global_pos = global_position

	# Vector from screen center to NPC
	var to_center = (screen_size * 0.5) - global_pos

	# If we're near the edge, repel in the direction of `to_center` the closer to edge, the stronger the repel
	var edge_distance = min(global_pos.x, screen_size.x - global_pos.x,
					global_pos.y, screen_size.y - global_pos.y)

	if edge_distance < edge_gap:
		var repel_strength = (edge_gap - edge_distance) / edge_gap
		repel_force = to_center.normalized() * repel_strength
	else:
		repel_force = Vector2.ZERO

	# Generate random direction vector
	# Determine edge proximity
	var near_left = global_pos.x - enemy_radius < edge_gap
	var near_right = global_pos.x + enemy_radius > screen_size.x - edge_gap
	var near_top = global_pos.y - enemy_radius < edge_gap
	var near_bottom = global_pos.y + enemy_radius > screen_size.y - edge_gap

	# Try to find a safe direction
	var max_attempts = 50
	var found_valid = false

	for i in max_attempts:
		var angle = randf_range(0, TAU)
		var test_direction = Vector2(cos(angle), sin(angle))

		# Check if direction is trying to go toward an edge we’re near
		var invalid = (
			(near_left and test_direction.x < 0.0) or
			(near_right and test_direction.x > 0.0) or
			(near_top and test_direction.y < 0.0) or
			(near_bottom and test_direction.y > 0.0)
		)

		if not invalid:
			return test_direction.normalized()
			

	# If no safe direction found, default to something safe (e.g. toward center)
	if not found_valid:
		return (global_pos - screen_size * 0.5).normalized()
	else:
		return direction

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
