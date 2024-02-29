extends Node3D
class_name Level
signal cube_recieved
signal cube_lost
var m_player:Player=null

func get_player()->Player:
	return m_player
