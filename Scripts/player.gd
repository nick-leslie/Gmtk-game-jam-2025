extends Node2D
class_name player

@export var starting_health: int = 3
@onready var line: Line2D = get_node("Line")
@onready var stylest = get_node("Stylest")
@onready var start_obj: Node2D = get_node("StartNode")
@onready var line_colider: Area2D = get_node("Line/LineCollider")
@onready var head_collider : CollisionShape2D = get_node("HeadColliderBody/HeadCollider")
@export var close_point_count: int
@export var point_scene: PackedScene


@export var min_range:float
@export var combo_decay_timeout:float
@export var max_allowed_decay:int
@onready var current_range = min_range
@onready var combo_decay_timer:Timer = Timer.new()
var is_combo_in_danger = false
var combo_count_decayed = 0
var max_combo_value:int



var col_shape_dict: Dictionary = {} # every colider is indexed by
var current_health

var drawing = false
var been_hit := false
var mouse_prev_state := false #true is pressed, false is not pressed
var prev_pos = Vector2(0, 0)

var combo = 0

func _ready():
	current_health = starting_health
	line_colider.area_entered.connect(on_loop_created)
	EventBus.EnemeyCircled.connect(increase_combo)
	EventBus.EnemyCollision.connect(hit_enemy)
	EventBus.ProjectileCollision.connect(hit_projectile)
	print("Starting health: " + str(current_health))
	call_deferred("_emit_health") # Need to do this so that the UI node has time to also run its _ready() function
	combo_decay_timer.wait_time = combo_decay_timeout
	combo_decay_timer.timeout.connect(decay_combo)
	combo_decay_timer.stop()
	add_child(combo_decay_timer)
	pass


func _physics_process(delta: float) -> void:
	var mouse_position = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size

	current_range=min_range+(20*combo)

	if max_combo_value < combo:
		max_combo_value = combo
		EventBus.MaxComboIncreased.emit(max_combo_value)

	queue_redraw()
	var is_offscreen = false
	if mouse_position.x < 0 or mouse_position.y < 0 or mouse_position.x > viewport_size.x or mouse_position.y > viewport_size.y:
		is_offscreen = true
	#print("Mouse Offscreen: " + str(is_offscreen))
	if combo_count_decayed > max_allowed_decay:
		end_combo()

	var pos = mouse_position
	if Input.is_mouse_button_pressed( 1 ) and !been_hit and !is_offscreen: # Left click


		if is_combo_in_danger == true:
			combo_count_decayed=0
			reset_combo_decay_timer()
			EventBus.ComboSalvaged.emit()


		head_collider.disabled = false
		mouse_prev_state = true

		if drawing && pos.distance_to(start_obj.position) < current_range:
			move_stylest(pos)

		if drawing == false:
			drawing = true
			start_obj.position = mouse_position

		var point_count = line.get_point_count()

		if point_count < 1:
			prev_pos = mouse_position
			return

		prev_pos = mouse_position
	elif drawing:
		# we let go of the mouse and should start decaying
		print("we should be decaying combo")
		start_obj.position = pos
		clear_line()
		start_decaying_combo()
	else:
		stylest.position = pos
		start_obj.position = pos
			#TODO maybe not free all of these
	#Reset the hit counter so the user can start drawing again
	if mouse_prev_state and !Input.is_mouse_button_pressed( 1 ) and been_hit == true:
		been_hit = false
	mouse_prev_state = Input.is_mouse_button_pressed( 1 )

func _draw():
	var center = start_obj.position  # Position of the circle
	var radius = current_range                 # Circle radius
	var start_angle = 0             # Start angle in radians
	var end_angle = TAU             # Full circle (TAU = 2 * PI)
	var point_count = 64            # Smoothness of the circle
	var color = Color(0, 0, 0,1)      # Red color
	var line_width = 2.0            # Thickness of the circle line

	draw_arc(center, radius, start_angle, end_angle, point_count, color, line_width)


func move_stylest(pos:Vector2):
	stylest.position = pos

	if pos.distance_to(prev_pos) > 5:

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
			head_line_shape.a = pos
			head_line_shape.b = line.get_point_position(count-2)
			head_collider.shape = head_line_shape

func end_combo():
	combo = 0
	current_range=min_range
	reset_combo_decay_timer()
	combo_count_decayed=0
	EventBus.ComboEnded.emit(max_combo_value)
	max_combo_value=0


func increase_combo():
	combo+=1
	EventBus.ComboIncreased.emit(combo)

func clear_line():
	line.clear_points()
	head_collider.disabled = true
	for child in line_colider.get_children():
		child.queue_free()
	drawing = false



func reset_combo_decay_timer():
	combo_decay_timer.stop()
	combo_decay_timer.wait_time = combo_decay_timeout
	is_combo_in_danger=false

func start_decaying_combo():
	combo_decay_timer.start()
	EventBus.ComboDecaying.emit()
	is_combo_in_danger = true

func _emit_health():
	EventBus.SetPlayerHealth.emit(current_health)

func on_loop_created(area):
	if area.name == "HeadColliderBody":
		EventBus.LoopCreated.emit()
		var closest_index = get_closest_point_index()
		remove_colider(closest_index)
		remove_colider(closest_index-1)
		remove_colider(closest_index-2)
		var point_count = line.get_point_count()
		for i in range(closest_index+1,point_count+1):
			if closest_index < line.points.size():
				line.remove_point(closest_index+1)
				remove_colider(i)

func hit_enemy():
	if !been_hit:
		reduce_health()

func decay_combo():
	print("decayed")
	combo-=1
	combo_count_decayed+=1
	if combo_count_decayed >= max_allowed_decay or combo <= 0:
		EventBus.ComboEnded.emit(max_combo_value)
		reset_combo_decay_timer()
	else:
		EventBus.ComboDecreased.emit(combo)
	pass

func hit_projectile():
	#print("Hit projectile")
	#print("Been hit status: " + str(been_hit))
	if Input.is_mouse_button_pressed( 1 ) and !been_hit:
		reduce_health()

func reduce_health():
	clear_line()
	been_hit = true
	end_combo()
	if current_health > 0: #making sure health doesn't go negative
		current_health -= 1

	if current_health == 0:
		EventBus.GameOver.emit()
		print("Game over!")
		get_tree().change_scene_to_file("res://Scenes/ui/game_over.tscn")

	EventBus.SetPlayerHealth.emit(current_health)

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
