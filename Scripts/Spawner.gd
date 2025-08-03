extends Node

@export var waves:Array[Wave]
var enemys
var current_wave: Array[Enemy]

var game_over := false

func _ready() -> void:
	EventBus.GameOver.connect(get_game_over)
	EventBus.NewGame.connect(get_new_game)
	pass

func _process(delta: float) -> void:
	for enemy in current_wave:
		if is_instance_valid(enemy):
			return
	current_wave = []
	if !game_over:
		spawn_new_wave()
	pass


func spawn_new_wave():
	var wave_choice = randi() % waves.size()
	var wave = waves[wave_choice]
	for enemy_scene in wave.Enemys:
		var enemy = enemy_scene.instantiate()
		enemy.position = get_random_screen_position(300)
		get_parent().add_child(enemy)
		current_wave.append(enemy)
		pass

func get_random_screen_position(buffer: float = 300.0) -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	return Vector2(
		randf() * (viewport_size.x - buffer * 2) + buffer,
		randf() * (viewport_size.y - buffer * 2) + buffer
	)
	
func get_new_game():
	game_over = false

func get_game_over():
	game_over = true
