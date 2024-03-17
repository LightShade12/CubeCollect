extends CharacterClass
class_name npc_retriever_enemy

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func update_target_location(target_loc: Vector3) -> void:
	nav_agent.set_target_position(target_loc)
	pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SPEED = 1.5
	set_physics_process(true)
	call_deferred("actor_setup")


func actor_setup() -> void:
	NavigationServer3D.map_changed.connect(Callable(map_ready))


func map_ready(_rid: RID) -> void:
	#set_physics_process(true)
	NavigationServer3D.map_changed.disconnect(Callable(map_ready))


func slay() -> void:
	self.call_deferred("free")
	pass


func _physics_process(_delta: float) -> void:
	var curr_loc: Vector3 = global_transform.origin
	var next_loc: Vector3 = nav_agent.get_next_path_position()

	var vel: Vector3 = (next_loc - curr_loc).normalized() * SPEED

	nav_agent.set_velocity(vel)

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
