extends Node2D

@export var line: Line2D

func _ready():
	pass


func _process(delta):
	var mouse_position = get_viewport().get_mouse_position()


	if Input.is_mouse_button_pressed( 1 ): # Left click
		position = mouse_position
		line.add_point(mouse_position)
	pass
