class_name UiKit
extends RefCounted

# Shared palette + widget builders for Pawfellas (640x360).

const BG = Color(0.07, 0.045, 0.09)
const PLUM = Color(0.15, 0.10, 0.19)
const PANEL = Color(0.17, 0.115, 0.23)
const GOLD = Color(0.79, 0.635, 0.15)
const GOLD_DIM = Color(0.52, 0.42, 0.13)
const CREAM = Color(0.91, 0.86, 0.75)
const DIM = Color(0.63, 0.57, 0.67)
const RED = Color(0.87, 0.32, 0.30)
const GREEN = Color(0.45, 0.80, 0.45)
const BLUE = Color(0.45, 0.65, 0.92)
const ORANGE = Color(0.95, 0.62, 0.25)


static func panel_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = PANEL
	s.border_color = GOLD_DIM
	s.set_border_width_all(2)
	s.set_corner_radius_all(6)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s


static func _btn_box(bg: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(2)
	s.set_corner_radius_all(6)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s


static func button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", 17)
	b.add_theme_color_override("font_color", CREAM)
	b.add_theme_color_override("font_hover_color", GOLD)
	b.add_theme_color_override("font_pressed_color", GOLD)
	b.add_theme_color_override("font_disabled_color", DIM)
	b.add_theme_stylebox_override("normal", _btn_box(PLUM, GOLD_DIM))
	b.add_theme_stylebox_override("hover", _btn_box(Color(0.20, 0.13, 0.25), GOLD))
	b.add_theme_stylebox_override("pressed", _btn_box(Color(0.10, 0.07, 0.13), GOLD))
	b.add_theme_stylebox_override("disabled", _btn_box(Color(0.10, 0.09, 0.12), Color(0.25, 0.22, 0.28)))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return b


static func gold_button(text: String) -> Button:
	var b := button(text)
	b.add_theme_color_override("font_color", Color(0.12, 0.08, 0.04))
	b.add_theme_color_override("font_hover_color", Color(0.12, 0.08, 0.04))
	b.add_theme_color_override("font_pressed_color", Color(0.98, 0.90, 0.70))
	b.add_theme_stylebox_override("normal", _btn_box(GOLD, Color(0.95, 0.80, 0.35)))
	b.add_theme_stylebox_override("hover", _btn_box(Color(0.88, 0.72, 0.22), Color(1.0, 0.88, 0.45)))
	b.add_theme_stylebox_override("pressed", _btn_box(GOLD_DIM, GOLD))
	return b


static func label(text: String, size: int = 16, color: Color = CREAM) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


static func title_label(text: String, size: int = 40) -> Label:
	var l := label(text, size, GOLD)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("shadow_offset_x", 3)
	l.add_theme_constant_override("shadow_offset_y", 3)
	return l


static func back_button(text: String = "< OFFICE") -> Button:
	var b := button(text)
	b.custom_minimum_size = Vector2(120, 36)
	return b


static func portrait(cat_id: String, px: int) -> TextureRect:
	var d := GameData.cat_by_id(cat_id)
	var tr := TextureRect.new()
	if not d.is_empty():
		tr.texture = load("res://assets/cats/" + String(d["portrait"]) + ".png")
		tr.modulate = d["tint"]
	tr.custom_minimum_size = Vector2(px, px)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return tr


static func sprite_tex(path: String, scale: float = 1.0) -> TextureRect:
	var tr := TextureRect.new()
	tr.texture = load(path)
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if scale != 1.0:
		tr.scale = Vector2(scale, scale)
	return tr


static func animated(strip_path: String, frames: int, fps: float = 6.0) -> AnimatedSprite2D:
	var a := AnimatedSprite2D.new()
	var tex: Texture2D = load(strip_path)
	var fw := int(tex.get_width() / frames)
	var fh := int(tex.get_height())
	var sf := SpriteFrames.new()
	sf.add_animation("play")
	sf.set_animation_speed("play", fps)
	sf.set_animation_loop("play", true)
	for i in frames:
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * fw, 0, fw, fh)
		sf.add_frame("play", at)
	a.frames = sf
	a.play("play")
	return a


static func stat_mini(label_text: String, value: int) -> HBoxContainer:
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 4)
	var l := label(label_text, 13, DIM)
	l.custom_minimum_size = Vector2(16, 0)
	hb.add_child(l)
	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 10
	bar.value = value
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(56, 12)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.10, 0.08, 0.13)
	bg.set_corner_radius_all(3)
	var fill := StyleBoxFlat.new()
	fill.bg_color = GOLD_DIM
	fill.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)
	hb.add_child(bar)
	var v := label(str(value), 13, CREAM)
	hb.add_child(v)
	return hb


static func fmt_time(sec: float) -> String:
	var s := int(maxf(0.0, sec))
	return "%d:%02d" % [s / 60, s % 60]


