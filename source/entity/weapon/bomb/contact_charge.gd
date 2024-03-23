extends RigidBody3D
@onready var core_audioplayer: AudioStreamPlayer3D = $coreAudioplayer
@onready var aux_audioplayer: AudioStreamPlayer3D = $auxAudioplayer
@onready var ray_cast: RayCast3D = $RayCast
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var trauma_area: Area3D = $traumaArea
@onready var damage_area: Area3D = $damageArea
@onready var kill_timer: Timer = $killTimer
@onready var explosion_audio_player: AudioStreamPlayer3D = $explosionAudioPlayer

const GRENADEDECAL: PackedScene = preload("res://source/entity/weapon/grenade/grenadedecal.tscn")
const BOMB_PARTICLE_SYSTEM: PackedScene = preload("res://source/entity/weapon/bomb/bomb_particle_system.tscn")
var exploded: bool = false
var items_in_rad: Array
var explosion_force: float = 15
var player_in_rad: Player = null  #can make it an array
# Called when the node enters the scene tree for the first time.
var lifetime: float = 10
var postexplodelifetime_secs: float = 5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	kill_timer.wait_time = lifetime
	kill_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if exploded:
		await get_tree().create_timer(postexplodelifetime_secs).timeout
		self.call_deferred("free")


func _physics_process(_delta: float) -> void:
	ray_cast.look_at(
		Vector3(self.global_transform.origin.x, self.global_transform.origin.y - 2, self.global_transform.origin.z),
		Vector3(1, 0, 0)
	)
	ray_cast.global_rotation.x += deg_to_rad(90)


func explode() -> void:
	explosion_audio_player.set_stream(preload("res://assets/sounds/weapon/bomber/hq-explosion-6288.mp3"))
	explosion_audio_player.volume_db = 20
	explosion_audio_player.play()
	($MeshInstance3D as MeshInstance3D).transparency = 1
	$OmniLight3D.light_energy = 0
	$GPUParticles3D.emitting = false

	var force_dir: Vector3

	var spnpt: Vector3 = ray_cast.get_collision_point()
	if spnpt == Vector3.ZERO:
		spnpt = global_position
	var decalnode: Decal = GRENADEDECAL.instantiate()
	add_sibling(decalnode)
	decalnode.global_transform.origin = spnpt
	var smokeptclsys: Node3D = BOMB_PARTICLE_SYSTEM.instantiate()
	add_sibling(smokeptclsys)
	smokeptclsys.global_transform.origin = spnpt

	for obj: Node3D in items_in_rad:
		var dist_fac: float = 1 - (0.125 * (self.global_transform.origin - obj.global_transform.origin).length())
		if obj is RigidBody3D:
			force_dir = self.global_transform.origin.direction_to(obj.global_transform.origin)
			obj.apply_impulse(force_dir * explosion_force * dist_fac)
		elif obj is CharacterClass:
			if obj is Player:
				obj.pdamage(90 * dist_fac, self.global_transform.origin)
			else:
				obj.damage(90 * dist_fac)

	if player_in_rad:
		var dist: float = (player_in_rad.global_position - self.global_position).length()
		var trauma_amt: float = max(0.3 + (1 - (0.066 * dist)), 0)
		player_in_rad.add_trauma(trauma_amt)  #0-1

	exploded = true

	#debris sfx
	await get_tree().create_timer(2).timeout
	core_audioplayer.volume_db = -5
	aux_audioplayer.volume_db = 0
	aux_audioplayer.stream = preload("res://assets/sounds/weapon/grenade/sand_debris.mp3")
	core_audioplayer.stream = preload("res://assets/sounds/weapon/grenade/debris_faded.wav")
	core_audioplayer.play()
	aux_audioplayer.play()


func _on_trauma_area_body_entered(body: Node3D) -> void:
	if body is Player:
		player_in_rad = body
	pass  # Replace with function body.


func _on_trauma_area_body_exited(body: Node3D) -> void:
	if body is Player:
		player_in_rad = null
	pass  # Replace with function body.


func _on_damage_area_body_entered(body: Node3D) -> void:
	if body.name != self.name:
		#if body is RigidBody3D:
		items_in_rad.append(body)
	pass  # Replace with function body.


func _on_damage_area_body_exited(body: Node3D) -> void:
	#if body is RigidBody3D:
	items_in_rad.erase(body)
	pass  # Replace with function body.


func _on_body_entered(_body: Node) -> void:
	kill_timer.stop()
	#contact_monitor = false
	set_deferred("contact_monitor", false)
	#max_contacts_reported = 0
	#print("explode")
	explode()


func _on_kill_timer_timeout() -> void:
	self.call_deferred("free")
	pass  # Replace with function body.
