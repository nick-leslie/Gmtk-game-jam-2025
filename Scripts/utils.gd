# Utils.gd

static func random_direction() -> Vector2:
	var random_direction := Vector2.ZERO
	while random_direction == Vector2.ZERO:
		var angle = randf_range(0, TAU)  # TAU is 2π
		random_direction = Vector2(cos(angle), sin(angle))
	return random_direction
