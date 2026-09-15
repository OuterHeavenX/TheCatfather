class_name NoirShell
extends Control

## Persistent shell. Views use existing GameMan commands; rendering never
## advances time or resolves an action. Ephemeral selections are not saves.
var main: Main
var page := "title"
var selected_cat := "jimmy_twotimes"
var district_id := "little_italy"
var venue_id := "blind_pig"
var crime_id := ""
var tier := 0
var operation := "collect"
var message := ""
var story_line := 0
var story_choices := false
var story_reply := ""
var story_beat: Dictionary = {}
var body: VBoxContainer
var scroll: ScrollContainer
var mobile := true
var rendered_page := ""

func go(target: String) -> void:
	if target == "story":
		story_beat = GameMan.pending_beat()
		story_line = 0
		story_choices = false
		story_reply = ""
	page = "home" if target == "desk" else target
	message = ""
	refresh()

func refresh() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	mobile = main.is_portrait() if is_instance_valid(main) else get_viewport_rect().size.x < 760
	var bg := ColorRect.new()
	bg.color = NoirKit.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right","top","bottom"]:
		var inset := 0
		if OS.has_feature("web"):
			inset = int(JavaScriptBridge.eval("parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--safe-"+side+"')) || 0"))
		margin.add_theme_constant_override("margin_"+side,(12 if mobile else 24)+inset)
	# CSS exposes safe-area values; the Godot shell applies the insets.
	add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation",10)
	margin.add_child(root)
	var brand := NoirKit.row(root)
	var home := NoirKit.button("THE CATFATHER",func() -> void: go("home") if GameMan.started else go("title"))
	home.add_theme_font_size_override("font_size",24)
	home.custom_minimum_size.y = 44
	brand.add_child(home)
	var sound := NoirKit.button("Music: off" if Jukebox.muted else "Music: on",func() -> void: Jukebox.toggle(); refresh())
	sound.custom_minimum_size.x = 98
	sound.size_flags_horizontal = Control.SIZE_SHRINK_END
	sound.add_theme_font_size_override("font_size",16)
	brand.add_child(sound)
	if page != "title": _hud(root)
	if GameMan.save_error != OK:
		root.add_child(NoirKit.text("Save could not be written. Keep this game open and retry from More.",16,NoirKit.RED))
	if OS.has_feature("web") and bool(JavaScriptBridge.eval("window.catfatherVolatile === true")):
		root.add_child(NoirKit.text("Temporary session: browser storage is unavailable. Progress will be lost when this page closes.",16,NoirKit.PAPER))
	if message != "":
		var alert := NoirKit.card(root)
		alert.add_child(NoirKit.text(message,17,NoirKit.PAPER))
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",16)
	scroll.add_child(body)
	match page:
		"title": _title()
		"home": _home()
		"city": _city()
		"district": _district()
		"location": _location()
		"racket": NoirActivities.racket(self)
		"crew", "profile", "recruit": NoirActivities.family(self)
		"gym": NoirActivities.gym(self)
		"fence": NoirActivities.fence(self)
		"empire": NoirBusiness.empire(self)
		"news": NoirBusiness.news(self)
		"morning", "ops", "ledger": NoirBusiness.daily(self)
		"story": NoirBusiness.story(self)
		_: _more()
	if page != "title": _nav(root)
	UiKit.allow_scroll_drag(self)
	if rendered_page != page:
		body.modulate.a = 0.0
		create_tween().tween_property(body,"modulate:a",1.0,0.12)
	rendered_page = page

func _hud(parent: Node) -> void:
	var r := NoirKit.row(parent)
	var values := [["CASH","%d T" % GameMan.treats],["ENERGY","%d/%d" % [GameMan.energy("jimmy_twotimes"),GameMan.energy_max("jimmy_twotimes")]],["NERVE","%d/%d" % [GameMan.nerve,GameMan.nerve_max()]],["HEAT","%d" % GameMan.heat],["RESPECT",str(GameMan.respect)]]
	for data in values:
		var v := VBoxContainer.new()
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r.add_child(v)
		var label := NoirKit.text(data[0],12,NoirKit.MUTED,true)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(label)
		var value := NoirKit.text(data[1],18,NoirKit.RED if data[0]=="HEAT" and GameMan.heat>=35 else NoirKit.PAPER)
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(value)
	var detail := NoirKit.button("DAY %d   /   %s   /   Resource guide" % [GameMan.day,GameData.rank_name(GameMan.respect)],func() -> void: go("resources"))
	detail.custom_minimum_size.y = 44
	detail.add_theme_font_size_override("font_size",16)
	parent.add_child(detail)

