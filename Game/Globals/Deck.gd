extends Node

var QUESTIONS_SRC_PATH = "res://Data/questions.txt"
var QUESTIONS_USER_PATH = "user://questions.txt"

var QUESTIONS: Array[String] = []
var ALL_QUESTIONS: Dictionary = {}
var CURRENT_QUESTION_IDX = 0
var IS_DECK_SHUFFLED = false


func _ready() -> void:
	SignalBus.shuffle_deck.connect(shuffle_deck)
	SignalBus.filters_screen_exit_pressed.connect(reset_deck_to_user)
	SignalBus.reset_deck_default.connect(reset_deck_to_default)


func load_questions(path: String = QUESTIONS_USER_PATH) -> bool:
	# Load questions from user file, then filter them by category settings
	ALL_QUESTIONS = File.parse_questions_file(path)
	if ALL_QUESTIONS.is_empty():
		return false
	
	_filter_questions()
	Debug.log("Questions loaded")
	return true


func import_questions(path: String) -> void:
	Debug.log("Importing questions...")
	var file = FileAccess.open(QUESTIONS_USER_PATH, FileAccess.WRITE)
	if not file:
		Debug.log("Failed to open file: " + QUESTIONS_USER_PATH)
		return
	
	var deck_is_empty = true
	for category in ALL_QUESTIONS.keys():
		if ALL_QUESTIONS[category].size() > 0:
			deck_is_empty = false
			break
		
	if deck_is_empty:
		Debug.log("Empty deck. Loading new questions...")
		if not load_questions(path):
			Debug.log("Questions failed to import")
			return
	else:
		# Merge old and new questions
		Debug.log("Merging questions")
		var new_questions = File.parse_questions_file(path)
		if new_questions.is_empty():
			Debug.log("Questions failed to import")
			return
		
		for category in ALL_QUESTIONS.keys():
			if new_questions.has(category):
				ALL_QUESTIONS[category].append_array(new_questions[category])
		_filter_questions()
	
	_write_dict_to_file(ALL_QUESTIONS, file)
	SignalBus.questions_imported.emit()
	Debug.log("Questions imported from file")


func reset_deck_to_default() -> void:
	# Replace user file with default source file
	File.copy_file(QUESTIONS_SRC_PATH, QUESTIONS_USER_PATH)
	reset_deck_to_user()
	Debug.log("Questions reset to default")


func reset_deck_to_user():
	# Reload deck then set card to first
	load_questions()
	set_card_idx_to_first()
	IS_DECK_SHUFFLED = false
	Debug.log("Questions reset to user")


func shuffle_deck() -> void:
	QUESTIONS.shuffle()
	set_card_idx_to_first()
	IS_DECK_SHUFFLED = true


func set_card_idx_to_first():
	CURRENT_QUESTION_IDX = 0


func add_user_question(category: String, new_question: String):
	var file = FileAccess.open(QUESTIONS_USER_PATH, FileAccess.WRITE)
	if not file:
		Debug.log("Failed to open user file: " + QUESTIONS_USER_PATH)
		return

	var current_all_questions: Dictionary = ALL_QUESTIONS
	var current_cat_questions: Array = current_all_questions.get(category, [])
	current_cat_questions.append(new_question)
	current_all_questions[category] = current_cat_questions

	_write_dict_to_file(current_all_questions, file)

	# Insert the question into the active deck or reload deck.
	if IS_DECK_SHUFFLED and Config.get_config("filters", category):
		QUESTIONS.insert(CURRENT_QUESTION_IDX, new_question)
	else:
		load_questions()

	SignalBus.new_question_added.emit()
	Debug.log("Added question: [" + category + "] " + new_question)


func delete_current_question() -> bool:
	var questions_dict: Dictionary = ALL_QUESTIONS
	if QUESTIONS.is_empty():
		Debug.log("Trying to delete question on empty list.")
		return false
	
	var file = FileAccess.open(QUESTIONS_USER_PATH, FileAccess.WRITE)
	if not file:
		Debug.log(str("Failed to open user file: ", QUESTIONS_USER_PATH))
		return false
	
	# Delete  question
	var question_to_delete = QUESTIONS[CURRENT_QUESTION_IDX]
	for category in questions_dict.keys():
		if Config.get_config("filters", category) and question_to_delete in questions_dict[category]:
			questions_dict[category].erase(question_to_delete)
			break
	
	_write_dict_to_file(questions_dict, file)
	
	if IS_DECK_SHUFFLED:
		QUESTIONS.remove_at(CURRENT_QUESTION_IDX)
	else:
		load_questions()
	
	Debug.log("Deleted question: " + question_to_delete)
	SignalBus.current_question_deleted.emit()
	return true


func delete_all_questions() -> void:
	var file = FileAccess.open(QUESTIONS_USER_PATH, FileAccess.WRITE)
	if not file:
		Debug.log(str("Failed to open user file: ", QUESTIONS_USER_PATH))
		return
	
	for category in ALL_QUESTIONS.keys():
		ALL_QUESTIONS[category] = []
	for category_key in ALL_QUESTIONS.keys():
		file.store_line(category_key + ":")
	file.close()
	QUESTIONS = []
	Debug.log("All questions deleted.")
	SignalBus.all_questions_deleted.emit()


func get_current_question_category() -> String:
	var current_q = QUESTIONS[CURRENT_QUESTION_IDX]
	for key in ALL_QUESTIONS.keys():
		for q in ALL_QUESTIONS[key]:
			if q == current_q:
				return str(key)
	return ""


func _write_dict_to_file(dict: Dictionary, file: FileAccess) -> void:
	for category_key in range(1,5):
		var category_str = str(category_key)
		file.store_line(category_str + ":")
		if dict.has(category_str):
			for question in dict[category_str]:
				file.store_line("- " + question)
	file.close()


func _filter_questions() -> void:
	var filtered_questions: Array[String] = []
	for category in ALL_QUESTIONS.keys():
		var filter_value = Config.get_config("filters", category)
		if filter_value:
			filtered_questions.append_array(ALL_QUESTIONS[category])
	QUESTIONS = filtered_questions
