extends Control
class_name launcher

@onready var exit_dialog = $CanvasLayer/exitDialog
@onready var server_configurator = $CanvasLayer/serverConfigurator

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_exit_button_pressed():
	exit_dialog.visible=true
	pass # Replace with function body.


func _on_exit_dialog_confirmed():
	get_tree().quit()
	pass # Replace with function body.

func _on_exit_dialog_canceled():
	exit_dialog.visible=false
	pass # Replace with function body.

func _on_start_button_pressed():
	server_configurator.visible=true
	pass # Replace with function body.
