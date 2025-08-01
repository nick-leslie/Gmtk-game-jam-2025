extends Control

@onready var combo_counnter:RichTextLabel = get_node("Combo")


func _ready() -> void:
	var player = get_parent().get_node("Player")
	print(player)
	if player != null:
		player.connect("loop_complete",on_loop_compleate)
	pass

func on_loop_compleate(combo:int):
	var string = "[font_size={{size}}]{combo}[/font_size]".format({"combo":combo,"size":100+combo})
	#todo animation???? cool like scaling fount based on combo sizer
	combo_counnter.clear()
	combo_counnter.append_text(string)
	pass
