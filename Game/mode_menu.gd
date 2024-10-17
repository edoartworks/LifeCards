extends Control

signal show_add_question


func _on_btn_add_q_pressed() -> void:
	show_add_question.emit()
