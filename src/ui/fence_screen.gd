class_name FenceScreen
extends Control

## The Fence: goods at a price that moves overnight, and the holdings that quietly
## change the rules — a bed for every cat, a room to plan in, a bank of your own.

var main: Main

var _bar_slot: MarginContainer
var _list: VBoxContainer


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	margin.add_child(vb)

	_bar_slot = MarginContainer.new()
	vb.add_child(_bar_slot)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vb.add_child(scroll)

	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_list)

	var back := UiKit.button("< DESK")
	back.custom_minimum_size = Vector2(0, 32)
	back.pressed.connect(func() -> void: main.show_screen("desk"))
	vb.add_child(back)


func refresh() -> void:
	for ch in _bar_slot.get_children():
		ch.queue_free()
	_bar_slot.add_child(UiKit.status_bar())
	for ch in _list.get_children():
		ch.queue_free()

	_list.add_child(UiKit.screen_header("The Fence"))
	_list.add_child(UiKit.body_text(
		"Prices move every night. What is dear this morning may be cheap tomorrow, "
		+ "and what you are sitting on may never be worth more than it is right now.",
		12, UiKit.DIM))

	for item in WorldData.items():
		var row := _item_panel(item)
		if row != null:
			_list.add_child(row)

	_list.add_child(UiKit.screen_header("Holdings"))
	_list.add_child(UiKit.body_text("Bought once. Paid out every night, for as long as you hold them.",
		12, UiKit.DIM))
	for pr in WorldData.properties():
		_list.add_child(_property_panel(pr))

	UiKit.allow_scroll_drag(self)


func _item_panel(item: Dictionary) -> PanelContainer:
	var iid := String(item["id"])
	var held := GameMan.stash_count(iid)
	var buyable := GameMan.buy_price(iid) > 0
	# Things nobody sells and you do not have are not worth a line on the board.
	if not buyable and held <= 0:
		return null

	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.panel_style())
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	p.add_child(vb)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 6)
	vb.add_child(head)
	var n := UiKit.label(String(item["name"]), 13, UiKit.INK_GOLD)
	n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(n)
	if held > 0:
		head.add_child(UiKit.label("x%d" % held, 12, UiKit.INK))

	var desc := UiKit.body_text(String(item["desc"]), 11, UiKit.INK_DIM)
	vb.add_child(desc)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	vb.add_child(row)
	row.add_child(_drift_label(iid))

	var pad := Control.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(pad)

	if buyable:
		var cost := GameMan.buy_price(iid)
		var bb := UiKit.button("BUY %d T" % cost)
		bb.add_theme_font_size_override("font_size", 11)
		bb.custom_minimum_size = Vector2(0, 26)
		bb.disabled = GameMan.treats < cost
		bb.pressed.connect(func() -> void:
			GameMan.buy_item(iid)
			refresh()
		)
		row.add_child(bb)

	if held > 0:
		var sb := UiKit.button("SELL %d T" % GameMan.sell_price(iid))
		sb.add_theme_font_size_override("font_size", 11)
		sb.custom_minimum_size = Vector2(0, 26)
		sb.pressed.connect(func() -> void:
			GameMan.sell_item(iid)
			refresh()
		)
		row.add_child(sb)
	return p


## Which way the night moved this price, so the board reads as a market.
func _drift_label(item_id: String) -> Label:
	var mod := GameMan.price_mod(item_id)
	var pct := int(round((mod - 1.0) * 100.0))
	if pct > 6:
		return UiKit.label("up %d%%" % pct, 11, UiKit.INK_RED)
	if pct < -6:
		return UiKit.label("down %d%%" % absi(pct), 11, UiKit.INK_GREEN)
	return UiKit.label("steady", 11, UiKit.INK_DIM)


func _property_panel(pr: Dictionary) -> PanelContainer:
	var pid := String(pr["id"])
	var owned := GameMan.has_property(pid)

	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UiKit.panel_style())
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	p.add_child(vb)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 6)
	vb.add_child(head)
	var n := UiKit.display_label(String(pr["name"]), 14, UiKit.INK_GOLD if owned else UiKit.INK)
	n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	n.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(n)
	if owned:
		head.add_child(UiKit.caps_label("YOURS", 12, UiKit.INK_GREEN))

	vb.add_child(UiKit.body_text(String(pr["perk"]), 11, UiKit.INK_BLUE))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	vb.add_child(row)
	var income := UiKit.label("+%d T a night" % int(pr["income"]), 11, UiKit.INK_DIM)
	income.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(income)

	if owned:
		return p

	var need := int(pr["req_respect"])
	if GameMan.respect < need:
		row.add_child(UiKit.label("needs %d respect" % need, 11, UiKit.INK_RED))
		return p

	var b := UiKit.gold_button("BUY %d T" % int(pr["cost"]))
	b.add_theme_font_size_override("font_size", 12)
	b.custom_minimum_size = Vector2(0, 28)
	b.disabled = not GameMan.can_buy_property(pid)
	b.pressed.connect(func() -> void:
		GameMan.buy_property(pid)
		refresh()
	)
	row.add_child(b)
	return p
