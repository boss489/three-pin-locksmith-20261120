extends Control

const Model = preload("res://Model.gd")
const FONT = preload("res://assets/NotoSansKR.ttf")
const C_BG = Color("101c29")
const C_PANEL = Color("203344")
const C_INK = Color("f5ead1")
const C_MUTED = Color("d0e0da")
const C_GOLD = Color("e9b864")
const C_TEAL = Color("70d6bf")
const C_RED = Color("fa7774")
var model = Model.new()
var screen := "title"
var selected := 0
var message := ""
var drag_pin := -1
var drag_start := Vector2.ZERO
var pulse := 0.0
var audio: AudioStreamPlayer
var tones := []
var display_font: FontVariation
var scale_factor := 1.0
var origin := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	model.start_level(0)
	load_progress()
	display_font = FontVariation.new()
	display_font.base_font = FONT
	display_font.variation_opentype = {"wght": 600}
	audio = AudioStreamPlayer.new()
	add_child(audio)
	for file in ["res://assets/tick.wav", "res://assets/buzz.wav", "res://assets/chime.wav"]:
		tones.append(load(file))
	queue_redraw()

func _process(delta: float) -> void:
	pulse += delta
	queue_redraw()

func layout() -> void:
	var sz := get_viewport_rect().size
	scale_factor = minf(sz.x / 390.0, sz.y / 760.0)
	origin = (sz - Vector2(390,760) * scale_factor) / 2.0

func _draw() -> void:
	layout()
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), C_BG)
	draw_set_transform(origin, 0.0, Vector2.ONE * scale_factor)
	# Blueprint grain, brass borders and radial star motifs are vector art.
	for i in range(12):
		var y := float(i) * 74.0 - 20.0
		draw_line(Vector2(0,y), Vector2(390,y), Color("294052", 0.33), 1)
	for i in range(7):
		var x := float(i) * 65.0
		draw_line(Vector2(x,0),Vector2(x,760),Color("294052",0.18),1)
	frame(Rect2(12,12,366,736), C_GOLD, 2.0)
	for x in [25.0, 365.0]:
		for y in [25.0, 735.0]: draw_circle(Vector2(x,y),3,C_GOLD)
	if screen == "title": draw_title()
	elif screen == "tutorial": draw_tutorial()
	elif screen == "play": draw_play()
	elif screen == "clear": draw_clear()
	elif screen == "victory": draw_victory()
	draw_set_transform(Vector2.ZERO)

func panel(r: Rect2, fill: Color = C_PANEL) -> void:
	draw_rect(r, fill)
	frame(r, C_GOLD.darkened(0.25), 1.5)

func frame(r: Rect2, color: Color, width: float = 1.0) -> void:
	draw_rect(r, color, false, width)

