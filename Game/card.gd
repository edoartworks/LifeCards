extends Control


@onready var CARD_TEXT = $cont_text/lbl_card_text


func set_card_text(text: String) -> void:
	CARD_TEXT.text = text
