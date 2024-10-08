extends Control


signal close_add_q_UI

@onready var TXTED_ADD_Q = $cont_add_q/txted_add_q


func add_user_question(new_question) -> void:
	var file = FileAccess.open(Global.QUESTIONS_USER_FILE_PATH, FileAccess.READ_WRITE)
	if not file:
		Global.debug(str("Failed to open user file: ", Global.QUESTIONS_USER_FILE_PATH))
		return
	
	var content = file.get_as_text()
	content += new_question + "\n"
	file.seek(0)
	file.store_string(content)
	file.close()
	
	Global.QUESTIONS.append(new_question)
	Global.debug("Added question: " + new_question)


func _on_btn_add_q_pressed() -> void:
	var q_text: String = TXTED_ADD_Q.text.strip_edges()
	if q_text.is_empty():
		Global.debug("Invalid question entered. Fix and try again")
		return
	add_user_question(q_text)
	close_add_q_UI.emit()
