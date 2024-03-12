extends Popup

var current_server_settings: Global.ServerSettings = null
@onready var mapselect_button: Button = $MapselectButton

var maplist: Dictionary = {
	"TestLevel": "res://scenes/levels/testlevel.tscn",
	"DemoLevel": "res://scenes/levels/demolevel.tscn",
	"Deadhouse": "res://scenes/levels/deadhouse.tscn",
	"TestLevel01": "res://scenes/levels/testlevel01.tscn"
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_server_settings = Global.ServerSettings.new()
	for map: String in maplist:
		mapselect_button.add_item(map)
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_cancel_button_pressed() -> void:
	self.visible = false
	pass  # Replace with function body.


func _on_start_button_pressed() -> void:
	current_server_settings.map_path = NodePath(
		maplist[mapselect_button.get_item_text(mapselect_button.get_selected_id())]
	)
	Global._start_server("res://source/class/server.tscn", current_server_settings)
	pass  # Replace with function body.
