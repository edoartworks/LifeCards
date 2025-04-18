extends CanvasLayer

@onready var toggle_buttons: Array[Node] = [
	$BG/MarginContainer/cont_main/filter_toggle_1,
	$BG/MarginContainer/cont_main/filter_toggle_2,
	$BG/MarginContainer/cont_main/filter_toggle_3,
	$BG/MarginContainer/cont_main/filter_toggle_4
]
@onready var btn_exit = $BG/MarginContainer/cont_main/HBoxContainer/btn_exit


func _ready():
	for button in toggle_buttons:
		button.connect("toggled", _on_button_toggled)
	_validate_toggles.call_deferred()

func _on_button_toggled():
	_validate_toggles()

func _validate_toggles():
	print("validating toggles")
	var toggled_count = 0
	for button in toggle_buttons:
		if button.filter_enabled:
			toggled_count += 1
	# Disable the exit button if no toggle buttons are enabled
	btn_exit.disabled = (toggled_count == 0)
	if toggled_count == 0:
		Debug.log("ALL FILTERS DISABLED!! impossible")


func _on_btn_exit_pressed() -> void:
	SignalBus.filters_screen_exit_pressed.emit()
