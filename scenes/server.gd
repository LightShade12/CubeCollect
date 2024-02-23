extends Node
class_name Server

var map:Level=null;
@export var scene:PackedScene=null;

func _ready():
	print("server started")
	map=scene.instantiate()
	print(map)
	add_child(map)

func _process(_delta):
	pass
