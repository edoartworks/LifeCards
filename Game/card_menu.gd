extends Control


func _on_btn_add_q_pressed() -> void:
	SignalBus.show_add_question_screen.emit()


func _on_btn_delete_q_pressed() -> void:
	if Deck.delete_current_question():
		SignalBus.current_question_deleted.emit()


func _on_btn_shuffle_deck_pressed() -> void:
	SignalBus.shuffle_deck.emit()


func _on_btn_font_less_pressed() -> void:
	SignalBus.font_size_less.emit()


func _on_btn_font_more_pressed() -> void:
	SignalBus.font_size_more.emit()
