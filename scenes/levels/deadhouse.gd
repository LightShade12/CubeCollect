extends Level

@onready var player: Player = $entities/player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get_tree().call_group("InteractableEntity","identify")
	m_player = player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
