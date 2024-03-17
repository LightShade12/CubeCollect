extends Control
class_name HUD_dmg_indicator
@onready var timer: Timer = $Timer
var tweenq: Tween = null
@onready var texture_rect: TextureRect = $TextureRect
var player: Player = null
var hurt_direction: Vector3
var dmg_attacker_loc: Vector3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = 3
	timer.start()
	if is_instance_valid(tweenq):
		tweenq.kill()
	tweenq = create_tween()
	tweenq.tween_property(self, "modulate", Color.TRANSPARENT, 3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	player = Global.player
	hurt_direction = dmg_attacker_loc - player.global_transform.origin
	texture_rect.rotation = atan2(-hurt_direction.x, hurt_direction.z) - ((5 * PI) / 4) + player.get_rotation().y


func _on_timer_timeout() -> void:
	self.call_deferred("free")
