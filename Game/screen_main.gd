extends CanvasLayer

@export var screen_add_q_path: NodePath
var SCREEN_ADD_Q: Node = null
@export var screen_card_path: NodePath
var SCREEN_CARD: Node = null
@export var screen_help_path: NodePath
var SCREEN_HELP: Node = null


func _ready():
	# Connect signals
	SCREEN_ADD_Q = get_node(screen_add_q_path)
	SCREEN_CARD = get_node(screen_card_path)
	SCREEN_HELP = get_node(screen_help_path)
	SignalBus.main_menu_play_pressed.connect(show_card_screen)
	SignalBus.card_screen_exit_pressed.connect(hide_card_screen)
	SignalBus.main_menu_help_pressed.connect(show_help_screen)
	SignalBus.help_screen_exit_pressed.connect(hide_help_screen)
	SignalBus.card_menu_add_question_pressed.connect(show_add_question_screen)
	SignalBus.hide_add_question_screen.connect(hide_add_question_screen)
	
	SCREEN_ADD_Q.set_process(false)

func show_add_question_screen():
	ProjectSettings.set_setting("application/run/low_processor_mode", false)
	SCREEN_ADD_Q.set_process(true)
	SCREEN_ADD_Q.visible = true


func hide_add_question_screen():
	ProjectSettings.set_setting("application/run/low_processor_mode", true)
	SCREEN_ADD_Q.set_process(false)
	SCREEN_ADD_Q.visible = false


func show_card_screen():
	SCREEN_CARD.visible = true


func hide_card_screen():
	SCREEN_CARD.visible = false


func show_help_screen():
	SCREEN_HELP.visible = true


func hide_help_screen():
	SCREEN_HELP.visible = false
