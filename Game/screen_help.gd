extends CanvasLayer



func _on_btn_exit_pressed() -> void:
	SignalBus.help_screen_exit_pressed.emit()
