extends Node
## Godot MCP Bridge
## Add this as an autoload singleton to enable MCP remote features like screenshots
##
## Setup:
## 1. In Godot Editor: Project > Project Settings > Autoload
## 2. Add this script with name "GodotMCPBridge"
## 3. Run your game (F5)
## 4. The MCP server can now send commands via print statements

# When true, periodically save a viewport screenshot to res://outputs/ so
# external tools (Claude Code, scripts) can read the latest frame from disk
# without needing an active TCP debug connection.
const AUTO_SCREENSHOT := true
const AUTO_SCREENSHOT_INTERVAL := 2.0
const AUTO_SCREENSHOT_PATH := "res://outputs/mcp_screenshot.png"
const COMMAND_FILE_PATH := "res://outputs/mcp_command.txt"
const COMMAND_POLL_INTERVAL := 0.1

var command_prefix = "MCP_COMMAND:"
var response_prefix = "MCP_RESPONSE:"

func _ready():
	# Keep polling and screenshots alive while the game is paused (pause menu testing)
	process_mode = Node.PROCESS_MODE_ALWAYS
	print(response_prefix + '{"type":"ready","bridge_version":"1.0"}')
	print("Godot MCP Bridge initialized")
	if AUTO_SCREENSHOT:
		_start_auto_screenshot()
	_start_command_polling()

func _process(_delta):
	# Check for commands from stdin (if running with --remote-debug)
	# For now, we'll use a simpler approach: respond to marker prints
	pass

func _start_auto_screenshot() -> void:
	var timer := Timer.new()
	timer.wait_time = AUTO_SCREENSHOT_INTERVAL
	timer.one_shot = false
	timer.timeout.connect(_save_screenshot_to_disk)
	add_child(timer)
	timer.start()

func _save_screenshot_to_disk() -> void:
	var viewport := get_tree().root.get_viewport()
	if viewport == null:
		return
	var img := viewport.get_texture().get_image()
	if img == null:
		return
	var dir_path := AUTO_SCREENSHOT_PATH.get_base_dir()
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(dir_path)):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir_path))
	var err := img.save_png(AUTO_SCREENSHOT_PATH)
	if err != OK:
		print(response_prefix + JSON.stringify({"type": "screenshot_saved", "error": err}))

## Capture a screenshot and print it as base64-encoded JSON
func capture_screenshot(format: String = "png") -> Dictionary:
	var viewport = get_tree().root.get_viewport()
	if not viewport:
		var error = {"type": "screenshot", "error": "Failed to get viewport"}
		print(response_prefix + JSON.stringify(error))
		return error

	var img = viewport.get_texture().get_image()
	if not img:
		var error = {"type": "screenshot", "error": "Failed to get image from viewport"}
		print(response_prefix + JSON.stringify(error))
		return error

	var buffer = PackedByteArray()
	if format == "jpg" or format == "jpeg":
		buffer = img.save_jpg_to_buffer(0.9)
	else:
		buffer = img.save_png_to_buffer()

	if buffer.is_empty():
		var error = {"type": "screenshot", "error": "Failed to encode image"}
		print(response_prefix + JSON.stringify(error))
		return error

	var base64 = Marshalls.raw_to_base64(buffer)
	var result = {
		"type": "screenshot",
		"success": true,
		"data": base64,
		"size": buffer.size(),
		"width": img.get_width(),
		"height": img.get_height(),
		"format": format
	}

	print(response_prefix + JSON.stringify(result))
	return result

## Call this from anywhere in your game to trigger a screenshot
## Example: GodotMCPBridge.request_screenshot()
func request_screenshot(format: String = "png"):
	capture_screenshot(format)

## Simulate a click at screen coordinates
func simulate_click(x: int, y: int, button: int = MOUSE_BUTTON_LEFT):
	var event = InputEventMouseButton.new()
	event.button_index = button
	event.pressed = true
	event.position = Vector2(x, y)

	Input.parse_input_event(event)

	# Also send release event
	await get_tree().create_timer(0.1).timeout
	event.pressed = false
	Input.parse_input_event(event)

	var result = {
		"type": "click",
		"success": true,
		"x": x,
		"y": y,
		"button": button
	}
	print(response_prefix + JSON.stringify(result))
	return result

