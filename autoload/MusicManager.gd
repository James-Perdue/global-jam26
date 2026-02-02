extends Node


var music = {
	"main_menu": preload("res://Audio/Menu Music Masquerade.wav"),
	"level_1": preload("res://Audio/Main Level Music Masquerade.wav")
}

@onready var music_player = AudioStreamPlayer.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music_player)
	music_player.finished.connect(func(): music_player.play())

	music_player.volume_db = -15

func _on_settings_change():
	pass
	#music_player.volume_db = linear_to_db(GameSettingsManager.volume_percent / 100 * .25)

func play_music(track : String):
	if !music.has(track):
		print("wrong music selected")
		return
	if music_player.playing:
		if( music_player.stream != music[track]):
			# Fade out current music
			var tween = create_tween()
			var current_volume = music_player.volume_db
			tween.tween_property(music_player, "volume_db", -80, 0.5)
			tween.tween_callback(func():
				music_player.stream = music[track]
				music_player.play()
				# Fade in new music
				var fade_in_tween = create_tween()
				fade_in_tween.tween_property(music_player, "volume_db", current_volume, 0.5)
			)
	else:
		music_player.stream = music[track]
		music_player.play()