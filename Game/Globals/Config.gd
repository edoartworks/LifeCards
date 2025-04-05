extends Node

var CONFIG_SRC_PATH = "res://Data/config.cfg"
var CONFIG_USER_PATH = "user://config.cfg"


func build_config() -> void:
	# Build config file by reading values from the various screens
	# and writing it to the res file.
	
	# Clear source config first
	var config = ConfigFile.new()
	var err = config.load(CONFIG_SRC_PATH)
	if err != OK:
		Debug.log(str("Error loading config file." + str(err)))
		return
	config.clear()
	var save_err = config.save(CONFIG_SRC_PATH)
	if save_err != OK:
		Debug.log(str("Error saving config file." + str(save_err)))
	
	var scene = get_node("/root/screen_main/screen_settings")
	if scene:
		var settings_nodes = scene.get_tree().get_nodes_in_group("settings")
		if settings_nodes:
			for node in settings_nodes:
				node.update_config(true)
		else:
			Debug.log("No settings found in settings screen")
	else:
		Debug.log("Failed to get settings screen")
	# same again for filters
	scene = get_node("/root/screen_main/screen_filters")
	if scene:
		var settings_nodes = scene.get_tree().get_nodes_in_group("filters")
		if settings_nodes:
			for node in settings_nodes:
				node.update_config(true)
		else:
			Debug.log("No filters found in filters screen")
	else:
		Debug.log("Failed to get filters screen")


func get_config(section: String, key: String) -> Variant:
	var config = ConfigFile.new()
	var err = config.load(CONFIG_USER_PATH)
	if err != OK:
		Debug.log(str("Error loading config file." + str(err)))
		return null
	
	if not config.has_section_key(section, key):
		Debug.log(str("Config section + key not found: [" + str(section) + "] " + str(key)))
	var value = config.get_value(section, key, null)
	#Debug.log(str("Getting config: [" + str(section) + "] " + str(key) + "=" + str(value)))
	return value


func set_config(section: String, key: String, value: Variant, source_file: bool = false) -> void:
	var config = ConfigFile.new()
	var path
	if source_file:
		path = CONFIG_SRC_PATH
	else:
		path = CONFIG_USER_PATH
	var err = config.load(path)
	if err != OK:
		Debug.log(str("Error loading config file." + str(err)))
		return
	
	config.set_value(section, key, value)
	if source_file:
		Debug.log(str("set source config: [" + str(section) + "] " + str(key) + "=" + str(value)))
	else:
		Debug.log(str("set user config: [" + str(section) + "] " + str(key) + "=" + str(value)))
	var save_err = config.save(path)
	if save_err != OK:
		Debug.log("Error saving config file.")
