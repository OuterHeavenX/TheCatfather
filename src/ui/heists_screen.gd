class_name HeistsScreen
extends Control

var main: Main

var _active_box: VBoxContainer
var _board_box: VBoxContainer
var _treats_label: Label
var _timer: Timer

# detail overlay
var _detail: Control
var _detail_heist: String = ""
var _selected: Array = []
var _detail_grid: GridContainer
var _detail_odds: Label
var _detail_start: Button

# resolve modal
var _modal: Control
var _showing_modal := false


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	add_child(margin)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	margin.add_child(vb)

	var top := HBoxContainer.new()
	vb.add_child(top)
	var back := UiKit.back_button()
	back.pressed.connect(func() -> void: main.show_screen("office"))
	top.add_child(back)
	var title := UiKit.label("HEISTS", 22, UiKit.GOLD)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(title)
	_treats_label = UiKit.label("", 18, UiKit.GOLD)
	_treats_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(_treats_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)

	content.add_child(UiKit.label("IN PROGRESS", 16, UiKit.ORANGE))
	_active_box = VBoxContainer.new()
	_active_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_active_box.add_theme_constant_override("separation", 6)
	content.add_child(_active_box)

	content.add_child(UiKit.hsep())
	content.add_child(UiKit.label("JOB BOARD", 16, UiKit.ORANGE))
	_board_box = VBoxContainer.new()
	_board_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_board_box.add_theme_constant_override("separation", 8)
	content.add_child(_board_box)

	_build_detail()
	_build_modal()

	_timer = Timer.new()
	_timer.wait_time = 0.5
	_timer.timeout.connect(refresh)
	add_child(_timer)
	_timer.start()


func refresh() -> void:
	_treats_label.text = "%d T" % GameMan.treats
	_rebuild_active()
	_rebuild_board()
	if not _showing_modal and not GameMan.pending_results.is_empty():
		_show_result(GameMan.pop_result())


# ---------------------------------------------------------------- active

func _rebuild_active() -> void:
	for ch in _active_box.get_children():
		ch.queue_free()
	if GameMan.active_heists.is_empty():
		_active_box.add_child(UiKit.label("No crews out. Pick a job below.", 14, UiKit.DIM))
		return
	for h in GameMan.active_heists:
		_active_box.add_child(_active_row(h))


func _active_row(h: Dictionary) -> PanelContainer:
	var hd := GameData.heist_by_id(String(h["heist_id"]))
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.panel_style())
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 4)
	p.add_child(vb)

	var top := HBoxContainer.new()
	vb.add_child(top)
	top.add_child(UiKit.label(String(hd["name"]), 17, UiKit.GOLD))
	var names: Array = []
	for cid in h["cat_ids"]:
		names.append(String(GameData.cat_by_id(String(cid))["name"]))
	var crew_l := UiKit.label("  —  " + ", ".join(names), 13, UiKit.DIM)
	crew_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(crew_l)

	var remaining: float = maxf(0.0, float(h["ends_at"]) - GameMan.now())
	var frac: float = 1.0 - remaining / float(h["duration"])
	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 1
	bar.value = clampf(frac, 0.0, 1.0)
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 14)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.10, 0.08, 0.13)
	bg.set_corner_radius_all(4)
	var fill := StyleBoxFlat.new()
	fill.bg_color = UiKit.ORANGE
	fill.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)
	vb.add_child(bar)

	var cd := UiKit.label(UiKit.fmt_time(remaining) + " left", 13, UiKit.ORANGE)
	cd.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vb.add_child(cd)
	return p


# ---------------------------------------------------------------- job board

func _rebuild_board() -> void:
	for ch in _board_box.get_children():
		ch.queue_free()
	for hd in GameData.heists():
		_board_box.add_child(_board_row(hd))


