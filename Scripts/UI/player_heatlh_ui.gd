extends Control

@onready var player_health_counter:RichTextLabel = get_node("PlayerHealth")
@onready var base_heart_ui:Control = get_node("Heart Ui")
@export var distance:int
var first_set_health = true
var health_ui:Array[Control] = []

func _ready() -> void:
	EventBus.SetPlayerHealth.connect(set_health)
	pass

func set_health(player_health: int):
	print("Setting Player Health UI to:" + str(player_health))
	var string = "[font_size={{size}}]Health: {player_health}[/font_size]".format({"player_health":player_health,"size":50})
	set_counter(string)
	if health_ui.size() > player_health && health_ui.size() >= 1:
		var heart =  health_ui.pop_back()
		heart.queue_free()
	if first_set_health:
		for i in range(player_health):
			print(i)
			var new_heart = base_heart_ui.duplicate()

			# Anchor to top-right
			new_heart.anchor_left = 1.0
			new_heart.anchor_top = 0.0
			new_heart.anchor_right = 1.0
			new_heart.anchor_bottom = 0.0

			# Offset leftwards by "distance" for each heart
			new_heart.offset_right = -(60 * i)
			new_heart.offset_left = -(distance * (i + 1))
			new_heart.offset_top = 100
			health_ui.append(new_heart)
			add_child(new_heart)
		base_heart_ui.queue_free() # this sucks but im a bad programer
		first_set_health = false
	pass

func set_counter(string):
	player_health_counter.clear()
	player_health_counter.append_text(string)
