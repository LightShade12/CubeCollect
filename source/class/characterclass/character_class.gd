extends CharacterBody3D
class_name CharacterClass

var SPEED: float = 5.0
var health: int = 100


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


func damage(dmg: int) -> void:
	health -= dmg


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	for i: int in get_slide_collision_count():
		var c: KinematicCollision3D = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal())
