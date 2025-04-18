extends CanvasLayer

@export var file_dialog_path :NodePath
var FILE_DIALOG :Node = null


func _ready() -> void:
	FILE_DIALOG = get_node(file_dialog_path)


func _on_btn_exit_pressed() -> void:
	SignalBus.settings_screen_exit_pressed.emit()


func _on_btn_add_q_pressed() -> void:
	SignalBus.show_add_question_screen.emit()


func _on_btn_reset_deck_pressed() -> void:
	Popups.show_confirm(self, _on_btn_reset_deck_confirmed)


func _on_btn_reset_deck_confirmed():
	SignalBus.reset_deck_default.emit()


func _on_btn_del_all_q_pressed() -> void:
	Popups.show_confirm(self, _on_btn_del_all_q_confirmed)


func _on_btn_del_all_q_confirmed():
	Deck.delete_all_questions()


func _on_add_q_from_file_pressed() -> void:
	FILE_DIALOG.visible = true
	# TODO: add warning popup if import failed


func _on_file_dialog_file_selected(path: String) -> void:
	Deck.import_questions(path)
