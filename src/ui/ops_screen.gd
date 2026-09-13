class_name OpsScreen
extends Control

## Day phase: put cats on venues as collections or shakedowns, then run the day.

var main: Main

var _picking_venue: String = ""
var _picking_op: String = ""

var _bar_slot: MarginContainer
var _body: VBoxContainer
var _footer: HBoxContainer


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	margin.add_child(vb)

	_bar_slot = MarginContainer.new()
	vb.add_child(_bar_slot)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vb.add_child(scroll)

	_body = VBoxContainer.new()
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 6)
	scroll.add_child(_body)

	_footer = HBoxContainer.new()
	_footer.add_theme_constant_override("separation", 6)
	vb.add_child(_footer)


func refresh() -> void:
	for ch in _bar_slot.get_children():
		ch.queue_free()
	_bar_slot.add_child(UiKit.status_bar())
	for ch in _body.get_children():
		ch.queue_free()
	for ch in _footer.get_children():
		ch.queue_free()

	if _picking_venue != "":
		_render_picker()
	else:
		_render_venues()

	UiKit.allow_scroll_drag(self)


# ---------------------------------------------------------------- venue list

func _render_venues() -> void:
	_body.add_child(UiKit.screen_header("Today's Jobs"))
	for v in WorldData.venues():
		_body.add_child(_venue_panel(v))

	var back := UiKit.button("< DESK")
	back.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back.pressed.connect(func() -> void: main.show_screen("desk"))
	_footer.add_child(back)

	var run := UiKit.gold_button("SEND THE BOYS OUT")
	run.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	run.custom_minimum_size = Vector2(0, 36)
	run.pressed.connect(_run_day)
	_footer.add_child(run)


func _venue_panel(v: Dictionary) -> PanelContainer:
	var vid := String(v["id"])
	var unlocked := GameMan.venue_unlocked(vid)
	var state: Dictionary = GameMan.venues[vid]
	var crew := GameMan.assigned_to(vid)
	var op := GameMan.venue_op(vid)

	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.panel_style())
	var outer := HBoxContainer.new()
	outer.add_theme_constant_override("separation", 10)
	p.add_child(outer)

	# trade sign
	var sign := TextureRect.new()
	sign.texture = load(WorldData.venue_icon(vid))
	sign.custom_minimum_size = Vector2(46, 46)
	sign.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sign.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sign.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	if not unlocked:
		sign.modulate = Color(1, 1, 1, 0.30)
	outer.add_child(sign)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 3)
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_child(vb)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 6)
	vb.add_child(head)
	var name_l := UiKit.display_label(String(v["name"]), 15, UiKit.INK_GOLD if unlocked else UiKit.INK_DIM)
	name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(name_l)
	if bool(state["controlled"]):
		head.add_child(UiKit.caps_label("HELD", 12, UiKit.INK_GREEN))

	if not unlocked:
		vb.add_child(UiKit.label("Locked — needs %d respect." % int(v["req_respect"]), 12, UiKit.INK_DIM))
		return p

	vb.add_child(UiKit.body_text(String(v["perk"]), 11, UiKit.INK_BLUE))
	vb.add_child(UiKit.meter("UNREST", float(state["unrest"]), WorldData.MAX_UNREST, UiKit.OXBLOOD, 84))

	# one row per job type: yield range, risk diamonds, and the send button
	for op_id in [WorldData.OP_COLLECT, WorldData.OP_SHAKEDOWN]:
		vb.add_child(_job_row(v, op_id, op))

	var loot := WorldData.item_by_id(String(v["loot"]))
	if not loot.is_empty():
		var lb := UiKit.label("Shakedown loot: %s — %s" % [String(loot["name"]), String(loot["desc"])], 10, UiKit.INK_DIM)
		lb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vb.add_child(lb)

	if not crew.is_empty():
		var crew_row := HBoxContainer.new()
		crew_row.add_theme_constant_override("separation", 4)
		vb.add_child(crew_row)
		crew_row.add_child(UiKit.caps_label(WorldData.op_label(op), 12, UiKit.INK_GOLD))
		for cid in crew:
			var b := Button.new()
			for st in ["normal", "hover", "pressed", "focus"]:
				b.add_theme_stylebox_override(st, StyleBoxEmpty.new())
			b.tooltip_text = "Pull off the job"
			b.custom_minimum_size = Vector2(30, 30)
			b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			var pic := UiKit.portrait(String(cid), 28)
			pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
			b.add_child(pic)
			b.pressed.connect(func() -> void:
				GameMan.clear_assignment(String(cid))
				refresh()
			)
			crew_row.add_child(b)
		var odds := GameMan.preview_chance(vid, op, crew)
		var col: Color = UiKit.INK_GREEN if odds >= 0.7 else (UiKit.INK_GOLD if odds >= 0.45 else UiKit.INK_RED)
		crew_row.add_child(UiKit.label("%d%% odds" % int(round(odds * 100.0)), 13, col))
	return p


