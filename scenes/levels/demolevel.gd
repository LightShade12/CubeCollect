extends Node3D
class_name Level
@onready var player = $player
@onready var detail_stream_player = $DetailStreamPlayer
var vmin=4990;var vmax=5000

func _ready():
	print("Demolevel")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var randn=randi_range(0,10000)
	if randn<vmax && randn>vmin and !detail_stream_player.playing:
		print("played sound")
		detail_stream_player.play()
	pass

func _physics_process(_delta):
	get_tree().call_group("enemies","update_target_location",player.global_transform.origin)

func _on_area_detection_body_entered(body):
	if body is Cube:
		print("Point scored")
	pass # Replace with function body.
