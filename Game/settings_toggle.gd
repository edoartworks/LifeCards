@tool
extends PanelContainer


@export var display_text: String
@export var setting_key: String
@export var setting_value: bool = false

var TOGGLE_ON_ART = load("res://Art/icon_toggle_on.png")
var TOGGLE_OFF_ART = load("res://Art/icon_toggle_off.png")
@onready var lbl_text = $h_cont/lbl_text
@onready var toggle_texture = $h_cont/t_toggle


func _ready() -> void:
	lbl_text.text = display_text
	add_to_group("settings")
	update_value_from_user_file.call_deferred()
	update_texture.call_deferred()


func _process(_delta: float) -> void:
	# Preview in editor
	if Engine.is_editor_hint():
		lbl_text.text = display_text
		add_to_group("settings")
		update_texture()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_pressed():
		setting_value = not setting_value
		update_texture()
		update_config()


func update_texture() -> void:
	if setting_value:
		toggle_texture.texture = TOGGLE_ON_ART
	else:
		toggle_texture.texture = TOGGLE_OFF_ART


func update_config(source_file = false) -> void:
	Config.set_config("settings", setting_key, setting_value, source_file)


func update_value_from_user_file() -> void:
	setting_value = Config.get_config("settings", setting_key)
