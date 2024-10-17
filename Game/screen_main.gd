extends CanvasLayer

@export var mode_card_path: NodePath
@export var mode_add_q_path: NodePath
@export var mode_menu: NodePath
var add_question_layer: Node = null
var menu_layer: Node = null


func _ready():
	# Connect signals
	var mode_card_node = get_node(mode_card_path)
	var mode_add_q_node = get_node(mode_add_q_path)
	var mode_menu_node = get_node(mode_menu)
	add_question_layer = mode_add_q_node.get_parent()
	menu_layer = mode_menu_node.get_parent()
	mode_menu_node.connect("show_add_question", _on_show_add_question)
	mode_add_q_node.connect("close_add_q_UI", _on_close_add_q_UI)
	mode_card_node.connect("show_menu", _on_show_menu)


func _on_show_add_question():
	add_question_layer.visible = true
	menu_layer.visible = false


func _on_close_add_q_UI():
	add_question_layer.visible = false


func _on_show_menu():
	menu_layer.visible = true
