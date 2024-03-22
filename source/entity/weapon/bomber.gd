extends Node3D
class_name bomber
@onready var spawn_marker: Marker3D = $spawn_marker
var dir: Vector3 = Vector3(-1, 0, 1)
var speed: float = 100
var bomb_count: int = 10
const CONTACT_CHARGE: PackedScene = preload("res://source/entity/weapon/contact_charge.tscn")
@onready var kill_timer: Timer = $killTimer
var lifetime: float = 25
var bombspread_extent: float = 0.1
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
var spawnDist: float = 1000
var altitude: float = 300


func constructor(spnpt: Vector3, _dir: Vector3, rot: float) -> void:
	dir = _dir
	global_position = Vector3(spnpt.x, altitude, spnpt.z) - (spawnDist * dir)
	rotation.y = rot


func deliveryTimingSecs(planespeed_mps: float, init_dist_m: float, altitude_m: float, hitdist_m: float) -> float:
	var playerpos_eta_secs: float = init_dist_m / planespeed_mps

	#n.b: lineardamp:0.1, ~10secs to halt
	var vertical_impact_eta: float = sqrt(2 * altitude_m / 9.8)  #t=sqrt((2s-2ut)/a)
	var pload_horizontal_travel_m: float = planespeed_mps * vertical_impact_eta

	#var hitdist_eta: float = hitdist_m / planespeed_mps
	var corrective_impact_eta: float = (hitdist_m / pload_horizontal_travel_m) * vertical_impact_eta
	var pload_hor_trav_m: float = (
		-(altitude_m * altitude_m) + 2 * 100 * altitude_m - (altitude_m * altitude_m)
		if altitude_m < 100
		else (100 if altitude_m * altitude_m > 100 else 100)
	)
	var pload_static_horizontal_travel_100m_alt = 100  #factors altitude and ploadspeed
	return (
		playerpos_eta_secs - (pload_static_horizontal_travel_100m_alt / planespeed_mps) + (hitdist_m / planespeed_mps)
	)
	#return playerpos_eta_secs - (altitude_m / planespeed_mps) + (hitdist_m / planespeed_mps)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player_3d.play()
	kill_timer.wait_time = lifetime
	kill_timer.start()
	await get_tree().create_timer(deliveryTimingSecs(speed, spawnDist, altitude, 0)).timeout  #3.05
	for i: int in range(0, bomb_count):
		await get_tree().create_timer(0.04).timeout
		var chinst: RigidBody3D = CONTACT_CHARGE.instantiate()
		add_sibling(chinst)
		chinst.global_position = spawn_marker.global_position
		chinst.apply_impulse(
			(
				(
					dir
					+ Vector3(
						randf_range(-bombspread_extent, bombspread_extent),
						0,
						randf_range(-bombspread_extent, bombspread_extent)
					)
				)
				* 20
			)
		)


func _physics_process(delta: float) -> void:
	global_position += dir * delta * speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_kill_timer_timeout() -> void:
	self.call_deferred("free")
	pass  # Replace with function body.
