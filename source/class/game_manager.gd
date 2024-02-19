extends Node
class_name GameManager
@export var level:PackedScene

#will probably have game loop

func _ready():
	print("begin")
	get_tree().call_deferred("change_scene_to_packed", level)

func _process(_delta):
	pass
