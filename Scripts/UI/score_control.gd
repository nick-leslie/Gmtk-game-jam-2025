extends Control

@onready var combo_counnter:RichTextLabel = get_node("Combo")
@onready var score_counter:RichTextLabel = get_node("Score")
@onready var max_combo_counter:RichTextLabel = get_node("Max")
@export var salvage_score_increase:int
var current_combo:int
var is_combo_decaying = false

var score = 0
func _ready() -> void:
	EventBus.ComboIncreased.connect(combo_changed)
	EventBus.ComboDecreased.connect(combo_changed)
	EventBus.ComboDecaying.connect(combo_decaying)
	EventBus.ComboSalvaged.connect(combo_salvaged)
	EventBus.ComboEnded.connect(combo_ended)
	EventBus.UpdateScore.connect(update_score)
	EventBus.MaxComboIncreased.connect(max_combo_increased)
	pass

func max_combo_increased(combo):
	var string = "[font_size={{size}}]{score}[/font_size]".format({"score":combo,"size":100})
	#todo animation???? cool like scaling fount based on combo sizer
	set_max_combo(string)
	pass

func update_score(count:int):
	score+=count
	var string = "[font_size={{size}}]{score}[/font_size]".format({"score":score,"size":100})
	#todo animation???? cool like scaling fount based on combo sizer
	set_score(string)

func combo_decaying():
	is_combo_decaying=true
	var string = "[color=red][font_size={{size}}]{combo}[/font_size][/color]".format({"combo":current_combo,"size":100+current_combo})
	#todo animation???? cool like scaling fount based on combo sizer
	set_counter(string)

func combo_ended(max_combo_count):
	is_combo_decaying=false
	update_score(max_combo_count)
	var string = "[font_size={{size}}]{combo}[/font_size]".format({"combo":0,"size":100})
	set_counter(string)

func combo_salvaged():
	update_score(salvage_score_increase)
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

func set_score(string):
	score_counter.clear()
	score_counter.append_text(string)
func set_max_combo(string):
	max_combo_counter.clear()
	max_combo_counter.append_text(string)
