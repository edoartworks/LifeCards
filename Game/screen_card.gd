extends CanvasLayer


@export var card_path :NodePath
@export var menu_path :NodePath
@export var prog_bar_path :NodePath
@export var debug_log_lbl_path :NodePath
var CARD :Node = null
var MENU :Node = null
var MENU_OVERLAY :Node = null
var PROG_BAR :ProgressBar = null
var DEBUG_LOG :Node = null
var DEBUG_SCROLL :Node = null


func _ready() -> void:
	CARD = get_node(card_path)
	MENU = get_node(menu_path)
	MENU_OVERLAY = MENU.get_parent()
	PROG_BAR = get_node(prog_bar_path)
	DEBUG_LOG = get_node(debug_log_lbl_path)
	DEBUG_SCROLL = DEBUG_LOG.get_parent()
	
	# Init UI
	CARD.set_card_text(Global.QUESTIONS[0])
	PROG_BAR.max_value = Global.QUESTIONS.size()
	PROG_BAR.value = 1
	


func _process(_delta: float) -> void:
	# Update debug log
	if DEBUG_LOG.text == Global.DEBUG_LOG:
		return
	DEBUG_LOG.text = Global.DEBUG_LOG
	call_deferred("_scroll_to_bottom")


func change_card_fwd() -> void:
	if Global.CURRENT_QUESTION_IDX < Global.QUESTIONS.size() -1:
		Global.CURRENT_QUESTION_IDX += 1
		CARD.set_card_text(Global.QUESTIONS[Global.CURRENT_QUESTION_IDX])
		PROG_BAR.value += 1
	else:
		Global.debug("No more questions")


func change_card_back() -> void:
	if Global.CURRENT_QUESTION_IDX > 0:
		Global.CURRENT_QUESTION_IDX -= 1
		CARD.set_card_text(Global.QUESTIONS[Global.CURRENT_QUESTION_IDX])
		PROG_BAR.value -= 1
	else:
		Global.debug("Reached first questions")


func _on_btn_fwd_pressed() -> void:
	change_card_fwd()


func _on_btn_back_pressed() -> void:
	change_card_back()


func _scroll_to_bottom():
	DEBUG_SCROLL.scroll_vertical = DEBUG_SCROLL.get_v_scroll_bar().max_value


func _on_btn_menu_pressed() -> void:
	MENU_OVERLAY.visible = true


func _on_obscure_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_pressed():
		MENU_OVERLAY.visible = false
