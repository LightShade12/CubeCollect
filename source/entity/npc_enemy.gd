extends CharacterClass
class_name npc_enemy

@onready var nav_agent = $NavigationAgent3D

func update_target_location(target_loc):
	nav_agent.set_target_position(target_loc)
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)
	call_deferred("actor_setup")

func actor_setup():
	NavigationServer3D.map_changed.connect(Callable(map_ready))

func map_ready(_rid): 
	set_physics_process(true)
	NavigationServer3D.map_changed.disconnect(Callable(map_ready))

func _physics_process(_delta):
	var curr_loc=global_transform.origin
	var next_loc=nav_agent.get_next_path_position()
	
	var vel=(next_loc-curr_loc).normalized()*SPEED
	
	nav_agent.set_velocity(vel)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity=velocity.move_toward(safe_velocity,.25)
	move_and_slide()
	pass # Replace with function body.
