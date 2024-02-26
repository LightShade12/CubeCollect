extends CharacterBody3D
class_name CharacterClass

var SPEED:float=5.0;
var health:int=100;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func damage(dmg:int):
	health-=dmg;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
