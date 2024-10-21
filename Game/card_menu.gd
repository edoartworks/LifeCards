extends CanvasLayer

signal close_menu


func _on_btn_add_q_pressed() -> void:
	SignalBus.open_add_question_screen.emit()


func _on_btn_close_menu_pressed() -> void:
	close_menu.emit()
