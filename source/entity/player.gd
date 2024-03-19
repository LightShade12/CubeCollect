extends CharacterClass
class_name Player

const JUMP_VELOCITY: float = 4.5
const HUD_DAMAGE_INDICATOR: PackedScene = preload("res://source/entity/hud_damage_indicator.tscn")

var mouse_sens: float = 0.2
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
#private
@onready var flashlight: SpotLight3D = $head/flashlight
@onready var head: Node3D = $head
@onready var interaction_hint_dislpay: Label = $Control/CanvasLayer/hudControl/movableHudControl/interactionHintDislpay
@onready
var healthdisplay: Label = $Control/CanvasLayer/hudControl/movableHudControl/healthdispbg/healthtxt/healthdisplay
@onready var hud_control: Control = $Control/CanvasLayer/hudControl
@onready var crouching_collisionshape: CollisionShape3D = $crouchingCollisionshape
@onready var standing_collisionshape: CollisionShape3D = $CollisionShape3D
@onready var cieling_raycast: RayCast3D = $cielingRaycast
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_pivot: Node3D = $head/camera_pivot
@onready var camera: Camera3D = $head/camera_pivot/Camera3D
@onready var manip_marker: Marker3D = $head/camera_pivot/Camera3D/ManipMarker
@onready var interaction_ray_cast: RayCast3D = $head/camera_pivot/Camera3D/interactionRayCast
@onready var movable_hud_control: Control = $Control/CanvasLayer/hudControl/movableHudControl

@export var trauma_reduction_rate: float = 1.0  #per process tick
@export var trauma_shake_max_x: float = 10.0
@export var trauma_shake_max_y: float = 10.0
@export var trauma_shake_max_z: float = 5.0

@export var trauma_shake_noise: FastNoiseLite
@export var trauma_shake_noise_speed: float = 50.0
@onready var initial_rotation: Vector3 = camera.rotation_degrees

#public
@onready var typetooltip: Label = $Control/CanvasLayer/hudControl/movableHudControl/typetooltip
@onready var cubecountdisplay: Label = $Control/CanvasLayer/hudControl/movableHudControl/cubestxt/cubecountdisplay
@onready
var objectivesdisplay: Label = $Control/CanvasLayer/hudControl/movableHudControl/currentobjectivetext/objectivesdisplay
@onready var timerdisplay: Label = $Control/CanvasLayer/hudControl/movableHudControl/timerdisplay
@onready var playermessagedisplay: Label = $Control/CanvasLayer/hudControl/movableHudControl/playermessagedisplay

#states
var sliding: bool = false
var walking: bool = false
var sprinting: bool = false
var crouching: bool = false
var freelooking: bool = false

var current_speed: float = 5.0

var slide_timer: float = 0.0
var slide_timer_max: float = 1.0
var slide_vector: Vector2 = Vector2.ZERO
var slide_speed: float = 10.0

var head_bobbing_crouching_intensity: float = 0.01
var head_bobbing_walking_intensity: float = 0.1
var head_bobbing_sprinting_intensity: float = 0.2

const head_bobbing_sprinting_speed: float = 22.0
const head_bobbing_walking_speed: float = 18.0
const head_bobbing_crouching_speed: float = 10.0

var head_bobbing_index: float = 0.0
var head_bobbing_vector: Vector2 = Vector2.ZERO
var head_bobbing_current_intensity: float = 0.0

const walking_speed: float = 3.0
const sprinting_speed: float = 6.0
const crouching_speed: float = 1.4
const crouching_depth: float = -0.6

const freelook_tilt_scale: float = 5.0

const sprint_fov: float = 110.0
const walk_fov: float = 90.0

var direction: Vector3 = Vector3.ZERO
const jump_velocity: float = 4.5
var lerp_speed: float = 12
var last_velocity: Vector3 = Vector3.ZERO

var trauma: float = 0.0

var time: float = 0.0

#intermediate working vars
var x_shake: float = 0
var y_shake: float = 0
var z_shake: float = 0
var vtween: Tween = null
var picked_obj: RigidBody3D = null
var object_in_range: Node3D = null

var pull_fac: float = 20
var throw_fac: float = 5
var hurt_direction: Vector3 = Vector3.ZERO


func add_trauma(trauma_amount: float) -> void:
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)


func get_shake_intensity() -> float:
	return trauma * trauma


func get_trauma_shake_noise_from_seed(_seed: int) -> float:
	trauma_shake_noise.seed = _seed
	return trauma_shake_noise.get_noise_1d(time * trauma_shake_noise_speed)


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func playermessagedisplayUpdate(message: String) -> void:
	if message:
		playermessagedisplay.text = message
	playermessagedisplay.set_self_modulate(Color.WHITE)
	if is_instance_valid(vtween):
		vtween.kill()
	vtween = create_tween()
	vtween.tween_property(playermessagedisplay, "self_modulate", Color.TRANSPARENT, 1).set_delay(3)


