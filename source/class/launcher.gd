extends Control
class_name launcher

@onready var exit_dialog: ConfirmationDialog = $CanvasLayer/exitDialog
@onready var server_configurator: Popup = $CanvasLayer/serverConfigurator


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_exit_dialog_confirmed() -> void:
	get_tree().quit()
	pass  # Replace with function body.


func _on_exit_dialog_canceled() -> void:
	exit_dialog.visible = false
	pass  # Replace with function body.


func _on_start_button_pressed() -> void:
	server_configurator.visible = true


func _on_exit_button_pressed() -> void:
	exit_dialog.visible = true


func _on_options_button_pressed() -> void:
	pass  # Replace with function body.
