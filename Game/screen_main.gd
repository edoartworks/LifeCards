extends CanvasLayer

@export var mode_card_path: NodePath
@export var mode_add_q_path: NodePath
@export var mode_menu: NodePath
var add_question_layer: Node = null
var menu_layer: Node = null
var mode_add_q_node: Node = null



func _ready():
	# Connect signals
	var mode_card_node = get_node(mode_card_path)
	mode_add_q_node = get_node(mode_add_q_path)
	var mode_menu_node = get_node(mode_menu)
	add_question_layer = mode_add_q_node.get_parent()
	menu_layer = mode_menu_node.get_parent()
	mode_menu_node.connect("show_add_question", _on_show_add_question)
	mode_add_q_node.connect("close_add_q_UI", _on_close_add_q_UI)
	mode_card_node.connect("show_menu", _on_show_menu)
	
	mode_add_q_node.set_process(false)

func _on_show_add_question():
	ProjectSettings.set_setting("application/run/low_processor_mode", false)
	mode_add_q_node.set_process(true)
	add_question_layer.visible = true
	menu_layer.visible = false


func _on_close_add_q_UI():
	ProjectSettings.set_setting("application/run/low_processor_mode", true)
	mode_add_q_node.set_process(false)
	add_question_layer.visible = false


func _on_show_menu():
	menu_layer.visible = true
