class_name StoryScreen
extends Control

## Dialogue beats. The art sits beside the text in landscape and above it in
## portrait, and the speech panel always shrinks to the line it is showing
## rather than stretching to fill a tall screen.

var main: Main

var _beat: Dictionary = {}
var _line: int = 0
var _mode: String = "lines"
var _reply: String = ""

var _title: Label
var _stage: VBoxContainer
var _buttons: VBoxContainer


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	_title = UiKit.label("", 17, UiKit.GOLD)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_title)

	# The stage holds art + speech and is centred in whatever space is left.
	_stage = VBoxContainer.new()
	_stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_stage.alignment = BoxContainer.ALIGNMENT_CENTER
	_stage.add_theme_constant_override("separation", 8)
	root.add_child(_stage)

	_buttons = VBoxContainer.new()
	_buttons.add_theme_constant_override("separation", 5)
	root.add_child(_buttons)


func refresh() -> void:
	_beat = GameMan.pending_beat()
	if _beat.is_empty():
		main.show_screen("desk")
		return
	_line = 0
	_mode = "lines"
	_reply = ""
	_render()


func _speech(speaker: String, text: String) -> VBoxContainer:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 3)
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vb.add_child(UiKit.label(speaker, 16, UiKit.GOLD))

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiKit.panel_style())
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vb.add_child(panel)
	panel.add_child(UiKit.body_text(text, 14))
	return vb


func _render() -> void:
	for ch in _buttons.get_children():
		_buttons.remove_child(ch)
		ch.queue_free()
	for ch in _stage.get_children():
		_stage.remove_child(ch)
		ch.queue_free()

	_title.text = String(_beat.get("title", ""))
	var lines: Array = _beat.get("lines", [])

	var who := "jimmy_twotimes"
	var speaker := "Jimmy \"Two-Times\""
	var text := ""
	match _mode:
		"lines":
			var entry: Dictionary = lines[_line]
			who = String(entry["who"])
			speaker = String(GameData.cat_by_id(who).get("name", who))
			text = String(entry["text"])
		"choices":
			text = "Your call."
		"reply":
			speaker = "That night"
			text = _reply

	var view := get_viewport_rect().size
	var portrait_mode := view.y > view.x
	var art_height := clampi(int(view.y * (0.30 if portrait_mode else 0.62)), 110, 250)

	if portrait_mode:
		var art := UiKit.body_portrait(who, art_height)
		art.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_stage.add_child(art)
		_stage.add_child(_speech(speaker, text))
	else:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_stage.add_child(row)
		var art2 := UiKit.body_portrait(who, art_height)
		art2.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(art2)
		row.add_child(_speech(speaker, text))

	match _mode:
		"lines":
			var more := _line < lines.size() - 1
			var b := UiKit.gold_button("NEXT" if more else _next_label())
			b.custom_minimum_size = Vector2(0, 36)
			b.pressed.connect(_advance)
			_buttons.add_child(b)
		"choices":
			var choices: Array = _beat.get("choices", [])
			for i in choices.size():
				var ch2: Dictionary = choices[i]
				var cb := UiKit.button(String(ch2["text"]))
				cb.custom_minimum_size = Vector2(0, 34)
				cb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				cb.pressed.connect(_choose.bind(i))
				_buttons.add_child(cb)
		"reply":
			var ob := UiKit.gold_button("BACK TO THE DESK")
			ob.custom_minimum_size = Vector2(0, 36)
			ob.pressed.connect(_finish)
			_buttons.add_child(ob)

	UiKit.allow_scroll_drag(self)


func _next_label() -> String:
	var choices: Array = _beat.get("choices", [])
	return "DECIDE" if not choices.is_empty() else "BACK TO THE DESK"


func _advance() -> void:
	var lines: Array = _beat.get("lines", [])
	if _line < lines.size() - 1:
		_line += 1
		_render()
		return
	var choices: Array = _beat.get("choices", [])
	if not choices.is_empty():
		_mode = "choices"
		_render()
		return
	GameMan.resolve_beat(String(_beat["id"]), -1)
	_finish()


func _choose(index: int) -> void:
	_reply = GameMan.resolve_beat(String(_beat["id"]), index)
	if _reply == "":
		_finish()
		return
	_mode = "reply"
	_render()


func _finish() -> void:
	# Beats can stack up if several days pass; show the next one straight away.
	if not GameMan.pending_beat().is_empty():
		refresh()
		return
	main.show_screen("desk")