func _dump_state() -> void:
	var player = Globals.player if "player" in Globals else null
	var info := {
		"type": "dbg",
		"player_pos": null,
		"interactables": [],
		"crystals": [],
		"enemies": [],
		"current_level": null,
		"interactable_in_range": null,
	}
	if player and is_instance_valid(player):
		info["player_pos"] = [player.global_position.x, player.global_position.y]
	for e in get_tree().get_nodes_in_group("Enemies"):
		var estate := ""
		var sm = e.get_node_or_null("FiniteStateMachine")
		if sm and "current_state" in sm and sm.current_state != null:
			estate = sm.current_state.name
		info["enemies"].append({
			"name": e.name,
			"pos": [round(e.global_position.x), round(e.global_position.y)],
			"dead": e.is_dead if "is_dead" in e else null,
			"in_battle": e.in_battle if "in_battle" in e else null,
			"state": estate,
			"vel": [round(e.velocity.x), round(e.velocity.y)] if "velocity" in e else null,
			"in_wind": e.in_wind if "in_wind" in e else null,
			"wind_force": [round(e.wind_force.x), round(e.wind_force.y)] if "wind_force" in e else null,
		})
	for n in get_tree().get_nodes_in_group("Interactables"):
		var entry := {
			"name": n.name,
			"pos": [n.global_position.x, n.global_position.y],
			"groups": n.get_groups(),
		}
		var prox := n.get_node_or_null("Proximity") as Area2D
		if prox != null:
			entry["prox_layer"] = prox.collision_layer
			entry["prox_mask"] = prox.collision_mask
			entry["prox_monitoring"] = prox.monitoring
			var bodies : Array = prox.get_overlapping_bodies()
			var names : Array = []
			for b in bodies:
				names.append(b.name)
			entry["overlapping"] = names
		info["interactables"].append(entry)
	for n in get_tree().get_nodes_in_group("LightCrystals"):
		var lit := false
		if "lit" in n:
			lit = n.lit
		info["crystals"].append({"name": n.name, "lit": lit, "pos": [n.global_position.x, n.global_position.y]})
	# Try to find the Level node and read interactable_in_range.
	for level in get_tree().get_nodes_in_group(""):
		pass
	var levels := get_tree().root.find_children("*", "Node2D", true, false)
	for lv in levels:
		if lv is Level:
			info["current_level"] = lv.name
			if "interactable_in_range" in lv and lv.interactable_in_range != null:
				info["interactable_in_range"] = lv.interactable_in_range.name
			break
	print(response_prefix + JSON.stringify(info))

func _press_button_by_text(needle: String) -> void:
	# A trailing "#N" picks the Nth (0-indexed) match: "Play #1" → second Play.
	var index := 0
	var hash_pos := needle.rfind("#")
	if hash_pos > 0:
		var idx_str := needle.substr(hash_pos + 1).strip_edges()
		if idx_str.is_valid_int():
			index = int(idx_str)
			needle = needle.substr(0, hash_pos).strip_edges()
	var match_lower := needle.to_lower()
	var hits : Array = []
	_find_matching_buttons(get_tree().root, match_lower, hits)
	if hits.size() <= index:
		print(response_prefix + JSON.stringify({"type": "btn", "needle": needle, "ok": false, "reason": "no_match", "want_index": index, "found": hits.size()}))
		return
	var btn : Button = hits[index]
	btn.emit_signal("pressed")
	print(response_prefix + JSON.stringify({"type": "btn", "needle": needle, "index": index, "ok": true, "matched": btn.text}))

func _find_matching_buttons(node: Node, needle_lower: String, hits: Array) -> void:
	if node is Button:
		var btn := node as Button
		if btn.text.strip_edges().to_lower().find(needle_lower) >= 0:
			hits.append(btn)
	for child in node.get_children():
		_find_matching_buttons(child, needle_lower, hits)

func _force_interact(node_name: String) -> void:
	for n in get_tree().get_nodes_in_group("Interactables"):
		if n.name == node_name:
			if n.has_method("interact"):
				n.interact()
				print(response_prefix + JSON.stringify({"type": "interact", "name": node_name, "ok": true}))
				return
	print(response_prefix + JSON.stringify({"type": "interact", "name": node_name, "ok": false}))

