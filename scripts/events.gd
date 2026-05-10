extends Node

signal enemy_spawned(enemy : CharacterBody2D)
signal level_end_reached(level : Node2D)
signal player_ready(player : Forresta)

signal crystal_lit(crystal : Node2D)
signal puzzle_solved(room_id : String)
signal beam_hit(target : Node2D, intensity : float)
