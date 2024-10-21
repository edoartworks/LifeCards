extends CanvasLayer


@export var card_path :NodePath
@export var menu_path :NodePath
@export var debug_log_lbl_path :NodePath
var CARD :Node = null
var MENU :Node = null
var DEBUG_LOG :Node = null
var DEBUG_SCROLL :Node = null


func _ready() -> void:
	CARD = get_node(card_path)
	MENU = get_node(menu_path)
	MENU.connect("close_menu", _on_close_menu)
	DEBUG_LOG = get_node(debug_log_lbl_path)
	DEBUG_SCROLL = DEBUG_LOG.get_parent()
	draw_card()
	# TODO: card should be empty first


func _process(_delta: float) -> void:
	# Update debug log
	if DEBUG_LOG.text == Global.DEBUG_LOG:
		return
	DEBUG_LOG.text = Global.DEBUG_LOG
	call_deferred("_scroll_to_bottom")

func draw_card() -> void:
	if Global.CURRENT_QUESTION_IDX < Global.QUESTIONS.size():
		CARD.set_card_text(Global.QUESTIONS[Global.CURRENT_QUESTION_IDX])
		Global.CURRENT_QUESTION_IDX += 1
	else:
		Global.debug("No more questions")


func _on_btn_fwd_pressed() -> void:
	draw_card()


func _scroll_to_bottom():
	DEBUG_SCROLL.scroll_vertical = DEBUG_SCROLL.get_v_scroll_bar().max_value


func _on_btn_menu_pressed() -> void:
	MENU.visible = true


func _on_close_menu() -> void:
	MENU.visible = false
