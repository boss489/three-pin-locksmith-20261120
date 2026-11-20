extends SceneTree

const Model = preload("res://Model.gd")
const FONT = preload("res://assets/NotoSansKR.ttf")

func _initialize() -> void:
	var m = Model.new()
	assert(m.levels.size() == 6)
	var seen := {}
	for level in m.levels:
		var target: Array = level["target"]
		assert(target.size() == 3 and not seen.has(str(target)))
		seen[str(target)] = true
		assert(level["hidden"] >= -1 and level["hidden"] < 3)
		if m.levels.find(level) == 0: assert(level["hidden"] == -1)
		else: assert(level["hidden"] >= 0)
		var wins := 0
		for a in range(4):
			for b in range(4):
				for c in range(4):
					var state := [a,b,c]
					var result: int = m.first_mismatch(state, target)
					if result == -1: wins += 1; assert(state == target)
					else: assert(result >= 0 and result <= 2 and state[result] != target[result])
		assert(wins == 1)
	m.start_level(0)
	assert(m.heights == [0,0,0])
	assert(m.adjust(0, 1))
	assert(m.heights == [1,0,0])
	assert(m.undo())
	assert(m.heights == [0,0,0])
	assert(not m.undo())
	assert(not m.adjust(0, -1))
	assert(not m.adjust(0, 4))
	assert(not m.check())
	assert(m.attempts == 1 and m.mismatch == 0)
	m.heights = m.levels[0]["target"].duplicate()
	assert(m.check() and m.completed == 1)
	var glyphs := "세 핀 열쇠공방 높이 조절 시험 실패 다시 시작 되돌리기 완료 다음 가린 홈"
	for ch in glyphs:
		if ch != " ": assert(FONT.has_char(ch.unicode_at(0)), "Missing glyph: " + ch)
	print("PASS: 6 distinct solvable levels, 384 states, undo, boundaries, mismatch, progression, Korean glyphs")
	quit()
