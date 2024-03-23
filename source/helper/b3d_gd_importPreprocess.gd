@tool
extends EditorScript


func _run():
	print("Script started")
	var editor_interface = EditorInterface
	var edited_scene_root = editor_interface.get_edited_scene_root()
	editor_interface.get_selection().add_node(edited_scene_root)
	var levelscene: Node3D = get_scene()
	print("Root node: " + str(levelscene))
	var meshes: Array[Node] = levelscene.get_children()

	#generating collision shapes
	for mesh: MeshInstance3D in meshes:
		print("    processing: " + str(mesh))
		EditorInterface.get_selection().add_node(mesh)
		mesh.create_trimesh_collision()
		print("    mesh: " + str(mesh) + " processed")
