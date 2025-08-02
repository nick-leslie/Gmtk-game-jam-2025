extends Enemy


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
func idleState(delta: float): #State logic for idle state
	pass

func attack_state():
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
