class_name NoirActivities
extends RefCounted

static func racket(s: NoirShell) -> void:
	s.heading("The Racket", "Small crimes. Big ambitions. / Experience opens doors.")
	var tabs := NoirKit.columns(s.body,false,2 if s.mobile else 4)
	for i in 4:
		s.action(tabs,CrimeData.tier_name(i),func() -> void: s.tier=i; s.crime_id=""; s.refresh(),true,s.tier==i)
	var open: bool = s.tier==0 or GameMan.tier_xp(s.tier-1)>=CrimeData.TIER_REQ[s.tier]
	var file := NoirKit.card(s.body,true)
	file.add_child(NoirKit.text("CASE FILES / "+CrimeData.tier_name(s.tier),25,NoirKit.INK,true))
	if not open:
		NoirKit.meter(file,"EXPERIENCE IN PREVIOUS TIER",GameMan.tier_xp(s.tier-1),CrimeData.TIER_REQ[s.tier],true)
		file.add_child(NoirKit.text("Keep working the earlier tier. Money cannot buy your way onto these jobs.",18,NoirKit.INK))
	else:
		file.add_child(NoirKit.text("%d experience banked here. Every attempt counts." % GameMan.tier_xp(s.tier),18,NoirKit.INK))
	s.picker(s.body)
	if s.crime_id!="":
		crime_detail(s)
		return
	var grid := NoirKit.columns(s.body,s.mobile)
	for c in CrimeData.crimes_in_tier(s.tier):
		var card := NoirKit.card(grid,true)
		card.add_child(NoirKit.text(c.name,26,NoirKit.INK,true))
		card.add_child(NoirKit.text(c.desc,18,NoirKit.INK))
		var pay := GameMan.crime_pay_range(c.id)
		card.add_child(NoirKit.text("%d–%d T  /  %d energy  /  %d nerve" % [pay.x,pay.y,c.energy,c.nerve],17,NoirKit.INK))
		card.add_child(NoirKit.text("%s  ·  %.0f%% odds  ·  %d runs" % [String(c.stat).to_upper(),GameMan.crime_chance(s.selected_cat,c.id)*100,GameMan.crime_runs(c.id)],17,NoirKit.INK))
		s.action(card,"OPEN CRIME FILE" if open else "LOCKED FILE",func() -> void: s.crime_id=c.id; s.refresh(),open)

static func crime_detail(s: NoirShell) -> void:
	var c := CrimeData.crime_by_id(s.crime_id)
	var card := NoirKit.card(s.body,true)
	card.add_child(NoirKit.text("CONFIDENTIAL / ONE CAT OPERATION",16,NoirKit.INK,true))
	card.add_child(NoirKit.text(c.name,32,NoirKit.INK,true))
	card.add_child(NoirKit.text(c.desc,20,NoirKit.INK))
	var pay := GameMan.crime_pay_range(c.id)
	card.add_child(NoirKit.text("Payout: %d–%d T before crew traits\nEnergy: %d  /  Nerve: %d\nRecommended: %s\nSuccess chance: %.0f%%\nHeat on success: %+.1f\nArrest risk on failure: %.0f%% before traits\nCrime experience: +%d per attempt\nCrew required: one available cat" % [pay.x,pay.y,c.energy,c.nerve,String(c.stat).to_upper(),GameMan.crime_chance(s.selected_cat,c.id)*100,c.heat,c.jail*100,c.xp],18,NoirKit.INK))
	card.add_child(NoirKit.text("Practice improves the odds. Failure can mean jail. The job resolves immediately.",17,NoirKit.INK))
	s.action(card,"COMMIT THE JOB",func() -> void:
		var out := GameMan.commit_crime(s.selected_cat,c.id)
		if out.is_empty(): s.notify("Job unavailable. Check crew, energy and nerve."); return
		var result := ("CLEAN GETAWAY. " if out.success else "JOB WENT WRONG. ")+String(out.text)
		if int(out.jailed)>0: result+=" Arrested: %d days. Bail is available in the Family dossier." % out.jailed
		s.notify(result)
	,GameMan.can_commit(s.selected_cat,c.id),true)
	s.action(s.body,"BACK TO THE JOB BOARD",func() -> void: s.crime_id=""; s.refresh())

