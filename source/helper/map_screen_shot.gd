@tool
extends EditorScript


func _run():
	var img = EditorInterface.get_editor_viewport_3d().get_texture().get_image()
	img.save_png("E:/game projects/CubeCollect/cubecollect/screenshots/deadhouse.png")
	print("Saved")
