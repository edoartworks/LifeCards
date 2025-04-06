extends Node

func parse_yaml_file(file_path: String) -> Dictionary:
	var all_questions: Dictionary = {}
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		Debug.log("Failed to open file: " + file_path)
		return {}
	
	var line: String
	var current_key: String = ""
	var question_list: Array = []
	
	while not file.eof_reached():
		line = file.get_line().strip_edges()
		if line.ends_with(":"):
			if current_key != "":
				all_questions[current_key] = question_list
			current_key = line.trim_suffix(":")
			question_list = []
		elif line.begins_with("-"):
			var question = line.lstrip("-").strip_edges()
			question_list.append(question)
	
	if current_key != "":
		all_questions[current_key] = question_list
	
	file.close()
	return all_questions


func read_text_file(file_path) -> Array[String]:
	var lines: Array[String] = []
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if not line.begins_with("#") and not line.is_empty():
				lines.append(line)
		file.close()
	else:
		Debug.log(str("Failed to open file: ", file_path))
	return lines


func copy_file(source_path: String, destination_path: String, override_existing: bool = true) -> void:
	var source_file = FileAccess.open(source_path, FileAccess.READ)
	if source_file:
		if FileAccess.file_exists(destination_path) and not override_existing:
			Debug.log(str("Destination file already exists and override is not allowed: " + destination_path))
			source_file.close()
			return
		
		var destination_file = FileAccess.open(destination_path, FileAccess.WRITE)
		if destination_file:
			destination_file.store_buffer(source_file.get_buffer(source_file.get_length()))
			destination_file.close()
			Debug.log(str("File [" + source_path + "] copied to: [" + destination_path + "]"))
		else:
			Debug.log(str("Failed to open file: " + destination_path))
		source_file.close()
	else:
		Debug.log(str("Failed to open source file: " + source_path))
