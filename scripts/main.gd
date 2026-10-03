extends Control
## UI flow and prototype clock. Energy values remain static catalog data.
const Catalog = preload("res://scripts/site_catalog.gd")
const SiteMap = preload("res://scripts/site_map.gd")
const INK = Color("#243e48")
const MUTED = Color("#6b8185")
const GREEN = Color("#248c77")
const PAPER = Color("#f8faf6")
var screen := ""
var player_name := ""
var objects: Dictionary = Catalog.objects()
var selected_id := ""
var elapsed_minutes := 480.0
var paused := false
var speed := 1
var day_finished := false
var ui: Control
var site: Control
var name_input: LineEdit
var name_error: Label
var clock_label: Label
var pause_button: Button
var inspector: Panel
var control_buttons: Dictionary = {}
var selection_mode: Label
var feedback: Label
var assistant_message: Label
var fps_label: Label
var hud_refresh := 0.0

func _ready() -> void:
	Engine.max_fps = 60
	_apply_theme()
	show_start()

func _apply_theme() -> void:
	var skin := Theme.new()
	skin.default_font_size = 23
	skin.set_color("font_color", "Label", INK)
	skin.set_color("font_color", "Button", INK)
	skin.set_color("font_hover_color", "Button", GREEN)
	skin.set_color("font_pressed_color", "Button", GREEN)
	skin.set_color("font_disabled_color", "Button", Color("#9aa9a9"))
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var color := Color("#e8efea")
		if state == "hover": color = Color("#d6e8df")
		if state == "pressed": color = Color("#c5e1d4")
		var style := panel_style(color, 12)
		if state == "focus":
			style.bg_color = Color.TRANSPARENT
			style.border_color = GREEN
			style.set_border_width_all(3)
		skin.set_stylebox(state, "Button", style)
	skin.set_stylebox("normal", "LineEdit", panel_style(Color("#eaf0eb"), 12))
	var focus := panel_style(Color("#eaf0eb"), 12)
	focus.border_color = GREEN
	focus.set_border_width_all(2)
	skin.set_stylebox("focus", "LineEdit", focus)
	skin.set_color("font_color", "LineEdit", INK)
	skin.set_color("caret_color", "LineEdit", GREEN)
	skin.set_color("font_placeholder_color", "LineEdit", MUTED)
	theme = skin

func panel_style(color: Color, radius: int = 18) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.content_margin_left = 18
	style.content_margin_right = 18
	return style

func place(node: Control, rect: Rect2, parent: Node = null) -> Control:
	node.position = rect.position
	node.size = rect.size
	(parent if parent != null else ui).add_child(node)
	return node

func panel(rect: Rect2, color: Color = PAPER, parent: Node = null) -> Panel:
	var node := Panel.new()
	node.add_theme_stylebox_override("panel", panel_style(color))
	place(node, rect, parent)
	return node

