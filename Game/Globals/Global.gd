extends Node

var DEBUG_MODE = true

var QUESTIONS_SRC_PATH = "res://Data/questions.txt"
var QUESTIONS_USER_PATH = "user://questions.txt"
var SETTINGS_SRC_PATH = "res://Data/settings.cfg"
var SETTINGS_USER_PATH = "user://settings.cfg"

var QUESTIONS: Array[String] = []
var CURRENT_QUESTION_IDX = 0

var DEBUG_QS_FILE_PATH = "res://Data/DEBUG_questions.txt"
var DEBUG_RESET_USR_QS = false
var DEBUG_RESET_SETTINGS = false
var DEBUG_LOG = ""


func _ready() -> void:
	if DEBUG_MODE:
		debug("DEBUG MODE: ON")
		QUESTIONS_SRC_PATH = DEBUG_QS_FILE_PATH
		DEBUG_RESET_USR_QS = true
		DEBUG_RESET_SETTINGS = true
		if OS.get_name() == "Windows":
			set_half_resolution()
	
	# Copy data once on app first launch
	if not FileAccess.file_exists(QUESTIONS_USER_PATH) or DEBUG_RESET_USR_QS:
		copy_file(QUESTIONS_SRC_PATH, QUESTIONS_USER_PATH)
	else:
		debug("User questions found. Skip res file copy")
	
	# Build settings file
	call_deferred("build_settings")
	if not FileAccess.file_exists(SETTINGS_USER_PATH) or DEBUG_RESET_SETTINGS:
		call_deferred("copy_file", SETTINGS_SRC_PATH, SETTINGS_USER_PATH)
	else:
		debug("User settings found. Skip res file copy")
		SignalBus.update_settings_UI.emit()
	
	load_questions()
	
	SignalBus.shuffle_deck.connect(_shuffle_deck)
	SignalBus.reset_deck_default.connect(_reset_questions_to_default)


func _shuffle_deck() -> void:
	QUESTIONS.shuffle()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			SignalBus.android_back_request.emit()


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


func build_settings() -> void:
	# Build settings file by reading values from the settings screen
	# and writing it to the res file.
	
	# Clear source settings first
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_SRC_PATH)
	if err != OK:
		debug("Error loading settings file.")
		return
	config.clear()
		
	var save_err = config.save(SETTINGS_SRC_PATH)
	if save_err != OK:
		debug("Error saving settings file.")
	
	var scene = get_node("/root/screen_main/screen_settings")
	if scene:
		var settings_nodes = scene.get_tree().get_nodes_in_group("settings")
		if settings_nodes:
			for node in settings_nodes:
				var key = node.get("setting_key")
				var value = node.get("setting_value")
				set_setting(key, value, true)
		else:
			debug("No settings found in settings screen")
	else:
		debug("Failed to get screen settings")


# Assuming we only have one "main" section in the cfg
func get_setting(key: String) -> Variant:
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_USER_PATH)
	if err != OK:
		debug("Error loading settings file.")
		return null
		
	return config.get_value("main", key, null)


func set_setting(key: String, value: Variant, source_file: bool = false) -> void:
	var config = ConfigFile.new()
	var path
	if source_file:
		path = SETTINGS_SRC_PATH
	else:
		path = SETTINGS_USER_PATH
	var err = config.load(path)
	if err != OK:
		debug("Error loading settings file.")
		return
	
	config.set_value("main", key, value)
	debug(str("set setting: " + str(key) + "=" + str(value)))
	var save_err = config.save(path)
	if save_err != OK:
		debug("Error saving settings file.")


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
			debug(str("File copied successfully to user folder: " + destination_path))
		else:
			debug(str("Failed to open user file: " + destination_path))
		source_file.close()
	else:
		debug(str("Failed to open source file: " + source_path))


func load_questions() -> void:
	QUESTIONS = _read_text_file(QUESTIONS_USER_PATH)
	if QUESTIONS.size() == 0:
		debug("No questions loaded.")


func _reset_questions_to_default() -> void:
	copy_file(QUESTIONS_SRC_PATH, QUESTIONS_USER_PATH)
	load_questions()
	CURRENT_QUESTION_IDX = 0


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