func _find_enemy(node_name: String) -> Node:
	for e in get_tree().get_nodes_in_group("Enemies"):
		if e.name == node_name:
			return e
	return null

func _force_battle(node_name: String) -> void:
	var e := _find_enemy(node_name)
	if e == null:
		print(response_prefix + JSON.stringify({"type": "battle", "name": node_name, "ok": false, "reason": "not_found"}))
		return
	if "in_battle" in e:
		e.in_battle = true
	BattleManager.start_battle(e, Globals.current_topic)
	print(response_prefix + JSON.stringify({"type": "battle", "name": node_name, "ok": true, "topic": Globals.current_topic}))

func _force_kill(node_name: String) -> void:
	var e := _find_enemy(node_name)
	if e == null:
		print(response_prefix + JSON.stringify({"type": "kill", "name": node_name, "ok": false, "reason": "not_found"}))
		return
	var sm = e.get_node_or_null("FiniteStateMachine")
	if sm and sm.has_method("transition"):
		sm.transition("DieState")
		print(response_prefix + JSON.stringify({"type": "kill", "name": node_name, "ok": true}))
	else:
		print(response_prefix + JSON.stringify({"type": "kill", "name": node_name, "ok": false, "reason": "no_fsm"}))

func _force_cast(node_name: String) -> void:
	var e := _find_enemy(node_name)
	if e == null:
		print(response_prefix + JSON.stringify({"type": "cast", "name": node_name, "ok": false, "reason": "not_found"}))
		return
	if "target" in e:
		e.target = Globals.player
	if e.has_method("cast_spell"):
		e.cast_spell()
		print(response_prefix + JSON.stringify({"type": "cast", "name": node_name, "ok": true}))
	else:
		print(response_prefix + JSON.stringify({"type": "cast", "name": node_name, "ok": false, "reason": "no_method"}))

func _tap_joy_button(button_index: int, hold_seconds: float) -> void:
	var down := InputEventJoypadButton.new()
	down.button_index = button_index
	down.pressed = true
	Input.parse_input_event(down)
	await get_tree().create_timer(hold_seconds).timeout
	var up := InputEventJoypadButton.new()
	up.button_index = button_index
	up.pressed = false
	Input.parse_input_event(up)
	print(response_prefix + JSON.stringify({"type": "joy", "button": button_index}))

func _tap_key(key_name: String, hold_seconds: float) -> void:
	var keycode := OS.find_keycode_from_string(key_name.to_upper())
	if keycode == KEY_NONE:
		print(response_prefix + JSON.stringify({"type": "key", "error": "unknown", "name": key_name}))
		return
	var down := InputEventKey.new()
	down.keycode = keycode
	down.pressed = true
	Input.parse_input_event(down)
	await get_tree().create_timer(hold_seconds).timeout
	var up := InputEventKey.new()
	up.keycode = keycode
	up.pressed = false
	Input.parse_input_event(up)
	print(response_prefix + JSON.stringify({"type": "key", "name": key_name, "code": keycode}))

## Hold or release a named InputMap action. Lets external tools drive the
## player without a real keyboard.
func set_action(action: String, pressed: bool) -> void:
	if not InputMap.has_action(action):
		print(response_prefix + JSON.stringify({"type": "action", "error": "missing", "action": action}))
		return
	if pressed:
		Input.action_press(action)
	else:
		Input.action_release(action)
	print(response_prefix + JSON.stringify({"type": "action", "action": action, "pressed": pressed}))

func tap_action(action: String, hold_seconds: float = 0.05) -> void:
	set_action(action, true)
	await get_tree().create_timer(hold_seconds).timeout
	set_action(action, false)

func _start_command_polling() -> void:
	var timer := Timer.new()
	timer.wait_time = COMMAND_POLL_INTERVAL
	timer.one_shot = false
	timer.timeout.connect(_poll_command_file)
	add_child(timer)
	timer.start()

