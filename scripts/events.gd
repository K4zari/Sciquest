extends Node

signal enemy_spawned(enemy : CharacterBody2D)
signal level_end_reached(level : Node2D)
signal player_ready(player : Sciquest)

signal crystal_lit(crystal : Node2D)
signal crystal_unlit(crystal : Node2D)
signal puzzle_solved(room_id : String)
signal beam_hit(target : Node2D, intensity : float)

# ── Energy puzzle (Topic 7) ──────────────────────────────────────────────────
signal energy_collected(source : int)          ## orb grabbed into the inventory
signal energy_consumed(source : int)           ## orb accepted by a generator
signal energy_select_requested(generator : Node) ## generator asks the inventory UI to open
signal interactable_spawned(node : Node)       ## a runtime-spawned interactable needs wiring
