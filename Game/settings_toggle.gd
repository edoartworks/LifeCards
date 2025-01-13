@tool
extends PanelContainer


@export var display_text: String
@export var setting_key: String
@export var setting_value: bool = false

var TOGGLE_ON_ART = load("res://Art/icon_toggle_on.png")
var TOGGLE_OFF_ART = load("res://Art/icon_toggle_off.png")
@onready var lbl_text = $h_cont/lbl_text
@onready var toggle_texture = $h_cont/t_toggle

signal toggle_pressed(setting_key: String, new_toggle_state: bool)


func _ready() -> void:
	lbl_text.text = display_text
	update_texture()
	add_to_group("settings")


func _process(_delta: float) -> void:
	# Preview string in editor
	if Engine.is_editor_hint():
		_ready()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_pressed():
		setting_value = not setting_value
		update_texture()
		toggle_pressed.emit(setting_value)


func update_texture() -> void:
	if setting_value:
		toggle_texture.texture = TOGGLE_ON_ART
	else:
		toggle_texture.texture = TOGGLE_OFF_ART
