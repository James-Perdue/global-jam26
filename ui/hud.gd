extends CanvasLayer
class_name Hud

var player: Player = null
var enemy: Enemy = null

var start_effect = "[eb"
var color_type = " color="
var end_effect = "[/eb]"

var writing_effect = "[we]"
var end_writing_effect = "[/we]"

var monster_effect = "[me]"
var end_monster_effect = "[/me]"

var current_objectives : Array[Objective] = []

@onready var health_bar: ProgressBar = %HealthBar
@onready var rich_text: RichTextLabel = %DialogueBox
@onready var hud_fps_label: Label = %FPSLabel
@onready var loading_screen: Control = %LoadingScreen
@onready var objectives_label: RichTextLabel = %ObjectiveLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.player_health_changed.connect(_on_player_health_changed)
	SignalBus.start_encounter.connect(_on_encounter_start)
	SignalBus.end_encounter.connect(_on_encounter_end)
	SignalBus.correct_mask.connect(_on_correct_mask)
	SignalBus.done_loading.connect(_on_done_loading)
	loading_screen.show()
func _process(_delta: float) -> void:
	if enemy != null:
		rich_text.show()
		rich_text.set_position(player.camera.unproject_position(enemy.get_label_location()) + Vector2(-500,-75))
		
	hud_fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func _on_player_health_changed(health: int) -> void:
	health_bar.value = health

func _on_done_loading():
	var tween = create_tween()
	tween.tween_property(loading_screen, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	loading_screen.hide()

func _on_encounter_start(encounter:Encounter):
	enemy = encounter.enemy
	var temp = 0
	
	rich_text.text = writing_effect + monster_effect    
	while temp < len(enemy.emotion_targets[0].emotions):
		rich_text.text += enemy.message_parts[temp]
		temp+=1
	rich_text.text += end_monster_effect + writing_effect
		
func _on_encounter_end():
	rich_text.hide()
	enemy = null
	
func _on_correct_mask():
	var emotion = 0
	rich_text.text = monster_effect
	while emotion < len(enemy.emotion_targets[0].emotions):
		print("in dis bitch")
		if emotion <  enemy.targeting_emotion_index:
			rich_text.text += start_effect
			rich_text.text +=color_type + EmotionDatabase.colors[Enums.Emotion.keys()[enemy.emotion_targets[0].emotions[emotion]]]
			rich_text.text += "]"  
		rich_text.text += enemy.message_parts[emotion] 
		if emotion< enemy.targeting_emotion_index:
			rich_text.text += end_effect
		print("enemy emotion: " +str(enemy.targeting_emotion_index) + " inside emotion: " + str(emotion))
		emotion+=1
		
	rich_text.text += end_monster_effect 

func update_objectives() -> void:
	var tween = create_tween()
	tween.tween_property(objectives_label, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE)
	await tween.finished
	
	var objective_text = ""
	for objective in current_objectives:
		var formatted_text = "* "
		if objective.is_completed:
			formatted_text += "[s]"
		formatted_text += objective.objective_description
		if objective.is_completed:
			formatted_text += "[/s]"
		formatted_text += "\n"
		objective_text += formatted_text
	objectives_label.text = objective_text
	
	var tween_back = create_tween()
	tween_back.tween_property(objectives_label, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)

func set_objectives(objectives: Array) -> void:
	current_objectives.clear()
	for objective in objectives:
		current_objectives.append(objective as Objective)
	update_objectives()
