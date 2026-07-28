extends Node2D
class_name CrystalMarker

## A tiny node that carries a `crystal_id` so it can drive CrusherDoor gates through
## the EventBus.crystal_lit / crystal_unlit channel. CrusherDoor._matches() checks for
## a `crystal_id` property, so any emitter just needs to expose one — the DayNightCycle
## uses two of these (one per phase) to open the day-gate and night-gate.

@export var crystal_id : String = ""
