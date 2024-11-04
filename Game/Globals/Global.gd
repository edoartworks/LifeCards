extends Node

var QUESTIONS_FILE_PATH = "res://Data/DEBUG_questions.txt"
#var QUESTIONS_FILE_PATH = "res://Data/questions.txt"
var QUESTIONS_USER_FILE_PATH = "user://questions.txt"

var QUESTIONS: Array[String] = []
var CURRENT_QUESTION_IDX = 0

# DEBUG
var RESET_USER_QUESTIONS = true
var DEBUG_LOG = ""

func _ready() -> void:
	copy_questions_to_user_file()
	load_questions()
	# DEBUG
	if OS.get_name() == "Windows":
		set_half_resolution()


func read_text_file(file_path) -> Array[String]:
	var lines: Array[String] = []
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if not line.begins_with("#") and not line.is_empty():
				lines.append(line)
		file.close()
	else:
		debug(str("Failed to open file at path: ", file_path))
	return lines


func load_questions() -> void:
	QUESTIONS = read_text_file(QUESTIONS_USER_FILE_PATH)
	# Shuffle questions
	if QUESTIONS.size() > 0:
		pass#QUESTIONS.shuffle()
		##debug(QUESTIONS)
	else:
		debug("No questions loaded.")


func copy_questions_to_user_file() -> void:
	if not FileAccess.file_exists(QUESTIONS_USER_FILE_PATH) or RESET_USER_QUESTIONS:
		var file = FileAccess.open(QUESTIONS_FILE_PATH, FileAccess.READ)
		if not file:
			debug(str("Failed to open res file: ", QUESTIONS_FILE_PATH))
			return
		
		var content = file.get_as_text()
		file.close()
		file = FileAccess.open(QUESTIONS_USER_FILE_PATH, FileAccess.WRITE)
		if not file:
			debug(str("Failed to open user file: ", QUESTIONS_USER_FILE_PATH))
			return
		
		file.store_string(content)
		file.close()
	else:
		debug("User questions found. Skip res file copy")
		return


### DEBUG
func set_half_resolution() -> void:
	var current_size = DisplayServer.window_get_size()
	var new_size = current_size / 2
	DisplayServer.window_set_size(new_size)
	# Center window
	var screen_size = DisplayServer.screen_get_size()
	var new_position = (screen_size - new_size) / 2
	DisplayServer.window_set_position(new_position)


func debug(text):
	DEBUG_LOG += str(text) + "\n"
	print(text)
