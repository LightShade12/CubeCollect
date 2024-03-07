extends Decal

var lifetime_secs: int = 30
@onready var kill_timer = $killTimer


# Called when the node enters the scene tree for the first time.
func _ready():
	kill_timer.start(lifetime_secs)
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_kill_timer_timeout():
	self.call_deferred("free")
	pass  # Replace with function body.
