extends CharacterClass
class_name npc_retriever_enemy
@onready var pickup_marker: Marker3D = $visionArea/pickupMarker
@onready var movetimer: Timer = $movetimer

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var cubeburner: Area3D = null
var ext_zone: Area3D = null
var searchtarget: Vector3 = Vector3.ZERO

#states
var fresh: bool = true
var is_moving_to_cb: bool = false
var is_moving_to_ext: bool = false
var reached_extzone: bool = false
var reached_cb: bool = false
var srch_target_exists: bool = false
var is_holding_cube: bool = false
var is_searching: bool = false

@onready var vision_ray_cast: RayCast3D = $visionArea/VisionRayCast

var cubes_in_sight: Array[Cube] = []

var target_cube: Cube
var current_picked_cube: Cube


func move_to_ext_zone() -> void:
	nav_agent.set_target_position(ext_zone.global_transform.origin)
	pass


func move_to_cb() -> void:
	nav_agent.set_target_position(cubeburner.global_transform.origin)
	pass


func _process(_delta: float) -> void:
	if fresh:
		move_to_ext_zone()
		is_moving_to_ext = true
		if (ext_zone.global_transform.origin - self.global_transform.origin).length() < 2:
			fresh = false
			reached_extzone = true
	elif reached_extzone:
		is_moving_to_ext = false
		if !is_holding_cube:
			is_searching = true
			search_cubes()  #should return true to is_holding_cube
		else:
			is_searching = false
			is_moving_to_cb = true
			move_to_cb()
			if (cubeburner.global_transform.origin - self.global_transform.origin).length() < 1:
				reached_extzone = false
				reached_cb = true
	elif reached_cb:
		is_holding_cube = false
		is_moving_to_ext = true
		move_to_ext_zone()
		if (ext_zone.global_transform.origin - self.global_transform.origin).length() < 2:
			reached_extzone = true
		else:
			pass
	else:
		print("behaviour leak")


#should set is_holding_cube to true
func search_cubes() -> void:
	if !target_cube:
		#begin searching
		if !srch_target_exists:
			var extent: int = 5
			var randpt: Vector3 = Vector3(randf_range(-extent, extent), 0, randf_range(-extent, extent))
			searchtarget = self.global_transform.origin + randpt
			srch_target_exists = true
			nav_agent.set_target_position(searchtarget)
			movetimer.start()

		#check for target cube
		var closestCubeDist: float = 100
		var closest_cube: Cube
		for cube: Cube in cubes_in_sight:
			if !cube.is_picked:
				vision_ray_cast.target_position = vision_ray_cast.to_local(cube.global_position)
				vision_ray_cast.force_raycast_update()
				var obj: Node3D = vision_ray_cast.get_collider()
				if obj is Cube:  #direct LOS
					var hitDist: float = (
						(vision_ray_cast.get_collision_point() - vision_ray_cast.global_position).length()
					)
					if hitDist <= closestCubeDist:
						closest_cube = obj
						closestCubeDist = hitDist

		target_cube = closest_cube
	elif target_cube:
		if !target_cube.is_picked:
			nav_agent.set_target_position(target_cube.global_position)
		else:
			target_cube = null
	else:
		print("behaviour leak")
	pass


func _on_navigation_agent_3d_target_reached() -> void:
	if is_searching:
		if target_cube:
			is_holding_cube = true  #should actually check for holding
			current_picked_cube = target_cube
			current_picked_cube.is_picked = true
			#print("picked target cube")
		else:
			srch_target_exists = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SPEED = 3.5
	cubeburner = (Global.current_scene as Server).get_cburner()
	ext_zone = (Global.current_scene as Server).get_ext_zone()
	set_physics_process(true)
	call_deferred("actor_setup")


func _input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_Y):
		is_holding_cube = !is_holding_cube
	if Input.is_key_pressed(KEY_U):
		pass


func actor_setup() -> void:
	NavigationServer3D.map_changed.connect(Callable(map_ready))


func map_ready(_rid: RID) -> void:
	#set_physics_process(true)
	NavigationServer3D.map_changed.disconnect(Callable(map_ready))


func slay() -> void:
	if current_picked_cube != null:
		current_picked_cube.is_picked = false
	self.call_deferred("free")
	pass


func _physics_process(delta: float) -> void:
	var curr_loc: Vector3 = global_transform.origin
	var next_loc: Vector3 = nav_agent.get_next_path_position()  #only possible if nav.targetpos is set

	var vel: Vector3 = (next_loc - curr_loc).normalized() * SPEED

	nav_agent.set_velocity(vel)

	var dir: Vector3 = nav_agent.get_next_path_position() - self.global_transform.origin
	rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z) + PI, delta * 8)

	if health <= 0:
		slay()

	if is_holding_cube and current_picked_cube != null:
		current_picked_cube.set_linear_velocity(
			(pickup_marker.global_position - current_picked_cube.global_position) * 20
		)


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	var physdelta: float = get_physics_process_delta_time()
	if not is_on_floor():
		safe_velocity.y -= gravity * physdelta * 30
	velocity = velocity.move_toward(safe_velocity, 0.25)
	move_and_slide()
	super._physics_process(physdelta)


func _on_vision_area_body_entered(body: Node3D) -> void:
	if body is Cube:
		cubes_in_sight.append(body)
		#print(cubes_in_sight)


func _on_vision_area_body_exited(body: Node3D) -> void:
	if body is Cube:
		cubes_in_sight.erase(body)
		#print(cubes_in_sight)


func _on_movetimer_timeout() -> void:
	if is_searching:
		srch_target_exists = false
	pass  # Replace with function body.