## A single job line: COLLECTION / SHAKEDOWN with its take and its danger.
func _job_row(v: Dictionary, op_id: String, current_op: String) -> HBoxContainer:
	var vid := String(v["id"])
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var label_box := VBoxContainer.new()
	label_box.add_theme_constant_override("separation", 0)
	label_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label_box)
	label_box.add_child(UiKit.caps_label(WorldData.op_label(op_id), 12, UiKit.INK))

	var r := GameMan.yield_range(vid, op_id)
	var bonus := 0.10 if op_id == WorldData.OP_SHAKEDOWN else 0.0
	var stats := UiKit.label("%d–%d T   %s" % [r.x, r.y, WorldData.risk_text(float(v["risk"]), bonus)], 11, UiKit.INK_DIM)
	label_box.add_child(stats)

	var b := UiKit.button("SEND")
	b.add_theme_font_size_override("font_size", 12)
	b.custom_minimum_size = Vector2(62, 28)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.disabled = current_op != "" and current_op != op_id
	b.pressed.connect(func() -> void:
		_picking_venue = vid
		_picking_op = op_id
		refresh()
	)
	row.add_child(b)
	return row


# ---------------------------------------------------------------- crew picker

func _render_picker() -> void:
	var v := WorldData.venue_by_id(_picking_venue)
	_body.add_child(UiKit.screen_header("%s — %s" % [String(v["name"]), WorldData.op_label(_picking_op)]))
	var stat: String = String(v["collect_stat"]) if _picking_op == WorldData.OP_COLLECT else String(v["shake_stat"])
	_body.add_child(UiKit.label("Job tests %s. Pick who goes." % GameData.STAT_LABELS.get(stat, stat), 12, UiKit.DIM))

	var free: Array = []
	for cid in GameMan.hired_cats():
		if GameMan.cat_state(cid) == "ready":
			free.append(cid)

	if free.is_empty():
		_body.add_child(UiKit.label("Nobody left to send. Everyone is out or licking wounds.", 13, UiKit.DIM))

	for cid in free:
		_body.add_child(_pick_row(String(cid), stat))

	var back := UiKit.button("< BLOCKS")
	back.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back.pressed.connect(func() -> void:
		_picking_venue = ""
		_picking_op = ""
		refresh()
	)
	_footer.add_child(back)


func _pick_row(cat_id: String, stat: String) -> PanelContainer:
	var d := GameData.cat_by_id(cat_id)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.panel_style())
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 8)
	p.add_child(hb)

	hb.add_child(UiKit.portrait(cat_id, 44))

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 1)
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(vb)
	vb.add_child(UiKit.label(String(d["name"]), 14, UiKit.INK_GOLD))
	vb.add_child(UiKit.label("LV %d  ·  %s %.1f"
		% [int(GameMan.cats[cat_id]["level"]), GameData.STAT_LABELS.get(stat, stat),
			GameMan.effective_stat(cat_id, stat)], 12, UiKit.INK))
	var trait_key := String(d.get("trait", ""))
	if trait_key != "":
		vb.add_child(UiKit.body_text(GameData.trait_name(trait_key), 11, UiKit.INK_BLUE))

	var b := UiKit.gold_button("SEND")
	b.custom_minimum_size = Vector2(74, 40)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.pressed.connect(func() -> void:
		GameMan.assign_cat(cat_id, _picking_venue, _picking_op)
		_picking_venue = ""
		_picking_op = ""
		refresh()
	)
	hb.add_child(b)
	return p


func _run_day() -> void:
	GameMan.end_day()
	main.show_screen("ledger")