static func spacer(h: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c


static func hsep() -> HSeparator:
	var s := HSeparator.new()
	s.add_theme_constant_override("separation", 6)
	return s


static func state_badge(cat_id: String) -> Label:
	match GameMan.cat_state(cat_id):
		"ready":
			return label("READY", 13, GREEN)
		"assigned":
			var vid := String(GameMan.cats[cat_id]["venue"])
			var v := WorldData.venue_by_id(vid)
			var op := String(GameMan.cats[cat_id]["op"])
			return label("%s — %s" % [WorldData.op_label(op), String(v.get("name", "")).to_upper()], 13, ORANGE)
		"wounded":
			var days := int(GameMan.cats[cat_id]["wounded_days"])
			return label("LICKING WOUNDS (%d day%s)" % [days, "" if days == 1 else "s"], 13, BLUE)
	return label("", 13, DIM)


## Full-body art for story scenes; falls back to the roster portrait for cats
## that were never drawn.
static func body_portrait(cat_id: String, height: int) -> TextureRect:
	var tr := TextureRect.new()
	var body := "res://assets/cats/mob/%s.png" % cat_id
	var tex: Texture2D = load(body) if ResourceLoader.exists(body) else null
	if tex == null:
		var d := GameData.cat_by_id(cat_id)
		if not d.is_empty():
			tex = load("res://assets/cats/%s.png" % String(d["portrait"]))
	tr.texture = tex
	tr.custom_minimum_size = Vector2(float(height) * 0.85, height)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return tr


## Labelled bar for treats / heat / tension / loyalty.
static func meter(text: String, value: float, maximum: float, fill_color: Color, width: int = 70) -> HBoxContainer:
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 5)
	var l := label(text, 12, DIM)
	l.custom_minimum_size = Vector2(46, 0)
	hb.add_child(l)
	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = maximum
	bar.value = clampf(value, 0.0, maximum)
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(width, 10)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.10, 0.08, 0.13)
	bg.set_corner_radius_all(3)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)
	hb.add_child(bar)
	hb.add_child(label(str(int(value)), 12, CREAM))
	return hb


## The persistent status strip across the top of every management screen.
static func status_bar() -> PanelContainer:
	var p := PanelContainer.new()
	var box := StyleBoxFlat.new()
	box.bg_color = PLUM
	box.border_color = GOLD_DIM
	box.set_border_width_all(2)
	box.set_corner_radius_all(5)
	box.content_margin_left = 8
	box.content_margin_right = 8
	box.content_margin_top = 4
	box.content_margin_bottom = 4
	p.add_theme_stylebox_override("panel", box)

	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	p.add_child(hb)

	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 1)
	hb.add_child(left)
	left.add_child(label("DAY %d" % GameMan.day, 17, GOLD))
	left.add_child(label(GameData.rank_name(GameMan.respect), 11, DIM))

	var mid := VBoxContainer.new()
	mid.add_theme_constant_override("separation", 1)
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(mid)
	mid.add_child(meter("HEAT", GameMan.heat, 100.0, RED))
	mid.add_child(meter("WAR", GameMan.tension, 100.0, ORANGE))

	var mute := Button.new()
	mute.text = "♪" if not Jukebox.muted else "♪̸"
	mute.tooltip_text = "Music on/off"
	mute.custom_minimum_size = Vector2(30, 26)
	mute.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	mute.add_theme_font_size_override("font_size", 15)
	mute.add_theme_color_override("font_color", GOLD if not Jukebox.muted else DIM)
	mute.add_theme_stylebox_override("normal", _btn_box(PLUM, GOLD_DIM))
	mute.add_theme_stylebox_override("hover", _btn_box(Color(0.20, 0.13, 0.25), GOLD))
	mute.add_theme_stylebox_override("pressed", _btn_box(Color(0.10, 0.07, 0.13), GOLD))
	mute.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	mute.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mute.pressed.connect(func() -> void:
		Jukebox.toggle()
		mute.text = "♪" if not Jukebox.muted else "♪̸"
		mute.add_theme_color_override("font_color", GOLD if not Jukebox.muted else DIM)
	)
	hb.add_child(mute)

	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 1)
	hb.add_child(right)
	var t := label("%d T" % GameMan.treats, 17, GOLD)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_child(t)
	var r := label("RESPECT %d" % GameMan.respect, 11, DIM)
	r.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_child(r)
	return p


static func body_text(text: String, size: int = 14, color: Color = CREAM) -> Label:
	var l := label(text, size, color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


## A touch drag has to reach the ScrollContainer to scroll the list. Every
## Control defaults to MOUSE_FILTER_STOP, so panels and rows swallow the drag
## and only the bare background scrolls. Let everything except buttons pass
## the event upward.
static func allow_scroll_drag(node: Node) -> void:
	for ch in node.get_children():
		if ch is Control and not (ch is BaseButton) and not (ch is ScrollContainer):
			(ch as Control).mouse_filter = Control.MOUSE_FILTER_PASS
		allow_scroll_drag(ch)
