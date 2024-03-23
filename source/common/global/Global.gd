extends Node

# this var is server during gameplay so we can call get player var from server instead of global player ref
var current_scene: Node = null

var gamepaused: bool = false

var player: Player = null


class ServerSettings:
	var map_path: NodePath = ""
	var map_name: String = ""
	var map_description: String = "uninitialized map text"
	var collectTimeSecs: int = 3
	var prepTimeSecs: int = 2
	var surviveTimeSecs: int = 6
	var gamemode: GAMEMODE = GAMEMODE.CLASSIC
	enum GAMEMODE { CLASSIC, SANDBOX }


func _ready() -> void:
	var root: Node = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)


func goto_scene(path: NodePath) -> void:
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.
	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path: NodePath) -> void:
	# It is now safe to remove the current scene.
	current_scene.free()

	# Load the new scene.
	var s: PackedScene = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene


func _start_server(path: String, serversettings: ServerSettings) -> void:
	call_deferred("_deferred_start_server", path, serversettings)


func _deferred_start_server(path: String, serversettings: ServerSettings) -> void:
	current_scene.free()  #i.e launcherscene

	# Load the new scene, i.e serverscene
	var s: PackedScene = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()
	current_scene.constructor(serversettings)
	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)
