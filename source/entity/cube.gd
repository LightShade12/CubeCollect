extends RigidBody3D
class_name Cube

var is_picked: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


func identify():
	print(self)


func getInterctionHint() -> String:
	if is_picked:
		return "Rclick to drop, Lclick to throw"
	else:
		return "Lclick to pickup"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
