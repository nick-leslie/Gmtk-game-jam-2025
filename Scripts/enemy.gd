# Enemy.gd
extends Node2D
class_name Enemy

#@export var enemy_stats: Resource #use .tres
@export_category("Stats")
@export var health: float
@export var max_speed: float
@export var dash_mult: float
@export var telegraph_blink_count: int = 3 # How many times you want the telegraph to blink
@export var edge_gap: int = 50 # Pixels away it can get to the edge 
var telegraph_blink_counter := 0 # Number of times the telegraph has blinked

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

@export var dash_state_time: float
var dash_elapsed_time := 0.0



@export_group("Raycast")
@export var ray_count:int = 10
@export var ray_length:float =10000
@export_flags_2d_physics var collision_mask: int = 1
@onready var debug_line = Line2D.new()

@onready var enemey_colider:Area2D = get_node("EnemyArea")

enum State {
	IDLE,
	TELEGRAPH,
	MOVE,
	WINDUP,
	ATTACK,
	RUNANDGUN,
	DASH
}

var current_state = State.IDLE

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
	pass

func _process(delta: float) -> void: #loop
	state_logic()
	current_state = get_transition(delta)

func _on_area_entered(area) -> void:
	if area.name == "HeadColliderBody" or area.name == "LineCollider" or area.name == "LineColliderBody":
		print("Get hit bozo")
		pass

func take_damage(combo:int):
	health -= combo
	print(health)

func check_circled() -> void: # godot refrence magic?
	print("gaming????")
	var looped = check_line_col()
	print(looped)
	if looped:
		EventBus.EnemeyCircled.emit()
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
		State.DASH:
			return dashTransition(delta)
	return State.IDLE #default is override

#State logic
func state_logic():
	match current_state:
		State.IDLE:
			idleState()
		State.TELEGRAPH:
			telegraphState()
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
func idleTransition(delta: float) -> State: # Default transition strucuture for only on transition option
	if idle_elapsed_time < idle_state_time:
		idle_elapsed_time += delta
		return State.IDLE
	else:
		idle_elapsed_time = 0.0
		return State.IDLE
	
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
	
func telegraphState():
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

func moveState(): #Default movement behavior
	var screen_size = get_viewport_rect().size
	var texture_size = $EnemySprite.texture.get_size()
	var sprite_size = texture_size * $EnemySprite.scale
	
	# Disable the telegraph sprite while moving
	$TelegraphSprite.visible = false
	
	# Move by vector
	var offset = direction * magnitude
	position += offset
	
	#Clamping to screen size
	var margin = (sprite_size.x / 2) + edge_gap

	if position.x < margin:
		position.x = lerp(position.x, margin, 0.5)
	elif position.x > screen_size.x - margin:
		position.x = lerp(position.x, screen_size.x - margin, 0.5)

	if position.y < margin:
		position.y = lerp(position.y, margin, 0.5)
	elif position.y > screen_size.y - margin:
		position.y = lerp(position.y, screen_size.y - margin, 0.5)

func windupState():
	pass

func attackState():
	pass

func runAndGunState():
	pass

func dashState():
	pass
