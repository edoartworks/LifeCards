extends Control


func _on_btn_add_q_pressed() -> void:
	SignalBus.show_add_question_screen.emit()


func _on_btn_delete_q_pressed() -> void:
	delete_current_question()
	SignalBus.current_question_deleted.emit()


func delete_current_question() -> void:
	var file = FileAccess.open(Deck.QUESTIONS_USER_PATH, FileAccess.WRITE)
	if not file:
		Debug.log(str("Failed to open user file: ", Deck.QUESTIONS_USER_PATH))
		return
	
	var questions_dict: Dictionary = Deck.ALL_QUESTIONS
	
	if Deck.QUESTIONS.size() == 1:
		Debug.log("Cannot delete the last question. Add one first.")
		return
	
	var current_question = Deck.QUESTIONS[Deck.CURRENT_QUESTION_IDX]
	
	for category in questions_dict.keys():
		if current_question in questions_dict[category]:
			questions_dict[category].erase(current_question)
			break
	
	for category_key in questions_dict.keys():
		file.store_line(category_key + ":")
		for question in questions_dict[category_key]:
			file.store_line("  - " + question)
	file.close()
	
	Debug.log("Deleting question: " + current_question)


func _on_btn_shuffle_deck_pressed() -> void:
	SignalBus.shuffle_deck.emit()


func _on_btn_font_less_pressed() -> void:
	SignalBus.font_size_less.emit()


func _on_btn_font_more_pressed() -> void:
	SignalBus.font_size_more.emit()
