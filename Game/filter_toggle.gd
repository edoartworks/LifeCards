@tool
extends PanelContainer


@export var display_text: String
@export var filter_key: String
@export var filter_enabled: bool = false

var TOGGLE_ON_ART = load("res://Art/icon_toggle_on.png")
var TOGGLE_OFF_ART = load("res://Art/icon_toggle_off.png")
@onready var lbl_text = $h_cont/lbl_text
@onready var toggle_texture = $h_cont/t_toggle

signal toggled


func _ready() -> void:
	lbl_text.text = display_text
	add_to_group("filters")
	call_deferred("update_value_from_user_file")
	call_deferred("update_texture")


func _process(_delta: float) -> void:
	# Preview in editor
	if Engine.is_editor_hint():
		lbl_text.text = display_text
		add_to_group("filters")
		update_texture()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_pressed():
		filter_enabled = not filter_enabled
		update_texture()
		update_config()
		toggled.emit()


func update_texture() -> void:
	if filter_enabled:
		toggle_texture.texture = TOGGLE_ON_ART
	else:
		toggle_texture.texture = TOGGLE_OFF_ART


func update_config(source_file = false) -> void:
	Global.set_config("filters", filter_key, filter_enabled, source_file)


func update_value_from_user_file() -> void:
	filter_enabled = Global.get_config("filters", filter_key)
	
