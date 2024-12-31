extends CanvasLayer


func _on_btn_exit_pressed() -> void:
	SignalBus.settings_screen_exit_pressed.emit()


func _on_btn_add_q_pressed() -> void:
	SignalBus.show_add_question_screen.emit()
