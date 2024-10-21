extends CanvasLayer


@export var txted_add_question_path : NodePath
@export var cont_add_q_path : NodePath
var TXTED_ADD_QUESTION :TextEdit = null
var CONT_ADD_QUESTION :Container = null

var initial_cont_size_y
var stop_adjusting_keyboard = false

var has_v_keyboard = DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD)

func _ready() -> void:
	TXTED_ADD_QUESTION = get_node(txted_add_question_path)
	CONT_ADD_QUESTION = get_node(cont_add_q_path)
	initial_cont_size_y = CONT_ADD_QUESTION.size.y


func _process(_delta: float) -> void:
	if has_v_keyboard:
		_adjust_to_keyboard()

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


func _adjust_to_keyboard() -> void:
	var keyb_heigh = DisplayServer.virtual_keyboard_get_height()
	if keyb_heigh > 0:
		var new_size_y = initial_cont_size_y - keyb_heigh
		CONT_ADD_QUESTION.set_size(Vector2(CONT_ADD_QUESTION.size.x, new_size_y))
	else:
		CONT_ADD_QUESTION.set_size(Vector2(CONT_ADD_QUESTION.size.x, initial_cont_size_y))


func _on_btn_confirm_pressed() -> void:
	var q_text: String = ""
	q_text = TXTED_ADD_QUESTION.text.strip_edges()
	# TODO: remove newlines inside
	if q_text.is_empty():
		Global.debug("Invalid question entered. Fix and try again")
		return
	add_user_question(q_text)
	TXTED_ADD_QUESTION.text = ""
	SignalBus.close_add_question_screen.emit()


func _on_btn_cancel_pressed() -> void:
	TXTED_ADD_QUESTION.text = ""
	SignalBus.close_add_question_screen.emit()
