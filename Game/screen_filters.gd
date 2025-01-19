extends CanvasLayer


func _on_btn_exit_pressed() -> void:
	SignalBus.filters_screen_exit_pressed.emit()
