extends Popup

var current_server_settings: Global.ServerSettings = null

@onready var gamemodesbutton: OptionButton = $VBoxContainer/gamemodeHbox/gamemodesbutton
@onready var mapselect_button: OptionButton = $VBoxContainer/mapselectHbox/MapselectButton
@onready
var mappreview_texture: TextureRect = $VBoxContainer/Control/HBoxContainer/Control/mappreviewTexture

@onready var collecttime_hbox: HBoxContainer = $VBoxContainer/collecttimeHbox
@onready var prep_time_hbox: HBoxContainer = $VBoxContainer/PrepTimeHbox
@onready var surv_time_hbox: HBoxContainer = $VBoxContainer/survTimeHbox

@onready var collect_time_spin_box: SpinBox = $VBoxContainer/collecttimeHbox/collectTimeSpinBox
@onready var prep_time_spinbox: SpinBox = $VBoxContainer/PrepTimeHbox/prepTimeSpinbox
@onready var surv_time_spin_box: SpinBox = $VBoxContainer/survTimeHbox/survTimeSpinBox

@onready var gammodedesc: Label = $VBoxContainer/gammodedesc
@onready var map_desc_label: Label = $VBoxContainer/Control/HBoxContainer/map_desc_label

var selectedMapData: MapData = null


class MapData:
	var map_path: NodePath = ""
	var image_path: NodePath = ""
	var map_desc: String = ""

	func _init(mappath: NodePath, imgpth: NodePath, mapdesc: String) -> void:
		map_path = mappath
		image_path = imgpth
		map_desc = mapdesc


var maplist: Dictionary = {
	"TestLevel":
	MapData.new(
		"res://scenes/levels/testlevel.tscn",
		"res://screenshots/testlevel.png",
		"Dev level. Used for enemy AI testing"
	),
	"DemoLevel":
	MapData.new(
		"res://scenes/levels/demolevel.tscn",
		"res://screenshots/demolevel.png",
		"Dev level. Used for grenade and cube physics testing"
	),
	"Deadhouse":
	MapData.new(
		"res://scenes/levels/deadhouse.tscn",
		"res://screenshots/deadhouse.png",
		"Official level. Steal ancient cubic relics from the abandoned supernatural hotel"
	),
	"TestLevel01":
	MapData.new(
		"res://scenes/levels/testlevel01.tscn",
		"res://screenshots/testlevel01.png",
		"Dev level. Larger map for movement and particles testing"
	)
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_server_settings = Global.ServerSettings.new()
	for map: String in maplist:
		mapselect_button.add_item(map)
	for gmode in Global.ServerSettings.GAMEMODE:
		gamemodesbutton.add_item(gmode)
	selectedMapData = maplist[mapselect_button.get_item_text(mapselect_button.get_selected_id())]
	current_server_settings.gamemode = gamemodesbutton.get_selected_id()
	current_server_settings.map_description = selectedMapData.map_desc
	gammodedesc.text = (
		str(Global.ServerSettings.GAMEMODE.keys()[current_server_settings.gamemode])
		+ ": Find and hoard cubes, set up defences and defend against enemies till timeout"
	)
	collect_time_spin_box.value = current_server_settings.collectTimeSecs
	prep_time_spinbox.value = current_server_settings.prepTimeSecs
	surv_time_spin_box.value = current_server_settings.surviveTimeSecs
	map_desc_label.text = current_server_settings.map_description


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_cancel_button_pressed() -> void:
	self.visible = false
	pass  # Replace with function body.


func _on_start_button_pressed() -> void:
	current_server_settings.map_path = selectedMapData.map_path
	current_server_settings.map_description = selectedMapData.map_desc
	Global._start_server("res://source/class/server.tscn", current_server_settings)


func _on_mapselect_button_item_selected(index: int) -> void:
	selectedMapData = maplist[mapselect_button.get_item_text(index)]
	map_desc_label.text = selectedMapData.map_desc
	mappreview_texture.texture = load(String(selectedMapData.image_path))


func _on_collect_time_spin_box_value_changed(value: float) -> void:
	current_server_settings.collectTimeSecs = value


func _on_prep_time_spinbox_value_changed(value: float) -> void:
	current_server_settings.prepTimeSecs = value


func _on_surv_time_spin_box_value_changed(value: float) -> void:
	current_server_settings.surviveTimeSecs = value


func _on_gamemodesbutton_item_selected(index: int) -> void:
	current_server_settings.gamemode = index

	if current_server_settings.gamemode == Global.ServerSettings.GAMEMODE.SANDBOX:
		collecttime_hbox.visible = false
		prep_time_hbox.visible = false
		surv_time_hbox.visible = false
		gammodedesc.text = (
			str(Global.ServerSettings.GAMEMODE.keys()[current_server_settings.gamemode])
			+ ": No timers or enemies. Free for roaming"
		)
	else:
		collecttime_hbox.visible = true
		prep_time_hbox.visible = true
		surv_time_hbox.visible = true
		gammodedesc.text = (
			str(Global.ServerSettings.GAMEMODE.keys()[current_server_settings.gamemode])
			+ ": Find and hoard cubes, set up defences and defend against enemies till timeout"
		)
