extends CanvasLayer


@export var txted_add_question_path : NodePath
@export var cont_add_q_path : NodePath
@export var cat_option_btn_path : NodePath
var TXTED_ADD_QUESTION :TextEdit = null
var CONT_ADD_QUESTION :Container = null
var CAT_OPTION :OptionButton = null

var initial_cont_size_y
var has_v_keyboard = DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD)


func _ready() -> void:
	TXTED_ADD_QUESTION = get_node(txted_add_question_path)
	CONT_ADD_QUESTION = get_node(cont_add_q_path)
	CAT_OPTION = get_node(cat_option_btn_path)
	initial_cont_size_y = CONT_ADD_QUESTION.size.y


func _process(_delta: float) -> void:
	if has_v_keyboard:
		_adjust_to_keyboard()


func add_user_question(category: String, new_question: String) -> void:
	var file = FileAccess.open(Global.QUESTIONS_USER_PATH, FileAccess.READ_WRITE)
	if not file:
		Global.debug(str("Failed to open user file: ", Global.QUESTIONS_USER_PATH))
		return
	
	var questions_dict: Dictionary = Global.ALL_QUESTIONS
	var questions_array = questions_dict[category]
	questions_array.append(new_question)
	questions_dict[category] = questions_array
	
	for category_key in questions_dict.keys():
		file.store_line(category_key + ":")
		for question in questions_dict[category_key]:
			file.store_line("  - " + question)
	file.close()
	
	Global.debug(str("Added question: [" + category + "] " + new_question))
	Global.reload_questions()
	SignalBus.new_question_added.emit()


func _adjust_to_keyboard() -> void:
	var keyb_heigh = DisplayServer.virtual_keyboard_get_height()
	if keyb_heigh > 0:
		var new_size_y = initial_cont_size_y - keyb_heigh
		CONT_ADD_QUESTION.set_size(Vector2(CONT_ADD_QUESTION.size.x, new_size_y))
		if not Global.IS_KEYBOARD_OPEN:
			Global.IS_KEYBOARD_OPEN = true
	else:
		CONT_ADD_QUESTION.set_size(Vector2(CONT_ADD_QUESTION.size.x, initial_cont_size_y))
		if Global.IS_KEYBOARD_OPEN:
			Global.IS_KEYBOARD_OPEN = false


func _on_btn_confirm_pressed() -> void:
	var q_text: String = ""
	q_text = TXTED_ADD_QUESTION.text.strip_edges()
	if q_text.is_empty():
		Global.debug("Invalid question entered. Fix and try again")
		return
	var selected_category = str(CAT_OPTION.get_selected_id() + 1)
	add_user_question(selected_category, q_text)
	TXTED_ADD_QUESTION.text = ""
	SignalBus.hide_add_question_screen.emit()


func _on_btn_cancel_pressed() -> void:
	Global.debug("Adding question cancelled")
	TXTED_ADD_QUESTION.text = ""
	SignalBus.hide_add_question_screen.emit()
