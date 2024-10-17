extends Control


signal close_add_q_UI

@export var txted_add_question_path : NodePath
var TXTED_ADD_QUESTION :TextEdit = null

func _ready() -> void:
	TXTED_ADD_QUESTION = get_node(txted_add_question_path)


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


func _on_btn_confirm_pressed() -> void:
	var q_text: String = ""
	q_text = TXTED_ADD_QUESTION.text.strip_edges()
	if q_text.is_empty():
		Global.debug("Invalid question entered. Fix and try again")
		return
	add_user_question(q_text)
	TXTED_ADD_QUESTION.text = ""
	close_add_q_UI.emit()


func _on_btn_cancel_pressed() -> void:
	TXTED_ADD_QUESTION.text = ""
	close_add_q_UI.emit()
