extends Enemy

#Transistion functions
func idleTransition():
	var random_number = randi() % 10
	if random_number > 5:
		print("Going to move state")
		return State.MOVE
	else:
		return State.IDLE
	
func moveTransition():
	var random_number = randi() % 10
	if random_number > 5:
		print("Going to move state")
		return State.MOVE
	else:
		return State.IDLE
	
func windupTransition():
	pass
	
func attackTransition():
	pass
	
func runAndGunTransition():
	pass	
	
func dashTransition():
	pass

# State logic functions
func idleState(): #State logic for idle state
	pass
	
func moveState():
	var screen_size = get_viewport_rect().size
	var texture_size = $Sprite2D.texture.get_size()
	var sprite_size = texture_size * $Sprite2D.scale
	
	print("In move state")
	var direction_x = randi_range(-1, 1)
	var random_number_x = (randi() % 10) * direction_x
	
	var direction_y = randi_range(-1, 1)
	var random_number_y = (randi() % 10) * direction_y
	position.x += random_number_x
	position.y += random_number_y
	
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