func _nav(parent: Node) -> void:
	var r := NoirKit.row(parent)
	r.add_theme_constant_override("separation",4)
	for target in ["city","racket","crew","empire","more"]:
		var b := NoirKit.button(target.to_upper(),func() -> void: go(target),page == target)
		b.add_theme_font_size_override("font_size",16 if mobile else 20)
		b.add_theme_stylebox_override("normal",NoirKit.box(Color("632b27") if page==target else NoirKit.DARK,NoirKit.BRASS,4))
		b.custom_minimum_size.y = 64
		b.icon = load("res://assets/ui/noir/"+target+".svg")
		b.expand_icon = true
		b.add_theme_constant_override("icon_max_width",22)
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		r.add_child(b)

func heading(title: String, subtitle: String) -> void:
	body.add_child(NoirKit.text(title.to_upper(),32,NoirKit.PAPER,true))
	if subtitle != "": body.add_child(NoirKit.text(subtitle,17,NoirKit.MUTED))

func action(parent: Node, label: String, call: Callable, enabled: bool = true, primary: bool = false) -> Button:
	var b := NoirKit.button(label,call,primary)
	b.disabled = not enabled
	parent.add_child(b)
	return b

func notify(line: String) -> void:
	var previous_scroll := scroll.scroll_vertical if is_instance_valid(scroll) else 0
	message = line if line != "" else "That action is unavailable. Review the requirements."
	refresh()
	scroll.set_deferred("scroll_vertical",previous_scroll)

func refresh_keep_scroll() -> void:
	var previous_scroll := scroll.scroll_vertical
	refresh()
	scroll.set_deferred("scroll_vertical",previous_scroll)

func picker(parent: Node, available_only: bool = false) -> void:
	var option := OptionButton.new()
	option.custom_minimum_size.y = 48
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option.fit_to_longest_item = false
	option.clip_text = true
	option.add_theme_font_size_override("font_size",18)
	option.get_popup().add_theme_font_size_override("font_size",18)
	option.get_popup().add_theme_constant_override("v_separation",26)
	option.get_popup().add_theme_stylebox_override("panel",NoirKit.box(NoirKit.DARK))
	option.add_theme_stylebox_override("normal",NoirKit.box(NoirKit.DARK))
	option.add_theme_color_override("font_color",NoirKit.CREAM)
	var ids: Array = []
	for cid in GameMan.hired_cats():
		if available_only and not GameMan.is_cat_available(cid): continue
		ids.append(cid)
		option.add_item(String(GameData.cat_by_id(cid).name)+" / "+GameMan.cat_state(cid))
	if selected_cat not in ids and not ids.is_empty(): selected_cat = ids[0]
	option.select(ids.find(selected_cat))
	option.item_selected.connect(func(index: int) -> void: selected_cat=ids[index]; refresh_keep_scroll())
	parent.add_child(option)

func _title() -> void:
	heading("Crime. Family. Ambition.","NEW YORK, 1928  /  A city full of cats. A shortage of loyalty.")
	var layout := NoirKit.columns(body,mobile)
	layout.add_child(NoirKit.picture("res://assets/art/noir/back_room.png",310 if mobile else 420))
	var c := NoirKit.card(layout,true)
	c.add_child(NoirKit.text("Your empire starts in the back room.",27,NoirKit.INK,true))
	c.add_child(NoirKit.text("The Don's catnip is missing. The truce is fraying. Jimmy has a family to feed and a city to win.",18,NoirKit.INK))
	action(c,"CONTINUE YOUR EMPIRE",func() -> void:
		if GameMan.load_game(): go("home")
		else: notify("This save could not be loaded. It has not been overwritten.")
	,GameMan.has_save(),true)
	action(c,"BEGIN JIMMY'S STORY",func() -> void:
		if GameMan.has_save():
			message="A saved empire exists. Continue it above, or confirm below to start again."
			refresh()
		else:
			GameMan.new_game(); go("home")
	)
	if message != "" and GameMan.has_save(): action(c,"CONFIRM NEW GAME — REPLACE SAVE",func() -> void: GameMan.new_game(); go("home"))

