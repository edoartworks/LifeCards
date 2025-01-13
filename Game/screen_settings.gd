extends CanvasLayer


func _on_btn_exit_pressed() -> void:
	SignalBus.settings_screen_exit_pressed.emit()


func _on_btn_add_q_pressed() -> void:
	SignalBus.show_add_question_screen.emit()


func _on_toggle_shuffle_play_toggle_pressed(setting_key: String, new_toggle_state: bool) -> void:
	Global.set_setting(setting_key, new_toggle_state)
