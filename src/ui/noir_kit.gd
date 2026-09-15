class_name NoirKit
extends RefCounted

const BLACK = Color("101311")
const DARK = Color("1b211e")
const BRASS = Color("ba9761")
const PAPER = Color("e0c99e")
const INK = Color("30281e")
const CREAM = Color("eee1c9")
const MUTED = Color("b2ad9e")
const RED = Color("9c4039")
const GREEN = Color("819777")

static func box(color: Color, border: Color = BRASS, pad: int = 16) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = border
	s.set_border_width_all(1)
	s.set_content_margin_all(pad)
	s.set_corner_radius_all(2)
	return s

static func text(value: String, size: int = 18, color: Color = CREAM, display: bool = false) -> Label:
	var l := Label.new()
	l.text = value
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_font_override("font", load(UiKit.FONT_CAPS if display else UiKit.FONT_BODY))
	return l

static func button(value: String, action: Callable, primary: bool = false) -> Button:
	var b := Button.new()
	b.text = value
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.custom_minimum_size.y = 48
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_override("font", load(UiKit.FONT_CAPS))
	b.add_theme_font_size_override("font_size", 19)
	b.add_theme_color_override("font_color", CREAM)
	b.add_theme_color_override("font_disabled_color", MUTED)
	b.add_theme_stylebox_override("normal", box(Color("632b27") if primary else DARK, BRASS, 10))
	b.add_theme_stylebox_override("hover", box(Color("40372a"), PAPER, 10))
	b.add_theme_stylebox_override("pressed", box(Color("36201c"), PAPER, 10))
	b.add_theme_stylebox_override("disabled", box(Color("222521"), Color("55564c"), 10))
	b.add_theme_stylebox_override("focus", box(Color(0,0,0,0), CREAM, 2))
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.pressed.connect(action)
	return b

static func card(parent: Node, paper: bool = false) -> VBoxContainer:
	var p := PanelContainer.new()
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if paper:
		p.add_theme_stylebox_override("panel", UiKit._tex_style("parchment_framed.png",14,18,16))
	else:
		p.add_theme_stylebox_override("panel", box(DARK, Color("65573f")))
	parent.add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)
	return v

static func row(parent: Node) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", 10)
	parent.add_child(r)
	return r

static func columns(parent: Node, mobile: bool, count: int = 2) -> GridContainer:
	var g := GridContainer.new()
	g.columns = 1 if mobile else count
	g.add_theme_constant_override("h_separation", 18)
	g.add_theme_constant_override("v_separation", 14)
	g.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(g)
	return g

static func picture(path: String, height: int) -> TextureRect:
	var t := TextureRect.new()
	if ResourceLoader.exists(path):
		t.texture = load(path)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	t.custom_minimum_size.y = height
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

static func meter(parent: Node, title: String, value: float, maximum: float, paper: bool = false) -> void:
	parent.add_child(text("%s  %.1f / %.1f" % [title, value, maximum],16, INK if paper else CREAM))
	var p := ProgressBar.new()
	p.max_value = maxf(maximum,1)
	p.value = value
	p.show_percentage = false
	p.custom_minimum_size.y = 7
	p.add_theme_stylebox_override("background",box(Color("393b32"),Color("393b32"),0))
	p.add_theme_stylebox_override("fill",box(GREEN,GREEN,0))
	parent.add_child(p)
