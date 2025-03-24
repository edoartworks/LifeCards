extends Control


@onready var CARD_TEXT = $cont_text/lbl_card_text

func _ready() -> void:
	SignalBus.font_size_less.connect(_font_size_less)
	SignalBus.font_size_more.connect(_font_size_more)
	
	var font_size_cfg = Global.get_config("settings", "font_size")
	if font_size_cfg:
		CARD_TEXT.label_settings.font_size = font_size_cfg
		Global.debug("Card font updated to match cfg")


func set_card_text(text: String) -> void:
	CARD_TEXT.text = text


func _font_size_less():
	CARD_TEXT.label_settings.font_size -= 6
	Global.set_config("settings", "font_size", CARD_TEXT.label_settings.font_size)


func _font_size_more():
	CARD_TEXT.label_settings.font_size += 6
	Global.set_config("settings", "font_size", CARD_TEXT.label_settings.font_size)
