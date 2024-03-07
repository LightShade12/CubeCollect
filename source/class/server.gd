extends Node
class_name Server

@onready var round_timer = $roundTimer
@onready var aux_timer = $auxTimer

var player: Player

var is_collecting: bool = false
var is_prepping: bool = false
var is_surviving: bool = false
var cubecount: int = 0

var prepTimeSecs: int = 10
var collectTimeSecs: int = 20
var surviveTimeSecs: int = 60

var current_map: String = "res://scenes/levels/testlevel.tscn"
var mapnode: Level = null

@onready var pausemenu_canvas = $pausemenu/pausemenuCanvas


func constructor(serversettings: Global.ServerSettings):
	current_map = serversettings.map
	pass


func _on_cube_recieved():
	cubecount += 1


func _on_cube_lost():
	cubecount -= 1


func _on_round_timer_timeout():
	if is_collecting:
		is_collecting = false
		beginPrep()
		return

	if is_prepping:
		is_prepping = false
		beginSurvival()
		return

	if is_surviving:
		is_surviving = false
		player.playermessagedisplay.text = "Extraction succesful"
		return


func updatetimerdisplay():
	var mins: int = int(round_timer.time_left / 60)
	player.timerdisplay.text = (
		"0"
		+ str(mins)
		+ ":"
		+ str(
			(
				int(round_timer.time_left - (mins * 60))
				if int(round_timer.time_left - (mins * 60)) > 9
				else "0" + str(int(round_timer.time_left - (mins * 60)))
			)
		)
	)


func beginCollection():
	is_collecting = true
	player.playermessagedisplayUpdate("Game Begins")
	round_timer.start(collectTimeSecs)
	aux_timer.start(3)


func beginPrep():
	is_prepping = true
	player.playermessagedisplayUpdate("Prepare for hostiles")
	player.objectivesdisplay.text = "Set up defensive positio	n"
	round_timer.start(prepTimeSecs)


func beginSurvival():
	player.playermessagedisplayUpdate("Survive and defend cubes till timeout")
	is_surviving = true
	player.objectivesdisplay.text = "Survive"
	round_timer.start(surviveTimeSecs)


func _ready():
	var mapscene = ResourceLoader.load(current_map)
	mapnode = mapscene.instantiate()
	mapnode.cube_recieved.connect(_on_cube_recieved)
	mapnode.cube_lost.connect(_on_cube_lost)
	add_child(mapnode)
	player = mapnode.get_player()
	pausemenu_canvas.layer = 9  #high val so it draws over hud layer
	beginCollection()


func _input(_event):
	if Input.is_action_just_pressed("key_escape"):
		Global.gamepaused = !Global.gamepaused
		if Global.gamepaused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			pausemenu_canvas.visible = true
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			pausemenu_canvas.visible = false
		get_tree().paused = Global.gamepaused


func _process(_delta):
	player.cubecountdisplay.text = str(cubecount)
	updatetimerdisplay()
	pass


func _physics_process(_delta):
	get_tree().call_group("enemies", "update_target_location", player.global_transform.origin)


func _on_resume_button_pressed():
	Global.gamepaused = false
	pausemenu_canvas.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = Global.gamepaused


func _on_quit_button_pressed():
	Global.gamepaused = false
	Global.goto_scene("res://source/class/launcher.tscn")
	get_tree().paused = Global.gamepaused


func _on_aux_timer_timeout():
	player.playermessagedisplayUpdate("Collect as many cubes as possible before timeout")
	player.objectivesdisplay.text = "Collect cubes"