static func family(s: NoirShell) -> void:
	s.heading("The Family","Loyal cats go further. Know who you are sending.")
	if s.page=="profile":
		profile(s)
		return
	var recruiting := s.page=="recruit"
	s.action(s.body,"VIEW THE FAMILY" if recruiting else "RECRUIT / MEET THE NEIGHBORHOOD",func() -> void: s.go("crew" if recruiting else "recruit"))
	var grid := NoirKit.columns(s.body,s.mobile,3)
	var ids := GameMan.recruitable_cats() if recruiting else GameMan.hired_cats()
	for cid in ids:
		var d := GameData.cat_by_id(cid)
		var c: Dictionary = GameMan.cats[cid]
		var card := NoirKit.card(grid,true)
		var row := NoirKit.row(card)
		row.add_child(UiKit.portrait(cid,96))
		row.add_child(NoirKit.text(d.name,25,NoirKit.INK,true))
		card.add_child(NoirKit.text(GameData.role_name(d.role)+"  /  LEVEL %d" % c.level,17,NoirKit.INK,true))
		card.add_child(NoirKit.text(d.flavor,17,NoirKit.INK))
		card.add_child(NoirKit.text("Muscle %.1f · Sneak %.1f · Charm %.1f" % [GameMan.effective_stat(cid,"muscle"),GameMan.effective_stat(cid,"sneak"),GameMan.effective_stat(cid,"charm")],17,NoirKit.INK))
		if recruiting:
			var cost := GameData.cat_cost(cid)
			s.action(card,"HIRE / %d T" % cost,func() -> void: s.notify("Welcome to the family." if GameMan.hire_cat(cid) else "Not enough cash."),GameMan.treats>=cost)
		else:
			card.add_child(NoirKit.text("%s · Energy %d/%d · Loyalty %d%%" % [GameMan.cat_state(cid).to_upper(),GameMan.energy(cid),GameMan.energy_max(cid),c.loyalty],17,NoirKit.INK))
			s.action(card,"OPEN DOSSIER",func() -> void: s.selected_cat=cid; s.go("profile"),true,cid=="jimmy_twotimes")

static func profile(s: NoirShell) -> void:
	var cid := s.selected_cat
	var d := GameData.cat_by_id(cid)
	var c: Dictionary = GameMan.cats[cid]
	var grid := NoirKit.columns(s.body,s.mobile)
	var card := NoirKit.card(grid,true)
	var portrait := UiKit.body_portrait(cid,230)
	portrait.size_flags_horizontal=Control.SIZE_SHRINK_CENTER
	card.add_child(portrait)
	card.add_child(NoirKit.text(d.name,30,NoirKit.INK,true))
	card.add_child(NoirKit.text(d.flavor,18,NoirKit.INK))
	card.add_child(NoirKit.text(GameData.role_name(d.role)+" / LEVEL %d" % c.level,18,NoirKit.INK))
	var stats := NoirKit.card(grid)
	for stat in ["muscle","sneak","charm"]:
		NoirKit.meter(stats,stat.to_upper(),GameMan.effective_stat(cid,stat),maxf(12,GameMan.effective_stat(cid,stat)))
	NoirKit.meter(stats,"LOYALTY",c.loyalty,100)
	NoirKit.meter(stats,"ENERGY",GameMan.energy(cid),GameMan.energy_max(cid))
	if int(c.level)<GameMan.MAX_LEVEL: NoirKit.meter(stats,"EXPERIENCE",c.xp,GameMan.xp_to_next(cid))
	var trait_text := GameData.trait_name(d.trait)
	stats.add_child(NoirKit.text(trait_text if trait_text!="" else "No special trait. Compare this cat's strengths when choosing a job.",18,NoirKit.PAPER))
	stats.add_child(NoirKit.text("STATUS / "+GameMan.cat_state(cid).to_upper(),20,NoirKit.PAPER,true))
	if GameMan.cat_state(cid)=="jail":
		stats.add_child(NoirKit.text("Held after a failed crime. %d day(s) remaining.\nUnavailable until released." % c.jail_days))
		var cost := GameMan.bail_cost(cid)
		s.action(stats,"POST BAIL / %d T" % cost,func() -> void: s.notify("Released from the precinct." if GameMan.post_bail(cid) else "Bail unavailable."),GameMan.treats>=cost,true)
	elif GameMan.cat_state(cid)=="wounded":
		stats.add_child(NoirKit.text("Recovering: %d day(s). Wounds heal when the books close." % c.wounded_days))
		s.action(stats,"PATCH UP / USE SALMON",func() -> void: s.notify(GameMan.use_item("salmon",cid)),GameMan.stash_count("salmon")>0)
	elif GameMan.cat_state(cid)=="assigned":
		stats.add_child(NoirKit.text("Assigned to "+String(WorldData.venue_by_id(c.venue).name)))
		s.action(stats,"RECALL FROM OPERATION",func() -> void: GameMan.clear_assignment(cid); s.notify("Recalled. Energy returned."))
	var actions := NoirKit.columns(s.body,s.mobile)
	s.action(actions,"TRAIN AT THE ALLEY GYM",func() -> void: s.go("gym"),GameMan.is_cat_available(cid))
	s.action(actions,"ASSIGN / EXPLORE THE CITY",func() -> void: s.go("city"),GameMan.is_cat_available(cid))
	var gear := NoirKit.card(s.body,true)
	gear.add_child(NoirKit.text("PERSONAL EFFECTS",25,NoirKit.INK,true))
	gear.add_child(NoirKit.text("Equipped: "+(String(WorldData.item_by_id(c.gear).name) if c.gear!="" else "Nothing"),18,NoirKit.INK))
	for item in WorldData.items():
		if item.kind=="gear" and GameMan.stash_count(item.id)>0:
			s.action(gear,"EQUIP "+String(item.name),func() -> void: GameMan.equip_item(item.id,cid); s.notify("Equipment updated."))
	s.action(gear,"VISIT THE FENCE",func() -> void: s.go("fence"))
	s.action(s.body,"BACK TO THE FAMILY",func() -> void: s.go("crew"))

