extends Node

var DEBUG_MODE = false

var QUESTIONS_SRC_PATH = "res://Data/questions.yml"
var QUESTIONS_USER_PATH = "user://questions.yml"
var CONFIG_SRC_PATH = "res://Data/config.cfg"
var CONFIG_USER_PATH = "user://config.cfg"

var QUESTIONS: Array[String] = []
var ALL_QUESTIONS = {}
var CURRENT_QUESTION_IDX = 0
var IS_DECK_SHUFFLED = false

var IS_KEYBOARD_OPEN = false

var DEBUG_QS_FILE_PATH = "res://Data/DEBUG_questions.yml"
var DEBUG_RESET_USR_QS = false
var DEBUG_RESET_CONFIG = false
var DEBUG_LOG = ""


func _ready() -> void:
	if DEBUG_MODE:
		debug("DEBUG MODE: ON")
		QUESTIONS_SRC_PATH = DEBUG_QS_FILE_PATH
		DEBUG_RESET_USR_QS = true
		DEBUG_RESET_CONFIG = true
		if OS.get_name() == "Windows":
			_set_half_resolution()
	
	# On first launch, build config and load questions
	var IS_APP_FIRST_LAUNCH
	if get_config("app", "is_first_launch") == null:
		IS_APP_FIRST_LAUNCH = true
	else:
		IS_APP_FIRST_LAUNCH = false
	
	if IS_APP_FIRST_LAUNCH or DEBUG_RESET_CONFIG:
		_build_config.call_deferred()
		copy_file.call_deferred(CONFIG_SRC_PATH, CONFIG_USER_PATH)
	
	if IS_APP_FIRST_LAUNCH or DEBUG_RESET_USR_QS:
		copy_file.call_deferred(QUESTIONS_SRC_PATH, QUESTIONS_USER_PATH)
		_load_questions.call_deferred()
	else:
		_load_questions()
	
	
	if IS_APP_FIRST_LAUNCH:
		set_config.call_deferred("app", "is_first_launch", false)
	
	SignalBus.shuffle_deck.connect(_shuffle_deck)
	SignalBus.reset_deck_default.connect(_reset_deck_to_default)
	SignalBus.filters_screen_exit_pressed.connect(_reset_deck_to_user)
	SignalBus.current_question_deleted.connect(_load_questions)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			SignalBus.android_back_request.emit()


func _load_questions() -> void:
	# Load questions from user file, then filter them by category settings
	ALL_QUESTIONS = _parse_yaml_file(QUESTIONS_USER_PATH)
	var filtered_questions: Array[String] = []
	for category in ALL_QUESTIONS.keys():
		var filter_value = get_config("filters", category)
		if filter_value:
			filtered_questions.append_array(ALL_QUESTIONS[category])
	QUESTIONS = filtered_questions
	debug("Questions loaded")


func _reset_deck_to_default() -> void:
	# Replace user file with default source file
	copy_file(QUESTIONS_SRC_PATH, QUESTIONS_USER_PATH)
	_reset_deck_to_user()
	debug("Questions reset to default")


func _reset_deck_to_user():
	# Reload deck then set card to first
	_load_questions()
	set_card_idx_to_first()
	IS_DECK_SHUFFLED = false
	debug("Questions reset to user")


func _shuffle_deck() -> void:
	QUESTIONS.shuffle()
	set_card_idx_to_first()
	IS_DECK_SHUFFLED = true


func _parse_yaml_file(file_path: String) -> Dictionary:
	var all_questions: Dictionary = {}
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		Global.debug("Unable to open file: " + file_path)
		return {}
	
	var line: String
	var current_key: String = ""
	var question_list: Array = []
	
	while not file.eof_reached():
		line = file.get_line().strip_edges()
		if line.ends_with(":"):
			if current_key != "":
				all_questions[current_key] = question_list
			current_key = line.trim_suffix(":")
			question_list = []
		elif line.begins_with("-"):
			var question = line.lstrip("-").strip_edges()
			question_list.append(question)
	
	if current_key != "":
		all_questions[current_key] = question_list
	
	file.close()
	return all_questions


func _read_text_file(file_path) -> Array[String]:
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


