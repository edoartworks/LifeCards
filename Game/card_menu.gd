extends PanelContainer


func _on_btn_add_q_pressed() -> void:
	SignalBus.open_add_question_screen.emit()
