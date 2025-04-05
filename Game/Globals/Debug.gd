extends Node

var DEBUG_LOG = ""


func log(text):
	DEBUG_LOG += str(text) + "\n"
	print(text)

func set_win_half_res() -> void:
	var current_size = DisplayServer.window_get_size()
	var new_size = current_size / 2
	DisplayServer.window_set_size(new_size)
	# Center window
	var screen_size = DisplayServer.screen_get_size()
	var new_position = (screen_size - new_size) / 2
	DisplayServer.window_set_position(new_position)
