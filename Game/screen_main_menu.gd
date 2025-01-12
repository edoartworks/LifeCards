extends CanvasLayer


func _on_btn_play_pressed() -> void:
	SignalBus.main_menu_play_pressed.emit()
	#TODO: shuffle if settings is enabled


func _on_btn_settings_pressed() -> void:
	SignalBus.main_menu_settings_pressed.emit()


func _on_btn_help_pressed() -> void:
	SignalBus.main_menu_help_pressed.emit()
