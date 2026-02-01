extends Node


signal start_encounter(encounter:Encounter)
signal end_encounter
signal wrong_mask(mask:Mask)
signal correct_mask(mask:Mask)

signal reset_game
signal game_over
signal win
signal player_health_changed(health:int)
signal player_healed(amount:int)
signal done_loading
signal shotgun_picked_up
signal drunk_started
signal toggled_crosshair(show:bool)
