extends Node

var DEBUG_MODE = false

var QUESTIONS_SRC_PATH = "res://Data/questions.yml"
var QUESTIONS_USER_PATH = "user://questions.yml"
var CONFIG_SRC_PATH = "res://Data/config.cfg"
var CONFIG_USER_PATH = "user://config.cfg"

var QUESTIONS: Array[String] = []
var ALL_QUESTIONS = {}
var CURRENT_QUESTION_IDX = 0

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
	SignalBus.reset_deck_default.connect(_reset_questions_to_default)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			SignalBus.android_back_request.emit()


func _load_questions() -> void:
	ALL_QUESTIONS = _parse_yaml_file(QUESTIONS_USER_PATH)
	var filtered_questions: Array[String] = []

	for category in ALL_QUESTIONS.keys():
		var filter_value = get_config("filters", category)
		if filter_value:
			filtered_questions.append_array(ALL_QUESTIONS[category])
	QUESTIONS = filtered_questions


func reload_questions(question_deleted = false) -> void:
	_load_questions()
	if not question_deleted:
		CURRENT_QUESTION_IDX = 0
		SignalBus.on_questions_reloaded.emit()
	debug("Questions reloaded")


func _reset_questions_to_default() -> void:
	copy_file(QUESTIONS_SRC_PATH, QUESTIONS_USER_PATH)
	_load_questions()
	CURRENT_QUESTION_IDX = 0
	debug("Questions reset to default")


func _shuffle_deck() -> void:
	QUESTIONS.shuffle()


func _parse_yaml_file(file_path: String) -> Dictionary:
	var all_questions: Dictionary = {}
	var file := FileAccess.open(file_path, FileAccess.ModeFlags.READ)
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
		debug(str("Error loading config file." + err))
		return
	config.clear()
	var save_err = config.save(CONFIG_SRC_PATH)
	if save_err != OK:
		debug(str("Error saving config file." + save_err))
	
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


func get_config(section: String, key: String) -> Variant:
	var config = ConfigFile.new()
	var err = config.load(CONFIG_USER_PATH)
	if err != OK:
		debug(str("Error loading config file." + err))
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
		debug(str("Error loading config file." + err))
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
