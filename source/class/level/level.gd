extends Node3D
class_name Level
signal cube_recieved
signal cube_lost

var m_player: Player = null
var m_cube_burner: Area3D = null
var m_ext_zone: Area3D = null


func get_player() -> Player:
	return m_player
