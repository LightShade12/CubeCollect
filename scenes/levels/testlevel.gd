extends Level

@onready var player: Player = $entities/player


func _ready() -> void:
	#get_tree().call_group("InteractableEntity","identify")
	m_player = player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_detection_body_entered(body: Node3D) -> void:
	if body is Cube:
		emit_signal("cube_recieved")
		pass


func _on_area_detection_body_exited(body: Node3D) -> void:
	if body is Cube:
		emit_signal("cube_lost")
		pass
