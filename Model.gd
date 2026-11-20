extends RefCounted

const LEVELS := [
	{"name":"첫 번째 톱니", "target":[1,2,1], "hidden":-1, "start":[0,0,0], "note":"홈의 높이를 그대로 따라가요."},
	{"name":"가린 홈", "target":[2,0,3], "hidden":1, "start":[0,1,0], "note":"가린 자리는 시험 결과로 찾아요."},
	{"name":"엇갈린 톱니", "target":[3,1,0], "hidden":0, "start":[1,2,2], "note":"처음 어긋난 핀만 표시돼요."},
	{"name":"낮은 기어", "target":[0,3,2], "hidden":2, "start":[3,0,1], "note":"먼저 보이는 홈을 맞춰 보세요."},
	{"name":"청동의 순서", "target":[2,3,1], "hidden":1, "start":[0,0,3], "note":"시험은 정답을 말하지 않아요."},
	{"name":"마지막 문", "target":[3,0,2], "hidden":2, "start":[1,3,0], "note":"세 핀을 모두 통과시키세요."}
]
var levels: Array = LEVELS
var level_index := 0
var heights: Array = [0,0,0]
var history: Array = []
var attempts := 0
var mismatch := -1
var completed := 0

func start_level(index: int) -> void:
	level_index = clampi(index, 0, levels.size() - 1)
	heights = levels[level_index]["start"].duplicate()
	history.clear()
	attempts = 0
	mismatch = -1

func adjust(pin: int, delta: int) -> bool:
	if pin < 0 or pin >= 3 or abs(delta) != 1 or heights[pin] + delta < 0 or heights[pin] + delta > 3:
		return false
	history.append(heights.duplicate())
	heights[pin] += delta
	mismatch = -1
	return true

func undo() -> bool:
	if history.is_empty(): return false
	heights = history.pop_back()
	mismatch = -1
	return true

static func first_mismatch(state: Array, target: Array) -> int:
	for i in range(3):
		if state[i] != target[i]: return i
	return -1

func check() -> bool:
	attempts += 1
	mismatch = first_mismatch(heights, levels[level_index]["target"])
	if mismatch == -1:
		completed = maxi(completed, level_index + 1)
		return true
	return false
