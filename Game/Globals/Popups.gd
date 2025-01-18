extends Node


@onready var screen_confirm = preload("res://Game/screen_confirm.tscn")


func show_confirm(parent: Node, callback: Callable):
	var screen = screen_confirm.instantiate()
	parent.add_child(screen)
	screen.show_screen(callback)
