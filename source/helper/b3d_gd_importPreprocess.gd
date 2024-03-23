@tool
extends EditorScript


func _run():
#_editor_interface = plugin.get_editor_interface()
#_edited_scene_root = _editor_interface.get_edited_scene_root()
#_editor_interface.get_selection().add_node(_edited_scene_root)
	#print("Script started")
	#var levelscene:Node3D=get_scene()

	var img = EditorInterface.get_editor_viewport_3d().get_texture().get_image()
	img.save_png("E:/game projects/CubeCollect/cubecollect/screenshots/deadhouse.png")
	print("Saved")
	#print("Root node: "+str(levelscene))
	#var meshes:Array[Node]=levelscene.get_children()
	#for mesh:MeshInstance3D in meshes:
	#print("processing: "+str(mesh))
	#EditorInterface.get_selection().add_node(mesh)
	#mesh.create_trimesh_collision()
	#print("mesh: "+str(mesh)+" processed")
