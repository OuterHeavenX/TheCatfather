class_name TitleScreen
extends Control

var main: Main
var _confirm_new := false


func _ready() -> void:
	# Pure black so Jimmy's logo (black background) blends seamlessly.
	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var logo := TextureRect.new()
	logo.texture = load("res://assets/logo-mark.png")
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	# Fill everything above the buttons and centre inside it, so the logo sits
	# properly in a tall portrait window as well as a short landscape one.
	logo.set_anchors_preset(Control.PRESET_FULL_RECT)
	logo.offset_bottom = -150
	logo.offset_left = 12
	logo.offset_right = -12
	logo.offset_top = 12
	add_child(logo)

	# Buttons docked at the bottom, over the logo's empty black band.
	var bottom := VBoxContainer.new()
	bottom.add_theme_constant_override("separation", 10)
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_top = -136
	bottom.offset_bottom = -18
	bottom.offset_left = 16
	bottom.offset_right = -16
	add_child(bottom)

	var new_btn := UiKit.gold_button("NEW GAME")
	new_btn.name = "NewBtn"
	new_btn.custom_minimum_size = Vector2(240, 46)
	new_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	new_btn.pressed.connect(_on_new_game.bind(new_btn))
	bottom.add_child(new_btn)

	var cont_btn := UiKit.button("CONTINUE")
	cont_btn.custom_minimum_size = Vector2(240, 46)
	cont_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cont_btn.visible = GameMan.has_save()
	cont_btn.name = "ContinueBtn"
	cont_btn.pressed.connect(_on_continue)
	bottom.add_child(cont_btn)

	var note := UiKit.label("Cat art: ToffeeCraft (free pack) — see NOTICE", 11, UiKit.DIM)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottom.add_child(note)

	refresh()


func refresh() -> void:
	_confirm_new = false
	for b in _find_buttons(self):
		if b.name == "ContinueBtn":
			b.visible = GameMan.has_save()
		if b.name == "NewBtn":
			b.text = "NEW GAME"


func _find_buttons(n: Node) -> Array:
	var out: Array = []
	for ch in n.get_children():
		if ch is Button:
			out.append(ch)
		out.append_array(_find_buttons(ch))
	return out


func _on_new_game(btn: Button) -> void:
	if GameMan.has_save() and not _confirm_new:
		_confirm_new = true
		btn.text = "OVERWRITE SAVE? TAP AGAIN"
		return
	GameMan.new_game()
	main.show_screen("story")


func _on_continue() -> void:
	if not GameMan.load_game():
		return
	if not GameMan.pending_beat().is_empty():
		main.show_screen("story")
	else:
		main.show_screen("desk")
