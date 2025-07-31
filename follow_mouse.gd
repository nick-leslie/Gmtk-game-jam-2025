extends Node2D

@export var line: Line2D
@export var start_obj: Node2D
@export var	col_dist:float
@export var too_close_count:int
var drawing = false
var prev_pos = Vector2(0, 0) 
@export var point_scene: PackedScene
@export var main_node: Node2D
@export var collider: StaticBody2D
@export var head_collider : CollisionShape2D


func _ready():
	pass


func _process(delta: float) -> void:
	var mouse_position = get_viewport().get_mouse_position()
	
	if Input.is_mouse_button_pressed( 1 ): # Left click
		var pos = mouse_position
		position = mouse_position
		
		if pos.distance_to(prev_pos) > 1:
			
			line.add_point(pos)
			var point = point_scene.instantiate()
			point.position = pos
			main_node.add_child(point)
			var count = line.get_point_count() 
			if count > 4:  
				#print("running")
				# Adding the collider to the line
				var col_shape = CollisionShape2D.new()
				var line_col = SegmentShape2D.new()
				line_col.a = line.get_point_position(count-3)
				line_col.b = line.get_point_position(count-4)
				print(pos)
				print(line.get_point_position(count-2))
				col_shape.shape = line_col
				collider.add_child(col_shape)
				
			if count > 1:
				#Adding the second line from the sytlist to the last point
				var head_line_shape = SegmentShape2D.new()
				head_line_shape.a = pos
				head_line_shape.b = line.get_point_position(count-2)
				head_collider.shape = head_line_shape

			
		if drawing == false:
			drawing = true
			start_obj.position = pos
		# collision detection test
		var point_count = line.get_point_count()
		print(point_count)
		if point_count < 1:
			prev_pos = mouse_position
			return
			
			#var dist = pos.distance_to(line.get_point_position(i))
			#if dist < col_dist and i < point_count-too_close_count:
				#print(true)
				#line.clear_points()
				#break
			#pass
		prev_pos = mouse_position
	elif drawing:
		line.clear_points()
		for child in collider.get_children():
			child.queue_free()
			#TODO maybe not free all of these
		drawing = false
	
