extends TextureRect

@export var animation:SpriteFrames

@export var timing:float
@export var frame:int
@onready var timer:Timer = Timer.new()


func _ready() -> void:
	timer.wait_time = timing
	timer.timeout.connect(change_frame)
	timer.autostart = true
	add_child(timer)

func change_frame():
	print("um what the slugma")
	if frame >= animation.get_frame_count("default"):
		frame = 0
	texture =  animation.get_frame_texture("default",frame)
	pass
