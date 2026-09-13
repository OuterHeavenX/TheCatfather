class_name RacketScreen
extends Control

## The Racket: solo jobs that resolve the instant you commit them. Paid for in
## nerve — which is yours and comes back overnight — and in the energy of the
## one cat you send. Running the same job over and over is what makes it safe,
## and banked experience in a tier is the only thing that opens the tier above.

var main: Main

var _picked: String = ""

var _bar_slot: MarginContainer
var _note: Label
var _list: VBoxContainer


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

	_note = UiKit.body_text("", 12, UiKit.GOLD)
	vb.add_child(_note)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vb.add_child(scroll)

	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_list)

	var back := UiKit.button("< DESK")
	back.custom_minimum_size = Vector2(0, 32)
	back.pressed.connect(func() -> void: main.show_screen("desk"))
	vb.add_child(back)


func refresh() -> void:
	for ch in _bar_slot.get_children():
		ch.queue_free()
	_bar_slot.add_child(UiKit.status_bar())
	for ch in _list.get_children():
		ch.queue_free()

	if _picked == "" or not GameMan.is_cat_available(_picked):
		_picked = _first_available()

	_list.add_child(UiKit.screen_header("The Racket"))
	_list.add_child(_nerve_panel())

	var jailed := _jailed()
	if not jailed.is_empty():
		_list.add_child(_jail_panel(jailed))

	_list.add_child(_crew_picker())

	for tier in CrimeData.TIER_NAMES.size():
		_list.add_child(_tier_header(tier))
		for c in CrimeData.crimes_in_tier(tier):
			_list.add_child(_crime_row(c))

	UiKit.allow_scroll_drag(self)


func _first_available() -> String:
	for cid in GameMan.hired_cats():
		if GameMan.is_cat_available(String(cid)):
			return String(cid)
	return ""


func _jailed() -> Array:
	var out: Array = []
	for cid in GameMan.hired_cats():
		if GameMan.cat_state(String(cid)) == "jail":
			out.append(String(cid))
	return out


func _nerve_panel() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.panel_style())
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	p.add_child(vb)
	vb.add_child(UiKit.meter("NERVE %d/%d" % [GameMan.nerve, GameMan.nerve_max()],
		float(GameMan.nerve), float(GameMan.nerve_max()), UiKit.INK_GOLD, 90))
	vb.add_child(UiKit.body_text("Comes back at +%d a night. Nothing else refills it."
		% GameMan.nerve_regen(), 11, UiKit.INK_DIM))
	return p


func _jail_panel(jailed: Array) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.danger_panel_style())
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 3)
	p.add_child(vb)
	vb.add_child(UiKit.caps_label("HELD AT THE PRECINCT", 13, UiKit.OXBLOOD))
	for cid in jailed:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		vb.add_child(row)
		var l := UiKit.label("%s — %d days"
			% [String(GameData.cat_by_id(String(cid))["name"]),
				int(GameMan.cats[String(cid)]["jail_days"])], 12, UiKit.INK)
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(l)
		var cost := GameMan.bail_cost(String(cid))
		var b := UiKit.button("BAIL %d T" % cost)
		b.add_theme_font_size_override("font_size", 11)
		b.custom_minimum_size = Vector2(0, 24)
		b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		b.disabled = GameMan.treats < cost
		b.pressed.connect(func() -> void:
			if GameMan.post_bail(String(cid)):
				_note.text = "%s walked out the front door." % String(GameData.cat_by_id(String(cid))["name"])
			refresh()
		)
		row.add_child(b)
	return p


## Who is pulling the job. Nerve is yours; the legwork is theirs.
func _crew_picker() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.panel_style())
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 3)
	p.add_child(vb)
	vb.add_child(UiKit.caps_label("WHO GOES", 12, UiKit.INK_DIM))

	# A full crew is two dozen portraits; they wrap rather than push the screen
	# wider than a phone.
	var row := HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 4)
	row.add_theme_constant_override("v_separation", 3)
	vb.add_child(row)

	var any := false
	for cid0 in GameMan.hired_cats():
		var cid := String(cid0)
		if not GameMan.is_cat_available(cid):
			continue
		any = true
		var b := Button.new()
		for st in ["normal", "hover", "pressed", "focus"]:
			b.add_theme_stylebox_override(st, StyleBoxEmpty.new())
		b.custom_minimum_size = Vector2(36, 36)
		b.tooltip_text = String(GameData.cat_by_id(cid)["name"])
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var pic := UiKit.portrait(cid, 34)
		pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if cid != _picked:
			pic.modulate = Color(1, 1, 1, 0.42)
		b.add_child(pic)
		b.pressed.connect(func() -> void:
			_picked = cid
			refresh()
		)
		row.add_child(b)

	if not any:
		vb.add_child(UiKit.label("Nobody is fit to go out.", 12, UiKit.INK_RED))
		return p

	vb.add_child(UiKit.label("%s  ·  energy %d/%d"
		% [String(GameData.cat_by_id(_picked)["name"]),
			GameMan.energy(_picked), GameMan.energy_max(_picked)], 12, UiKit.INK))
	return p


