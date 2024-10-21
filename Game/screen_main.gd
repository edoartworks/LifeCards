extends CanvasLayer

@export var screen_card_path: NodePath
@export var screen_add_q_path: NodePath
var SCREEN_ADD_Q: Node = null


func _ready():
	# Connect signals
	SCREEN_ADD_Q = get_node(screen_add_q_path)
	SignalBus.connect("close_add_question_screen", _on_close_add_question_screen)
	SignalBus.connect("open_add_question_screen", _on_open_add_question_screen)
	
	SCREEN_ADD_Q.set_process(false)

func _on_open_add_question_screen():
	ProjectSettings.set_setting("application/run/low_processor_mode", false)
	SCREEN_ADD_Q.set_process(true)
	SCREEN_ADD_Q.visible = true


func _on_close_add_question_screen():
	ProjectSettings.set_setting("application/run/low_processor_mode", true)
	SCREEN_ADD_Q.set_process(false)
	SCREEN_ADD_Q.visible = false
