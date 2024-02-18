extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Demolevel")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_detection_body_entered(body):
	if body is Cube:
		print("Point scored")
	pass # Replace with function body.
