class_name TitleScreen
extends Control

var main: Main
var _confirm_new := false


func _ready() -> void:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(vb)

	var art := UiKit.portrait("al_catpone", 96)
	art.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vb.add_child(art)

	var t := UiKit.title_label("THE CATFATHER", 50)
	vb.add_child(t)

	var sub := UiKit.label("A mobster-cat crew empire", 18, UiKit.DIM)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(sub)

	vb.add_child(UiKit.spacer(10))

	var new_btn := UiKit.gold_button("NEW GAME")
	new_btn.name = "NewBtn"
	new_btn.custom_minimum_size = Vector2(240, 46)
	new_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	new_btn.pressed.connect(_on_new_game.bind(new_btn))
	vb.add_child(new_btn)

	var cont_btn := UiKit.button("CONTINUE")
	cont_btn.custom_minimum_size = Vector2(240, 46)
	cont_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cont_btn.visible = GameMan.has_save()
	cont_btn.name = "ContinueBtn"
	cont_btn.pressed.connect(_on_continue)
	vb.add_child(cont_btn)

	vb.add_child(UiKit.spacer(10))

	var note := UiKit.label("Cat art: ToffeeCraft (free pack) — see NOTICE", 11, UiKit.DIM)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(note)

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
	main.show_screen("office")


func _on_continue() -> void:
	if GameMan.load_game():
		main.show_screen("office")
