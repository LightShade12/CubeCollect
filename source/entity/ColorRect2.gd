extends ColorRect
@onready var camera_node: Camera3D = $"../../../head/camera_pivot/Camera3D"
@onready var directional_light: DirectionalLight3D = $"../../../../../DirectionalLight3D"

#default tint=1.4,1.2,1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var effective_sun_direction: Vector3 = directional_light.global_transform.basis.z * maxf(camera_node.near, 1.0)

	effective_sun_direction += camera_node.global_transform.origin

# Disable rendering of lens flare if sun is behind the camera

	visible = not camera_node.is_position_behind(effective_sun_direction)

# Only change shader param when visible

	if visible:
		var unprojected_sun_position: Vector2 = camera_node.unproject_position(effective_sun_direction)
		(material as ShaderMaterial).set_shader_parameter("sun_position", unprojected_sun_position)
