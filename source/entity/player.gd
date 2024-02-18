extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const mouse_sens:float=0.2;
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head = $head
@onready var interaction_ray_cast = $head/Camera3D/interactionRayCast
@onready var manip_marker = $head/Camera3D/ManipMarker
@onready var camera_3d = $head/Camera3D
@onready var typetooltip = $Control/CanvasLayer/typetooltip

var picked_obj:RigidBody3D=null;
var pull_fac:float=20;
var throw_fac:float=5;

func _ready():
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED;
	pass


func _input(event):
	if (event is InputEventMouseMotion):
		rotate_y(deg_to_rad(-event.relative.x*mouse_sens))
		
		head.rotate_x(deg_to_rad(-event.relative.y*mouse_sens))

		head.rotation.x=clamp(head.rotation.x,deg_to_rad(-90),deg_to_rad(90));
	
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("lclick"):
		if picked_obj!=null:
			throw_obj();
		else:
			pick_obj()
		
	if Input.is_action_just_pressed("rclick"):
		drop_obj()

func throw_obj():
	if picked_obj!=null:
		picked_obj.apply_impulse((picked_obj.global_transform.origin- camera_3d.global_transform.origin)*throw_fac)
		picked_obj=null;

func pick_obj():
	var collider=interaction_ray_cast.get_collider()
	if collider!=null and collider is RigidBody3D:
		picked_obj=collider;


func drop_obj():
	if picked_obj!=null:
		picked_obj=null;


func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("key_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_front", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	if picked_obj!=null:
		picked_obj.set_linear_velocity((manip_marker.global_transform.origin-picked_obj.global_transform.origin)*pull_fac)
		typetooltip.text=(picked_obj.get_meta("cubetype"))
	else:
		typetooltip.text=""
