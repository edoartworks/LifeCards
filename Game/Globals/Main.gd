extends Node

var IS_KEYBOARD_OPEN = false # Read/write from other screens

var DEBUG_MODE = true
var DEBUG_QS_FILE_PATH = "res://Data/DEBUG_questions.txt"


func _ready() -> void:
	var CONFIG_SRC_PATH = Config.CONFIG_SRC_PATH
	var CONFIG_USER_PATH = Config.CONFIG_USER_PATH
	var QUESTIONS_SRC_PATH = Deck.QUESTIONS_SRC_PATH
	var QUESTIONS_USER_PATH = Deck.QUESTIONS_USER_PATH
	var DEBUG_RESET_USR_QS = false
	var DEBUG_RESET_CONFIG = false
	
	#Debug.log("Requesting permissions...")
	#Debug.log(OS.request_permissions())
	
	if DEBUG_MODE:
		Debug.log("DEBUG MODE: ON")
		QUESTIONS_SRC_PATH = DEBUG_QS_FILE_PATH
		DEBUG_RESET_USR_QS = true
		DEBUG_RESET_CONFIG = true
		if OS.get_name() == "Windows":
			Debug.set_win_half_res()
	
	# On first launch, build config and load questions
	var IS_APP_FIRST_LAUNCH
	if Config.get_config("app", "is_first_launch") == null:
		IS_APP_FIRST_LAUNCH = true
		Debug.log("Initialising app for first launch...")
	else:
		IS_APP_FIRST_LAUNCH = false
	
	# Dev
	if OS.get_name() == "Windows":
		Config.build_config.call_deferred()
	
	if IS_APP_FIRST_LAUNCH or DEBUG_RESET_CONFIG:
		File.copy_file.call_deferred(CONFIG_SRC_PATH, CONFIG_USER_PATH)
	
	if IS_APP_FIRST_LAUNCH or DEBUG_RESET_USR_QS:
		File.copy_file.call_deferred(QUESTIONS_SRC_PATH, QUESTIONS_USER_PATH)
		Deck.load_questions.call_deferred()
	else:
		Deck.load_questions()
	
	if IS_APP_FIRST_LAUNCH:
		Config.set_config.call_deferred("app", "is_first_launch", false)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			SignalBus.android_back_request.emit()
