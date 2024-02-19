extends Node3D
@onready var player = $player

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Demolevel")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _physics_process(_delta):
	get_tree().call_group("enemies","update_target_location",player.global_transform.origin)

func _on_area_detection_body_entered(body):
	if body is Cube:
		print("Point scored")
	pass # Replace with function body.
