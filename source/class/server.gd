extends Node
class_name Server

@onready var varlabel = $CanvasLayer/varlabel
var word:String="Placeholder text"

func constructor(serversettings:Global.ServerSettings):
	word=serversettings.text
	pass

func _ready():
	varlabel.text=word
	pass

func _process(_delta):
	pass

func _on_button_pressed():
	#get_tree().change_scene_to_file("res://source/class/launcher.tscn")
	Global.goto_scene("res://source/class/launcher.tscn")
	pass # Replace with function body.	


func _on_button_2_pressed():
	print_tree_pretty()
	pass # Replace with function body.
