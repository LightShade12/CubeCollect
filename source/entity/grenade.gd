extends RigidBody3D
class_name Grenade

@onready var timer = $Timer
@onready var core_audioplayer = $coreAudioplayer
@onready var aux_audioplayer = $auxAudioplayer

var exploded:bool=false;
var is_active=false;
var items_in_rad:Array
var explosion_force:float=10
var interval:int =10
var int_timer:int=interval;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func grenade_activate():
	timer.start()
	is_active=true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !exploded and is_active:
		if int_timer==0:
			core_audioplayer.stream=load("res://assets/sounds/grenade/beep-sound-8333.mp3")
			core_audioplayer.play()
			int_timer=interval*timer.time_left+15
		else:
			int_timer-=1
	
	if exploded:
		await get_tree().create_timer(1.5).timeout
		self.call_deferred("free")

func explode():
	core_audioplayer.set_stream(load("res://assets/sounds/grenade/shotgun-firing-4-6746.mp3"))
	core_audioplayer.play()
	visible=false
	var force_dir:Vector3
	
	for obj in items_in_rad:
		if obj:
			force_dir=self.position.direction_to(obj.position)
			obj.apply_impulse(force_dir*explosion_force)
	exploded=true

func _on_area_3d_body_entered(body):
	if body.name!=self.name:
		if body is RigidBody3D:
			items_in_rad.append(body)

func _on_area_3d_body_exited(body):
	if body is RigidBody3D:
		items_in_rad.erase(body)

func _on_timer_timeout():
	print("explode")
	explode()
	pass # Replace with function body.

func _on_body_entered(body):
	if !exploded:
		if linear_velocity.length()>1:
			aux_audioplayer.pitch_scale=randf_range(0.95,1.05)
			aux_audioplayer.play()
	pass # Replace with function body.