func _home() -> void:
	heading("The Back Room","Your empire starts here.")
	var layout := NoirKit.columns(body,mobile)
	var left := VBoxContainer.new()
	left.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	layout.add_child(left)
	left.add_child(NoirKit.picture("res://assets/art/noir/back_room.png",280 if mobile else 390))
	left.add_child(NoirKit.text('“Same city. Bigger plans. Bigger plans.”\n— Jimmy “Two-Times”',20,NoirKit.PAPER))
	var todo := NoirKit.card(layout,true)
	todo.add_child(NoirKit.text("TODAY'S BUSINESS",26,NoirKit.INK,true))
	var ready := 0
	var injured := 0
	var jailed := 0
	for cid in GameMan.hired_cats():
		match GameMan.cat_state(cid):
			"ready": ready+=1
			"wounded": injured+=1
			"jail": jailed+=1
	todo.add_child(NoirKit.text("%d ready / %d wounded / %d inside" % [ready,injured,jailed],17,NoirKit.INK))
	var beat := GameMan.pending_beat()
	if not beat.is_empty():
		todo.add_child(NoirKit.text("A message is waiting: "+String(beat.title),18,NoirKit.INK))
		action(todo,"ANSWER THE CALL",func() -> void: go("story"),true,true)
	action(todo,"MORNING BUSINESS  /  Tariffs & crew cut",func() -> void: go("morning"))
	action(todo,"WORK THE CITY  /  Collections & shakedowns",func() -> void: go("city"))
	action(todo,"CHECK THE FAMILY  /  %d on the books" % GameMan.hired_cats().size(),func() -> void: go("crew"))
	todo.add_child(NoirKit.text("Tonight: %d T payroll · %d T bribes\nHoldings pay %d T when you close the books." % [GameMan.nightly_payout(),GameMan.nightly_bribes(),GameMan.holdings_income()],17,NoirKit.INK))
	action(todo,"REVIEW CITY OPERATIONS",func() -> void: go("ops"))
	var news: Dictionary = CityData.headlines()[0]
	var paper := NoirKit.card(body,true)
	paper.add_child(NoirKit.text("THE DAILY WHISKER",27,NoirKit.INK,true))
	paper.add_child(NoirKit.text(news.title,23,NoirKit.INK,true))
	paper.add_child(NoirKit.text(news.body,18,NoirKit.INK))
	action(paper,"READ TODAY'S PAPER",func() -> void: go("news"))

func _city() -> void:
	heading("New York, 1928","A city of opportunities. And consequences.")
	if not GameMan.pending_beat().is_empty():
		action(body,"MESSAGE AT THE BACK ROOM / "+String(GameMan.pending_beat().title),func() -> void: go("story"),true,true)
	var map := CityMap.new()
	map.custom_minimum_size.y=440 if mobile else 510
	map.district_selected.connect(func(id: String) -> void: district_id=id; go("district"))
	body.add_child(map)
	var grid := NoirKit.columns(body,mobile,3)
	for d in CityData.districts():
		var c := NoirKit.card(grid)
		c.add_child(NoirKit.text(d.name,24,NoirKit.PAPER,true))
		c.add_child(NoirKit.text(d.tag,17))
		var open := CityData.unlocked(d.id)
		action(c,"ENTER DISTRICT" if open else ("FUTURE DISTRICT" if int(d.respect)<0 else "%d RESPECT REQUIRED" % d.respect),func() -> void: district_id=d.id; go("district"),open)

func _district() -> void:
	var d := CityData.district(district_id)
	heading(d.name,d.tag)
	if not CityData.unlocked(district_id):
		body.add_child(NoirKit.text("This district is beyond your current reach. "+("Its opportunities belong to a future chapter." if int(d.respect)<0 else "Earn %d respect through city operations to open its doors." % d.respect)))
		action(body,"BACK TO THE MAP",func() -> void: go("city"))
		return
	body.add_child(NoirKit.picture("res://assets/art/noir/docks.png" if district_id=="docks" else "res://assets/art/noir/street.png",240 if mobile else 330))
	var grid := NoirKit.columns(body,mobile)
	for vid in d.venues:
		var v := WorldData.venue_by_id(vid)
		var c := NoirKit.card(grid,true)
		var r := NoirKit.row(c)
		var art := NoirKit.picture(WorldData.venue_scene(vid),96)
		art.custom_minimum_size.x=96
		art.size_flags_horizontal=Control.SIZE_SHRINK_BEGIN
		r.add_child(art)
		r.add_child(NoirKit.text(v.name,25,NoirKit.INK,true))
		c.add_child(NoirKit.text(CityData.description(vid),18,NoirKit.INK))
		action(c,"VISIT LOCATION",func() -> void: venue_id=vid; go("location"),GameMan.venue_unlocked(vid),true)
	if district_id=="little_italy":
		action(body,"THE ALLEY GYM",func() -> void: go("gym"))
		action(body,"THE FENCE  /  Back-alley market",func() -> void: go("fence"))
	action(body,"BACK TO NEW YORK",func() -> void: go("city"))

