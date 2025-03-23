extends Control


func _on_btn_add_q_pressed() -> void:
	SignalBus.show_add_question_screen.emit()


func _on_btn_delete_q_pressed() -> void:
	delete_current_question()
	SignalBus.current_question_deleted.emit()


func delete_current_question() -> void:
	var file = FileAccess.open(Global.QUESTIONS_USER_PATH, FileAccess.WRITE)
	if not file:
		Global.debug(str("Failed to open user file: ", Global.QUESTIONS_USER_PATH))
		return
	
	var questions_dict: Dictionary = Global.ALL_QUESTIONS
	
	if Global.QUESTIONS.size() == 1:
		Global.debug("Cannot delete the last question. Add one first.")
		return
	
	var current_question = Global.QUESTIONS[Global.CURRENT_QUESTION_IDX]
	
	for category in questions_dict.keys():
		if current_question in questions_dict[category]:
			questions_dict[category].erase(current_question)
			break
	
	for category_key in questions_dict.keys():
		file.store_line(category_key + ":")
		for question in questions_dict[category_key]:
			file.store_line("  - " + question)
	file.close()
	
	Global.debug("Deleting question: " + current_question)


func _on_btn_shuffle_deck_pressed() -> void:
	SignalBus.shuffle_deck.emit()
