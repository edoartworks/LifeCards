extends CanvasLayer


@export var card_path :NodePath
@export var menu_overlay_path :NodePath
@export var prog_bar_path :NodePath
@export var debug_log_lbl_path :NodePath
var CARD :Node = null
var MENU_OVERLAY :Node = null
var PROG_BAR :ProgressBar = null
var DEBUG_LOG :Node = null
var DEBUG_SCROLL :Node = null


func _ready() -> void:
	CARD = get_node(card_path)
	MENU_OVERLAY = get_node(menu_overlay_path)
	PROG_BAR = get_node(prog_bar_path)
	
	SignalBus.card_swipe_left.connect(_on_btn_fwd_pressed)
	SignalBus.card_swipe_right.connect(_on_btn_back_pressed)
	
	SignalBus.show_add_question_screen.connect(_on_card_menu_add_question_pressed)
	SignalBus.new_question_added.connect(_on_new_question_added)
	SignalBus.current_question_deleted.connect(_on_current_question_deleted)
	SignalBus.shuffle_deck.connect(_on_deck_shuffled)
	SignalBus.reset_deck_default.connect(_on_deck_reset)
	SignalBus.on_questions_reloaded.connect(_on_deck_reset)
	
	if Global.DEBUG_MODE:
		DEBUG_LOG = get_node(debug_log_lbl_path)
		DEBUG_SCROLL = DEBUG_LOG.get_parent()
		DEBUG_SCROLL.visible = true
	
	init_UI.call_deferred() # deferred to wait for questions to be loaded


func _process(_delta: float) -> void:
	if Global.DEBUG_MODE:
		# Update debug log
		if DEBUG_LOG.text == Global.DEBUG_LOG:
			return
		DEBUG_LOG.text = Global.DEBUG_LOG
		call_deferred("_debug_scroll_to_bottom")


func init_UI() -> void:
	refresh_card_text()
	PROG_BAR.max_value = Global.QUESTIONS.size()
	PROG_BAR.value = 1


func change_card_fwd() -> bool:
	if Global.CURRENT_QUESTION_IDX < Global.QUESTIONS.size() -1:
		Global.CURRENT_QUESTION_IDX += 1
		refresh_card_text()
		return true
	else:
		Global.debug("No more questions")
		return false


func change_card_back() -> bool:
	if Global.CURRENT_QUESTION_IDX > 0:
		Global.CURRENT_QUESTION_IDX -= 1
		refresh_card_text()
		return true
	else:
		Global.debug("Reached first questions")
		return false


func refresh_card_text() -> void:
	CARD.set_card_text(Global.QUESTIONS[Global.CURRENT_QUESTION_IDX])


func set_card_to_first() -> void:
	Global.CURRENT_QUESTION_IDX = 0
	PROG_BAR.value = 1
	refresh_card_text()


func _on_btn_fwd_pressed() -> void:
	if change_card_fwd():
		PROG_BAR.value += 1


func _on_btn_back_pressed() -> void:
	if change_card_back():
		PROG_BAR.value -= 1


func _debug_scroll_to_bottom():
	DEBUG_SCROLL.set_deferred("scroll_vertical", DEBUG_SCROLL.get_v_scroll_bar().max_value)


func _on_btn_menu_pressed() -> void:
	MENU_OVERLAY.visible = true


func _on_obscure_gui_input(event: InputEvent) -> void:
	# Hide menu overlay when screen is touched outside the menu area
	if event is InputEventScreenTouch and event.is_pressed():
		MENU_OVERLAY.visible = false


func _on_current_question_deleted() -> void:
	PROG_BAR.max_value -= 1
	Global.CURRENT_QUESTION_IDX -= 1
	if not change_card_fwd():
		Global.CURRENT_QUESTION_IDX += 1
		if not change_card_back():
			CARD.set_card_text("")
			Global.debug("No more questions left in the deck!")


func _on_new_question_added() -> void:
	PROG_BAR.max_value += 1
	# known bug: minor visual. ignore, probably forever.
		# When adding a new Q when only one Q is left in the deck,
		# the prog bar kinda bugs out, but not in a disruptive way.
		# and should fix when user restart the app.


func _on_card_menu_add_question_pressed() -> void:
	MENU_OVERLAY.visible = false


func _on_deck_shuffled() -> void:
	set_card_to_first()


func _on_deck_reset() -> void:
	init_UI()


func _on_btn_exit_pressed() -> void:
	SignalBus.card_screen_exit_pressed.emit()


func _on_btn_back_to_first_pressed() -> void:
	if Global.CURRENT_QUESTION_IDX > 0:
		set_card_to_first()
	else:
		Global.debug("Already at first questions")
