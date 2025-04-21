extends CanvasLayer


@export var screen_more_path :NodePath
var SCREEN_MORE: Node = null
@export var text_1_path :NodePath
var TEXT_1: Node = null
@export var text_2_path :NodePath
var TEXT_2: Node = null

var alt_text_shown = false


func _ready() -> void:
	SCREEN_MORE = get_node(screen_more_path)
	TEXT_1 = get_node(text_1_path)
	TEXT_2 = get_node(text_2_path)


func _on_btn_exit_pressed() -> void:
	TEXT_1.visible = true
	TEXT_2.visible = false
	alt_text_shown = false
	SignalBus.help_screen_exit_pressed.emit()


func _on_btn_more_pressed() -> void:
	if not alt_text_shown:
		TEXT_1.visible = false
		TEXT_2.visible = true
		alt_text_shown = true
	else:
		SCREEN_MORE.visible = true


func _on_btn_more_exit_pressed() -> void:
	TEXT_1.visible = true
	TEXT_2.visible = false
	alt_text_shown = false
	SCREEN_MORE.visible = false


func on_android_back_req() -> bool:
	# Called by screen_main on android back request.
	# Returns false if this screen shouldn't be hidden.
	if SCREEN_MORE.is_visible() == true:
		_on_btn_more_exit_pressed()
		return false
	elif alt_text_shown:
		TEXT_1.visible = true
		TEXT_2.visible = false
		alt_text_shown = false
		return false
	else:
		return true