func _tier_header(tier: int) -> PanelContainer:
	var open: bool = tier == 0 or GameMan.tier_xp(tier - 1) >= int(CrimeData.TIER_REQ[tier])
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.wood_style(8, 4))
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 6)
	p.add_child(hb)
	var l := UiKit.caps_label(CrimeData.tier_name(tier), 13, UiKit.GOLD if open else UiKit.DIM)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(l)
	if open:
		hb.add_child(UiKit.label("%d exp" % GameMan.tier_xp(tier), 11, UiKit.DIM))
	else:
		hb.add_child(UiKit.label("%d / %d exp"
			% [GameMan.tier_xp(tier - 1), CrimeData.TIER_REQ[tier]], 11, UiKit.RED))
	return p


func _crime_row(c: Dictionary) -> PanelContainer:
	var cid := String(c["id"])
	var unlocked := GameMan.crime_unlocked(cid)

	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.panel_style())
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	p.add_child(vb)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 6)
	vb.add_child(head)
	var n := UiKit.display_label(String(c["name"]), 14, UiKit.INK_GOLD if unlocked else UiKit.INK_DIM)
	n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(n)
	var runs := GameMan.crime_runs(cid)
	if runs > 0:
		head.add_child(UiKit.label("x%d" % runs, 12, UiKit.INK_DIM))

	if not unlocked:
		vb.add_child(UiKit.body_text("Word has not got around to you yet.", 11, UiKit.INK_DIM))
		return p

	vb.add_child(UiKit.body_text(String(c["desc"]), 11, UiKit.INK_BLUE))

	var pay := GameMan.crime_pay_range(cid)
	var costs := HBoxContainer.new()
	costs.add_theme_constant_override("separation", 8)
	vb.add_child(costs)
	costs.add_child(UiKit.label("%d–%d T" % [pay.x, pay.y], 11, UiKit.INK))
	costs.add_child(UiKit.label("%d nerve" % int(c["nerve"]), 11, UiKit.INK_DIM))
	costs.add_child(UiKit.label("%d energy" % int(c["energy"]), 11, UiKit.INK_DIM))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	vb.add_child(row)

	var odds_box := VBoxContainer.new()
	odds_box.add_theme_constant_override("separation", 0)
	odds_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(odds_box)
	if _picked == "":
		odds_box.add_child(UiKit.label("No one to send.", 12, UiKit.INK_RED))
	else:
		var odds := GameMan.crime_chance(_picked, cid)
		var col: Color = UiKit.INK_GREEN if odds >= 0.7 else (UiKit.INK_GOLD if odds >= 0.45 else UiKit.INK_RED)
		odds_box.add_child(UiKit.label("%d%% odds" % int(round(odds * 100.0)), 13, col))
		var jail_pips := clampi(int(round(float(c["jail"]) * 14.0)), 1, 5)
		var pip_row := HBoxContainer.new()
		pip_row.add_theme_constant_override("separation", 4)
		pip_row.add_child(UiKit.label("PINCH", 10, UiKit.INK_DIM))
		pip_row.add_child(UiKit.risk_pips(jail_pips))
		odds_box.add_child(pip_row)

	var b := UiKit.gold_button("PULL IT")
	b.add_theme_font_size_override("font_size", 12)
	b.custom_minimum_size = Vector2(76, 30)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	b.disabled = _picked == "" or not GameMan.can_commit(_picked, cid)
	b.pressed.connect(func() -> void: _pull(cid))
	row.add_child(b)
	return p


func _pull(crime_id: String) -> void:
	var who := _picked
	var out := GameMan.commit_crime(who, crime_id)
	if out.is_empty():
		return
	var name_str := String(GameData.cat_by_id(who)["name"])
	var text := "%s — %s" % [name_str, String(out["text"])]
	if int(out["jailed"]) > 0:
		text += " Picked up. %d days inside." % int(out["jailed"])
	if bool(out["levelled"]):
		text += " Moved up a level."
	_note.text = text
	_note.add_theme_color_override("font_color", UiKit.GOLD if bool(out["success"]) else UiKit.RED)
	refresh()
