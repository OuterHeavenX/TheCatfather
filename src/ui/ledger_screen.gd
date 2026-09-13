class_name LedgerScreen
extends Control

## Night phase: what the day earned, what it cost, and who hit back.

var main: Main

var _bar_slot: MarginContainer
var _body: VBoxContainer


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
	_body.add_theme_constant_override("separation", 5)
	scroll.add_child(_body)

	var next := UiKit.gold_button("NEXT DAY >")
	next.custom_minimum_size = Vector2(0, 36)
	next.pressed.connect(_next_day)
	vb.add_child(next)


func refresh() -> void:
	for ch in _bar_slot.get_children():
		ch.queue_free()
	_bar_slot.add_child(UiKit.status_bar())
	for ch in _body.get_children():
		ch.queue_free()

	var r := GameMan.last_report
	if r.is_empty():
		_body.add_child(UiKit.label("Nothing on the books yet.", 14, UiKit.DIM))
		return

	_body.add_child(UiKit.label("NIGHT — THE LEDGER, DAY %d" % int(r["day"]), 15, UiKit.GOLD))

	var ops: Array = r["ops"]
	if ops.is_empty():
		_body.add_child(UiKit.label("You sent nobody out. The blocks noticed.", 13, UiKit.DIM))
	for o in ops:
		_body.add_child(_op_panel(o))

	_body.add_child(_money_panel(r))

	if not (r["loot"] as Array).is_empty():
		var names: Array = []
		for iid in r["loot"]:
			names.append(String(WorldData.item_by_id(String(iid))["name"]))
		_body.add_child(UiKit.body_text("Taken: " + ", ".join(names), 12, UiKit.BLUE))

	for cid in r["levelled"]:
		_body.add_child(UiKit.body_text("%s is moving up — now level %d."
			% [String(GameData.cat_by_id(String(cid))["name"]), int(GameMan.cats[String(cid)]["level"])], 12, UiKit.GREEN))

	for cid in r["injuries"]:
		_body.add_child(UiKit.body_text("%s got hurt and is out for a couple of days."
			% String(GameData.cat_by_id(String(cid))["name"]), 12, UiKit.ORANGE))

	if bool(r["unpaid"]):
		_body.add_child(UiKit.body_text("You could not make payroll. Nobody says anything. Everybody remembers.", 13, UiKit.RED))

	for cid in r["defected"]:
		_body.add_child(UiKit.body_text("%s walked. Cleared out their locker and everything in it."
			% String(GameData.cat_by_id(String(cid))["name"]), 13, UiKit.RED))

	if String(r["rival"]) != "":
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", UiKit.panel_style())
		var pv := VBoxContainer.new()
		pv.add_theme_constant_override("separation", 2)
		panel.add_child(pv)
		pv.add_child(UiKit.label("THE ALLEY SYNDICATE ANSWERS", 13, UiKit.RED))
		pv.add_child(UiKit.body_text(String(r["rival"]), 12, UiKit.CREAM))
		_body.add_child(panel)


func _op_panel(o: Dictionary) -> PanelContainer:
	var v := WorldData.venue_by_id(String(o["venue"]))
	var success := bool(o["success"])
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.panel_style())
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	p.add_child(vb)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 6)
	vb.add_child(head)
	var l := UiKit.label("%s — %s" % [String(v["name"]), WorldData.op_label(String(o["op"]))], 13, UiKit.GOLD)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(l)
	head.add_child(UiKit.label("CLEAN" if success else "BOTCHED", 13, UiKit.GREEN if success else UiKit.RED))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	vb.add_child(row)
	for cid in o["crew"]:
		row.add_child(UiKit.portrait(String(cid), 26))
	var odds := UiKit.label("%d%% odds" % int(round(float(o["chance"]) * 100.0)), 11, UiKit.DIM)
	odds.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	odds.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(odds)
	row.add_child(UiKit.label("+%d T" % int(o["take"]), 14, UiKit.GOLD))
	return p


func _money_panel(r: Dictionary) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.panel_style())
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 1)
	p.add_child(vb)

	vb.add_child(_line("Job takings", int(r["takings"]), UiKit.CREAM))
	vb.add_child(_line("Protection money", int(r["protection"]), UiKit.CREAM))
	vb.add_child(_line("Crew payroll", -int(r["payout"]), UiKit.CREAM))
	vb.add_child(_line("Police bribes", -int(r["bribes"]), UiKit.CREAM))
	vb.add_child(UiKit.hsep())
	var net := int(r["net"])
	vb.add_child(_line("NET", net, UiKit.GREEN if net >= 0 else UiKit.RED))
	if int(r["respect_gain"]) > 0:
		vb.add_child(UiKit.label("Respect +%d — %s" % [int(r["respect_gain"]), GameData.rank_name(GameMan.respect)], 12, UiKit.BLUE))
	return p


func _line(text: String, amount: int, color: Color) -> HBoxContainer:
	var hb := HBoxContainer.new()
	var l := UiKit.label(text, 13, UiKit.DIM)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(l)
	hb.add_child(UiKit.label("%+d T" % amount, 13, color))
	return hb


func _next_day() -> void:
	if not GameMan.pending_beat().is_empty():
		main.show_screen("story")
		return
	main.show_screen("desk")
