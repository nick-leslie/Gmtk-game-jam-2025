extends Node

@export var waves:Array[Wave]
var enemys
var current_wave: Array[Enemy]


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	for enemy in current_wave:
		if is_instance_valid(enemy):
			return
	current_wave = []
	spawn_new_wave()
	pass


func spawn_new_wave():
	var wave_choice = randi() % waves.size()
	var wave = waves[wave_choice]
	for enemy_scene in wave.Enemys:
		var enemy = enemy_scene.instantiate()
		enemy.position = get_random_screen_position(50)
		get_parent().add_child(enemy)
		current_wave.append(enemy)
		pass

func get_random_screen_position(buffer: float = 150.0) -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	return Vector2(
		randf() * (viewport_size.x - buffer * 2) + buffer,
		randf() * (viewport_size.y - buffer * 2) + buffer
	)
