extends CanvasLayer


func _on_btn_exit_pressed() -> void:
	SignalBus.settings_screen_exit_pressed.emit()


func _on_btn_add_q_pressed() -> void:
	SignalBus.show_add_question_screen.emit()


func _on_btn_reset_deck_pressed() -> void:
	Popups.show_confirm(self, _on_btn_reset_deck_confirmed)


func _on_btn_reset_deck_confirmed():
	SignalBus.reset_deck_default.emit()
