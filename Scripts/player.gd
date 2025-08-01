extends Node2D
class_name player


@onready var line: Line2D = get_node("Line")
@onready var stylest = get_node("Stylest")
@onready var start_obj: Node2D = get_node("StartNode")
@onready var line_colider: Area2D = get_node("Line/LineCollider")
@onready var head_collider : CollisionShape2D = get_node("HeadColliderBody/HeadCollider")
# @export var point_scene: PackedScene
# @export var main_node: Node2D


signal loop_complete

var drawing = false
var prev_pos = Vector2(0, 0)


func _ready():
	line_colider.area_entered.connect(on_loop_created)
	pass

func on_loop_created(area):
	if area.name == "HeadColliderBody":
		loop_complete.emit()
		print("Line is overlapping")
	pass

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
			#TODO maybe not free all of these
		drawing = false
