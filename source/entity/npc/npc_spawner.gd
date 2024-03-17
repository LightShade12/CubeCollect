extends Node3D
@onready var text_3d: MeshInstance3D = $text3d
var enemy_types: Array[NodePath] = [
	"res://source/entity/npc/npc_attacker_enemy.tscn", "res://source/entity/npc/npc_retriever_enemy.tscn"
]
var path: NodePath = ""
@onready var spawn_timer: Timer = $spawnTimer
@export var total_enemy_count: int = 5
var current_spawn_count: int = 0
@export var interval_secs: int = 5
@export var spawn_on_start: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_3d.visible = false
	spawn_timer.wait_time = interval_secs
	if spawn_on_start:
		start_spawner()


func start_spawner() -> void:
	spawn_timer.start(interval_secs)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_spawn_timer_timeout() -> void:
	if current_spawn_count < total_enemy_count:
		var enemyinst: CharacterClass = (load(String(enemy_types[0])) as PackedScene).instantiate()
		add_sibling(enemyinst)
		enemyinst.global_transform.origin = self.global_transform.origin
		current_spawn_count += 1
