extends CanvasLayer


func _on_btn_play_pressed() -> void:
	SignalBus.main_menu_play_pressed.emit()
	if Config.get_config("settings", "shuffle_on_play"):
		SignalBus.shuffle_deck.emit()


func _on_btn_settings_pressed() -> void:
	SignalBus.main_menu_settings_pressed.emit()


func _on_btn_help_pressed() -> void:
	SignalBus.main_menu_help_pressed.emit()


func _on_btn_filter_pressed() -> void:
	SignalBus.main_menu_filter_pressed.emit()
