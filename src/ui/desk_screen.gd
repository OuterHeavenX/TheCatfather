class_name DeskScreen
extends Control

## Morning phase: tariffs, crew payouts, and the way out to the streets.

var main: Main

var _root: VBoxContainer
var _bar_slot: MarginContainer
var _body: VBoxContainer
var _footer: VBoxContainer


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	_root = VBoxContainer.new()
	_root.add_theme_constant_override("separation", 6)
	margin.add_child(_root)

	_bar_slot = MarginContainer.new()
	_root.add_child(_bar_slot)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_root.add_child(scroll)

	_body = VBoxContainer.new()
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 6)
	scroll.add_child(_body)

	# Pinned to the bottom of the screen, so a tall portrait window reads as
	# laid out rather than as content stranded at the top.
	_footer = VBoxContainer.new()
	_footer.add_theme_constant_override("separation", 6)
	_root.add_child(_footer)


func refresh() -> void:
	for ch in _bar_slot.get_children():
		ch.queue_free()
	_bar_slot.add_child(UiKit.status_bar())
	for ch in _body.get_children():
		ch.queue_free()

	_body.add_child(UiKit.screen_header("Speakeasy Desk"))

	_body.add_child(_tariff_panel())
	_body.add_child(_payroll_panel())
	if not GameMan.stash.is_empty():
		var stash_panel := _stash_panel()
		if stash_panel != null:
			_body.add_child(stash_panel)

	for ch in _footer.get_children():
		ch.queue_free()

	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 6)
	_footer.add_child(nav)

	var crew := UiKit.button("CREW")
	crew.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	crew.pressed.connect(func() -> void: main.show_screen("crew"))
	nav.add_child(crew)

	var rec := UiKit.button("RECRUIT")
	rec.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rec.pressed.connect(func() -> void: main.show_screen("recruit"))
	nav.add_child(rec)

	var go := UiKit.gold_button("SEND THE CREW OUT >")
	go.custom_minimum_size = Vector2(0, 36)
	go.pressed.connect(func() -> void: main.show_screen("ops"))
	_footer.add_child(go)

	UiKit.allow_scroll_drag(self)


func _panel(title: String) -> Array:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.panel_style())
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 3)
	p.add_child(vb)
	vb.add_child(UiKit.label(title, 14, UiKit.INK_GOLD))
	return [p, vb]


func _tariff_panel() -> PanelContainer:
	var parts := _panel("TARIFFS ON GOODS THROUGH YOUR TURF")
	var p: PanelContainer = parts[0]
	var vb: VBoxContainer = parts[1]

	for g in WorldData.goods():
		var gid := String(g["id"])
		var level := int(GameMan.tariffs[gid])
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		vb.add_child(row)

		var names := VBoxContainer.new()
		names.add_theme_constant_override("separation", 0)
		names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(names)
		names.add_child(UiKit.label(String(g["name"]), 13, UiKit.INK))
		names.add_child(UiKit.label(String(g["blurb"]), 11, UiKit.INK_DIM))

		var b := UiKit.button(WorldData.TARIFF_LABELS[level])
		b.custom_minimum_size = Vector2(78, 28)
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		b.pressed.connect(func() -> void:
			GameMan.cycle_tariff(gid)
			refresh()
		)
		row.add_child(b)

	var gain := GameMan.daily_tension_gain()
	var warn: Color = UiKit.INK_GREEN if gain < 5.0 else (UiKit.INK_GOLD if gain < 10.0 else UiKit.INK_RED)
	vb.add_child(UiKit.label("Take +%d%% on every job  ·  war tension +%.0f a night"
		% [int((GameMan.tariff_multiplier() - 1.0) * 100.0), gain], 12, warn))
	return p


func _payroll_panel() -> PanelContainer:
	var parts := _panel("THE CREW'S CUT")
	var p: PanelContainer = parts[0]
	var vb: VBoxContainer = parts[1]

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	vb.add_child(row)

	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 0)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	info.add_child(UiKit.label("Tonight's payroll: %d T" % GameMan.nightly_payout(), 13, UiKit.INK))
	info.add_child(UiKit.label("Police bribes: %d T  (heat %d)"
		% [GameMan.nightly_bribes(), int(GameMan.heat)], 11, UiKit.INK_DIM))

	var b := UiKit.button(WorldData.PAYOUT_LABELS[GameMan.payout_level])
	b.custom_minimum_size = Vector2(100, 28)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.pressed.connect(func() -> void:
		GameMan.cycle_payout()
		refresh()
	)
	row.add_child(b)

	var loyal: int = WorldData.PAYOUT_LOYALTY[GameMan.payout_level]
	var col: Color = UiKit.INK_GREEN if loyal > 0 else UiKit.INK_RED
	vb.add_child(UiKit.label("Loyalty %+d a night. At zero loyalty, a cat walks." % loyal, 12, col))
	return p


func _stash_panel() -> PanelContainer:
	var parts := _panel("THE STASH")
	var p: PanelContainer = parts[0]
	var vb: VBoxContainer = parts[1]
	var any := false
	for item in WorldData.items():
		var iid := String(item["id"])
		var n := GameMan.stash_count(iid)
		if n <= 0:
			continue
		any = true
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		vb.add_child(row)
		var info := VBoxContainer.new()
		info.add_theme_constant_override("separation", 0)
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info)
		info.add_child(UiKit.label("%s x%d" % [String(item["name"]), n], 13, UiKit.INK))
		info.add_child(UiKit.label(String(item["desc"]), 11, UiKit.INK_DIM))
		if String(item["kind"]) == "use" and String(item["stat"]) != "heal":
			var ub := UiKit.button("USE")
			ub.custom_minimum_size = Vector2(62, 26)
			ub.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			ub.pressed.connect(func() -> void:
				GameMan.use_item(iid)
				refresh()
			)
			row.add_child(ub)
		else:
			var l := UiKit.label("in CREW", 11, UiKit.INK_DIM)
			l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			row.add_child(l)
	if not any:
		p.queue_free()
		return null
	return p
