extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const mouse_sens:float=0.2;
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#private
@onready var head = $head
@onready var interaction_ray_cast = $head/Camera3D/interactionRayCast
@onready var manip_marker = $head/Camera3D/ManipMarker
@onready var camera_3d = $head/Camera3D

#public
@onready var typetooltip = $Control/CanvasLayer/typetooltip
@onready var cubecountdisplay = $Control/CanvasLayer/cubestxt/cubecountdisplay
@onready var objectivesdisplay = $Control/CanvasLayer/currentobjectivetext/objectivesdisplay
@onready var timerdisplay = $Control/CanvasLayer/timerdisplay
@onready var playermessagedisplay = $Control/CanvasLayer/playermessagedisplay

@onready var gui_timer = $Control/guiTimer


var picked_obj:RigidBody3D=null;
var pull_fac:float=20;
var throw_fac:float=5;

var startfade:bool=false;
var vtween:Tween=null;

func _ready():
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED;

func playermessagedisplayUpdate(message:String):
	startfade=false;
	if message:
		playermessagedisplay.text=message
	playermessagedisplay.set_self_modulate(Color.WHITE)
	gui_timer.start(3)

func _process(_delta):
	if startfade:
		vtween=create_tween()
		vtween.tween_property(playermessagedisplay,"self_modulate",Color.TRANSPARENT,1)
	else:
		vtween=create_tween()
		vtween.tween_property(playermessagedisplay,"self_modulate",Color.WHITE,0)

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
		if picked_obj is Grenade && !picked_obj.is_active:
			picked_obj.grenade_activate()
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
		if (picked_obj is Cube):
			typetooltip.text=(picked_obj.get_meta("cubetype"))
	else:
		typetooltip.text=""

func _on_gui_timer_timeout():
	startfade=true
