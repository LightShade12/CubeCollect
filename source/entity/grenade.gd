extends RigidBody3D
class_name Grenade

@onready var core_audioplayer = $coreAudioplayer
@onready var aux_audioplayer = $auxAudioplayer
@onready var fuse_timer = $FuseTimer
@onready var ray_cast = $RayCast
const GRENADEDECAL = preload("res://source/entity/grenadedecal.tscn")
const GRENADE_PARTICLE_SYSTEM = preload("res://source/entity/grenade_particle_system.tscn")
var exploded:bool=false;
var is_active=false;
var items_in_rad:Array
var explosion_force:float=10
var interval:int =10
var int_timer:int=interval;
var fuse_time_secs:float=4;
var is_picked=false;
var player_in_rad:Player=null;#can make it an array
# Called when the node enters the scene tree for the first time.

func _ready():
	pass # Replace with function body.

func grenade_activate():
	fuse_timer.start(fuse_time_secs)
	is_active=true

func identify():
	print(self)

func getInterctionHint()->String:
	if is_picked:
		return "Lclick to throw"
	else:
		return "Lclick to equip"

func _physics_process(_delta):
	ray_cast.look_at(Vector3(self.global_transform.origin.x,self.global_transform.origin.y-2,self.global_transform.origin.z),Vector3(1,0,0))
	ray_cast.global_rotation.x+=deg_to_rad(90)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !exploded and is_active:
		if int_timer==0:
			core_audioplayer.stream=load("res://assets/sounds/grenade/beep-sound-8333.mp3")
			core_audioplayer.play()
			int_timer=interval*fuse_timer.time_left+15
		else:
			int_timer-=1
	
	if exploded:
		await get_tree().create_timer(3.5).timeout
		self.call_deferred("free")

func explode():
	core_audioplayer.set_stream(preload("res://assets/sounds/grenade/shotgun-firing-4-6746.mp3"))
	core_audioplayer.volume_db=20
	core_audioplayer.play()
	visible=false
	var force_dir:Vector3
	
	var spnpt=ray_cast.get_collision_point()
	
	var decalnode=GRENADEDECAL.instantiate()
	add_sibling(decalnode)
	decalnode.global_transform.origin=spnpt
	var smokeptclsys=GRENADE_PARTICLE_SYSTEM.instantiate()
	add_sibling(smokeptclsys)
	smokeptclsys.global_transform.origin=spnpt
	
	
	for obj in items_in_rad:
		if obj is RigidBody3D:
			force_dir=self.global_transform.origin.direction_to(obj.global_transform.origin)
			obj.apply_impulse(force_dir*explosion_force)
		elif obj is CharacterClass:
			obj.damage(50)
	
	if player_in_rad:
		var dist=(player_in_rad.global_position-self.global_position).length()
		var trauma_amt=max(0.3+(1-(0.066*dist)),0)
		print(trauma_amt)
		player_in_rad.add_trauma(trauma_amt)#0-1
	
	exploded=true
	
	#debris sfx
	await get_tree().create_timer(1).timeout
	core_audioplayer.volume_db=-5
	aux_audioplayer.volume_db=0
	aux_audioplayer.stream=preload("res://assets/sounds/grenade/zapsplat_foley_sand_handful_drop_ground_002_43847.mp3")
	core_audioplayer.stream=preload("res://assets/sounds/grenade/debris.wav")
	core_audioplayer.play()
	aux_audioplayer.play()

func _on_area_3d_body_entered(body):
	if body.name!=self.name:
		#if body is RigidBody3D:
		items_in_rad.append(body)

func _on_area_3d_body_exited(body):
	#if body is RigidBody3D:
	items_in_rad.erase(body)

func _on_timer_timeout():
	pass # Replace with function body.

#collision sound
func _on_body_entered(_body):
	if !exploded:
		if linear_velocity.length()>1:
			#aux_audioplayer.pitch_scale=randf_range(0.95,1.05)
			aux_audioplayer.play()
	pass # Replace with function body.


func _on_fuse_timer_timeout():
	explode()
	pass # Replace with function body.


func _on_trauma_area_body_entered(body):
	if body is Player:
		player_in_rad=body;
	pass # Replace with function body.

func _on_trauma_area_body_exited(body):
	if body is Player:
		player_in_rad=null;
	pass # Replace with function body.
