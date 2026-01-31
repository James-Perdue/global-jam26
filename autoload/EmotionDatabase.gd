extends Node

var emotions: Dictionary = {} # Dictionary[Enums.Emotion, Array[EmotionMessage]]

func _ready() -> void:
	_load_emotions()

func _load_emotions() -> void:
	var file_path = "res://data/emotion_messages.json"
	if not FileAccess.file_exists(file_path):
		push_error("EmotionDatabase: File not found at " + file_path)
		return
		
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		push_error("EmotionDatabase: JSON parse error: " + json.get_error_message())
		return
		
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("EmotionDatabase: JSON data is not a dictionary")
		return
		
	for emotion_key in data.keys():
		if emotion_key in Enums.Emotion:
			var enum_value = Enums.Emotion[emotion_key]
			var messages_data = data[emotion_key]
			var messages_list: Array[EmotionMessage] = []
			
			for msg_data in messages_data:
				var emotion_msg = EmotionMessage.new()
				emotion_msg.audio_key = msg_data.get("audio_key", "")
				emotion_msg.message = msg_data.get("message", "")
				emotion_msg.emotion = enum_value
				messages_list.append(emotion_msg)
				
			emotions[enum_value] = messages_list
		else:
			push_warning("EmotionDatabase: Unknown emotion key in JSON: " + emotion_key)

func get_messages(emotion: Enums.Emotion) -> Array[EmotionMessage]:
	return emotions.get(emotion, [])
