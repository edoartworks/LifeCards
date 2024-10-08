extends CanvasLayer

@export var mode_card_path: NodePath
@export var canvlayer_add_q_path: NodePath
@export var mode_add_q_path: NodePath
var add_question_layer: Node = null


func _ready():
	# Connect signals
	var mode_card_node = get_node(mode_card_path)
	var mode_add_q_node = get_node(mode_add_q_path)
	add_question_layer = get_node(canvlayer_add_q_path)
	mode_card_node.connect("show_add_question", _on_show_add_question)
	mode_add_q_node.connect("close_add_q_UI", _on_close_add_q_UI)


func _on_show_add_question():
	add_question_layer.visible = true


func _on_close_add_q_UI():
	add_question_layer.visible = false
