extends Node3D

@onready var player:Player = $entities/player
@onready var roundtimer:Timer = $roundtimer
@onready var auxtimer:Timer = $auxtimer

var is_collecting:bool=false;
var is_prepping:bool=false;
var is_surviving:bool=false;
var cubecount:int=0;

var prepTimeSecs:int=10;
var collectTimeSecs:int=20;
var surviveTimeSecs:int=60;


func beginCollection():
	is_collecting=true
	player.playermessagedisplayUpdate("Game Begins")
	roundtimer.start(collectTimeSecs)
	auxtimer.start(3)

func beginPrep():
	is_prepping=true
	player.playermessagedisplayUpdate("Prepare for hostiles")
	player.objectivesdisplay.text="Set up defensive positio	n"
	roundtimer.start(prepTimeSecs)

func beginSurvival():
	player.playermessagedisplayUpdate("Survive and defend cubes till timeout")
	is_surviving=true
	player.objectivesdisplay.text="Survive"
	roundtimer.start(surviveTimeSecs)

func _ready():
	#get_tree().call_group("InteractableEntity","identify")
	beginCollection()
	pass # Replace with function body.

func updatetimerdisplay():
	var mins:int=int(roundtimer.time_left/60)
	player.timerdisplay.text="0"+str(mins)+":"+str(int(roundtimer.time_left-(mins*60))if int(roundtimer.time_left-(mins*60))>9 else "0"+str(int(roundtimer.time_left-(mins*60))));

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	player.cubecountdisplay.text=str(cubecount)
	updatetimerdisplay()

func _physics_process(_delta):
	get_tree().call_group("enemies","update_target_location",player.global_transform.origin)

func _on_area_detection_body_entered(body):
	if body is Cube:
		cubecount+=1
	pass # Replace with function body.

func _on_area_detection_body_exited(body):
	if body is Cube:
		cubecount-=1
	pass # Replace with function body.

func _on_auxtimer_timeout():
	player.playermessagedisplayUpdate("Collect as many cubes as possible before timeout")
	player.objectivesdisplay.text="Collect cubes"

func _on_roundtimer_timeout():
	if is_collecting:
		is_collecting=false
		beginPrep()
		return
	
	if is_prepping:
		is_prepping=false
		beginSurvival()
		return
	
	if is_surviving:
		is_surviving=false
		player.playermessagedisplay.text="Extraction succesful"
		return

