extends CanvasLayer

@export var delay_to_start_screen: float = 5.0
var time_elapsed := 0.0

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
	


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
