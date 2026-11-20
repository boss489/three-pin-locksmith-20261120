extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var g = load("res://Main.tscn").instantiate()
	root.add_child(g)
	await process_frame
	assert(g.screen == "title")
	g.model.completed = 0 # Deterministic fixture despite prior user:// saves.
	g.touch_down(Vector2(195,580)); g.touch_up(Vector2(195,580))
	assert(g.screen == "tutorial")
	g.touch_down(Vector2(195,610)); g.touch_up(Vector2(195,610))
	assert(g.screen == "play")
	g.touch_down(Vector2(94,290)); g.touch_up(Vector2(94,290))
	assert(g.model.heights[0] == 1)
	g.touch_down(Vector2(94,390)); g.touch_up(Vector2(94,346))
	assert(g.model.heights[0] == 2)
	g.undo()
	assert(g.model.heights[0] == 1)
	g.touch_down(Vector2(195,640)); g.touch_up(Vector2(195,640))
	assert(g.model.mismatch == 1 and g.model.attempts == 1)
	g.selected = 1
	g.adjust_selected(1); g.adjust_selected(1)
	g.selected = 2; g.adjust_selected(1)
	g.test_lock()
	assert(g.screen == "clear" and g.model.completed >= 1)
	g.touch_down(Vector2(195,630)); g.touch_up(Vector2(195,630))
	assert(g.screen == "play" and g.model.level_index == 1)
	for index in range(1,6):
		g.model.heights = g.model.levels[index]["target"].duplicate()
		g.test_lock()
		assert(g.screen == ("victory" if index == 5 else "clear"))
		if index < 5: g.start_play(index+1)
	assert(g.model.completed == 6)
	g.touch_down(Vector2(195,644)); g.touch_up(Vector2(195,644))
	assert(g.screen == "play" and g.model.level_index == 0 and g.model.completed == 6)
	g.load_progress()
	assert(g.model.completed == 6)
	print("PASS: touch arrows/drag/test, first mismatch, undo, six-level completion, replay, save reload")
	g.queue_free()
	await process_frame
	quit()
