extends Node

@export var easy_waves:Array[Wave]
@export var med_waves:Array[Wave]
@export var hard_waves:Array[Wave]

@export var med_threashold:int
@export var hard_threashold:int

var enemys
var current_wave: Array[Enemy]

var game_over := false

@onready var player:player = get_node("Player")

func _ready() -> void:
	EventBus.GameOver.connect(get_game_over)
	EventBus.NewGame.connect(get_new_game)
	pass

func _process(delta: float) -> void:
	if game_over:
		current_wave = []
	for enemy in current_wave:
		if is_instance_valid(enemy):
			return
	current_wave = []
	if !game_over:
		spawn_new_wave()
	pass


func spawn_new_wave():
	if player.combo >= med_threashold:
		spawn_wave(med_waves[randi() % med_waves.size()])
	elif  player.combo >= hard_threashold:
		spawn_wave(hard_waves[randi() % hard_waves.size()])
	else:
		spawn_wave(easy_waves[randi() % easy_waves.size()])


func spawn_wave(wave:Wave):
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

func get_game_over(final_score:int):
	for enemy in current_wave:
		if is_instance_valid(enemy):
			enemy.queue_free()
	current_wave = []
	game_over = true
