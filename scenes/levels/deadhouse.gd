extends Level

@onready var player = $entities/player


# Called when the node enters the scene tree for the first time.
func _ready():
	#get_tree().call_group("InteractableEntity","identify")
	m_player = player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
