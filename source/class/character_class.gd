extends CharacterBody3D
class_name CharacterClass

var SPEED: float = 5.0
var health: int = 100


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


func damage(dmg: int) -> void:
	health -= dmg


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
