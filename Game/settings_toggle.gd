@tool
extends PanelContainer


@export var display_text: String
@export var is_toggle_on: bool = false
@export var setting_key: String

var TOGGLE_ON_ART = load("res://Art/icon_toggle_on.png")
var TOGGLE_OFF_ART = load("res://Art/icon_toggle_off.png")
@onready var lbl_text = $h_cont/lbl_text
@onready var toggle_texture = $h_cont/t_toggle

signal toggle_pressed(new_toggle_state: bool)


func _ready() -> void:
	lbl_text.text = display_text
	update_texture()


func _process(_delta: float) -> void:
	# Preview string in editor
	if Engine.is_editor_hint():
		_ready()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_pressed():
		is_toggle_on = not is_toggle_on
		update_texture()
		toggle_pressed.emit(is_toggle_on)


func update_texture() -> void:
	if is_toggle_on:
		toggle_texture.texture = TOGGLE_ON_ART
	else:
		toggle_texture.texture = TOGGLE_OFF_ART
