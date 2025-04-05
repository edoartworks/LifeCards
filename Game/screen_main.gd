extends CanvasLayer

@export var screen_add_q_path: NodePath
var SCREEN_ADD_Q: Node = null
@export var screen_card_path: NodePath
var SCREEN_CARD: Node = null
@export var screen_help_path: NodePath
var SCREEN_HELP: Node = null
@export var screen_settings_path: NodePath
var SCREEN_SETTINGS: Node = null
@export var screen_filters_path: NodePath
var SCREEN_FILTERS: Node = null


func _ready():
	# Connect signals
	SCREEN_ADD_Q = get_node(screen_add_q_path)
	SCREEN_CARD = get_node(screen_card_path)
	SCREEN_HELP = get_node(screen_help_path)
	SCREEN_SETTINGS = get_node(screen_settings_path)
	SCREEN_FILTERS = get_node(screen_filters_path)
	
	SignalBus.main_menu_play_pressed.connect(show_card_screen)
	SignalBus.card_screen_exit_pressed.connect(hide_card_screen)
	SignalBus.main_menu_help_pressed.connect(show_help_screen)
	SignalBus.help_screen_exit_pressed.connect(hide_help_screen)
	SignalBus.main_menu_settings_pressed.connect(show_settings_screen)
	SignalBus.settings_screen_exit_pressed.connect(hide_settings_screen)
	SignalBus.main_menu_filter_pressed.connect(show_filters_screen)
	SignalBus.filters_screen_exit_pressed.connect(hide_filters_screen)
	
	SignalBus.android_back_request.connect(_on_android_back_request)
	
	SignalBus.show_add_question_screen.connect(show_add_question_screen)
	SignalBus.hide_add_question_screen.connect(hide_add_question_screen)
	
	SCREEN_ADD_Q.process_mode = Node.PROCESS_MODE_DISABLED
	SCREEN_CARD.process_mode = Node.PROCESS_MODE_DISABLED


func show_add_question_screen():
	# disable low_processor_mode to allow fancy animation
	ProjectSettings.set_setting("application/run/low_processor_mode", false)
	SCREEN_ADD_Q.process_mode = Node.PROCESS_MODE_INHERIT
	SCREEN_ADD_Q.visible = true


func hide_add_question_screen():
	ProjectSettings.set_setting("application/run/low_processor_mode", true)
	SCREEN_ADD_Q.process_mode = Node.PROCESS_MODE_DISABLED
	SCREEN_ADD_Q.visible = false


func show_card_screen():
	SCREEN_CARD.visible = true
	SCREEN_CARD.process_mode = Node.PROCESS_MODE_INHERIT


func hide_card_screen():
	SCREEN_CARD.visible = false
	SCREEN_CARD.process_mode = Node.PROCESS_MODE_DISABLED
	SCREEN_CARD.MENU_OVERLAY.visible = false


func show_help_screen():
	SCREEN_HELP.visible = true


func hide_help_screen():
	SCREEN_HELP.visible = false


func show_settings_screen():
	SCREEN_SETTINGS.visible = true


func hide_settings_screen():
	SCREEN_SETTINGS.visible = false


func show_filters_screen():
	SCREEN_FILTERS.visible = true


func hide_filters_screen():
	SCREEN_FILTERS.visible = false


func _on_android_back_request():
	Debug.log("android back request")
	var layers = get_tree().current_scene.get_children()
	var highest_visible_layer_node = null
	var highest_visible_layer = -1

	for node in layers:
		if node.visible and node.layer > highest_visible_layer:
			highest_visible_layer = node.layer
			highest_visible_layer_node = node

	if highest_visible_layer_node and highest_visible_layer > 1:
		match highest_visible_layer_node:
			SCREEN_ADD_Q:
				# Little bug here, not sure what's going on but seems like
				# back_request is called when typing. So this kinda works
				if not Main.IS_KEYBOARD_OPEN:
					hide_add_question_screen()
			SCREEN_CARD:
				hide_card_screen()
			SCREEN_HELP:
				hide_help_screen()
			SCREEN_SETTINGS:
				hide_settings_screen()
			SCREEN_FILTERS:
				hide_filters_screen()


# DEBUG
func _input(event):
	if Main.DEBUG_MODE:
		if event.is_action_pressed("back"):
			_on_android_back_request()
