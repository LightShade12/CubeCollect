extends Level

@onready var player: Player = $entities/player
@onready var cube_burner: Area3D = $entities/cube_burner
@onready var extraction_area: Area3D = $entities/extraction_area


func _ready() -> void:
	#get_tree().call_group("InteractableEntity","identify")
	m_player = player
	m_cube_burner = cube_burner
	m_ext_zone = extraction_area


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_extraction_area_body_entered(body: Node3D) -> void:
	if body is Cube:
		emit_signal("cube_recieved")


func _on_extraction_area_body_exited(body: Node3D) -> void:
	if body is Cube:
		emit_signal("cube_lost")
