class_name GymScreen
extends Control

## The Alley Gym. Stats are not handed out by levelling any more — they are put
## on here, one small session at a time, paid for in a cat's energy and your
## money. Every point already trained makes the next one dearer and smaller.

var main: Main

var _bar_slot: MarginContainer
var _list: VBoxContainer
var _note: Label


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

	_note = UiKit.body_text("", 12, UiKit.GREEN)
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

	_list.add_child(UiKit.screen_header("The Alley Gym"))
	_list.add_child(UiKit.body_text(
		("A session costs %d energy. Energy comes back at dawn, so what a cat does "
		+ "today is what they do not do tonight.") % GameMan.TRAIN_ENERGY, 12, UiKit.DIM))

	for cid in GameMan.hired_cats():
		_list.add_child(_cat_panel(String(cid)))

	UiKit.allow_scroll_drag(self)


func _cat_panel(cat_id: String) -> PanelContainer:
	var d := GameData.cat_by_id(cat_id)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.panel_style())
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 4)
	p.add_child(vb)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	vb.add_child(head)
	head.add_child(UiKit.portrait(cat_id, 40))

	var who := VBoxContainer.new()
	who.add_theme_constant_override("separation", 1)
	who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(who)
	var n := UiKit.display_label(String(d["name"]), 14, UiKit.INK_GOLD)
	n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	who.add_child(n)
	who.add_child(UiKit.meter("ENERGY %d/%d" % [GameMan.energy(cat_id), GameMan.energy_max(cat_id)],
		float(GameMan.energy(cat_id)), float(GameMan.energy_max(cat_id)), UiKit.INK_GREEN, 62))

	var state := GameMan.cat_state(cat_id)
	if state == "wounded" or state == "jail":
		vb.add_child(UiKit.label(
			"Laid up — no training." if state == "wounded" else "Inside — no training.",
			12, UiKit.INK_RED))
		return p

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	vb.add_child(row)
	for r in WorldData.regimens():
		row.add_child(_regimen_cell(cat_id, r))

	if bool(GameMan.cats[cat_id].get("boosted", false)):
		vb.add_child(UiKit.body_text("Full of catnip — the next session counts double.", 11, UiKit.INK_GREEN))
	elif GameMan.stash_count("catnip_tin") > 0:
		var tin := UiKit.button("OPEN A TIN OF CATNIP")
		tin.add_theme_font_size_override("font_size", 11)
		tin.custom_minimum_size = Vector2(0, 24)
		tin.pressed.connect(func() -> void:
			_note.text = GameMan.use_item("catnip_tin", cat_id)
			refresh()
		)
		vb.add_child(tin)
	return p


## One column of the gym: what the regimen is, what it adds, what it costs.
func _regimen_cell(cat_id: String, regimen: Dictionary) -> VBoxContainer:
	var stat := String(regimen["stat"])
	var cell := VBoxContainer.new()
	cell.add_theme_constant_override("separation", 1)
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var cap := UiKit.caps_label(String(GameData.STAT_LABELS.get(stat, stat)), 11, UiKit.INK_DIM)
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cell.add_child(cap)

	var now := UiKit.label("%.1f" % GameMan.effective_stat(cat_id, stat), 14, UiKit.INK)
	now.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cell.add_child(now)

	var fee := GameMan.train_fee(cat_id, stat)
	var gain := GameMan.train_gain(cat_id, stat)
	if bool(GameMan.cats[cat_id].get("boosted", false)):
		gain *= 2.0

	var b := UiKit.button("+%.2f" % gain)
	b.add_theme_font_size_override("font_size", 12)
	b.custom_minimum_size = Vector2(0, 26)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.disabled = GameMan.treats < fee or GameMan.energy(cat_id) < GameMan.TRAIN_ENERGY
	b.pressed.connect(func() -> void:
		var line := GameMan.train_cat(cat_id, stat)
		if line != "":
			_note.text = line
		refresh()
	)
	cell.add_child(b)

	var cost := UiKit.label("%d T" % fee, 11, UiKit.INK_DIM)
	cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cell.add_child(cost)
	return cell
