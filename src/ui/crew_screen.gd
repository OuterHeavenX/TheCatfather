class_name CrewScreen
extends Control

## The crew sheet: experience, loyalty, gear and who is fit to work.

var main: Main

var _bar_slot: MarginContainer
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
	_list.add_child(UiKit.label("THE CREW", 15, UiKit.GOLD))
	for cid in GameMan.hired_cats():
		_list.add_child(_row(String(cid)))
	UiKit.allow_scroll_drag(self)


func _row(cat_id: String) -> PanelContainer:
	var d := GameData.cat_by_id(cat_id)
	var c: Dictionary = GameMan.cats[cat_id]

	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.panel_style())
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	p.add_child(hb)

	hb.add_child(UiKit.portrait(cat_id, 60))

	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 2)
	hb.add_child(vb)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 6)
	vb.add_child(head)
	var n := UiKit.label(String(d["name"]), 16, UiKit.GOLD)
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(n)
	head.add_child(UiKit.label("LV %d" % int(c["level"]), 14, UiKit.CREAM))

	var role_text := GameData.role_name(String(d.get("role", "")))
	if role_text != "":
		vb.add_child(UiKit.label(role_text, 11, UiKit.GOLD_DIM))

	if int(c["level"]) < GameMan.MAX_LEVEL:
		vb.add_child(UiKit.meter("XP", float(c["xp"]), float(GameMan.xp_to_next(cat_id)), UiKit.BLUE, 80))
	vb.add_child(UiKit.meter("LOYAL", float(c["loyalty"]), 100.0, _loyalty_color(int(c["loyalty"])), 80))

	var stats := HBoxContainer.new()
	stats.add_theme_constant_override("separation", 8)
	vb.add_child(stats)
	stats.add_child(UiKit.label("M %.1f" % GameMan.effective_stat(cat_id, "muscle"), 12, UiKit.CREAM))
	stats.add_child(UiKit.label("S %.1f" % GameMan.effective_stat(cat_id, "sneak"), 12, UiKit.CREAM))
	stats.add_child(UiKit.label("C %.1f" % GameMan.effective_stat(cat_id, "charm"), 12, UiKit.CREAM))
	stats.add_child(UiKit.label("cut %d T" % GameMan.cat_cut(cat_id), 12, UiKit.DIM))

	var trait_key := String(d.get("trait", ""))
	if trait_key != "":
		vb.add_child(UiKit.label(GameData.trait_name(trait_key), 11, UiKit.BLUE))

	vb.add_child(_gear_row(cat_id))
	vb.add_child(UiKit.state_badge(cat_id))

	if GameMan.cat_state(cat_id) == "wounded" and GameMan.stash_count("salmon") > 0:
		var heal: Button = UiKit.button("PATCH UP (Grade-A Salmon)")
		heal.custom_minimum_size = Vector2(0, 26)
		heal.pressed.connect(func() -> void:
			GameMan.use_item("salmon", cat_id)
			refresh()
		)
		vb.add_child(heal)
	return p


func _gear_row(cat_id: String) -> HBoxContainer:
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 4)
	var worn := String(GameMan.cats[cat_id]["gear"])
	if worn != "":
		hb.add_child(UiKit.label("Wearing: " + String(WorldData.item_by_id(worn)["name"]), 11, UiKit.GREEN))
	else:
		hb.add_child(UiKit.label("No gear", 11, UiKit.DIM))
	for item in WorldData.items():
		if String(item["kind"]) != "gear":
			continue
		var iid := String(item["id"])
		if GameMan.stash_count(iid) <= 0 or iid == worn:
			continue
		var b := UiKit.button("+ " + String(item["name"]))
		b.add_theme_font_size_override("font_size", 11)
		b.custom_minimum_size = Vector2(0, 22)
		b.pressed.connect(func() -> void:
			GameMan.equip_item(iid, cat_id)
			refresh()
		)
		hb.add_child(b)
	return hb


func _loyalty_color(value: int) -> Color:
	if value >= 60:
		return UiKit.GREEN
	if value >= 30:
		return UiKit.ORANGE
	return UiKit.OXBLOOD
