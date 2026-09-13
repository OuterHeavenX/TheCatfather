class_name StoryScreen
extends Control

## Dialogue beats: full-body art on the left, the speaker on the right, and
## choices that set your alignment.

var main: Main

var _beat: Dictionary = {}
var _line: int = 0
var _mode: String = "lines"
var _reply: String = ""

var _title: Label
var _portrait_slot: MarginContainer
var _speaker: Label
var _text: Label
var _buttons: VBoxContainer


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	margin.add_child(vb)

	_title = UiKit.label("", 17, UiKit.GOLD)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(_title)

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(body)

	_portrait_slot = MarginContainer.new()
	_portrait_slot.custom_minimum_size = Vector2(150, 0)
	body.add_child(_portrait_slot)

	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 4)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)

	_speaker = UiKit.label("", 16, UiKit.GOLD)
	right.add_child(_speaker)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiKit.panel_style())
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(panel)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)

	_text = UiKit.body_text("", 14)
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(_text)

	_buttons = VBoxContainer.new()
	_buttons.add_theme_constant_override("separation", 4)
	vb.add_child(_buttons)


func refresh() -> void:
	_beat = GameMan.pending_beat()
	if _beat.is_empty():
		main.show_screen("desk")
		return
	_line = 0
	_mode = "lines"
	_reply = ""
	_render()


func _render() -> void:
	for ch in _buttons.get_children():
		ch.queue_free()
	for ch in _portrait_slot.get_children():
		ch.queue_free()

	_title.text = String(_beat.get("title", ""))
	var lines: Array = _beat.get("lines", [])

	match _mode:
		"lines":
			var entry: Dictionary = lines[_line]
			var who := String(entry["who"])
			var d := GameData.cat_by_id(who)
			_speaker.text = String(d.get("name", who))
			_text.text = String(entry["text"])
			_portrait_slot.add_child(UiKit.body_portrait(who, 175))
			var more := _line < lines.size() - 1
			var b := UiKit.gold_button("NEXT" if more else _next_label())
			b.custom_minimum_size = Vector2(0, 34)
			b.pressed.connect(_advance)
			_buttons.add_child(b)
		"choices":
			_speaker.text = "Jimmy \"Two-Times\""
			_text.text = "Your call."
			_portrait_slot.add_child(UiKit.body_portrait("jimmy_twotimes", 175))
			var choices: Array = _beat.get("choices", [])
			for i in choices.size():
				var ch: Dictionary = choices[i]
				var cb := UiKit.button(String(ch["text"]))
				cb.custom_minimum_size = Vector2(0, 30)
				cb.pressed.connect(_choose.bind(i))
				_buttons.add_child(cb)
		"reply":
			_speaker.text = "That night"
			_text.text = _reply
			_portrait_slot.add_child(UiKit.body_portrait("jimmy_twotimes", 175))
			var ob := UiKit.gold_button("BACK TO THE DESK")
			ob.custom_minimum_size = Vector2(0, 34)
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
