extends Control


func _on_btn_add_q_pressed() -> void:
	SignalBus.card_menu_add_question_pressed.emit()


func _on_btn_delete_q_pressed() -> void:
	delete_current_question()
	SignalBus.current_question_deleted.emit()


func delete_current_question() -> void:
	var file = FileAccess.open(Global.QUESTIONS_USER_FILE_PATH, FileAccess.READ_WRITE)
	if not file:
		Global.debug(str("Failed to open user file: ", Global.QUESTIONS_USER_FILE_PATH))
		return
		
	var content = file.get_as_text()
	if Global.QUESTIONS.size() == 1:
		Global.debug("Cannot delete the last question. Add one first.")
		return
	var current_question = Global.QUESTIONS[Global.CURRENT_QUESTION_IDX]
	var lines = content.split("\n")
	var new_lines = []
	for line in lines:
		if line.find(current_question) == -1:
			new_lines.append(line)
	content = "\n".join(new_lines)
	file.store_string(content)
	file.close()

	Global.QUESTIONS.erase(current_question)
	Global.debug("Deleted question: " + current_question)


func _on_btn_shuffle_deck_pressed() -> void:
	SignalBus.shuffle_deck.emit()
