extends CharacterClass
class_name Player
const JUMP_VELOCITY = 4.5

const mouse_sens: float = 0.2
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#private
@onready var head = $head
@onready var interaction_ray_cast = $head/Camera3D/interactionRayCast
@onready var manip_marker = $head/Camera3D/ManipMarker
@onready var camera: Camera3D = $head/Camera3D
@onready var interaction_hint_dislpay = $Control/CanvasLayer/hudControl/interactionHintDislpay
@onready var healthdisplay = $Control/CanvasLayer/hudControl/healthdispbg/healthtxt/healthdisplay
@onready var hud_control = $Control/CanvasLayer/hudControl

@export var trauma_reduction_rate := 1.0

@export var max_x := 10.0
@export var max_y := 10.0
@export var max_z := 5.0

@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var noise_speed := 50.0
@onready var initial_rotation := camera.rotation_degrees as Vector3

var trauma := 0.0

var time := 0.0

#public
@onready var typetooltip = $Control/CanvasLayer/hudControl/typetooltip
@onready var cubecountdisplay = $Control/CanvasLayer/hudControl/cubestxt/cubecountdisplay
@onready
var objectivesdisplay = $Control/CanvasLayer/hudControl/currentobjectivetext/objectivesdisplay
@onready var timerdisplay = $Control/CanvasLayer/hudControl/timerdisplay
@onready var playermessagedisplay = $Control/CanvasLayer/hudControl/playermessagedisplay

var picked_obj: RigidBody3D = null
var pull_fac: float = 20
var throw_fac: float = 5
var object_in_range = null
var vtween: Tween = null


func add_trauma(trauma_amount: float) -> void:
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)


func get_shake_intensity() -> float:
	return trauma * trauma


func get_noise_from_seed(_seed: int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func playermessagedisplayUpdate(message: String):
	if message:
		playermessagedisplay.text = message
	playermessagedisplay.set_self_modulate(Color.WHITE)
	if is_instance_valid(vtween):
		vtween.kill()
	vtween = create_tween()
	vtween.tween_property(playermessagedisplay, "self_modulate", Color.TRANSPARENT, 1).set_delay(3)


var x_shake: float = 0
var y_shake: float = 0
var z_shake: float = 0


func _process(delta):
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)

	x_shake = max_x * get_shake_intensity() * get_noise_from_seed(0)
	y_shake = max_y * get_shake_intensity() * get_noise_from_seed(1)
	z_shake = max_z * get_shake_intensity() * get_noise_from_seed(2)

	camera.rotation_degrees.x = initial_rotation.x + x_shake
	camera.rotation_degrees.y = initial_rotation.y + y_shake
	camera.rotation_degrees.z = initial_rotation.z + z_shake

	hud_control.rotation = z_shake * 0.01
	hud_control.position.x = y_shake * 10
	hud_control.position.y = x_shake * 10

	healthdisplay.text = str(health)
	pass


func _input(event):
	if event is InputEventMouseMotion && !Global.gamepaused:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))

		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))

		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	if Input.is_action_just_pressed("lclick"):
		if picked_obj != null:
			throw_obj()
		else:
			pick_obj()

	if Input.is_action_just_pressed("rclick"):
		drop_obj()

	if Input.is_action_just_pressed("key_interact"):
		if object_in_range is GrenadeSpawner:
			object_in_range.interact()


func throw_obj():
	if picked_obj != null:
		picked_obj.apply_impulse(
			(picked_obj.global_transform.origin - camera.global_transform.origin) * throw_fac
		)
		if picked_obj is Grenade && !picked_obj.is_active:
			picked_obj.grenade_activate()
		picked_obj.is_picked = false
		picked_obj = null


func pick_obj():
	if object_in_range != null and object_in_range is RigidBody3D:
		picked_obj = object_in_range
		picked_obj.is_picked = true


func drop_obj():
	if picked_obj != null:
		picked_obj = null
		picked_obj.is_picked = false


func _physics_process(delta):
	object_in_range = interaction_ray_cast.get_collider()
	if object_in_range:
		if object_in_range.is_in_group("InteractableEntity"):
			interaction_hint_dislpay.text = object_in_range.getInterctionHint()
	else:
		interaction_hint_dislpay.text = ""
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

	if picked_obj != null:
		picked_obj.set_linear_velocity(
			(manip_marker.global_transform.origin - picked_obj.global_transform.origin) * pull_fac
		)
		if picked_obj is Cube:
			typetooltip.text = (picked_obj.get_meta("cubetype"))
	else:
		typetooltip.text = ""
