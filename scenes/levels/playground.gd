extends Level
@onready var player: Player = $entities/player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	m_player = player
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
