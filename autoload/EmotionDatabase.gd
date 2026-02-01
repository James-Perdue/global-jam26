extends Node

var emotions: Dictionary = {} # Dictionary[string, Array[EmotionMessage]]

var colors: Dictionary = {"HAPPY": "yellow", "SAD": "blue", "ANGRY": "red", "ANNOYED": "green", "FEAR": "purple"} #Dictionary[string emotion, string color]

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
		
	for message_data in data["Messages"]:
		var emotion_msg = EmotionMessage.new()
		emotion_msg.audio_key = message_data.get("audio_key", "")
		emotion_msg.message = message_data.get("message", "")
		
		var emotions_strings = message_data.get("emotions", [])
		var result_emotions: Array[Enums.Emotion] = []
		for e_str in emotions_strings:
			if e_str in Enums.Emotion:
				result_emotions.append(Enums.Emotion[e_str])
		
		emotion_msg.emotions = result_emotions
		emotions[emotion_msg.audio_key] = emotion_msg

func select_new_emotion_message() -> EmotionMessage:
	return emotions.values().pick_random()

func select_specific_emotion_message(audio_key: String) -> EmotionMessage:
	if audio_key in emotions:
		return emotions[audio_key]
	else:
		push_error("EmotionDatabase: Audio key not found: " + audio_key)
		return null