func _poll_command_file() -> void:
	var abs_path := ProjectSettings.globalize_path(COMMAND_FILE_PATH)
	if not FileAccess.file_exists(COMMAND_FILE_PATH):
		return
	var f := FileAccess.open(COMMAND_FILE_PATH, FileAccess.READ)
	if f == null:
		return
	var contents := f.get_as_text()
	f.close()
	# Delete first so a long-running command doesn't get re-executed.
	DirAccess.remove_absolute(abs_path)
	for raw_line in contents.split("\n"):
		var line := raw_line.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue
		await _run_command_line(line)

func _run_command_line(line: String) -> void:
	# Supported commands (one per line):
	#   press <action>        — start holding an InputMap action
	#   release <action>      — release an InputMap action
	#   tap <action> [secs]   — press then release after secs (default 0.05)
	#   wait <secs>           — sleep before next command
	#   shot                  — force an immediate screenshot save
	var parts := line.split(" ", false)
	if parts.is_empty():
		return
	var cmd := parts[0]
	match cmd:
		"press":
			if parts.size() >= 2:
				set_action(parts[1], true)
		"release":
			if parts.size() >= 2:
				set_action(parts[1], false)
		"tap":
			if parts.size() >= 2:
				var hold := 0.05
				if parts.size() >= 3:
					hold = float(parts[2])
				tap_action(parts[1], hold)
		"wait":
			if parts.size() >= 2:
				await get_tree().create_timer(float(parts[1])).timeout
		"shot":
			_save_screenshot_to_disk()
		"tp":
			# tp <x> <y> — teleport the player (dev/testing only)
			if parts.size() >= 3 and Globals.player:
				Globals.player.global_position = Vector2(float(parts[1]), float(parts[2]))
				print(response_prefix + JSON.stringify({"type": "tp", "x": float(parts[1]), "y": float(parts[2])}))
		"dbg":
			_dump_state()
		"interact":
			# interact <NodeName> — find a node by name and call its interact()
			if parts.size() >= 2:
				_force_interact(parts[1])
		"battle":
			# battle <EnemyName> — force-start an MCQ battle with a named enemy
			if parts.size() >= 2:
				_force_battle(parts[1])
		"kill":
			# kill <EnemyName> — transition a named enemy straight to DieState
			if parts.size() >= 2:
				_force_kill(parts[1])
		"forcecast":
			# forcecast <EnemyName> — make a caster enemy cast its spell at the player
			if parts.size() >= 2:
				_force_cast(parts[1])
		"btn":
			# btn <substring of button text> — emit "pressed" on the first matching Button
			if parts.size() >= 2:
				_press_button_by_text(line.substr(line.find(" ") + 1).strip_edges())
		"click":
			# click <x> <y> — simulate a left mouse click at screen coordinates
			if parts.size() >= 3:
				await simulate_click(int(parts[1]), int(parts[2]))
		"focusinfo":
			# focusinfo — report which Control currently holds keyboard/UI focus
			var owner := get_viewport().gui_get_focus_owner()
			print(response_prefix + JSON.stringify({"type": "focus", "owner": str(owner.get_path()) if owner else null}))
		"joy":
			# joy <button_index> [hold_seconds] — inject a real InputEventJoypadButton
			if parts.size() >= 2:
				var jhold := 0.05
				if parts.size() >= 3:
					jhold = float(parts[2])
				_tap_joy_button(int(parts[1]), jhold)
		"key":
			# key <KEYCODE_NAME> [hold_seconds]   e.g. "key E 0.05"
			if parts.size() >= 2:
				var hold := 0.05
				if parts.size() >= 3:
					hold = float(parts[2])
				_tap_key(parts[1], hold)
		_:
			print(response_prefix + JSON.stringify({"type": "command", "error": "unknown", "cmd": cmd}))

## Process commands from MCP
## Commands should be printed with prefix "MCP_COMMAND:" followed by JSON
func _on_command_received(command_str: String):
	var json = JSON.new()
	var error = json.parse(command_str)
	if error != OK:
		print(response_prefix + '{"type":"error","message":"Invalid JSON command"}')
		return

	var command = json.data
	match command.get("action"):
		"screenshot":
			var format = command.get("format", "png")
			capture_screenshot(format)
		"click":
			var x = command.get("x", 0)
			var y = command.get("y", 0)
			var button = command.get("button", MOUSE_BUTTON_LEFT)
			simulate_click(x, y, button)
		_:
			print(response_prefix + '{"type":"error","message":"Unknown command action"}')
