extends CanvasLayer


var _callback_function: Callable


func show_screen(callback_function: Callable):
	_callback_function = callback_function
	self.visible = true 


func _on_btn_ok_pressed() -> void:
	if _callback_function:
		_callback_function.call()
	self.queue_free()


func _on_btn_cancel_pressed() -> void:
	self.queue_free()
