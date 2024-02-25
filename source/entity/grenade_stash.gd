extends StaticBody3D
class_name GrenadeSpawner
# Called when the node enters the scene tree for the first time.

var grenadeSet:Array[Grenade]
@onready var spawnpoint_3d = $spawnpoint3d
@onready var grenaderef:PackedScene=preload("res://source/entity/grenade.tscn")

func _ready():
	pass # Replace with function body.

func identify():
	print(self)

func interact():
	for i in range(0,1):
		var gren=grenaderef.instantiate()
		add_child(gren)
		gren.position=spawnpoint_3d.position
	pass

func getInterctionHint()->String:
	return "press "+ InputMap.action_get_events("key_interact")[0].as_text() +" to get stash"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
