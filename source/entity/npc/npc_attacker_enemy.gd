extends CharacterClass
class_name npc_attacker_enemy
@onready var step_up_separation_ray_f: CollisionShape3D = $step_up_separation_ray_f
@onready var step_up_separation_ray_l: CollisionShape3D = $step_up_separation_ray_l
@onready var step_up_separation_ray_r: CollisionShape3D = $step_up_separation_ray_r

@onready var _initial_separation_ray_dist: float = abs(step_up_separation_ray_f.position.z)

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var attack_cooldown_timer: Timer = $attackCooldownTimer
var player: Player = null


func update_target_location(target_loc: Vector3) -> void:
	nav_agent.set_target_position(target_loc)
	pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SPEED = 3.5
	attack_cooldown_timer.wait_time = 2
	#set_physics_process(false)
	call_deferred("actor_setup")


func actor_setup() -> void:
	NavigationServer3D.map_changed.connect(Callable(map_ready))


func map_ready(_rid: RID) -> void:
	set_physics_process(true)
	NavigationServer3D.map_changed.disconnect(Callable(map_ready))


func slay() -> void:
	self.call_deferred("free")
	pass


func _physics_process(delta: float) -> void:
	var curr_loc: Vector3 = global_transform.origin
	var next_loc: Vector3 = nav_agent.get_next_path_position()

	var vel: Vector3 = (next_loc - curr_loc).normalized() * SPEED

	nav_agent.set_velocity(vel)

	var dir: Vector3 = nav_agent.get_next_path_position() - self.global_transform.origin
	rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z) + PI, delta * 8)

	var xz_f_ray_pos: Vector3 = dir.normalized() * _initial_separation_ray_dist
	step_up_separation_ray_f.global_position.x = self.global_position.x + xz_f_ray_pos.x
	step_up_separation_ray_f.global_position.z = self.global_position.z + xz_f_ray_pos.z

	var xz_l_ray_pos: Vector3 = xz_f_ray_pos.rotated(Vector3(0, 1.0, 0), deg_to_rad(-50))
	step_up_separation_ray_l.global_position.x = self.global_position.x + xz_l_ray_pos.x
	step_up_separation_ray_l.global_position.z = self.global_position.z + xz_l_ray_pos.z

	var xz_r_ray_pos: Vector3 = xz_f_ray_pos.rotated(Vector3(0, 1.0, 0), deg_to_rad(50))
	step_up_separation_ray_r.global_position.x = self.global_position.x + xz_r_ray_pos.x
	step_up_separation_ray_r.global_position.z = self.global_position.z + xz_r_ray_pos.z

	if health <= 0:
		slay()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if not is_on_floor():
		safe_velocity.y -= gravity * get_physics_process_delta_time() * 30
	velocity = velocity.move_toward(safe_velocity, 0.25)
	move_and_slide()
	super._physics_process(get_physics_process_delta_time())


func _on_navigation_agent_3d_target_reached() -> void:
	if attack_cooldown_timer.is_stopped():
		Global.player.pdamage(10, self.global_transform.origin)
		attack_cooldown_timer.start()
