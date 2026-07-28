extends Node

var topics: Dictionary = {
	0: Topic0Tutorial.questions,
	4: Topic4Plants.questions,
	5: Topic5Light.questions,
	7: Topic7Energy.questions,
	9: Topic9Earth.questions,
	10: Topic10Machines.questions,
}

func get_topic_name(id: int) -> String:
	var names := {
		0: tr("Tutorial: Training Grounds"),
		4: tr("Topic 4: Plants"),
		5: tr("Topic 5: Properties of Light"),
		7: tr("Topic 7: Energy"),
		9: tr("Topic 9: Earth"),
		10: tr("Topic 10: Machines"),
	}
	return names.get(id, "Topic %d" % id)

var topic_names: Dictionary = {
	0: "Tutorial: Training Grounds",
	4: "Topic 4: Plants",
	5: "Topic 5: Properties of Light",
	7: "Topic 7: Energy",
	9: "Topic 9: Earth",
	10: "Topic 10: Machines",
}

var topic_colors: Dictionary = {
	0: Color(1.0, 0.84, 0.25),
	4: Color(0.2, 0.7, 0.2),
	5: Color(0.9, 0.9, 0.2),
	7: Color(0.9, 0.4, 0.1),
	9: Color(0.2, 0.4, 0.9),
	10: Color(0.6, 0.4, 0.8),
}

func get_question(topic_id: int, used_indices: Array, difficulty: String = "") -> Dictionary:
	var pool: Array = topics[topic_id]
	var available: Array = _filter_pool(pool, used_indices, difficulty)
	if available.is_empty():
		# Cycle exhausted — clear used indices for this difficulty group and retry.
		_clear_used_for_difficulty(pool, used_indices, difficulty)
		available = _filter_pool(pool, used_indices, difficulty)
	if available.is_empty():
		# No questions match the difficulty at all (shouldn't happen) — fall back to all.
		used_indices.clear()
		available = range(pool.size())
	var idx = available[randi() % available.size()]
	used_indices.append(idx)
	return _shuffled_copy(pool[idx])

## Returns a copy of the question with its four options randomly reordered so the
## correct answer isn't always in the same slot (and a long correct option isn't a
## fixed positional tell). options/options_ms are permuted with the SAME order and
## `correct` is remapped. Works on a deep copy so the static question data is never
## mutated.
func _shuffled_copy(q: Dictionary) -> Dictionary:
	var out := q.duplicate(true)
	var order := [0, 1, 2, 3]
	order.shuffle()
	var opts: Array = q.options
	var opts_ms: Array = q.get("options_ms", q.options)
	var new_opts := []
	var new_opts_ms := []
	for new_i in range(4):
		var src: int = order[new_i]
		new_opts.append(opts[src])
		new_opts_ms.append(opts_ms[src])
	out.options = new_opts
	if q.has("options_ms"):
		out.options_ms = new_opts_ms
	out.correct = order.find(q.correct)
	return out

func _filter_pool(pool: Array, used_indices: Array, difficulty: String) -> Array:
	var available: Array = []
	for i in range(pool.size()):
		if used_indices.has(i):
			continue
		if not _matches_difficulty(pool[i], difficulty):
			continue
		available.append(i)
	return available

func _matches_difficulty(question: Dictionary, difficulty: String) -> bool:
	var q_diff: String = question.get("difficulty", "medium")
	if difficulty == "hard":
		return q_diff == "hard"
	# Default: regular enemies see easy + medium, never hard.
	return q_diff != "hard"

func _clear_used_for_difficulty(pool: Array, used_indices: Array, difficulty: String) -> void:
	var i := used_indices.size() - 1
	while i >= 0:
		var idx: int = used_indices[i]
		if idx >= 0 and idx < pool.size() and _matches_difficulty(pool[idx], difficulty):
			used_indices.remove_at(i)
		i -= 1
