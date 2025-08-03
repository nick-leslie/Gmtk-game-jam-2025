extends Control

@onready var player_health_counter:RichTextLabel = get_node("PlayerHealth")

func _ready() -> void:
	EventBus.SetPlayerHealth.connect(set_health)
	pass

func set_health(player_health: int):
	print("Setting Player Health UI to:" + str(player_health))
	var string = "[font_size={{size}}]Health: {player_health}[/font_size]".format({"player_health":player_health,"size":50})
	set_counter(string)
	pass

func set_counter(string):
	player_health_counter.clear()
	player_health_counter.append_text(string)
