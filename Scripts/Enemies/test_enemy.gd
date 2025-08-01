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

# State logic functions
	
func moveState():
	var screen_size = get_viewport_rect().size
	var texture_size = $EnemySprite.texture.get_size()
	var sprite_size = texture_size * $EnemySprite.scale
	
	# Disable the telegraph sprite while moving
	$TelegraphSprite.visible = false
	
	# Move by vector
	var offset = direction * magnitude
	position += offset
	
	#Clamping to screen size
	position.x = clamp(position.x, 0 + (sprite_size.x/2), screen_size.x - (sprite_size.x/2))
	position.y = clamp(position.y, 0 + (sprite_size.y/2), screen_size.y - (sprite_size.y/2))
