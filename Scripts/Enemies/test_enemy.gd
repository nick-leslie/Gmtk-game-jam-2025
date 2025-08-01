extends Enemy

var direction := Vector2(
		randi_range(-1, 1),
		randi_range(-1,1)
		)
var magnitude := randi_range(1, max_speed)

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

# State logic functions
func idleState(): #State logic for idle state
	pass
	
func telegraphState():
	
	var texture_size = $EnemySprite.texture.get_size()
	var sprite_size = texture_size * $EnemySprite.scale
	var enemy_radius = max(sprite_size.x, sprite_size.y) * 0.5
	
	# First time entering state logic
	if telegraph_elapsed_time == 0:
		# Generate random direction vector
		var angle = randf_range(0, TAU)
		direction = Vector2(cos(angle), sin(angle))
		# TODO bias it to move in away from the edge of the screen if it gets too close
	
		# Generate random magnitude 
		magnitude = randi_range(1, max_speed)
		
	#Scale the telegraph sprite	
	var telegraph_texture_size = $TelegraphSprite.texture.get_size()
	var target_size = sprite_size * (magnitude / max_speed) # TODO might need to scale this better
	
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
	
func moveState():
	var screen_size = get_viewport_rect().size
	var texture_size = $EnemySprite.texture.get_size()
	var sprite_size = texture_size * $EnemySprite.scale
	
	
	# Move by vector
	var offset = direction * magnitude
	position += offset
	
	#Clamping to screen size
	position.x = clamp(position.x, 0 + (sprite_size.x/2), screen_size.x - (sprite_size.x/2))
	position.y = clamp(position.y, 0 + (sprite_size.y/2), screen_size.y - (sprite_size.y/2))

func windupState():
	pass
	
func attackState():
	pass

func runAndGunState():
	pass
	
func dashState():
	pass
