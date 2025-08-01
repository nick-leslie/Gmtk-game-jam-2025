extends Area2D

signal collision

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area):
	if area.name == "HeadColliderBody":
		collision.emit()
		print("Line is overlapping")
	pass
