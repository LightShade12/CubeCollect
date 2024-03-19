extends Node3D
class_name bomber
@onready var spawn_marker: Marker3D = $spawn_marker
var dir: Vector3 = Vector3(-1, 0, 1)
var speed: float = 100
var bomb_count: int = 10
const CONTACT_CHARGE: PackedScene = preload("res://source/entity/weapon/contact_charge.tscn")
@onready var kill_timer: Timer = $killTimer
var lifetime: float = 20
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D


func constructor(spnpt: Vector3, _dir: Vector3, rot: float) -> void:
	dir = _dir
	global_position = spnpt - (300 * dir)
	rotation.y = rot


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player_3d.play()
	kill_timer.wait_time = lifetime
	kill_timer.start()
	await get_tree().create_timer(3.05).timeout
	for i: int in range(0, bomb_count):
		await get_tree().create_timer(0.04).timeout
		var chinst: RigidBody3D = CONTACT_CHARGE.instantiate()
		add_sibling(chinst)
		chinst.global_position = spawn_marker.global_position


func _physics_process(delta: float) -> void:
	global_position += dir * delta * speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_kill_timer_timeout() -> void:
	self.call_deferred("free")
	pass  # Replace with function body.
