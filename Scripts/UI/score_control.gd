extends Control

@onready var combo_counnter:RichTextLabel = get_node("Combo")


func _ready() -> void:
	EventBus.ComboIncreased.connect(combo_increaded)
	EventBus.ComboEnded.connect(combo_ended)
	pass

func combo_increaded(combo:int):
	var string = "[font_size={{size}}]{combo}[/font_size]".format({"combo":combo,"size":100+combo})
	#todo animation???? cool like scaling fount based on combo sizer
	set_counter(string)
	pass

func combo_ended():
	var string = "[font_size={{size}}]{combo}[/font_size]".format({"combo":0,"size":100})
	set_counter(string)

func set_counter(string):
	combo_counnter.clear()
	combo_counnter.append_text(string)
