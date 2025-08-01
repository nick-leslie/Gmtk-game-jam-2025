extends Node2D
class_name player


@onready var line: Line2D = get_node("Line")
@onready var stylest = get_node("Stylest")
@onready var start_obj: Node2D = get_node("StartNode")
@onready var line_colider: Area2D = get_node("Line/LineCollider")
@onready var head_collider : CollisionShape2D = get_node("HeadColliderBody/HeadCollider")
@export var close_point_count: int
@export var point_scene: PackedScene
var col_shape_dict: Dictionary = {}

var drawing = false
var prev_pos = Vector2(0, 0)

var combo = 0


func _ready():
	line_colider.area_entered.connect(on_loop_created)
	EventBus.EnemeyCircled.connect(increase_combo)
	pass

func increase_combo():
	combo+=1
	EventBus.ComboIncreased.emit(combo)

func on_loop_created(area):
	if area.name == "HeadColliderBody":
		EventBus.LoopCreated.emit()
		var closest_index = get_closest_point_index()
		remove_colider(closest_index)
		remove_colider(closest_index-1)
		remove_colider(closest_index-2)
		var point_count = line.get_point_count()
		for i in range(closest_index+1,point_count+1):
			line.remove_point(closest_index+1)
			remove_colider(i)




func remove_colider(index:int):
	if col_shape_dict.has(index):
		var collider = col_shape_dict[index]
		if is_instance_valid(collider):
			collider.queue_free()
		col_shape_dict.erase(index)


func get_closest_point_index():
	var point_count = line.get_point_count()
	var last_point = line.get_point_position(point_count-2)
	var closest = 0
	var closest_dist = last_point.distance_to(line.get_point_position(0))

	for i in range(1,point_count-close_point_count):
		var point = line.get_point_position(i+1)
		var dist = point.distance_to(last_point)
		if dist < closest_dist:
			closest = i
			closest_dist = dist
	return closest

func _physics_process(delta: float) -> void:
	var mouse_position = get_viewport().get_mouse_position()

	if Input.is_mouse_button_pressed( 1 ): # Left click
		var pos = mouse_position
		stylest.position = mouse_position

		if pos.distance_to(prev_pos) > 1:

			line.add_point(pos)
			var count = line.get_point_count()
			if count > 3:
				#print("running")
				# Adding the collider to the line
				var col_shape = CollisionShape2D.new()
				var line_col = SegmentShape2D.new()
				line_col.a = line.get_point_position(count-3)
				line_col.b = line.get_point_position(count-4)
				col_shape.shape = line_col
				col_shape_dict[count-4] = col_shape
				line_colider.add_child(col_shape)

			if count > 1:
				#Adding the second line from the sytlist to the last point
				var head_line_shape = SegmentShape2D.new()
				head_line_shape.a = mouse_position
				head_line_shape.b = line.get_point_position(count-2)
				head_collider.shape = head_line_shape


		if drawing == false:
			drawing = true
			start_obj.position = pos
		var point_count = line.get_point_count()

		if point_count < 1:
			prev_pos = mouse_position
			return

		prev_pos = mouse_position
	elif drawing:
		line.clear_points()
		for child in line_colider.get_children():
			child.queue_free()
		combo = 0
		EventBus.ComboEnded.emit()
			#TODO maybe not free all of these
		drawing = false
