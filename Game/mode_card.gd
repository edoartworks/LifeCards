extends Panel


signal show_add_question

@onready var CARD = $VBoxContainer/card
@onready var DEBUG_LOG = $VBoxContainer/cont_debug_log/lbl_debug_log
@onready var DEBUG_SCROLL = $VBoxContainer/cont_debug_log


func _ready() -> void:
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


func _on_btn_draw_pressed() -> void:
	draw_card()


func _on_btn_add_q_pressed() -> void:
	show_add_question.emit()


func _scroll_to_bottom():
	DEBUG_SCROLL.scroll_vertical = DEBUG_SCROLL.get_v_scroll_bar().max_value
