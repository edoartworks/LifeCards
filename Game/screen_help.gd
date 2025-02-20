extends CanvasLayer


@export var screen_more_path :NodePath
var SCREEN_MORE: Node = null


func _ready() -> void:
	SCREEN_MORE = get_node(screen_more_path)


func _on_btn_exit_pressed() -> void:
	SignalBus.help_screen_exit_pressed.emit()


func _on_btn_more_pressed() -> void:
	SCREEN_MORE.visible = true


func _on_btn_more_exit_pressed() -> void:
	SCREEN_MORE.visible = false
