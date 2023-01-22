extends Node2D

export(PackedScene) var level1


func _on_Start_pressed():
	print(get_tree().change_scene_to(level1))


func _on_Exit_pressed():
	get_tree().quit()
