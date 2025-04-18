extends CanvasLayer

@export var card_path :NodePath
@export var menu_overlay_path :NodePath
@export var prog_bar_path :NodePath
@export var categ_art_path :NodePath
@export var debug_log_lbl_path :NodePath
var CARD :Node = null
var MENU_OVERLAY :Node = null
var PROG_BAR :ProgressBar = null
var CATEG_ART :TextureRect = null
var DEBUG_LOG :Node = null
var DEBUG_SCROLL :Node = null

var CAT_1_ART = load("res://Art/art_category_1.png")
var CAT_2_ART = load("res://Art/art_category_2.png")
var CAT_3_ART = load("res://Art/art_category_3.png")
var CAT_4_ART = load("res://Art/art_category_4.png")

var prev_q_cat = "0"

func _ready() -> void:
	CARD = get_node(card_path)
	MENU_OVERLAY = get_node(menu_overlay_path)
	PROG_BAR = get_node(prog_bar_path)
	CATEG_ART = get_node(categ_art_path)
	
	SignalBus.card_swipe_left.connect(_on_btn_fwd_pressed)
	SignalBus.card_swipe_right.connect(_on_btn_back_pressed)
	
	SignalBus.show_add_question_screen.connect(_hide_menu_overlay)
	SignalBus.new_question_added.connect(_init_UI)
	SignalBus.questions_imported.connect(_init_UI)
	SignalBus.current_question_deleted.connect(_on_current_question_deleted)
	SignalBus.all_questions_deleted.connect(_set_empty_card)
	SignalBus.shuffle_deck.connect(_on_deck_shuffled)
	SignalBus.reset_deck_default.connect(_init_UI)
	SignalBus.filters_screen_exit_pressed.connect(_init_UI)
	SignalBus.cardmenu_goto_first.connect(_on_menu_goto_first_pressed)
	
	if Main.DEBUG_MODE:
		DEBUG_LOG = get_node(debug_log_lbl_path)
		DEBUG_SCROLL = DEBUG_LOG.get_parent()
		DEBUG_SCROLL.visible = true
	
	_init_UI.call_deferred() # deferred to wait for questions to be loaded


func _process(_delta: float) -> void:
	if Main.DEBUG_MODE:
		# Update debug log
		if DEBUG_LOG.text == Debug.DEBUG_LOG:
			return
		DEBUG_LOG.text = Debug.DEBUG_LOG
		call_deferred("_debug_scroll_to_bottom")


func _init_UI() -> void:
	_refresh_card_text()
	PROG_BAR.max_value = Deck.QUESTIONS.size()
	PROG_BAR.value = Deck.CURRENT_QUESTION_IDX + 1


func _change_card_fwd() -> bool:
	if Deck.CURRENT_QUESTION_IDX < Deck.QUESTIONS.size() -1:
		Deck.CURRENT_QUESTION_IDX += 1
		_refresh_card_text()
		return true
	else:
		Debug.log("Last card. Can't go forward.")
		return false


func _change_card_back() -> bool:
	if Deck.CURRENT_QUESTION_IDX > 0:
		Deck.CURRENT_QUESTION_IDX -= 1
		_refresh_card_text()
		return true
	else:
		Debug.log("First card. Can't go backwards.")
		return false


func _update_category_art() -> void:
	var current_q_categ = Deck.get_current_question_category()
	if prev_q_cat == "0":
		prev_q_cat = current_q_categ
	
	if current_q_categ == prev_q_cat:
		return
	
	match current_q_categ:
		"1": CATEG_ART.texture = CAT_1_ART
		"2": CATEG_ART.texture = CAT_2_ART
		"3": CATEG_ART.texture = CAT_3_ART
		"4": CATEG_ART.texture = CAT_4_ART
	prev_q_cat = current_q_categ


func _refresh_card_text() -> void:
	if not Deck.QUESTIONS.is_empty():
		CARD.set_card_text(Deck.QUESTIONS[Deck.CURRENT_QUESTION_IDX])
		_update_category_art()


func _on_btn_fwd_pressed() -> void:
	if _change_card_fwd():
		PROG_BAR.value += 1


func _on_btn_back_pressed() -> void:
	if _change_card_back():
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
	Deck.CURRENT_QUESTION_IDX -= 1
	if not _change_card_fwd():
		Deck.CURRENT_QUESTION_IDX += 1
		if not _change_card_back():
			_set_empty_card()
			Debug.log("No more questions left in the deck!")


func _set_empty_card() -> void:
	CARD.set_card_text("")
	CATEG_ART.texture = null
	PROG_BAR.max_value = 0
	PROG_BAR.value = 0


func _on_new_question_added() -> void:
	PROG_BAR.max_value += 1


func _hide_menu_overlay() -> void:
	MENU_OVERLAY.visible = false


func _set_card_to_first() -> void:
	Deck.set_card_idx_to_first()
	PROG_BAR.value = Deck.CURRENT_QUESTION_IDX + 1
	_refresh_card_text()


func _on_deck_shuffled() -> void:
	_set_card_to_first()
	_hide_menu_overlay()


func _on_btn_exit_pressed() -> void:
	SignalBus.card_screen_exit_pressed.emit()


func _on_menu_goto_first_pressed() -> void:
	if Deck.CURRENT_QUESTION_IDX > 0:
		_set_card_to_first()
	else:
		Debug.log("Already at first questions")
