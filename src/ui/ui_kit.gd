class_name UiKit
extends RefCounted

# Shared palette + widget builders for The Catfather (640x360, pixel art).

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
	var st := GameMan.cat_state(cat_id)
	var l: Label
	match st:
		"ready":
			l = label("READY", 13, GREEN)
		"on_heist":
			var h := GameData.heist_by_id(String(GameMan.cats[cat_id]["heist_id"]))
			l = label("ON HEIST: " + String(h.get("name", "")).to_upper(), 13, ORANGE)
		"wounded":
			l = label("LICKING WOUNDS " + fmt_time(GameMan.wound_remaining(cat_id)), 13, BLUE)
		_:
			l = label(st.to_upper(), 13, DIM)
	return l
