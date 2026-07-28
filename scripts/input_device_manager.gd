extends Node
## Tracks whether the player last used keyboard/mouse or a controller and
## resolves human-readable button prompts for input actions.

signal device_changed(using_controller : bool)

var using_controller : bool = false

const JOY_BUTTON_NAMES := {
	JOY_BUTTON_A: "A",
	JOY_BUTTON_B: "B",
	JOY_BUTTON_X: "X",
	JOY_BUTTON_Y: "Y",
	JOY_BUTTON_BACK: "Back",
	JOY_BUTTON_START: "Start",
	JOY_BUTTON_LEFT_STICK: "L3",
	JOY_BUTTON_RIGHT_STICK: "R3",
	JOY_BUTTON_LEFT_SHOULDER: "LB",
	JOY_BUTTON_RIGHT_SHOULDER: "RB",
	JOY_BUTTON_DPAD_UP: "D-Up",
	JOY_BUTTON_DPAD_DOWN: "D-Down",
	JOY_BUTTON_DPAD_LEFT: "D-Left",
	JOY_BUTTON_DPAD_RIGHT: "D-Right",
}

const JOY_AXIS_NAMES := {
	JOY_AXIS_TRIGGER_LEFT: "LT",
	JOY_AXIS_TRIGGER_RIGHT: "RT",
	JOY_AXIS_LEFT_X: "Left Stick",
	JOY_AXIS_LEFT_Y: "Left Stick",
	JOY_AXIS_RIGHT_X: "Right Stick",
	JOY_AXIS_RIGHT_Y: "Right Stick",
}


func _input(event):
	if event is InputEventJoypadButton:
		_set_device(true)
	elif event is InputEventJoypadMotion:
		if abs(event.axis_value) > 0.5:
			_set_device(true)
	elif event is InputEventKey or event is InputEventMouseButton:
		_set_device(false)


func _set_device(controller : bool):
	if using_controller == controller:
		return
	using_controller = controller
	device_changed.emit(using_controller)


## Returns the binding label for an action on the active device, e.g. "E" or "B".
func get_prompt_text(action : String) -> String:
	return get_binding_text(action, using_controller)


## Returns the binding label for an action on a specific device.
func get_binding_text(action : String, controller : bool) -> String:
	if not InputMap.has_action(action):
		return "?"
	for event in InputMap.action_get_events(action):
		if controller:
			if event is InputEventJoypadButton:
				return JOY_BUTTON_NAMES.get(event.button_index, "Btn %d" % event.button_index)
			if event is InputEventJoypadMotion:
				return JOY_AXIS_NAMES.get(event.axis, "Axis %d" % event.axis)
		else:
			if event is InputEventKey:
				var keycode : int = event.keycode if event.keycode != 0 else event.physical_keycode
				return OS.get_keycode_string(keycode)
	return "?"
