extends CanvasLayer
## UI stays active while the world is paused. Containers adapt to viewport changes.
var game: Node3D
var menu: ColorRect
var status_label: Label
var balance: Label
var collect_button: Button
var badge: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var theme := Theme.new()
	theme.default_font_size = 20
	for kind in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("253952") if kind == "normal" else Color("3b5b78")
		style.set_corner_radius_all(12)
		style.content_margin_left = 18
		style.content_margin_right = 18
		style.content_margin_top = 12
		style.content_margin_bottom = 12
		theme.set_stylebox(kind, "Button", style)
	root.theme = theme
	var top := VBoxContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 24
	top.offset_right = -24
	top.offset_top = 20
	root.add_child(top)
	var row := HBoxContainer.new()
	top.add_child(row)
	var title := label("POCKET ROOMS", 26)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	row.add_child(button("☰ Menü", open_menu))
	balance = label("", 20)
	top.add_child(balance)
	status_label = label("", 18)
	top.add_child(status_label)
	var bottom := VBoxContainer.new()
	bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_left = 24
	bottom.offset_right = -24
	bottom.offset_top = -155
	bottom.offset_bottom = -20
	root.add_child(bottom)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.add_child(actions)
	actions.add_child(button("◈ Werkbank", game.go_to_station))
	actions.add_child(button("◇ Erkunden", game.explore))
	collect_button = button("✦ Abholen", game.collect)
	actions.add_child(collect_button)
	badge = label("●", 24)
	badge.add_theme_color_override("font_color", Color("ff526c"))
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	collect_button.add_child(badge)
	badge.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	badge.position += Vector2(-18, -8)
	var rotation := HBoxContainer.new()
	rotation.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.add_child(rotation)
	rotation.add_child(button("↶ 90°", func(): game.rotate_camera(-1)))
	rotation.add_child(button("90° ↷", func(): game.rotate_camera(1)))
	_build_menu(root)
	game.worker.speed = game.settings.get_value("game", "speed", 2.8)

func label(text: String, size: int) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", size)
	return node

func button(text: String, callback: Callable) -> Button:
	var node := Button.new()
	node.text = text
	node.custom_minimum_size.y = 52
	node.pressed.connect(callback)
	return node

func _build_menu(root: Control) -> void:
	menu = ColorRect.new()
	menu.color = Color("101b2c")
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(menu)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(center)
	var content := VBoxContainer.new()
	content.custom_minimum_size.x = 360
	content.add_theme_constant_override("separation", 16)
	center.add_child(content)
	content.add_child(label("Hauptmenü", 34))
	content.add_child(label("Die Spielwelt ist pausiert.", 18))
	var auto := CheckButton.new()
	auto.text = "Automatische Produktion"
	auto.button_pressed = game.automatic
	auto.toggled.connect(func(value: bool): game.automatic = value; game.save_settings())
	content.add_child(auto)
	content.add_child(label("Laufgeschwindigkeit", 20))
	var speed := HSlider.new()
	speed.min_value = 1
	speed.max_value = 5
	speed.step = 0.2
	speed.value = game.settings.get_value("game", "speed", 2.8)
	speed.custom_minimum_size.y = 48
	speed.value_changed.connect(func(value: float): game.worker.speed = value; game.save_settings())
	content.add_child(speed)
	content.add_child(button("Zurück zum Spiel", close_menu))
	content.add_child(label("Tippe auf den Boden oder die Werkbank.\nDesktop: Q / E drehen · Esc öffnet das Menü", 16))
	menu.hide()

func open_menu() -> void:
	menu.show()
	get_tree().paused = true

func close_menu() -> void:
	get_tree().paused = false
	menu.hide()

func _process(_delta: float) -> void:
	status_label.text = game.status
	balance.text = "✦ %d Münzen   ·   %d bereit zur Abholung" % [game.coins, game.pending]
	badge.visible = game.pending > 0
	collect_button.disabled = game.pending == 0

func _input(event: InputEvent) -> void:
	if menu.visible and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close_menu()
		get_viewport().set_input_as_handled()
