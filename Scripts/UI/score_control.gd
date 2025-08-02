extends Control

@onready var combo_counnter:RichTextLabel = get_node("Combo")
var current_combo:int
var is_combo_decaying = false
func _ready() -> void:
	EventBus.ComboIncreased.connect(combo_changed)
	EventBus.ComboDecreased.connect(combo_changed)
	EventBus.ComboDecaying.connect(combo_decaying)
	EventBus.ComboSalvaged.connect(combo_salvaged)
	EventBus.ComboEnded.connect(combo_ended)
	pass

func combo_decaying():
	is_combo_decaying=true
	var string = "[color=red][font_size={{size}}]{combo}[/font_size][/color]".format({"combo":current_combo,"size":100+current_combo})
	#todo animation???? cool like scaling fount based on combo sizer
	set_counter(string)

func combo_ended():
	is_combo_decaying=false
	var string = "[font_size={{size}}]{combo}[/font_size]".format({"combo":0,"size":100})
	set_counter(string)

func combo_salvaged():
	is_combo_decaying=false
	# var string = "[font_size={{size}}]{combo}[/font_size]".format({"combo":current_combo,"size":100})
	# set_counter(string)
func combo_changed(combo:int):
	current_combo = combo
	if is_combo_decaying:
		var string = "[color=red][font_size={{size}}]{combo}[/font_size][/color]".format({"combo":combo,"size":100+combo})
		set_counter(string)
	else:
		var string = "[font_size={{size}}]{combo}[/font_size]".format({"combo":combo,"size":100+combo})
		set_counter(string)
	#todo animation???? cool like scaling fount based on combo sizer


func set_counter(string):
	combo_counnter.clear()
	combo_counnter.append_text(string)
