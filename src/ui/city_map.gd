class_name CityMap
extends Control

signal district_selected(id: String)
const POSITIONS = [Vector2(.30,.78),Vector2(.24,.50),Vector2(.72,.68),Vector2(.56,.34),Vector2(.72,.13)]

func _ready() -> void:
	custom_minimum_size.y = 440
	clip_contents = true
	var art := NoirKit.picture("res://assets/art/noir/city_map.png",0)
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(art)
	for i in CityData.districts().size():
		var d: Dictionary = CityData.districts()[i]
		var open := CityData.unlocked(d.id)
		var suffix := "Explore" if open else ("Future district" if int(d.respect)<0 else "%d respect" % int(d.respect))
		var b := NoirKit.button(String(d.name).to_upper()+"\n"+suffix, func() -> void: district_selected.emit(d.id))
		b.add_theme_font_size_override("font_size",17)
		b.add_theme_color_override("font_color",NoirKit.INK)
		b.add_theme_stylebox_override("normal",NoirKit.box(NoirKit.PAPER, d.color,6))
		b.set_anchors_preset(Control.PRESET_TOP_LEFT)
		b.anchor_left = POSITIONS[i].x
		b.anchor_top = POSITIONS[i].y
		b.anchor_right = POSITIONS[i].x
		b.anchor_bottom = POSITIONS[i].y
		b.offset_left = -65
		b.offset_right = 65
		b.offset_top = -30
		b.offset_bottom = 30
		add_child(b)
