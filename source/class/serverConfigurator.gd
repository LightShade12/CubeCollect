extends Popup

var current_server_settings:Global.ServerSettings=null;
@onready var mapselect_button = $MapselectButton

var maplist:Dictionary={"TestLevel":"res://scenes/levels/testlevel.tscn",
"DemoLevel":"res://scenes/levels/demolevel.tscn","Deadhouse":"res://scenes/levels/deadhouse.tscn"}

# Called when the node enters the scene tree for the first time.
func _ready():
	current_server_settings=Global.ServerSettings.new()
	for map in maplist:
		mapselect_button.add_item(map)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_cancel_button_pressed():
	self.visible=false
	pass # Replace with function body.


func _on_start_button_pressed():
	current_server_settings.map=maplist[mapselect_button.get_item_text(mapselect_button.get_selected_id())]
	Global._start_server("res://source/class/server.tscn",current_server_settings)
	pass # Replace with function body.