static func gym(s: NoirShell) -> void:
	s.heading("The Alley Gym","Discipline builds empires. One session at a time.")
	s.body.add_child(NoirKit.picture("res://assets/art/noir/gym.png",190 if s.mobile else 260))
	s.picker(s.body)
	var cid := s.selected_cat
	var intro := NoirKit.card(s.body)
	var row := NoirKit.row(intro)
	row.add_child(UiKit.portrait(cid,96))
	row.add_child(NoirKit.text("%s\n%d/%d energy · %s" % [GameData.cat_by_id(cid).name,GameMan.energy(cid),GameMan.energy_max(cid),GameMan.cat_state(cid)],22,NoirKit.PAPER,true))
	intro.add_child(NoirKit.text("Each session costs %d energy. Gains diminish and fees increase with training. Money cannot buy back today's energy." % GameMan.TRAIN_ENERGY))
	var boosted := bool(GameMan.cats[cid].boosted)
	if boosted: intro.add_child(NoirKit.text("CATNIP BOOST / Next session counts double.",18,NoirKit.GREEN))
	elif GameMan.stash_count("catnip_tin")>0:
		s.action(intro,"OPEN A TIN OF CATNIP",func() -> void: s.notify(GameMan.use_item("catnip_tin",cid)))
	var grid := NoirKit.columns(s.body,s.mobile,3)
	for r in WorldData.regimens():
		var card := NoirKit.card(grid,true)
		card.add_child(NoirKit.text(r.name,28,NoirKit.INK,true))
		card.add_child(NoirKit.text(r.desc,18,NoirKit.INK))
		var gain := GameMan.train_gain(cid,r.stat)*(2 if boosted else 1)
		var value := GameMan.effective_stat(cid,r.stat)
		var cost := GameMan.train_fee(cid,r.stat)
		card.add_child(NoirKit.text("%s\n%.2f → %.2f\n+%.2f this session\n%d T / %d energy" % [String(r.stat).to_upper(),value,value+gain,gain,cost,GameMan.TRAIN_ENERGY],22,NoirKit.INK))
		s.action(card,"TRAIN",func() -> void: s.notify(GameMan.train_cat(cid,r.stat)),GameMan.is_cat_available(cid) and GameMan.energy(cid)>=GameMan.TRAIN_ENERGY and GameMan.treats>=cost,true)

static func fence(s: NoirShell) -> void:
	s.heading("The Fence","Quality goods for discerning cats. / Prices change overnight.")
	s.picker(s.body)
	var note := NoirKit.card(s.body,true)
	note.add_child(NoirKit.text("BACK-ALLEY QUOTATIONS",26,NoirKit.INK,true))
	note.add_child(NoirKit.text("Percentages compare today's asking price with the usual price, not yesterday. The Fence takes a cut on sales. Consumables apply to your selected cat where relevant.",17,NoirKit.INK))
	var grid := NoirKit.columns(s.body,s.mobile,3)
	for item in WorldData.items():
		var card := NoirKit.card(grid,true)
		card.add_child(NoirKit.text(item.name,26,NoirKit.INK,true))
		card.add_child(NoirKit.text(item.desc,18,NoirKit.INK))
		card.add_child(NoirKit.text("OWNED %d   /   %+.0f%% vs usual" % [GameMan.stash_count(item.id),(GameMan.price_mod(item.id)-1)*100],17,NoirKit.INK))
		if int(item.price)>0:
			var cost := GameMan.buy_price(item.id)
			s.action(card,"BUY / %d T" % cost,func() -> void: s.notify("Purchased "+String(item.name) if GameMan.buy_item(item.id) else "Purchase unavailable."),GameMan.treats>=cost)
		else: card.add_child(NoirKit.text("Taken on jobs. Never sold here.",17,NoirKit.INK))
		s.action(card,"SELL / %d T" % GameMan.sell_price(item.id),func() -> void: s.notify("Sold "+String(item.name) if GameMan.sell_item(item.id) else "None in the stash."),GameMan.stash_count(item.id)>0)
		if item.kind=="use":
			s.action(card,"USE",func() -> void: s.notify(GameMan.use_item(item.id,s.selected_cat)),GameMan.stash_count(item.id)>0)
		else:
			s.action(card,"EQUIP SELECTED CAT",func() -> void: s.notify("Equipment updated." if GameMan.equip_item(item.id,s.selected_cat) else "Equipment unavailable."),GameMan.stash_count(item.id)>0)
