extends Node

@export var waves:Array[Wave]
var enemys
var current_wave: Array[Enemy]

var game_over_status = false

func _ready() -> void:
	EventBus.GameOver.connect(game_over)
	EventBus.NewGame.connect(new_game)
	

func _process(delta: float) -> void:
	for enemy in current_wave:
		if is_instance_valid(enemy):
			return
	current_wave = []
	if !game_over_status:
		spawn_new_wave()
	pass


func spawn_new_wave():
	var wave_choice = randi() % waves.size()
	var wave = waves[wave_choice]
	for enemy_scene in wave.Enemys:
		var enemy = enemy_scene.instantiate()
		enemy.position = get_random_screen_position()
		get_parent().add_child(enemy)
		current_wave.append(enemy)
		pass

func get_random_screen_position() -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	return Vector2(
		randf() * viewport_size.x,
		randf() * viewport_size.y
	)

func game_over():
	game_over_status = true

func new_game():
	game_over_status = false
