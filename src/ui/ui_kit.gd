class_name UiKit
extends RefCounted

# Shared palette + widget builders for Pawfellas (640x360).

# "Noir, Wealth & Blood" — Midnight Black, Oxblood Red, Warm Brass Gold,
# Smoky Charcoal and Aged Parchment. Black and charcoal carry the neutral
# baseline, brass marks anything you can press, and oxblood is reserved for
# things going wrong.
const BG = Color("121212")           # Midnight Black — the shadow world
const SHADOW = Color("1C1C1E")         # between black and charcoal, for button faces
const PANEL = Color("2C2C2E")        # Smoky Charcoal — cards and secondary panels
const GOLD = Color("D4AF37")         # Warm Brass Gold — money, rank, interactables
const GOLD_DIM = Color("B19233")     # brass in shadow, for borders and captions
const CREAM = Color("E6D5B8")        # Aged Parchment — body text
const DIM = Color("A39A8D")          # parchment, dropped back for secondary text
const OXBLOOD = Color("6B1111")      # Oxblood Red — fills and borders only
const RED = Color("CD7D76")          # oxblood lifted to stay legible as text
const GREEN = Color("8A9A5B")        # bottle green, desaturated to sit with brass
const BLUE = Color("8298AA")         # slate, for informational notes
const ORANGE = Color("C08A3E")       # tarnished brass, for in-progress states

# Ink, for text on the parchment cards. The dark palette above is for chrome:
# wood bars, buttons and the background behind everything.
const INK = Color("2A2118")          # iron gall ink
const INK_DIM = Color("61533E")      # faded ink, secondary lines
const INK_GOLD = Color("6C5010")     # brass struck on paper
const INK_RED = Color("6B1111")      # Oxblood — finally legible, on paper
const INK_GREEN = Color("3F5A2A")
const INK_BLUE = Color("3A4E63")

const FONT_BODY = "res://assets/fonts/Lora-Regular.ttf"
const FONT_BOLD = "res://assets/fonts/Lora-Bold.ttf"
const FONT_DISPLAY = "res://assets/fonts/LibreBaskerville-Regular.ttf"
const FONT_CAPS = "res://assets/fonts/ArsenalSC-Regular.ttf"

const TEX_DIR = "res://assets/ui/gen/"


## 9-patch from a generated texture: the brass border stays crisp while the
## paper in the middle stretches to whatever the panel needs.
static func _tex_style(file: String, margin: int = 14, pad_h: int = 10, pad_v: int = 8) -> StyleBoxTexture:
	var s := StyleBoxTexture.new()
	s.texture = load(TEX_DIR + file)
	s.set_texture_margin_all(margin)
	s.content_margin_left = pad_h
	s.content_margin_right = pad_h
	s.content_margin_top = pad_v
	s.content_margin_bottom = pad_v
	return s


## Aged ledger paper — the default card.
static func panel_style() -> StyleBoxTexture:
	return _tex_style("parchment_framed.png")


## Slightly darker stock, for rows nested inside another card.
static func panel_dim_style() -> StyleBoxTexture:
	return _tex_style("parchment_dim_framed.png")


## Stained wood, for chrome: headers and the status bar.
static func wood_style(pad_h: int = 10, pad_v: int = 6) -> StyleBoxTexture:
	return _tex_style("wood_framed.png", 14, pad_h, pad_v)


static func chip_style() -> StyleBoxTexture:
	return _tex_style("chip.png", 12, 8, 4)


## Parchment stained red, reserved for critical events.
static func danger_panel_style() -> StyleBoxTexture:
	var s := panel_style()
	s.modulate_color = Color(1.0, 0.70, 0.64)
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
	b.add_theme_font_override("font", load(FONT_BOLD))
	b.add_theme_font_size_override("font_size", 17)
	b.add_theme_color_override("font_color", CREAM)
	b.add_theme_color_override("font_hover_color", GOLD)
	b.add_theme_color_override("font_pressed_color", GOLD)
	b.add_theme_color_override("font_disabled_color", DIM)
	b.add_theme_stylebox_override("normal", _btn_box(SHADOW, GOLD_DIM))
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


## Risk as drawn diamonds. None of the project fonts carry U+25C6/U+25C7, so
## typing them renders a tofu box; these are textures.
static func risk_pips(filled: int, total: int = 5, px: int = 11) -> HBoxContainer:
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 2)
	for i in total:
		var t := TextureRect.new()
		t.texture = load(TEX_DIR + ("pip_full.png" if i < filled else "pip_empty.png"))
		t.custom_minimum_size = Vector2(px, px)
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hb.add_child(t)
	return hb


static func glyph(file: String, px: int) -> TextureRect:
	var t := TextureRect.new()
	t.texture = load(TEX_DIR + file)
	t.custom_minimum_size = Vector2(px, px)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return t


