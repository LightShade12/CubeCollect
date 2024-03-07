extends Node3D

@onready var debrisptcls = $debrisptcls
@onready var smokeptcls = $smokeptcls
@onready var blastlightomni = $blastlightomni
@onready var kill_timer = $killTimer
@onready var explosionfire = $explosionfire
@onready var scorchsmoke = $scorchsmoke
@onready var ember_explosive_ptcls = $ember_explosive_ptcls
@onready var ember_after_ptcls = $ember_after_ptcls

var stween: Tween = null
var ftween: Tween = null


func flash():
	blastlightomni.light_energy = 0

	if is_instance_valid(ftween):
		ftween.kill()
	ftween = create_tween()

	explosionfire.emitting = true
	ftween.tween_property(blastlightomni, "light_energy", 264, 0.1)
	ftween.tween_property(blastlightomni, "light_energy", 0, 0.2)
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	kill_timer.start(16)

	scorchsmoke.visible = true
	explosionfire.visible = true
	debrisptcls.visible = true
	ember_explosive_ptcls.visible = true
	ember_after_ptcls.visible = true
	smokeptcls.visible = true

	#scorchsmoke.one_shot=true;
	explosionfire.one_shot = true
	debrisptcls.one_shot = true
	ember_explosive_ptcls.one_shot = true
	ember_after_ptcls.one_shot = true
	smokeptcls.one_shot = true

	#emission order
	flash()
	await get_tree().create_timer(0.1).timeout
	debrisptcls.emitting = true
	await get_tree().create_timer(0.1).timeout
	ember_explosive_ptcls.emitting = true
	await get_tree().create_timer(0.1).timeout
	smokeptcls.emitting = true
	ember_after_ptcls.emitting = true
	await get_tree().create_timer(0.1).timeout
	scorchsmoke.emitting = true

	scorchsmoke.transparency = 1

	if is_instance_valid(stween):
		stween.kill()
	stween = create_tween()
	stween.tween_property(scorchsmoke, "transparency", 0, 2)
	stween.tween_property(scorchsmoke, "transparency", 1, 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_kill_timer_timeout():
	self.call_deferred("free")
	pass  # Replace with function body.