func _process(delta: float) -> void:
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)

	movable_hud_control.position.x = lerpf(movable_hud_control.position.x, 0, delta * 5)
	movable_hud_control.position.y = lerpf(movable_hud_control.position.y, 0, delta * 5)

	x_shake = trauma_shake_max_x * get_shake_intensity() * get_trauma_shake_noise_from_seed(0)
	y_shake = trauma_shake_max_y * get_shake_intensity() * get_trauma_shake_noise_from_seed(1)
	z_shake = trauma_shake_max_z * get_shake_intensity() * get_trauma_shake_noise_from_seed(2)

	camera.rotation_degrees.x = initial_rotation.x + x_shake
	camera.rotation_degrees.y = initial_rotation.y + y_shake
	camera.rotation_degrees.z = initial_rotation.z + z_shake

	hud_control.rotation = z_shake * 0.01
	hud_control.position.x = y_shake * 10
	hud_control.position.y = x_shake * 10

	healthdisplay.text = str(health)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		movable_hud_control.position.x -= event.relative.x
		movable_hud_control.position.y -= event.relative.y

		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))

		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))

		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	if Input.is_action_just_pressed("key_flashlight_toggle"):
		flashlight.visible = !flashlight.visible

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


func throw_obj() -> void:
	if picked_obj != null:
		picked_obj.apply_impulse((picked_obj.global_transform.origin - camera.global_transform.origin) * throw_fac)
		if picked_obj is Grenade && !picked_obj.is_active:
			picked_obj.grenade_activate()
		picked_obj.is_picked = false
		picked_obj = null


func pick_obj() -> void:
	if object_in_range != null and object_in_range is RigidBody3D:
		picked_obj = object_in_range
		picked_obj.is_picked = true


func drop_obj() -> void:
	if picked_obj != null:
		picked_obj.is_picked = false
		picked_obj = null


func _physics_process(delta: float) -> void:
	object_in_range = interaction_ray_cast.get_collider()
	if object_in_range:
		if object_in_range.is_in_group("InteractableEntity"):
			interaction_hint_dislpay.text = object_in_range.getInterctionHint()
	else:
		interaction_hint_dislpay.text = ""

	# Get the input direction and handle the movement/deceleration.
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_front", "move_back")

	# Add the gravity.`
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("key_jump") and is_on_floor():
		#animation_player.play("jump")
		crouching = false
		velocity.y = jump_velocity
		sliding = false

	#CROUCH
	if Input.is_action_just_pressed("key_crouch"):
		crouching = !crouching
		if sliding:
			sliding = false
			crouching = true

	if crouching || sliding:
		if is_on_floor():
			current_speed = lerp(current_speed, crouching_speed, delta * lerp_speed)
		camera_pivot.position.y = lerp(camera_pivot.position.y, crouching_depth, lerp_speed * delta)

		standing_collisionshape.disabled = true
		crouching_collisionshape.disabled = false

		#SLIDE START
		if sprinting && (input_dir != Vector2.ZERO) && is_on_floor():
			slide_vector = input_dir
			sliding = true
			slide_timer = slide_timer_max

		walking = false
		sprinting = false

	elif !cieling_raycast.is_colliding():
		#STANDING
		standing_collisionshape.disabled = false
		crouching_collisionshape.disabled = true

		camera_pivot.position.y = lerp(camera_pivot.position.y, 0.0, lerp_speed * delta)

		if Input.is_action_pressed("key_sprint"):
			#SPRINT
			camera.fov = lerp(camera.fov, sprint_fov, delta * lerp_speed * 0.3)
			current_speed = lerp(current_speed, sprinting_speed, delta * lerp_speed)

			walking = false
			sprinting = true
			crouching = false
		else:
			#WALK
			camera.fov = lerp(camera.fov, walk_fov, delta * lerp_speed * 0.2)
			current_speed = lerp(current_speed, walking_speed, delta * lerp_speed)

			walking = true
			sprinting = false
			crouching = false

	#SLIDE END
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
			crouching = false
			freelooking = false

	#HEADBOBBING
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed * delta
	elif walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed * delta

	if is_on_floor() && !sliding && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index / 2.0) + 0.5
		camera_pivot.position.y = lerp(
			camera_pivot.position.y, head_bobbing_vector.y * (head_bobbing_current_intensity / 2.0), delta * lerp_speed
		)
		camera_pivot.position.x = lerp(
			camera_pivot.position.x, head_bobbing_vector.x * head_bobbing_current_intensity, delta * lerp_speed
		)
	else:
		#idle/still
		camera_pivot.position.y = lerp(camera_pivot.position.y, 0.0, delta * lerp_speed)
		camera_pivot.position.x = lerp(camera_pivot.position.x, 0.0, delta * lerp_speed)

	if is_on_floor() && last_velocity.y < 0:
		animation_player.play("jump_landing")
		pass

	#AIR CONTROL
	if is_on_floor():
		direction = lerp(
			direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), lerp_speed * delta
		)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta)

	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
		current_speed = (slide_timer + 0.1) * slide_speed

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

	#DEACCEL (currently apparently nonfunctional)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	movable_hud_control.position.x -= (velocity.x * cos(rotation.y) + -velocity.z * sin(rotation.y))
	movable_hud_control.position.y += velocity.y
	last_velocity = velocity

	move_and_slide()

	super(delta)

	if picked_obj != null:
		picked_obj.set_linear_velocity(
			(manip_marker.global_transform.origin - picked_obj.global_transform.origin) * pull_fac
		)
		if picked_obj is Cube:
			typetooltip.text = (picked_obj.get_meta("cubetype"))
	else:
		typetooltip.text = ""


func pdamage(dmg: int, dmgloc: Vector3) -> void:
	health -= dmg
	var inst: HUD_dmg_indicator = HUD_DAMAGE_INDICATOR.instantiate()
	inst.dmg_attacker_loc = dmgloc
	hud_control.add_child(inst)
