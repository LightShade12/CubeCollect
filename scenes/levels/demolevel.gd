extends Level
@onready var detail_stream_player = $DetailStreamPlayer
var vmin=4990;var vmax=5000
@onready var player = $entities/player

func _ready():
	#get_tree().call_group("InteractableEntity","identify")
	m_player=player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var randn=randi_range(0,10000)
	if randn<vmax && randn>vmin and !detail_stream_player.playing:
		print("played sound")
		detail_stream_player.play()
	pass


func _on_area_detection_body_entered(body):
	if body is Cube:
		emit_signal("cube_recieved")


func _on_area_detection_body_exited(body):
	if body is Cube:
		emit_signal("cube_lost")
