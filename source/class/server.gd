extends Node
class_name Server

var current_map:String="res://scenes/levels/testlevel.tscn"
@onready var pausemenu = $pausemenu
func constructor(serversettings:Global.ServerSettings):
	current_map=serversettings.map
	pass

func _ready():
	#pausemenu.z_index=RenderingServer.CANVAS_ITEM_Z_MAX
	var mapscene= ResourceLoader.load(current_map)
	var mapnode=mapscene.instantiate()
	add_child(mapnode)
	pass

func _input(_event):
	if Input.is_action_just_pressed("key_escape"):
		Global.gamepaused=!Global.gamepaused
		if Global.gamepaused:
			Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
			pausemenu.visible=true
		else:
			Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
			pausemenu.visible=false
	pass

func _process(_delta):
	pass


func _on_resume_button_pressed():
	Global.gamepaused=false
	pausemenu.visible=false
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	pass # Replace with function body.

func _on_quit_button_pressed():
	Global.gamepaused=false
	Global.goto_scene("res://source/class/launcher.tscn")
	pass # Replace with function body.