func _board_row(hd: Dictionary) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.panel_style())
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 4)
	p.add_child(vb)

	var top := HBoxContainer.new()
	vb.add_child(top)
	var name_l := UiKit.label(String(hd["name"]), 18, UiKit.GOLD)
	name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(name_l)
	var locked := GameMan.heist_locked(String(hd["id"]))
	if locked:
		top.add_child(UiKit.label("NEEDS %d RESPECT" % int(hd["req_respect"]), 13, UiKit.RED))

	var desc := UiKit.label(String(hd["desc"]), 13, UiKit.DIM)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(desc)

	var meta := HBoxContainer.new()
	meta.add_theme_constant_override("separation", 12)
	vb.add_child(meta)
	meta.add_child(UiKit.label(String(GameData.STAT_LABELS[String(hd["stat"])]), 13, UiKit.BLUE))
	meta.add_child(UiKit.label("DIFF %d" % int(hd["difficulty"]), 13, UiKit.DIM))
	meta.add_child(UiKit.label("Crew %d-%d" % [int(hd["min_cats"]), int(hd["max_cats"])], 13, UiKit.DIM))
	meta.add_child(UiKit.label(UiKit.fmt_time(float(hd["duration"])), 13, UiKit.DIM))
	meta.add_child(UiKit.label("+%dT  +%dR" % [int(hd["reward_t"]), int(hd["reward_r"])], 13, UiKit.GREEN))
	meta.add_child(UiKit.label("Risk %d%%" % int(float(hd["injury"]) * 100.0), 13, UiKit.RED))

	var plan := UiKit.gold_button("PLAN")
	plan.custom_minimum_size = Vector2(90, 40)
	plan.disabled = locked
	var hid := String(hd["id"])
	plan.pressed.connect(func() -> void: _open_detail(hid))
	meta.add_child(plan)
	return p


# ---------------------------------------------------------------- detail overlay

func _build_detail() -> void:
	_detail = Control.new()
	_detail.set_anchors_preset(Control.PRESET_FULL_RECT)
	_detail.visible = false
	add_child(_detail)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_detail.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_detail.add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiKit.panel_style())
	panel.custom_minimum_size = Vector2(560, 0)
	center.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	panel.add_child(vb)
	_detail_vbox = vb


var _detail_vbox: VBoxContainer


func _open_detail(heist_id: String) -> void:
	_detail_heist = heist_id
	_selected.clear()
	for ch in _detail_vbox.get_children():
		ch.queue_free()

	var hd := GameData.heist_by_id(heist_id)
	_detail_vbox.add_child(UiKit.title_label(String(hd["name"]), 26))
	var desc := UiKit.label(String(hd["desc"]), 14, UiKit.DIM)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_vbox.add_child(desc)

	var meta := UiKit.label(
		"%s   •   DIFF %d   •   %s   •   +%dT +%dR   •   Risk %d%%" % [
			String(GameData.STAT_LABELS[String(hd["stat"])]),
			int(hd["difficulty"]),
			UiKit.fmt_time(float(hd["duration"])),
			int(hd["reward_t"]), int(hd["reward_r"]),
			int(float(hd["injury"]) * 100.0),
		], 14, UiKit.CREAM)
	meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_vbox.add_child(meta)
	_detail_vbox.add_child(UiKit.hsep())

	_detail_vbox.add_child(UiKit.label("PICK YOUR CREW (%d–%d):" % [int(hd["min_cats"]), int(hd["max_cats"])], 15, UiKit.ORANGE))

	_detail_grid = GridContainer.new()
	_detail_grid.columns = 3
	_detail_grid.add_theme_constant_override("h_separation", 8)
	_detail_grid.add_theme_constant_override("v_separation", 8)
	_detail_vbox.add_child(_detail_grid)

	var avail: Array = []
	for cid in GameMan.hired_cats():
		if GameMan.is_cat_available(cid):
			avail.append(cid)
	if avail.is_empty():
		_detail_grid.add_child(UiKit.label("No cats available — crews are out or licking wounds.", 14, UiKit.RED))
	for cid in avail:
		_detail_grid.add_child(_crew_toggle(cid))

	_detail_odds = UiKit.label("", 15, UiKit.GOLD)
	_detail_odds.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_vbox.add_child(_detail_odds)

	var btns := HBoxContainer.new()
	btns.alignment = BoxContainer.ALIGNMENT_CENTER
	btns.add_theme_constant_override("separation", 12)
	_detail_vbox.add_child(btns)

	_detail_start = UiKit.gold_button("START HEIST")
	_detail_start.custom_minimum_size = Vector2(180, 46)
	_detail_start.pressed.connect(_on_start_heist)
	btns.add_child(_detail_start)

	var cancel := UiKit.button("CANCEL")
	cancel.custom_minimum_size = Vector2(140, 46)
	cancel.pressed.connect(func() -> void: _detail.visible = false)
	btns.add_child(cancel)

	_update_detail_state()
	_detail.visible = true


func _crew_toggle(cat_id: String) -> Button:
	var d := GameData.cat_by_id(cat_id)
	var b := UiKit.button(String(d["name"]))
	b.toggle_mode = true
	b.custom_minimum_size = Vector2(168, 44)
	b.add_theme_font_size_override("font_size", 14)
	var cid := cat_id
	b.toggled.connect(func(on: bool) -> void:
		if on:
			if not cid in _selected:
				_selected.append(cid)
		else:
			_selected.erase(cid)
		_update_detail_state()
	)
	return b


