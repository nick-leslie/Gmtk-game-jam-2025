extends Node

@export var easy_waves:Array[Wave]
@export var medium_waves:Array[Wave]
@export var hard_waves:Array[Wave]
var enemys
var current_wave: Array[Enemy]
@export var edge_limit:float
@export var medium_threashold:int
@export var hard_threashold:int
@onready var player:player = get_node("Player")

var game_over_status = false

func _ready() -> void:

	EventBus.GameOver.connect(game_over)
	EventBus.NewGame.connect(new_game)
	

	spawn_new_wave(easy_waves)
	pass


func _process(delta: float) -> void:
	for enemy in current_wave:
		if is_instance_valid(enemy):
			return
	current_wave = []
  
	if !game_over_status:
    if player.combo > medium_threashold:
      spawn_new_wave(easy_waves)
    elif player.combo > hard_threashold:
      spawn_new_wave(medium_waves)
    else:
      spawn_new_wave(hard_waves)
	pass


func spawn_new_wave(waves:Array[Wave]):
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
		randf() * viewport_size.x + edge_limit,
		randf() * viewport_size.y + edge_limit
	)

func game_over():
	game_over_status = true

func new_game():
	game_over_status = false
