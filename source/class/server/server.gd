extends Node
class_name Server

@onready var round_timer: Timer = $roundTimer
@onready var aux_timer: Timer = $auxTimer
@onready
var gamemodetxt: Label = $pausemenu/pausemenuCanvas/MarginContainer/AspectRatioContainer/VBoxContainer3/HBoxContainer/VBoxContainer/gamemodetxt
@onready
var mapdesctxt: Label = $pausemenu/pausemenuCanvas/MarginContainer/AspectRatioContainer/VBoxContainer3/HBoxContainer/VBoxContainer/mapdesctxt
@onready
var map_nametxt: Label = $pausemenu/pausemenuCanvas/MarginContainer/AspectRatioContainer/VBoxContainer3/HBoxContainer/VBoxContainer/mapNametxt

var player: Player

var is_collecting: bool = false
var is_prepping: bool = false
var is_surviving: bool = false
var cubecount: int = 0

var preparationTimeSecs: int = 10
var collectionTimeSecs: int = 20
var survivalTimeSecs: int = 60
var sbox_mode: bool = false

var current_map_path: NodePath = "res://scenes/levels/deadhouse.tscn"
#var current_map_path: NodePath = "res://scenes/levels/testlevel.tscn"
var mapnode: Level = null
var pause_desc: String = ""
var current_map_name: String = ""
var servergamemode: Global.ServerSettings.GAMEMODE = Global.ServerSettings.GAMEMODE.SANDBOX

@onready var pausemenu_canvas: CanvasLayer = $pausemenu/pausemenuCanvas


func get_ext_zone() -> Area3D:
	return mapnode.m_ext_zone


func get_cburner() -> Area3D:
	return mapnode.m_cube_burner


func constructor(serversettings: Global.ServerSettings) -> void:
	current_map_path = serversettings.map_path
	collectionTimeSecs = serversettings.collectTimeSecs
	preparationTimeSecs = serversettings.prepTimeSecs
	survivalTimeSecs = serversettings.surviveTimeSecs
	pause_desc = serversettings.map_description
	servergamemode = serversettings.gamemode
	current_map_name = serversettings.map_name


func _on_cube_recieved() -> void:
	cubecount += 1


func _on_cube_lost() -> void:
	cubecount -= 1


func _on_round_timer_timeout() -> void:
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
		player.playermessagedisplayUpdate("Extraction succesful")
		return


func updatetimerdisplay() -> void:
	var mins: int = int(round_timer.time_left / 60)
	player.timerdisplay.text = (
		"0"
		+ str(mins)
		+ ":"
		+ (
			str(int(round_timer.time_left) - (mins * 60))
			if (int(round_timer.time_left - (mins * 60)) > 9)
			else "0" + str(int(round_timer.time_left - (mins * 60)))
		)
	)


func roundStart() -> void:
	player.playermessagedisplayUpdate("Game Begins")
	if !sbox_mode:
		beginCollection()


func beginCollection() -> void:
	aux_timer.start(3)  # freeze time delay for game begin


func beginPrep() -> void:
	is_prepping = true
	player.playermessagedisplayUpdate("Prepare for hostiles")
	player.objectivesdisplay.text = "Set up defensive positio	n"
	round_timer.start(preparationTimeSecs)


func beginSurvival() -> void:
	player.playermessagedisplayUpdate("Survive and defend cubes till timeout")
	is_surviving = true
	player.objectivesdisplay.text = "Survive"
	round_timer.start(survivalTimeSecs)
	get_tree().call_group("npc_spawners", "start_spawner")


func _ready() -> void:
	var mapscene: PackedScene = load(String(current_map_path))
	mapnode = mapscene.instantiate() as Level
	mapnode.cube_recieved.connect(_on_cube_recieved)
	mapnode.cube_lost.connect(_on_cube_lost)

	add_child(mapnode)

	player = mapnode.get_player()
	Global.player = player

	pausemenu_canvas.layer = 9  #high val so it draws over hud layer
	mapdesctxt.text = pause_desc
	gamemodetxt.text = str(Global.ServerSettings.GAMEMODE.keys()[servergamemode])
	map_nametxt.text = current_map_name
	sbox_mode = servergamemode  # loose code
	roundStart()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("key_escape"):
		Global.gamepaused = !Global.gamepaused
		if Global.gamepaused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			pausemenu_canvas.visible = true
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			pausemenu_canvas.visible = false
		get_tree().paused = Global.gamepaused


func _process(_delta: float) -> void:
	player.cubecountdisplay.text = str(cubecount)
	updatetimerdisplay()
	pass


func _physics_process(_delta: float) -> void:
	get_tree().call_group("enemies_attacker", "update_target_location", player.global_transform.origin)


func _on_resume_button_pressed() -> void:
	Global.gamepaused = false
	pausemenu_canvas.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = Global.gamepaused


func _on_quit_button_pressed() -> void:
	Global.gamepaused = false
	Global.goto_scene("res://scenes/main/launcher.tscn")
	get_tree().paused = Global.gamepaused


func _on_aux_timer_timeout() -> void:
	player.playermessagedisplayUpdate("Collect as many cubes as possible before timeout")
	is_collecting = true
	player.objectivesdisplay.text = "Collect cubes"
	round_timer.start(collectionTimeSecs)
