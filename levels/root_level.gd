extends Node3D
class_name RootLevel

var objectives: Array[Objective] = []
var current_objectives: Array = []
var completed_objectives: Array[Objective] = []

var current_objective_tier: int = 0
var objective_tiers = {} # Dictionary[int, Array[Objective]]

@onready var tier_level_nodes: Array = [$Tier1, %Tier2, %Tier3]
@onready var player: Player = $Player
@onready var hud: Hud = $Hud
@onready var blockers: Array[Node3D] = [null, %Tier2Blocker, %Tier3Blocker]


func _ready() -> void:
	hud.player = player
	var temp_objectives = get_tree().get_nodes_in_group("ObjectiveGroup")
	for objective in temp_objectives:
		objectives.append(objective as Objective)
	build_objective_tiers()
	MusicManager.play_music("level_1")
	for objective in objectives:
		if(objective.tier < 0):
			continue
		print(objective.name)
		objective.completed.connect(_on_objective_completed)
	for i in range(tier_level_nodes.size()):
		var tier = tier_level_nodes[i]
		if tier != null and i != 0:
			tier.hide()
	_process_objective_tier()

func build_objective_tiers() -> void:
	for objective in objectives:
		if(objective.tier < 0):
			continue
		if objective.tier not in objective_tiers:
			objective_tiers[objective.tier] = []
		objective_tiers[objective.tier].append(objective)
		
func _on_objective_completed(objective: Objective) -> void:
	if(objective in completed_objectives):
		return
	if(objective.tier != current_objective_tier):
		return
	print("Objective completed: ", objective.name)
	objective.complete()
	completed_objectives.append(objective)
	if completed_objectives.size() == current_objectives.size():
		print("All objectives completed for tier: ", current_objective_tier)
		advance_objective_tier()
	else:
		hud.update_objectives()

func advance_objective_tier() -> void:
	completed_objectives.clear()
	if(tier_level_nodes[current_objective_tier] != null and current_objective_tier < 0):
		tier_level_nodes[current_objective_tier-1].hide()
	current_objective_tier += 1
	if current_objective_tier not in objective_tiers:
		print("No more objectives to complete")
		SignalBus.win.emit()
		return
	if(tier_level_nodes[current_objective_tier] != null):
		tier_level_nodes[current_objective_tier].show()
		if(blockers[current_objective_tier] != null):
			blockers[current_objective_tier].queue_free()
	_process_objective_tier()

func _process_objective_tier() -> void:
	if(len(objective_tiers.keys()) <= 0):
		return
	current_objectives = objective_tiers[current_objective_tier]
	hud.set_objectives(current_objectives)
	# for objective in current_objectives:
	# 	objective.enable_objective()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var pause_menu = preload("res://ui/pause_menu.tscn").instantiate()
		hud.add_child(pause_menu)
		pause_menu.show_pause_menu()