func label(text: String, rect: Rect2, size_px: int = 23, color: Color = INK, parent: Node = null) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", size_px)
	node.add_theme_color_override("font_color", color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(node, rect, parent)
	return node

func paragraph(text: String, rect: Rect2, size_px: int = 23, color: Color = MUTED, parent: Node = null) -> Label:
	var node := Label.new()
	# Configure wrapping before text enters the tree and computes its minimum size.
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.size = rect.size
	node.text = text
	node.add_theme_font_size_override("font_size", size_px)
	node.add_theme_color_override("font_color", color)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	place(node, rect, parent)
	return node

func button(text: String, rect: Rect2, callback: Callable, parent: Node = null, primary: bool = false) -> Button:
	var node := Button.new()
	node.text = text
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if primary:
		node.add_theme_stylebox_override("normal", panel_style(GREEN, 12))
		node.add_theme_stylebox_override("hover", panel_style(GREEN.lightened(0.1), 12))
		node.add_theme_stylebox_override("pressed", panel_style(GREEN.darkened(0.12), 12))
		for state in ["font_color", "font_hover_color", "font_pressed_color"]:
			node.add_theme_color_override(state, Color.WHITE)
	node.pressed.connect(callback)
	place(node, rect, parent)
	return node

func clear_screen(next: String) -> void:
	if is_instance_valid(ui):
		remove_child(ui)
		ui.queue_free()
	ui = Control.new()
	ui.name = "Screen"
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(ui)
	screen = next

func brand(show_version: bool = true) -> void:
	label("◈", Rect2(52, 28, 50, 55), 46, GREEN)
	label("OptiMesh", Rect2(108, 27, 300, 60), 36)
	label("OFFICE ENERGY LAB", Rect2(320, 44, 350, 35), 16, MUTED)
	if show_version:
		label("VISUAL PROTOTYPE  /  01", Rect2(1530, 43, 330, 35), 17, MUTED)

func menu_background() -> void:
	brand()
	var preview := SiteMap.new()
	place(preview, Rect2(590, 330, 1380, 620))
	preview.scale = Vector2(0.90, 0.90)
	preview.modulate = Color(1, 1, 1, 0.66)
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label("ONE SITE. MANY POSSIBILITIES.", Rect2(650, 250, 1000, 50), 21, GREEN)
	label("A little energy intelligence goes a long way.", Rect2(650, 925, 1100, 60), 26, MUTED)

func show_start() -> void:
	clear_screen("start")
	menu_background()
	var card := panel(Rect2(80, 240, 500, 640))
	label("WELCOME TO", Rect2(40, 42, 420, 40), 19, GREEN, card)
	label("OptiMesh", Rect2(40, 90, 420, 90), 62, INK, card)
	paragraph("Your office.\nYour energy decisions.", Rect2(40, 194, 410, 115), 32, INK, card)
	paragraph("Explore a small workplace and get to know the systems that power it.", Rect2(40, 334, 410, 104), 23, MUTED, card)
	button("New Game  →", Rect2(40, 472, 420, 64), show_name, card, true)
	label("Demo Mode · local desktop prototype", Rect2(40, 550, 420, 45), 19, MUTED, card)

func show_name() -> void:
	clear_screen("name")
	menu_background()
	var card := panel(Rect2(80, 240, 500, 640))
	label("01  /  MEET THE MANAGER", Rect2(40, 40, 420, 40), 18, GREEN, card)
	label("Hello there.", Rect2(40, 108, 420, 80), 48, INK, card)
	paragraph("What should we call you?", Rect2(40, 208, 420, 60), 27, INK, card)
	name_input = LineEdit.new()
	name_input.placeholder_text = "Your name"
	name_input.max_length = 24
	name_input.text = player_name
	place(name_input, Rect2(40, 302, 420, 70), card)
	name_input.text_submitted.connect(func(_text: String): submit_name())
	name_input.text_changed.connect(func(_text: String): name_error.text = "")
	name_error = label("", Rect2(40, 385, 420, 50), 20, Color("#ad5143"), card)
	button("Continue  →", Rect2(40, 465, 420, 64), submit_name, card, true)
	button("← Back", Rect2(40, 550, 160, 48), show_start, card)
	name_input.grab_focus()

func submit_name() -> void:
	var cleaned := name_input.text.strip_edges()
	if cleaned.is_empty():
		name_error.text = "Please enter a name to continue."
		name_input.grab_focus()
		return
	player_name = cleaned
	show_modes()

func show_modes() -> void:
	clear_screen("modes")
	brand()
	label("Choose your first day.", Rect2(170, 195, 1400, 100), 54)
	label("Welcome, %s. Start with a guided look around the site." % player_name, Rect2(174, 300, 1500, 65), 26, MUTED)
	var demo := panel(Rect2(170, 425, 760, 390))
	label("READY TO EXPLORE", Rect2(40, 34, 680, 40), 19, GREEN, demo)
	label("Demo Mode", Rect2(40, 93, 680, 70), 43, INK, demo)
	paragraph("A working site interface, clickable equipment and a clock you control. All energy readings are illustrative.", Rect2(40, 181, 675, 105), 25, MUTED, demo)
	button("Start Demo  →", Rect2(40, 300, 680, 60), start_demo, demo, true)
	var normal := panel(Rect2(975, 425, 760, 390), Color("#e1e9e3"))
	label("COMING LATER", Rect2(40, 34, 680, 40), 19, MUTED, normal)
	label("Normal Mode", Rect2(40, 93, 680, 70), 43, MUTED, normal)
	paragraph("Energy simulation, scenarios and scoring will arrive in a future milestone.", Rect2(40, 181, 675, 105), 25, MUTED, normal)
	var disabled := button("Not available yet", Rect2(40, 300, 680, 60), func(): pass, normal)
	disabled.disabled = true
	button("← Your name", Rect2(170, 880, 250, 60), show_name)

func start_demo() -> void:
	elapsed_minutes = 480.0
	paused = false
	speed = 1
	day_finished = false
	selected_id = ""
	objects = Catalog.objects()
	show_game()

func metric(x: float, title: String, value: String, detail: String, color: Color = INK) -> Label:
	var card := panel(Rect2(x, 111, 265, 100))
	label(title, Rect2(20, 10, 225, 28), 16, MUTED, card)
	var result := label(value, Rect2(20, 38, 225, 44), 32, color, card)
	label(detail, Rect2(20, 78, 225, 20), 13, MUTED, card)
	return result

func show_game() -> void:
	clear_screen("game")
	brand(false)
	button("Menu", Rect2(1736, 30, 130, 50), show_start)
	label("DEMO", Rect2(715, 42, 90, 32), 19, GREEN)
	label("Manager: " + player_name, Rect2(835, 42, 650, 34), 20, MUTED)
	clock_label = metric(55, "OFFICE DAY  /  01", "08:00", "1× = 1 simulated minute / second", GREEN)
	metric(340, "ELECTRICITY PRICE", "€0.18 / kWh", "Illustrative tariff")
	metric(625, "GRID IMPORT", "11.8 kW", "Illustrative reading")
	metric(910, "SOLAR GENERATION", "12.8 kW", "Illustrative reading", GREEN)
	var transport := panel(Rect2(1195, 111, 671, 100))
	label("CLOCK CONTROLS", Rect2(20, 9, 310, 28), 16, MUTED, transport)
	pause_button = button("Pause", Rect2(20, 42, 125, 44), toggle_pause, transport)
	for index in range(3):
		var rate: int = [1, 5, 15][index]
		var rate_button := button("%d×" % rate, Rect2(160 + index * 115, 42, 100, 44), set_speed.bind(rate), transport)
		rate_button.name = "Speed%d" % rate
	button("Reset day", Rect2(510, 42, 142, 44), reset_clock, transport)
	_update_speed_buttons()
	label("WESTBROOK CAMPUS", Rect2(65, 228, 650, 38), 22)
	label("Click a system to inspect it", Rect2(975, 228, 460, 38), 21, MUTED)
	site = SiteMap.new()
	place(site, Rect2(45, 285, 1380, 620))
	site.object_selected.connect(select_object)
	inspector = panel(Rect2(1460, 235, 406, 800))
	show_inspector_empty()
	var events := panel(Rect2(55, 929, 370, 106))
	label("UPCOMING", Rect2(20, 9, 330, 28), 16, MUTED, events)
	label("12:30 · EV 01 departure", Rect2(20, 39, 330, 32), 22, INK, events)
	label("Preview event · no simulation", Rect2(20, 77, 330, 23), 15, MUTED, events)
	var performance := panel(Rect2(445, 929, 320, 106))
	label("SITE SNAPSHOT", Rect2(20, 9, 280, 28), 16, MUTED, performance)
	label("Self-supply  52 %", Rect2(20, 39, 280, 32), 24, GREEN, performance)
	fps_label = label("Demo metric  ·  60 FPS", Rect2(20, 77, 280, 23), 15, MUTED, performance)
	var assistant := panel(Rect2(785, 929, 640, 106), Color("#dae9e0"))
	label("OPTI  /  SITE GUIDE", Rect2(20, 9, 600, 28), 16, GREEN, assistant)
	assistant_message = paragraph("Try selecting the battery, then choose Charge, Hold or Discharge.", Rect2(20, 41, 600, 56), 22, INK, assistant)

func empty_inspector() -> void:
	for child in inspector.get_children():
		inspector.remove_child(child)
		child.queue_free()
	control_buttons.clear()

func show_inspector_empty() -> void:
	empty_inspector()
	label("SITE INSPECTOR", Rect2(28, 27, 350, 40), 17, MUTED, inspector)
	label("A connected\nworkplace.", Rect2(28, 110, 350, 145), 38, INK, inspector)
	paragraph("Select an object on the map to view readings and explore its controls.", Rect2(28, 290, 350, 120), 25, MUTED, inspector)
	paragraph("Solar · Building · HVAC\nBattery · Grid · Inverter\nEV bays 01, 02 and 03", Rect2(28, 457, 350, 130), 23, INK, inspector)
	paragraph("DEMO VALUES\nThe clock runs. Energy readings stay fixed in this prototype.", Rect2(28, 642, 350, 120), 20, MUTED, inspector)

func select_object(id: String) -> void:
	if not objects.has(id): return
	selected_id = id
	site.select(id)
	show_object_panel()
	assistant_message.text = "Selected %s. Explore its controls in the site inspector." % objects[id].name

func show_object_panel() -> void:
	empty_inspector()
	var data: Dictionary = objects[selected_id]
	label(data.type, Rect2(28, 28, 310, 40), 16, Color(data.color), inspector)
	button("×", Rect2(335, 23, 44, 44), close_inspector, inspector)
	label(data.name, Rect2(28, 87, 350, 65), 30, INK, inspector)
	paragraph(data.description, Rect2(28, 168, 350, 122), 21, MUTED, inspector)
	for index in range(data.values.size()):
		var entry: Array = data.values[index]
		var row := panel(Rect2(23, 305 + index * 61, 360, 54), Color("#edf2ed"), inspector)
		label(entry[0], Rect2(12, 4, 325, 22), 15, MUTED, row)
		label(entry[1], Rect2(12, 22, 325, 30), 23, INK, row)
	label("CONTROL INTENT", Rect2(28, 563, 350, 30), 16, MUTED, inspector)
	selection_mode = label("", Rect2(28, 598, 350, 34), 23, GREEN, inspector)
	var count: int = data.controls.size()
	var gap := 8.0
	var width := (350.0 - gap * (count - 1)) / count
	for index in range(count):
		var mode: String = data.controls[index]
		var item := button(mode, Rect2(28 + index * (width + gap), 652, width, 52), apply_control.bind(mode), inspector)
		item.add_theme_font_size_override("font_size", 16)
		for state in ["normal", "hover", "pressed", "focus"]:
			var compact := item.get_theme_stylebox(state).duplicate() as StyleBoxFlat
			compact.content_margin_left = 8
			compact.content_margin_right = 8
			item.add_theme_stylebox_override(state, compact)
		item.size = Vector2(width, 52)
		control_buttons[mode] = item
	feedback = paragraph("Demo controls change intent only.", Rect2(28, 722, 350, 65), 18, MUTED, inspector)
	_update_mode_buttons()

func apply_control(mode: String) -> void:
	if selected_id.is_empty(): return
	objects[selected_id].mode = mode
	_update_mode_buttons()
	feedback.text = "%s selected. Readings remain illustrative." % mode
	assistant_message.text = "%s: %s intent saved for this demo session." % [objects[selected_id].name, mode]

func _update_mode_buttons() -> void:
	var mode: String = objects[selected_id].mode
	selection_mode.text = "Setting: " + mode
	for key in control_buttons:
		var item: Button = control_buttons[key]
		var compact := panel_style(Color("#c5e1d4") if key == mode else Color("#e8efea"), 10)
		compact.content_margin_left = 8
		compact.content_margin_right = 8
		item.add_theme_stylebox_override("normal", compact)
		item.add_theme_color_override("font_color", GREEN if key == mode else INK)

func close_inspector() -> void:
	selected_id = ""
	site.select("")
	show_inspector_empty()
	assistant_message.text = "Select another system on the map to explore the site."

func toggle_pause() -> void:
	if day_finished: return
	paused = not paused
	pause_button.text = "Resume" if paused else "Pause"

func set_speed(rate: int) -> void:
	speed = rate
	_update_speed_buttons()

func _update_speed_buttons() -> void:
	for rate in [1, 5, 15]:
		var item: Button = ui.find_child("Speed%d" % rate, true, false)
		if item:
			item.add_theme_stylebox_override("normal", panel_style(Color("#c5e1d4") if speed == rate else Color("#e8efea"), 10))

func reset_clock() -> void:
	elapsed_minutes = 480.0
	paused = false
	day_finished = false
	pause_button.disabled = false
	pause_button.text = "Pause"
	_update_clock_text()
	assistant_message.text = "Office day reset to 08:00. Your equipment settings are retained."

func advance_clock(delta: float) -> void:
	if paused or day_finished: return
	elapsed_minutes = minf(elapsed_minutes + delta * speed, 1080.0)
	if elapsed_minutes >= 1080.0:
		day_finished = true
		paused = true
		if is_instance_valid(pause_button):
			pause_button.text = "Day ended"
			pause_button.disabled = true
		if is_instance_valid(assistant_message):
			assistant_message.text = "18:00 · Office day complete. Reset the clock to explore again."

func _update_clock_text() -> void:
	var minutes := int(elapsed_minutes)
	clock_label.text = "%02d:%02d" % [floori(float(minutes) / 60.0), minutes % 60]

func _process(delta: float) -> void:
	if screen != "game": return
	advance_clock(delta)
	hud_refresh += delta
	if hud_refresh >= 0.2:
		hud_refresh = 0.0
		_update_clock_text()
		fps_label.text = "Demo metric  ·  %d FPS live" % Engine.get_frames_per_second()

func _unhandled_key_input(event: InputEvent) -> void:
	if screen != "game" or not event is InputEventKey or not event.pressed or event.echo: return
	match event.keycode:
		KEY_SPACE: toggle_pause()
		KEY_1: set_speed(1)
		KEY_2: set_speed(5)
		KEY_3: set_speed(15)
		KEY_ESCAPE: close_inspector()
		KEY_F11:
			var mode := DisplayServer.window_get_mode()
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if mode == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
		_: return
	get_viewport().set_input_as_handled()