## Small-caps display face, for screen titles and card headings.
static func display_label(text: String, size: int = 18, color: Color = GOLD) -> Label:
	var l := label(text, size, color)
	l.add_theme_font_override("font", load(FONT_DISPLAY))
	return l


static func caps_label(text: String, size: int = 14, color: Color = GOLD) -> Label:
	var l := label(text, size, color)
	l.add_theme_font_override("font", load(FONT_CAPS))
	return l


## The ornamented screen header from the concepts: wood plate, centred display
## title, brass rule with a diamond under it.
static func screen_header(title: String) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", wood_style(12, 6))
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 1)
	p.add_child(vb)
	var t := display_label(title.to_upper(), 19, GOLD)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	t.add_theme_constant_override("shadow_offset_x", 1)
	t.add_theme_constant_override("shadow_offset_y", 2)
	vb.add_child(t)
	vb.add_child(glyph("rule_diamond.png", 8))
	return p


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
	var l := label(label_text, 12, DIM)
	l.custom_minimum_size = Vector2(12, 0)
	hb.add_child(l)
	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 10
	bar.value = value
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(40, 11)
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


## Always drawn inside a parchment card, so these are ink tones.
static func state_badge(cat_id: String) -> Label:
	match GameMan.cat_state(cat_id):
		"jail":
			var held := int(GameMan.cats[cat_id]["jail_days"])
			return caps_label("INSIDE (%d day%s)" % [held, "" if held == 1 else "s"], 13, OXBLOOD)
		"ready":
			return caps_label("READY", 13, INK_GREEN)
		"assigned":
			var vid := String(GameMan.cats[cat_id]["venue"])
			var v := WorldData.venue_by_id(vid)
			var op := String(GameMan.cats[cat_id]["op"])
			return caps_label("%s — %s" % [WorldData.op_label(op), String(v.get("name", ""))], 13, INK_GOLD)
		"wounded":
			var days := int(GameMan.cats[cat_id]["wounded_days"])
			return caps_label("LICKING WOUNDS (%d day%s)" % [days, "" if days == 1 else "s"], 13, OXBLOOD)
	return label("", 13, INK_DIM)


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
	if text != "":
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


## The persistent status strip: brass chips on a wood plate.
static func _chip(title: String, body: Control) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", chip_style())
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 0)
	p.add_child(vb)
	var t := caps_label(title, 9, GOLD_DIM)
	t.clip_text = true
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(t)
	body.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vb.add_child(body)
	return p


## Two compact rows, because one row of chips needs more width than a phone
## has and its minimum drags every panel on the screen off the right edge.
static func status_bar() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", wood_style(6, 3))

	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 3)
	p.add_child(rows)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 4)
	rows.add_child(top)

	var day := display_label(str(GameMan.day), 14, CREAM)
	day.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top.add_child(_chip("DAY", day))

	var cash := display_label("%d T" % GameMan.treats, 14, GOLD)
	cash.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top.add_child(_chip("CASH", cash))

	var rank := caps_label(GameData.rank_name(GameMan.respect), 11, CREAM)
	rank.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rank.clip_text = true
	var rank_chip := _chip("RESPECT %d" % GameMan.respect, rank)
	rank_chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(rank_chip)

	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 4)
	rows.add_child(bottom)

	var heat := VBoxContainer.new()
	heat.add_theme_constant_override("separation", 0)
	heat.add_child(meter("", GameMan.heat, 100.0, OXBLOOD, 48))
	var heat_chip := _chip("HEAT", heat)
	heat_chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(heat_chip)

	var war := VBoxContainer.new()
	war.add_theme_constant_override("separation", 0)
	war.add_child(meter("", GameMan.tension, 100.0, ORANGE, 48))
	var war_chip := _chip("WAR", war)
	war_chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(war_chip)

	var mute := Button.new()
	mute.icon = load(TEX_DIR + ("note_on.png" if not Jukebox.muted else "note_off.png"))
	mute.expand_icon = true
	mute.tooltip_text = "Music on/off"
	mute.custom_minimum_size = Vector2(28, 26)
	mute.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	mute.add_theme_constant_override("icon_max_width", 16)
	mute.add_theme_stylebox_override("normal", _btn_box(SHADOW, GOLD_DIM))
	mute.add_theme_stylebox_override("hover", _btn_box(Color(0.20, 0.16, 0.10), GOLD))
	mute.add_theme_stylebox_override("pressed", _btn_box(Color(0.10, 0.08, 0.05), GOLD))
	mute.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	mute.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mute.pressed.connect(func() -> void:
		Jukebox.toggle()
		mute.icon = load(TEX_DIR + ("note_on.png" if not Jukebox.muted else "note_off.png"))
	)
	bottom.add_child(mute)
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
