extends Node

onready var scene_player: Node = $ScenePlayer


func _on_Pause_toggled(button_pressed: bool) -> void:
	get_tree().paused = button_pressed

func _on_Reload_pressed() -> void:
	scene_player.load_scene(Global.target_file)