func _build_config() -> void:
	# Build config file by reading values from the various screens
	# and writing it to the res file.
	
	# Clear source config first
	var config = ConfigFile.new()
	var err = config.load(CONFIG_SRC_PATH)
	if err != OK:
		debug(str("Error loading config file." + str(err)))
		return
	config.clear()
	var save_err = config.save(CONFIG_SRC_PATH)
	if save_err != OK:
		debug(str("Error saving config file." + str(save_err)))
	
	var scene = get_node("/root/screen_main/screen_settings")
	if scene:
		var settings_nodes = scene.get_tree().get_nodes_in_group("settings")
		if settings_nodes:
			for node in settings_nodes:
				node.update_config(true)
		else:
			debug("No settings found in settings screen")
	else:
		debug("Failed to get settings screen")
	# same again for filters
	scene = get_node("/root/screen_main/screen_filters")
	if scene:
		var settings_nodes = scene.get_tree().get_nodes_in_group("filters")
		if settings_nodes:
			for node in settings_nodes:
				node.update_config(true)
		else:
			debug("No filters found in filters screen")
	else:
		debug("Failed to get filters screen")


func set_card_idx_to_first():
	CURRENT_QUESTION_IDX = 0


func add_user_question(category: String, new_question: String):
	var file = FileAccess.open(QUESTIONS_USER_PATH, FileAccess.WRITE)
	if not file:
		debug("Failed to open user file: " + QUESTIONS_USER_PATH)
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

	# Handle updating the active deck (QUESTIONS)
	if IS_DECK_SHUFFLED:
		# Only insert the question into the active deck if its category is enabled.
		if get_config("filters", category):
			QUESTIONS.insert(CURRENT_QUESTION_IDX, new_question)
	else:
		_load_questions()

	SignalBus.new_question_added.emit()
	debug("Added question: [" + category + "] " + new_question)
	# TODO: bug: if adding a Q to a category that's currently disabled
	# The progress bar will go up by 1, but it shouldn't


func get_current_question_category() -> String:
	var current_q = QUESTIONS[CURRENT_QUESTION_IDX]
	for key in ALL_QUESTIONS.keys():
		for q in ALL_QUESTIONS[key]:
			if q == current_q:
				return str(key)
	return ""


func get_config(section: String, key: String) -> Variant:
	var config = ConfigFile.new()
	var err = config.load(CONFIG_USER_PATH)
	if err != OK:
		debug(str("Error loading config file." + str(err)))
		return null
	
	if not config.has_section_key(section, key):
		debug(str("Config section + key not found: [" + str(section) + "] " + str(key)))
	var value = config.get_value(section, key, null)
	#debug(str("Getting config: [" + str(section) + "] " + str(key) + "=" + str(value)))
	return value


func set_config(section: String, key: String, value: Variant, source_file: bool = false) -> void:
	var config = ConfigFile.new()
	var path
	if source_file:
		path = CONFIG_SRC_PATH
	else:
		path = CONFIG_USER_PATH
	var err = config.load(path)
	if err != OK:
		debug(str("Error loading config file." + str(err)))
		return
	
	config.set_value(section, key, value)
	if source_file:
		debug(str("set source config: [" + str(section) + "] " + str(key) + "=" + str(value)))
	else:
		debug(str("set user config: [" + str(section) + "] " + str(key) + "=" + str(value)))
	var save_err = config.save(path)
	if save_err != OK:
		debug("Error saving config file.")


func copy_file(source_path: String, destination_path: String, override_existing: bool = true) -> void:
	var source_file = FileAccess.open(source_path, FileAccess.READ)
	if source_file:
		if FileAccess.file_exists(destination_path) and not override_existing:
			debug(str("Destination file already exists and override is not allowed: " + destination_path))
			source_file.close()
			return
		
		var destination_file = FileAccess.open(destination_path, FileAccess.WRITE)
		if destination_file:
			destination_file.store_buffer(source_file.get_buffer(source_file.get_length()))
			destination_file.close()
			debug(str("File copied to user folder: " + destination_path))
		else:
			debug(str("Failed to open user file: " + destination_path))
		source_file.close()
	else:
		debug(str("Failed to open source file: " + source_path))


### DEBUG
func _set_half_resolution() -> void:
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
