class_name OfficeScreen
extends Control

var main: Main

var _treats_label: Label
var _respect_label: Label
var _respect_bar: ProgressBar
var _turf_label: Label
var _notice_label: Label
var _timer: Timer


func _ready() -> void:
	# ---- backdrop: dark plum office with furniture
	var bg := ColorRect.new()
	bg.color = Color(0.13, 0.09, 0.17)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	_place("res://assets/office/window.png", Vector2(500, 26), 1.0)
	_place("res://assets/office/bookshelf.png", Vector2(28, 60), 1.0)
	_place("res://assets/office/wall_art.png", Vector2(150, 40), 1.0)
	_place("res://assets/office/poster.png", Vector2(205, 96), 1.0)
	_place("res://assets/office/plant.png", Vector2(430, 120), 1.0)
	_place("res://assets/office/cat_tree.png", Vector2(300, 130), 1.0)

	var idle_cat := UiKit.animated("res://assets/cats/mochi_idle.png", 10, 5.0)
	idle_cat.position = Vector2(330, 278)
	idle_cat.scale = Vector2(2, 2)
	add_child(idle_cat)

	var box_cat := UiKit.animated("res://assets/cats/mochi_box.png", 4, 3.0)
	box_cat.position = Vector2(120, 278)
	box_cat.scale = Vector2(2, 2)
	add_child(box_cat)

	# ---- top HUD bar
	var top := PanelContainer.new()
	top.add_theme_stylebox_override("panel", UiKit.panel_style())
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_bottom = 64
	add_child(top)

	var top_hb := HBoxContainer.new()
	top_hb.add_theme_constant_override("separation", 14)
	top.add_child(top_hb)

	var bowl := UiKit.sprite_tex("res://assets/food/treats_bowl.png")
	bowl.custom_minimum_size = Vector2(30, 30)
	bowl.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bowl.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	top_hb.add_child(bowl)

	_treats_label = UiKit.label("100 T", 22, UiKit.GOLD)
	_treats_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top_hb.add_child(_treats_label)

	var rv := VBoxContainer.new()
	rv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rv.add_theme_constant_override("separation", 2)
	top_hb.add_child(rv)

	_respect_label = UiKit.label("RESPECT 0", 14, UiKit.CREAM)
	rv.add_child(_respect_label)

	_respect_bar = ProgressBar.new()
	_respect_bar.min_value = 0
	_respect_bar.max_value = 100
	_respect_bar.show_percentage = false
	_respect_bar.custom_minimum_size = Vector2(0, 12)
	var rbg := StyleBoxFlat.new()
	rbg.bg_color = Color(0.10, 0.08, 0.13)
	rbg.set_corner_radius_all(4)
	var rfill := StyleBoxFlat.new()
	rfill.bg_color = UiKit.GOLD_DIM
	rfill.set_corner_radius_all(4)
	_respect_bar.add_theme_stylebox_override("background", rbg)
	_respect_bar.add_theme_stylebox_override("fill", rfill)
	rv.add_child(_respect_bar)

	_turf_label = UiKit.label("The Living Room Rug", 14, UiKit.DIM)
	_turf_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top_hb.add_child(_turf_label)

	# ---- notice line (active heist / pending results)
	_notice_label = UiKit.label("", 15, UiKit.ORANGE)
	_notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_notice_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_notice_label.offset_top = 70
	_notice_label.offset_bottom = 94
	add_child(_notice_label)

	# ---- bottom nav
	var nav := HBoxContainer.new()
	nav.alignment = BoxContainer.ALIGNMENT_CENTER
	nav.add_theme_constant_override("separation", 16)
	nav.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	nav.offset_top = -68
	nav.offset_bottom = -12
	add_child(nav)

	for entry in [["CREW", "crew"], ["RECRUIT", "recruit"], ["HEISTS", "heists"]]:
		var b := UiKit.gold_button(String(entry[0]))
		b.custom_minimum_size = Vector2(170, 52)
		var target := String(entry[1])
		b.pressed.connect(func() -> void: main.show_screen(target))
		nav.add_child(b)

	_timer = Timer.new()
	_timer.wait_time = 1.0
	_timer.timeout.connect(refresh)
	add_child(_timer)
	_timer.start()


func _place(path: String, pos: Vector2, s: float) -> void:
	var tr := UiKit.sprite_tex(path, s)
	tr.position = pos
	add_child(tr)


func refresh() -> void:
	_treats_label.text = "%d T" % GameMan.treats
	_respect_label.text = "RESPECT %d / 100" % GameMan.respect
	_respect_bar.value = GameMan.respect
	var turf := GameData.turf_name(GameMan.respect)
	_turf_label.text = turf
	if GameMan.respect >= 100:
		_turf_label.add_theme_color_override("font_color", UiKit.GOLD)
		_turf_label.text = "DON OF THE HOUSE"
	if not GameMan.pending_results.is_empty():
		_notice_label.text = "A crew has returned — check HEISTS for the take."
	elif not GameMan.active_heists.is_empty():
		_notice_label.text = "%d heist(s) in progress..." % GameMan.active_heists.size()
	else:
		_notice_label.text = ""
