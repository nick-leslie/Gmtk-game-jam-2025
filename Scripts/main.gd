extends Node2D

@export var enemy_scene: PackedScene

func _ready():
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(300, 300)
	add_child(enemy)
