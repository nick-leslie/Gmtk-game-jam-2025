extends Node2D
class_name Projectile

@export var speed: int

@onready var projectile_colider:Area2D = get_node("ProjectileArea")
@onready var screen_notifier = $VisibleOnScreenNotifier2D

var direction := Vector2.ZERO

func _ready() -> void:
	projectile_colider.area_entered.connect(_on_area_entered)
	screen_notifier.screen_exited.connect(_on_screen_exited)
	
	#generate a random non-zero vector
	while direction == Vector2.ZERO:
		var angle = randf_range(0, TAU)  # TAU is 2π
		direction = Vector2(cos(angle), sin(angle))
	pass
	
func _process(delta: float) -> void:
	# Move by vector
	var offset = direction * speed
	position += offset
	pass

func _on_area_entered(area):
	if area.name == "LineCollider" or area.name == "LineColliderBody":
		EventBus.ProjectileCollision.emit()
		#print("Hit detected: " + area.name)
		

func _on_screen_exited():
	queue_free()

func set_direction(new_direction: Vector2):
	direction = new_direction
	
static func random_direction() -> Vector2:
	var random_direction := Vector2.ZERO
	while random_direction == Vector2.ZERO:
		var angle = randf_range(0, TAU)  # TAU is 2π
		random_direction = Vector2(cos(angle), sin(angle))
	return random_direction