func label(text: String, x: float, y: float, size: int = 18, color: Color = C_INK, center: bool = false) -> void:
	var dx := 0.0
	if center: dx = display_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x / 2.0
	draw_string(display_font, Vector2(x-dx,y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func button(text: String, r: Rect2, active: bool = true) -> void:
	panel(r, C_GOLD if active else Color("304656"))
	label(text, r.position.x + r.size.x/2.0, r.position.y + r.size.y/2.0+6, 17, C_BG if active else C_MUTED, true)

func ornament(cx: float, cy: float, radius: float) -> void:
	draw_arc(Vector2(cx,cy),radius,0,TAU,64,C_GOLD,2.0)
	draw_arc(Vector2(cx,cy),radius-11,0,TAU,64,C_TEAL,1.0)
	for i in range(12):
		var a := TAU * i / 12.0 + pulse * 0.09
		var p := Vector2(cx,cy) + Vector2.from_angle(a)*radius
		draw_circle(p,2,C_GOLD)

func draw_title() -> void:
	label("ATELIER  ·  01",195,90,16,C_TEAL,true)
	label("세 핀 열쇠공방",195,157,34,C_INK,true)
	label("세 개의 높이, 단 하나의 열쇠",195,193,17,C_MUTED,true)
	ornament(195,356,109)
	# An original key and lock silhouette, not a stock image.
	draw_circle(Vector2(145,355),33,C_GOLD)
	draw_circle(Vector2(145,355),19,C_BG)
	draw_rect(Rect2(169,347,101,17),C_GOLD)
	for x in [207.0,238.0,266.0]: draw_rect(Rect2(x,357,11,25),C_GOLD)
	draw_colored_polygon(PackedVector2Array([Vector2(195,436),Vector2(200,451),Vector2(215,456),Vector2(200,461),Vector2(195,476),Vector2(190,461),Vector2(175,456),Vector2(190,451)]),C_TEAL)
	button("공방 열기  →",Rect2(44,550,302,62))
	label("마우스  ·  터치  ·  키보드",195,672,15,C_MUTED,true)
	if model.completed > 0: label("저장된 진행  %d / 6" % model.completed,195,704,14,C_TEAL,true)

func draw_tutorial() -> void:
	label("작업 설명서",195,99,32,C_INK,true)
	label("01 / 홈을 읽고",57,173,21,C_GOLD)
	label("보이는 목표 높이를 살펴보세요.",57,202,17)
	label("가린 홈은 시험으로 유추합니다.",57,229,16,C_MUTED)
	label("02 / 핀을 움직이고",57,308,21,C_GOLD)
	label("화살표 탭 · 핀 드래그 · 1~3 선택",57,337,16)
	label("↑↓ 로 높이를 0~3 사이 조절",57,364,16,C_MUTED)
	label("03 / 열쇠 시험",57,443,21,C_GOLD)
	label("처음 어긋난 핀만 붉게 표시해요.",57,472,16)
	label("정답 높이는 알려주지 않습니다.",57,499,16,C_MUTED)
	button("첫 번째 잠금장치  →",Rect2(34,577,322,64))
	label("되돌리기: Z   ·   시험: Enter",195,697,14,C_MUTED,true)

func draw_play() -> void:
	var lvl: Dictionary = model.levels[model.level_index]
	label("세 핀 열쇠공방",28,64,24)
	label("%02d / 06" % (model.level_index+1),355,63,17,C_TEAL,true)
	label(lvl["name"],28,103,19,C_GOLD)
	label(lvl["note"],28,129,14,C_MUTED)
	panel(Rect2(27,149,336,100))
	label("열쇠 홈   /   목표 높이",43,174,14,C_MUTED)
	for i in range(3):
		var x := 94.0 + i * 101.0
		var hidden: bool = lvl["hidden"] == i
		var h: int = lvl["target"][i]
		if hidden:
			draw_rect(Rect2(x-32,185,64,46),Color("516473"))
			for j in range(4): draw_line(Vector2(x-29+j*17,185),Vector2(x-29+j*17,231),C_BG,2)
			label("?",x,219,26,C_INK,true)
		else:
			draw_rect(Rect2(x-30,214-h*8,60,8+h*8),C_GOLD)
			label(str(h),x,219,20,C_BG,true)
		label(str(i+1),x-39,220,14,C_MUTED)
	# Lock body: tall chambers, restrained moving brass pins and annotated notches.
	panel(Rect2(28,275,334,288),Color("172a39"))
	for i in range(3):
		var x := 94.0 + i*101.0
		var chosen := selected == i
		var bad: bool = model.mismatch == i
		var accent: Color = C_RED if bad else (C_TEAL if chosen else C_GOLD)
		draw_rect(Rect2(x-37,316,74,202),Color("304657"))
		for step in range(4):
			var y := 463.0-step*40.0
			draw_line(Vector2(x-31,y),Vector2(x+31,y),Color("8fa8ad",0.55),1)
			draw_rect(Rect2(x-24,450-model.heights[i]*40,48,56+model.heights[i]*40),accent)
			draw_rect(Rect2(x-24,450-model.heights[i]*40,48,7),C_INK)
		label(str(model.heights[i]),x,488,23,C_BG,true)
		label("▲",x,308,23,accent,true)
		label("▼",x,545,23,accent,true)
		if bad: label("!",x,381,26,C_BG,true)
	label(message if message != "" else "핀을 조절한 뒤 시험해 보세요",195,598,16,C_RED if model.mismatch >= 0 else C_MUTED,true)
	button("시험  ↗",Rect2(28,618,334,55))
	button("되돌리기",Rect2(28,681,160,48), not model.history.is_empty())
	panel(Rect2(198,681,164,48),Color("304656"))
	label("시험 %d회" % model.attempts,280,712,16,C_INK,true)

func draw_clear() -> void:
	label("잠금 해제",195,154,37,C_GOLD,true)
	ornament(195,336,109)
	draw_colored_polygon(PackedVector2Array([Vector2(195,278),Vector2(210,326),Vector2(260,340),Vector2(210,354),Vector2(195,402),Vector2(180,354),Vector2(130,340),Vector2(180,326)]),C_TEAL)
	label("%02d번 장치 완료" % (model.level_index+1),195,500,23,C_INK,true)
	label("시험 %d회 · 진행 자동 저장" % model.attempts,195,540,17,C_MUTED,true)
	button("다음 잠금장치  →",Rect2(38,603,314,61))

func draw_victory() -> void:
	label("MASTER KEY",195,104,18,C_TEAL,true)
	label("공방의 문이 열렸습니다",195,171,29,C_GOLD,true)
	ornament(195,349,118)
	for i in range(3):
		var x := 130.0+i*65
		draw_rect(Rect2(x-11,335-i*23,22,91+i*23),C_GOLD)
		draw_circle(Vector2(x,335-i*23),14,C_INK)
	label("여섯 장치를 모두 해제했어요",195,536,20,C_INK,true)
	label("기록은 보존됩니다. 언제든 다시 도전하세요.",195,572,15,C_MUTED,true)
	button("처음부터 다시 하기",Rect2(38,614,314,61))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed: touch_down(event.position)
		else: touch_up(event.position)
	elif event is InputEventScreenTouch:
		if event.pressed: touch_down(event.position)
		else: touch_up(event.position)
	elif event is InputEventMouseMotion and drag_pin >= 0:
		pass

func logical(pos: Vector2) -> Vector2:
	layout()
	return (pos-origin)/scale_factor

func touch_down(pos: Vector2) -> void:
	var p := logical(pos)
	drag_start = p
	if screen == "play" and p.y >= 316 and p.y <= 518 and p.x >= 55 and p.x <= 330:
		drag_pin = clampi(int((p.x-44)/101),0,2)
		selected = drag_pin
		queue_redraw()

func touch_up(pos: Vector2) -> void:
	var p := logical(pos)
	if drag_pin >= 0:
		var dy := p.y-drag_start.y
		if absf(dy) > 18:
			adjust_selected(-1 if dy > 0 else 1)
		else: selected = drag_pin
		drag_pin = -1
		queue_redraw()
		return
	if screen == "title" and Rect2(44,550,302,62).has_point(p): screen = "tutorial"; sound(0)
	elif screen == "tutorial" and Rect2(34,577,322,64).has_point(p): start_play(mini(model.completed,5))
	elif screen == "play":
		if p.y >= 275 and p.y <= 317 or p.y >= 518 and p.y <= 566:
			var i := clampi(int((p.x-44)/101),0,2)
			if p.x >= 55 and p.x <= 330:
				selected = i
				adjust_selected(1 if p.y < 317 else -1)
		elif Rect2(28,618,334,55).has_point(p): test_lock()
		elif Rect2(28,681,160,48).has_point(p): undo()
	elif screen == "clear" and Rect2(38,603,314,61).has_point(p): start_play(model.level_index+1)
	elif screen == "victory" and Rect2(38,614,314,61).has_point(p): start_play(0)
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.pressed or event.echo: return
	if screen == "title" and event.keycode in [KEY_ENTER,KEY_SPACE]: screen = "tutorial"; sound(0)
	elif screen == "tutorial" and event.keycode in [KEY_ENTER,KEY_SPACE]: start_play(mini(model.completed,5))
	elif screen == "play":
		if event.keycode >= KEY_1 and event.keycode <= KEY_3: selected = event.keycode - KEY_1; sound(0)
		elif event.keycode == KEY_UP: adjust_selected(1)
		elif event.keycode == KEY_DOWN: adjust_selected(-1)
		elif event.keycode in [KEY_ENTER, KEY_SPACE]: test_lock()
		elif event.keycode in [KEY_Z, KEY_BACKSPACE]: undo()
	elif screen == "clear" and event.keycode in [KEY_ENTER,KEY_SPACE]: start_play(model.level_index+1)
	elif screen == "victory" and event.keycode in [KEY_ENTER,KEY_SPACE]: start_play(0)
	queue_redraw()

func start_play(index: int) -> void:
	model.start_level(index)
	selected = 0
	message = ""
	screen = "play"
	sound(0)

func adjust_selected(delta: int) -> void:
	if model.adjust(selected,delta): message = ""; sound(0)

func undo() -> void:
	if model.undo(): message = "되돌렸습니다"; sound(0)

func test_lock() -> void:
	if model.check():
		save_progress()
		screen = "victory" if model.completed == 6 else "clear"
		sound(2)
	else:
		message = "%d번 핀이 처음 걸립니다 · 다시 조절하세요" % (model.mismatch+1)
		sound(1)

func sound(index: int) -> void:
	if audio != null and index < tones.size() and tones[index] != null:
		audio.stream = tones[index]
		audio.play()

func save_progress() -> void:
	var file := FileAccess.open("user://three_pin_save.json", FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"completed":model.completed}))

func load_progress() -> void:
	if not FileAccess.file_exists("user://three_pin_save.json"): return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("user://three_pin_save.json"))
	if parsed is Dictionary:
		model.completed = clampi(int(parsed.get("completed",0)),0,6)
