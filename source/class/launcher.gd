extends Control
class_name launcher

@onready var line_edit = $CanvasLayer/LineEdit
var current_server_settings:Global.ServerSettings=null;
# Called when the node enters the scene tree for the first time.
func _ready():
	current_server_settings=Global.ServerSettings.new()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_button_pressed():
	Global._start_server("res://source/class/server.tscn",current_server_settings)
	#get_tree().change_scene_to_file("res://source/class/server.tscn")

func _on_line_edit_text_submitted(new_text):
	current_server_settings.text=new_text
	pass # Replace with function body.

func _on_button_2_pressed():
	print_tree_pretty()
	pass # Replace with function body.