func _location() -> void:
	var v := WorldData.venue_by_id(venue_id)
	var state: Dictionary = GameMan.venues[venue_id]
	heading(v.name,CityData.for_venue(venue_id).name+"  /  "+("Under your protection" if state.controlled else "Independent business"))
	var grid := NoirKit.columns(body,mobile)
	var scene := VBoxContainer.new()
	scene.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	grid.add_child(scene)
	if venue_id in ["blind_pig","fishmonger"]:
		scene.add_child(NoirKit.picture("res://assets/art/noir/docks.png" if venue_id=="fishmonger" else "res://assets/art/noir/street.png",240 if mobile else 350))
	else:
		var original := NoirKit.picture(WorldData.venue_scene(venue_id),128)
		original.custom_minimum_size.x=128
		original.size_flags_horizontal=Control.SIZE_SHRINK_CENTER
		scene.add_child(original)
		scene.add_child(NoirKit.text("FROM THE CITY FILES / "+String(v.name),22,NoirKit.PAPER,true))
	var info := NoirKit.card(grid,true)
	var row := NoirKit.row(info)
	var thumb := NoirKit.picture(WorldData.venue_scene(venue_id),96)
	thumb.custom_minimum_size.x=96
	thumb.size_flags_horizontal=Control.SIZE_SHRINK_BEGIN
	row.add_child(thumb)
	row.add_child(NoirKit.text(v.perk,18,NoirKit.INK))
	info.add_child(NoirKit.text(CityData.description(venue_id),18,NoirKit.INK))
	info.add_child(NoirKit.text("Unrest: %.0f%%\nJob injury risk: %s\nPolice attention: %.0f / 100" % [state.unrest,v.risk_label,GameMan.heat],18,NoirKit.INK))
	var jobs := NoirKit.card(body)
	jobs.add_child(NoirKit.text("LEAVE INSTRUCTIONS",24,NoirKit.PAPER,true))
	var modes := NoirKit.row(jobs)
	for op in ["collect","shakedown"]:
		action(modes,WorldData.op_label(op),func() -> void: operation=op; refresh(),true,operation==op)
	var assigned := GameMan.assigned_to(venue_id)
	var pay := GameMan.yield_range(venue_id,operation)
	jobs.add_child(NoirKit.text("%d–%d T before crew bonuses · %d energy per cat\nUses %s. Resolves when the books close." % [pay.x,pay.y,GameMan.JOB_ENERGY,String(v.collect_stat if operation=="collect" else v.shake_stat).to_upper()]))
	picker(jobs)
	var proposed := assigned.duplicate()
	if selected_cat not in proposed: proposed.append(selected_cat)
	jobs.add_child(NoirKit.text("With this crew: %.0f%% success chance" % (GameMan.preview_chance(venue_id,operation,proposed)*100),18,NoirKit.PAPER))
	var can := GameMan.is_cat_available(selected_cat) and GameMan.cat_state(selected_cat)!="assigned" and GameMan.energy(selected_cat)>=GameMan.JOB_ENERGY and (assigned.is_empty() or GameMan.venue_op(venue_id)==operation)
	action(jobs,"ASSIGN SELECTED CAT",func() -> void: notify("Instructions sent. The job is reserved for tonight." if GameMan.assign_cat(selected_cat,venue_id,operation) else "Assignment unavailable."),can,true)
	for cid in assigned:
		action(jobs,"RECALL "+String(GameData.cat_by_id(cid).name),func() -> void: GameMan.clear_assignment(cid); notify("Recalled. Reserved energy returned."))
	action(body,"REVIEW OPERATIONS",func() -> void: go("ops"))
	action(body,"LEAVE / DISTRICT",func() -> void: district_id=CityData.for_venue(venue_id).id; go("district"))

func _more() -> void:
	heading("The Back Office","Everything has its place.")
	if page == "resources":
		body.add_child(NoirKit.text("Energy belongs to each cat. Training, crimes and venue work compete for it. Energy refills when the books close.\n\nNerve belongs to the family. Crime spends it; %d points return per day, up to %d.\n\nHeat reduces crime odds and increases bribes. Respect opens venues and holdings through successful city operations.\n\nTime advances when you close the books. There is no offline refill timer." % [GameMan.nerve_regen(),GameMan.nerve_max()]))
	var grid := NoirKit.columns(body,mobile)
	for data in [["home","THE BACK ROOM"],["news","THE DAILY WHISKER"],["gym","THE ALLEY GYM"],["fence","THE FENCE & STASH"],["morning","MORNING BUSINESS"],["ops","CITY OPERATIONS"],["ledger","LAST NIGHT'S LEDGER"],["recruit","RECRUIT THE FAMILY"],["resources","RESOURCE GUIDE"]]:
		action(grid,data[1],func() -> void: go(data[0]))
	action(body,"SAVE PROGRESS",func() -> void: GameMan.save_game(); notify("Saved locally." if GameMan.save_error==OK else "Save failed. Keep this session open."))
	action(body,"TITLE SCREEN",func() -> void: go("title"))
