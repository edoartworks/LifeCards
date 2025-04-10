extends Node

var QUESTIONS_SRC_PATH = "res://Data/questions.yml"
var QUESTIONS_USER_PATH = "user://questions.yml"

var QUESTIONS: Array[String] = []
var ALL_QUESTIONS = {}
var CURRENT_QUESTION_IDX = 0
var IS_DECK_SHUFFLED = false

func _ready() -> void:
	SignalBus.shuffle_deck.connect(shuffle_deck)
	SignalBus.filters_screen_exit_pressed.connect(reset_deck_to_user)
	SignalBus.reset_deck_default.connect(reset_deck_to_default)


func load_questions() -> void:
	# Load questions from user file, then filter them by category settings
	ALL_QUESTIONS = File.parse_yaml_file(QUESTIONS_USER_PATH)
	var filtered_questions: Array[String] = []
	for category in ALL_QUESTIONS.keys():
		var filter_value = Config.get_config("filters", category)
		if filter_value:
			filtered_questions.append_array(ALL_QUESTIONS[category])
	QUESTIONS = filtered_questions
	Debug.log("Questions loaded")


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

	# Update ALL_QUESTIONS with the new question.
	var current_all_questions: Dictionary = ALL_QUESTIONS
	var current_cat_questions: Array = current_all_questions.get(category, [])
	current_cat_questions.append(new_question)
	current_all_questions[category] = current_cat_questions

	# Rewrite the updated ALL_QUESTIONS back to the file.
	for category_key in current_all_questions.keys():
		file.store_line(category_key + ":")
		for question in current_all_questions[category_key]:
			file.store_line("  - " + question)
	file.close()

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
	
	# Write all categories back to the file, including empty ones for reusability
	for category_key in questions_dict.keys():
		file.store_line(category_key + ":")
		for question in questions_dict[category_key]:
			file.store_line("  - " + question)
	file.close()
	
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
	
	var questions_dict: Dictionary = ALL_QUESTIONS
	for category in questions_dict.keys():
		questions_dict[category] = []
	for category_key in questions_dict.keys():
		file.store_line(category_key + ":")
	file.close()
	
	Debug.log("All questions deleted.")
	load_questions()
	SignalBus.all_questions_deleted.emit()


func get_current_question_category() -> String:
	var current_q = QUESTIONS[CURRENT_QUESTION_IDX]
	for key in ALL_QUESTIONS.keys():
		for q in ALL_QUESTIONS[key]:
			if q == current_q:
				return str(key)
	return ""
