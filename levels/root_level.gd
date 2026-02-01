extends Node3D
class_name RootLevel

var objectives: Array[Objective] = []
var current_objectives: Array = []
var completed_objectives: Array[Objective] = []

var current_objective_tier: int = 0
var objective_tiers = {} # Dictionary[int, Array[Objective]]

@onready var player: Player = $Player
@onready var hud: Hud = $Hud

func _ready() -> void:
	hud.player = player
	var temp_objectives = get_tree().get_nodes_in_group("ObjectiveGroup")
	for objective in temp_objectives:
		objectives.append(objective as Objective)
	build_objective_tiers()
	for objective in objectives:
		print(objective.name)
		objective.completed.connect(_on_objective_completed)
	_process_objective_tier()

func build_objective_tiers() -> void:
	for objective in objectives:
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

func advance_objective_tier() -> void:
	completed_objectives.clear()
	current_objective_tier += 1
	if current_objective_tier not in objective_tiers:
		print("No more objectives to complete")
		SignalBus.win.emit()
		return
	_process_objective_tier()

func _process_objective_tier() -> void:
	if(len(objective_tiers.keys()) <= 0):
		return
	current_objectives = objective_tiers[current_objective_tier]
	# for objective in current_objectives:
	# 	objective.enable_objective()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var pause_menu = preload("res://ui/pause_menu.tscn").instantiate()
		hud.add_child(pause_menu)
		pause_menu.show_pause_menu()
