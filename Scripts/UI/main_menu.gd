extends CanvasLayer

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn") #TODO make a level select screen
	


func _on_options_pressed() -> void:
	pass #TODO replace with the options menu


func _on_quit_pressed() -> void:
	get_tree().quit()
