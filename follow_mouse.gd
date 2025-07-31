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
			if count > 1:  
				print("running")
				var col_shape = CollisionShape2D.new()
				var line_col = SegmentShape2D.new()
				line_col.a = pos
				line_col.b = line.get_point_position(count-2)
				print(pos)
				print(line.get_point_position(count-2))
				col_shape.shape = line_col
				collider.add_child(col_shape)

			
			
		if drawing == false:
			drawing = true
			start_obj.position = pos
		# collision detection test
		var point_count = line.get_point_count()
		print(point_count)
		if point_count < 1:
			prev_pos = mouse_position
			return
		#for i in point_count-2:
				#var searched_forward = line.get_point_position(i+1)
				#var searched_back = line.get_point_position(i)
				#
				#var current = line.get_point_position(point_count)
				#var prev = line.get_point_position(point_count-1)
				#
				#var uA = ((prev.x-current.x)*(searched_forward.y-current.y) - (prev.y-current.y)*(searched_forward.x-current.x)) / ((prev.y-current.y)*(searched_back.x-searched_forward.x) - (prev.x-current.x)*(searched_back.y-searched_forward.y));
				#var uB = ((searched_back.x-searched_forward.x)*(searched_forward.y-current.y) - (searched_back.y-searched_forward.y)*(searched_forward.x-current.x)) / ((prev.y-current.y)*(searched_back.x-searched_forward.x) - (prev.x-current.x)*(searched_back.x-searched_forward.x));
				#
				#print("hello")
				#
			
			#var dist = pos.distance_to(line.get_point_position(i))
			#if dist < col_dist and i < point_count-too_close_count:
				#print(true)
				#line.clear_points()
				#break
			#pass
		prev_pos = mouse_position
	elif drawing:
		line.clear_points()
		drawing = false
	
