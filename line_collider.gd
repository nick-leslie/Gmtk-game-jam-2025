extends Area2D
signal collision

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area):
	#collision.emit()
	if area.name == "HeadColliderBody":
		print("Line is overlapping")
	pass