func _update_detail_state() -> void:
	var hd := GameData.heist_by_id(_detail_heist)
	var min_c := int(hd["min_cats"])
	var max_c := int(hd["max_cats"])
	# enforce max
	if _selected.size() > max_c:
		_selected = _selected.slice(0, max_c)
		for ch in _detail_grid.get_children():
			if ch is Button and not _is_selected_name(ch):
				ch.button_pressed = false
	_detail_start.disabled = _selected.size() < min_c
	if _selected.is_empty():
		_detail_odds.text = "Select at least %d cat(s)." % min_c
	else:
		var chance := GameMan.preview_chance(_detail_heist, _selected)
		var target := clampi(roundi(chance * 20.0), 2, 19)
		_detail_odds.text = "Odds: %d%%  —  d20 roll of %d or less succeeds" % [int(roundf(chance * 100.0)), target]


func _is_selected_name(b: Button) -> bool:
	for cid in _selected:
		if String(GameData.cat_by_id(cid)["name"]) == b.text:
			return true
	return false


func _on_start_heist() -> void:
	if GameMan.start_heist(_detail_heist, _selected):
		_detail.visible = false
		_selected.clear()
		refresh()


# ---------------------------------------------------------------- resolve modal

func _build_modal() -> void:
	_modal = Control.new()
	_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	_modal.visible = false
	add_child(_modal)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_modal.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_modal.add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiKit.panel_style())
	panel.custom_minimum_size = Vector2(480, 0)
	center.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vb)
	_modal_vbox = vb


var _modal_vbox: VBoxContainer


func _show_result(r: Dictionary) -> void:
	_showing_modal = true
	for ch in _modal_vbox.get_children():
		ch.queue_free()

	var hd := GameData.heist_by_id(String(r["heist_id"]))
	var success := bool(r["success"])

	_modal_vbox.add_child(UiKit.title_label(
		"HEIST SUCCESSFUL" if success else "THE JOB WENT SOUTH",
		28 if success else 26))

	var sub := UiKit.label(String(hd["name"]), 16, UiKit.DIM)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_modal_vbox.add_child(sub)

	if bool(hd.get("show_dog", false)):
		var dog := UiKit.animated("res://assets/dog/bark.png", 11, 8.0)
		dog.scale = Vector2(2, 2)
		var dog_center := CenterContainer.new()
		dog_center.add_child(dog)
		dog_center.custom_minimum_size = Vector2(0, 70)
		_modal_vbox.add_child(dog_center)
		_modal_vbox.add_child(UiKit.label("The dog never saw it coming." if success else "The dog fought back.", 13, UiKit.DIM))

	var art := CenterContainer.new()
	if success:
		var happy := UiKit.sprite_tex("res://assets/cats/sit_happy_01.png", 2.0)
		art.add_child(happy)
	else:
		var skull := UiKit.sprite_tex("res://assets/ui/skull.png", 2.0)
		art.add_child(skull)
	art.custom_minimum_size = Vector2(0, 96)
	_modal_vbox.add_child(art)

	var roll_l := UiKit.label("Rolled %d — needed %d or less (%d%% odds)" % [
		int(r["roll"]), int(r["target"]), int(roundf(float(r["chance"]) * 100.0))], 14, UiKit.CREAM)
	roll_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_modal_vbox.add_child(roll_l)

	if success:
		var take := UiKit.label("Take: +%d T    +%d Respect" % [int(r["treats_won"]), int(r["respect_won"])], 18, UiKit.GREEN)
		take.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_modal_vbox.add_child(take)
	else:
		var take := UiKit.label("No take this time. The family regroups.", 15, UiKit.DIM)
		take.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_modal_vbox.add_child(take)

	var injuries: Array = r["injuries"]
	if injuries.is_empty():
		var ok := UiKit.label("Everyone walked away clean.", 14, UiKit.DIM)
		ok.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_modal_vbox.add_child(ok)
	else:
		var names: Array = []
		for cid in injuries:
			names.append(String(GameData.cat_by_id(String(cid))["name"]))
		var inj := UiKit.label("Licking wounds (90s): " + ", ".join(names), 14, UiKit.BLUE)
		inj.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		inj.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_modal_vbox.add_child(inj)

	var btn := UiKit.gold_button("COLLECT" if success else "LAY LOW")
	btn.custom_minimum_size = Vector2(200, 46)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.pressed.connect(func() -> void:
		_modal.visible = false
		_showing_modal = false
		refresh()
	)
	_modal_vbox.add_child(btn)

	_modal.visible = true
