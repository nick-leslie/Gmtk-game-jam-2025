extends CanvasLayer

@onready var select_sfx: AudioStreamPlayer = get_node("Control/VBoxContainer/SelectSFX")
@onready var score_lable:RichTextLabel = get_node("Control/VBoxContainer/ScoreLabel")
func _ready() -> void:
	score_lable.text = "[color=gold][outline_size={5}][font_size={50}]Score: "+ str(EventBus.final_score) + "[/font_size][/outline_size][/color] " 
	pass

func _process(delta: float) -> void:
	pass



func _on_play_again_pressed() -> void:
	select_sfx.play()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_quit_pressed() -> void:
	select_sfx.play()
	await select_sfx.finished
	get_tree().quit()
