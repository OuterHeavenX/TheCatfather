class_name CrewScreen
extends Control

var main: Main

var _list: VBoxContainer
var _count_label: Label
var _timer: Timer


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
	_count_label = UiKit.label("", 18, UiKit.GOLD)
	_count_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(_count_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_child(scroll)

	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_list)

	_timer = Timer.new()
	_timer.wait_time = 1.0
	_timer.timeout.connect(refresh)
	add_child(_timer)
	_timer.start()


func refresh() -> void:
	for ch in _list.get_children():
		ch.queue_free()
	var ids := GameMan.hired_cats()
	_count_label.text = "THE FAMILY  (%d / 24)" % ids.size()
	for cid in ids:
		_list.add_child(_row(cid))


func _row(cat_id: String) -> PanelContainer:
	var d := GameData.cat_by_id(cat_id)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.panel_style())
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 12)
	p.add_child(hb)

	hb.add_child(UiKit.portrait(cat_id, 64))

	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 2)
	hb.add_child(vb)

	vb.add_child(UiKit.label(String(d["name"]), 19, UiKit.GOLD))
	var fl := UiKit.label(String(d["flavor"]), 13, UiKit.DIM)
	fl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(fl)

	var role_text := GameData.role_name(String(d.get("role", "")))
	if role_text != "":
		vb.add_child(UiKit.label(role_text, 12, UiKit.GOLD_DIM))

	var stats := HBoxContainer.new()
	stats.add_theme_constant_override("separation", 10)
	vb.add_child(stats)
	stats.add_child(UiKit.stat_mini("M", int(d["muscle"])))
	stats.add_child(UiKit.stat_mini("S", int(d["sneak"])))
	stats.add_child(UiKit.stat_mini("C", int(d["charm"])))

	var trait_key := String(d.get("trait", ""))
	if trait_key != "":
		vb.add_child(UiKit.label(GameData.trait_name(trait_key), 12, UiKit.BLUE))

	vb.add_child(UiKit.state_badge(cat_id))
	return p
