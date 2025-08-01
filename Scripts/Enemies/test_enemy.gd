extends Enemy

@export var idle_state_time: float
var idle_counter := 0.0

@export var move_state_time: float
var move_counter := 0.0



#Transistion functions
func idleTransition(delta: float):
	if idle_counter < idle_state_time:
		idle_counter += delta
		return State.IDLE
	else:
		idle_counter = 0.0
		return State.MOVE
	
func moveTransition(delta: float):
	if move_counter < move_state_time:
		move_counter += delta
		return State.MOVE
	else:
		move_counter = 0.0
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
	
func moveState():
	var screen_size = get_viewport_rect().size
	var texture_size = $Sprite2D.texture.get_size()
	var sprite_size = texture_size * $Sprite2D.scale
	
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
