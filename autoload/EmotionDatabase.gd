extends Node

var emotions: Dictionary = {} # Dictionary[string,EmotionMessage]

var colors: Dictionary = {"HAPPY": "yellow", "SAD": "blue", "ANGRY": "red", "ANNOYED": "green", "FEAR": "purple"} #Dictionary[string emotion, string color]

var used_emotion_keys: Array[String] = []

var monster_audio_lookup: Dictionary[String, AudioStream] = {
	"happy_1": preload("res://Audio/ReversedAudio/happy_1.wav"),
	"happy_2": preload("res://Audio/ReversedAudio/happy_2.wav"),
	"happy_3": preload("res://Audio/ReversedAudio/happy_3.wav"),
	"happy_4": preload("res://Audio/ReversedAudio/happy_4.wav"),
	"sad_1": preload("res://Audio/ReversedAudio/sad_1.wav"),
	"sad_2": preload("res://Audio/ReversedAudio/sad_2.wav"),
	"sad_3": preload("res://Audio/ReversedAudio/sad_3.wav"),
	"angry_1": preload("res://Audio/ReversedAudio/angry_1.wav"),
	"angry_2": preload("res://Audio/ReversedAudio/angry_2.wav"),
	"angry_3": preload("res://Audio/ReversedAudio/angry_3.wav"),
	"angry_4": preload("res://Audio/ReversedAudio/angry_4.wav"),
	"fear_1": preload("res://Audio/ReversedAudio/fear_1.wav"),
	"fear_2": preload("res://Audio/ReversedAudio/fear_2.wav"),
	"fear_3": preload("res://Audio/ReversedAudio/fear_3.wav"),
	"fear_4": preload("res://Audio/ReversedAudio/fear_4.wav"),
	"fear_5": preload("res://Audio/ReversedAudio/fear_5.wav"),
	"fear_6": preload("res://Audio/ReversedAudio/fear_6.wav"),
	"annoyed_1": preload("res://Audio/ReversedAudio/annoyed_1.wav"),
	"annoyed_2": preload("res://Audio/ReversedAudio/annoyed_2.wav"),
	"annoyed_3": preload("res://Audio/ReversedAudio/annoyed_3.wav"),
	"annoyed_4": preload("res://Audio/ReversedAudio/annoyed_4.wav"),
	"annoyed_5": preload("res://Audio/ReversedAudio/annoyed_5.wav"),
	"ant_man": preload("res://Audio/ReversedAudio/ant_man.wav"),
	"drink": preload("res://Audio/ReversedAudio/drink.wav"),
	"gum": preload("res://Audio/ReversedAudio/gum.wav"),
	"monologue": preload("res://Audio/ReversedAudio/monologue.wav"),
	"pants": preload("res://Audio/ReversedAudio/pants.wav"),
	"puke": preload("res://Audio/ReversedAudio/puke.wav"),
	"annoyed_6": preload("res://Audio/ReversedAudio/annoyed_6.wav"),
	"see": preload("res://Audio/ReversedAudio/see.wav"),
	"shoe": preload("res://Audio/ReversedAudio/shoe.wav"),
	"uber": preload("res://Audio/ReversedAudio/uber.wav"),
	"weed_guy": preload("res://Audio/ReversedAudio/weed_guy.wav"),
}

var player_audio_lookup: Dictionary[String,AudioStream] = {
	"great": preload("res://Audio/Responses/That's Great!.wav"),
	"nice": preload("res://Audio/Responses/Nice_2.wav"),
	"bummer": preload("res://Audio/Responses/Bummer_2.wav"),
	"that_sucks": preload("res://Audio/Responses/That_Sucks_2.wav"),
	"be_okay": preload("res://Audio/Responses/GonnaBeOK_1.wav"),
	"fine": preload("res://Audio/Responses/Fine_1.wav"),
	"woah": preload("res://Audio/Responses/Woah_1.wav"),
	"damn": preload("res://Audio/Responses/Damn_1.wav"),
	"crazy": preload("res://Audio/Responses/Crazy_2.wav"),
	"really": preload("res://Audio/Responses/Really_2.wav"),
	"for_sure": preload("res://Audio/Responses/NoYaForSure.wav"),
}

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

func select_new_emotion_message(num_emotions: int = -1) -> EmotionMessage:
	var available_messages : Array = []
	if(num_emotions == -1):
		available_messages = emotions.values().filter(func(m: EmotionMessage): return not m.audio_key in used_emotion_keys)
	else:
		available_messages = emotions.values().filter(func(m: EmotionMessage): return m.emotions.size() == num_emotions and not m.audio_key in used_emotion_keys)
	if(available_messages.size() == 0):
		push_warning("No more unique messages available for emotion count, picking random message: " + str(num_emotions))
		return emotions.values().filter(func(m: EmotionMessage): return m.emotions.size() == num_emotions).pick_random()
	
	var new_message = available_messages.pick_random()
	used_emotion_keys.append(new_message.audio_key)
	return new_message

func select_specific_emotion_message(audio_key: String) -> EmotionMessage:
	if audio_key in emotions:
		used_emotion_keys.append(audio_key)
		return emotions[audio_key]
	else:
		push_error("EmotionDatabase: Audio key not found: " + audio_key)
		return null
	


func get_audio_file_for_message(message: EmotionMessage) -> AudioStream:
	if not message.audio_key in monster_audio_lookup:
		print("Warning: Audio file not found: " + message.audio_key)
		return null
	return monster_audio_lookup[message.audio_key]
	
func get_canned_audio_file(key: String) -> AudioStream:
	if not key in player_audio_lookup:
		print("Warning: Audio file not found: " + key)
		return null
	return player_audio_lookup[key]
