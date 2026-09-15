class_name NoirBusiness
extends RefCounted

static func empire(s: NoirShell) -> void:
	s.heading("The Empire","From a room of your own to a city that knows your name.")
	var summary := NoirKit.card(s.body)
	summary.add_child(NoirKit.text("%d HOLDINGS / %d T EACH NIGHT" % [GameMan.properties.size(),GameMan.holdings_income()],27,NoirKit.PAPER,true))
	summary.add_child(NoirKit.text("Buildings change the rules. Their income is settled when you close the books."))
	var grid := NoirKit.columns(s.body,s.mobile)
	for p in WorldData.properties():
		var owned := GameMan.has_property(p.id)
		var card := NoirKit.card(grid,true)
		card.add_child(NoirKit.text("DEED OF OWNERSHIP / "+("ACQUIRED" if owned else "AVAILABLE"),16,NoirKit.INK,true))
		card.add_child(NoirKit.text(p.name,30,NoirKit.INK,true))
		card.add_child(NoirKit.text(p.perk,19,NoirKit.INK))
		card.add_child(NoirKit.text("%d T nightly income\nPurchase: %d T\nRequired respect: %d" % [p.income,p.cost,p.req_respect],18,NoirKit.INK))
		s.action(card,"OWNED" if owned else "ACQUIRE PROPERTY",func() -> void: s.notify("The keys are yours." if GameMan.buy_property(p.id) else "Requirements are not met."),GameMan.can_buy_property(p.id),not owned)
	s.action(s.body,"MORNING BUSINESS / TARIFFS & PAYROLL",func() -> void: s.go("morning"))
	s.action(s.body,"VIEW LAST NIGHT'S LEDGER",func() -> void: s.go("ledger"))

static func news(s: NoirShell) -> void:
	var paper := NoirKit.card(s.body,true)
	paper.add_child(NoirKit.text("THE DAILY WHISKER",46 if not s.mobile else 35,NoirKit.INK,true))
	paper.add_child(NoirKit.text("NEW YORK'S FINEST NEWS (MOSTLY) / DAY %d / 1928" % GameMan.day,15,NoirKit.INK,true))
	paper.add_child(HSeparator.new())
	var entries := CityData.headlines()
	var lead: Dictionary = entries[0]
	paper.add_child(NoirKit.text(lead.title,34,NoirKit.INK,true))
	paper.add_child(NoirKit.picture("res://assets/art/noir/street.png",200 if s.mobile else 300))
	paper.add_child(NoirKit.text(lead.body,21,NoirKit.INK))
	var grid := NoirKit.columns(paper,s.mobile)
	for i in range(1,entries.size()):
		var e: Dictionary = entries[i]
		var article := VBoxContainer.new()
		article.add_theme_constant_override("separation",10)
		article.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		grid.add_child(article)
		article.add_child(HSeparator.new())
		article.add_child(NoirKit.text(e.title,25,NoirKit.INK,true))
		article.add_child(NoirKit.text("DAY %d" % e.day,14,NoirKit.INK,true))
		article.add_child(NoirKit.text(e.body,18,NoirKit.INK))
	paper.add_child(HSeparator.new())
	paper.add_child(NoirKit.text("Same city. Different stories.",20,NoirKit.INK))

static func daily(s: NoirShell) -> void:
	match s.page:
		"morning": morning(s)
		"ops": operations(s)
		"ledger": ledger(s)

static func morning(s: NoirShell) -> void:
	s.heading("Morning Business","Set the terms. Keep the family fed. Then work the blocks.")
	var grid := NoirKit.columns(s.body,s.mobile)
	for g in WorldData.goods():
		var c := NoirKit.card(grid,true)
		c.add_child(NoirKit.text(g.name,28,NoirKit.INK,true))
		c.add_child(NoirKit.text(g.blurb,18,NoirKit.INK))
		var level := int(GameMan.tariffs[g.id])
		c.add_child(NoirKit.text("%s / +%.0f%% yield contribution\n+%.1f nightly tension" % [WorldData.TARIFF_LABELS[level],WorldData.TARIFF_YIELD[level]*100,WorldData.TARIFF_TENSION[level]],18,NoirKit.INK))
		s.action(c,"CHANGE TARIFF",func() -> void: GameMan.cycle_tariff(g.id); s.refresh())
	var pay := NoirKit.card(grid,true)
	pay.add_child(NoirKit.text("THE FAMILY'S CUT",28,NoirKit.INK,true))
	pay.add_child(NoirKit.text("%s / %d T expected tonight\nCurrent bribe estimate: %d T" % [WorldData.PAYOUT_LABELS[GameMan.payout_level],GameMan.nightly_payout(),GameMan.nightly_bribes()],19,NoirKit.INK))
	pay.add_child(NoirKit.text("A skimmed cut hurts loyalty. Unpaid cats may eventually walk.",18,NoirKit.INK))
	s.action(pay,"CHANGE CREW PAYOUT",func() -> void: GameMan.cycle_payout(); s.refresh())
	s.action(s.body,"OPEN CITY OPERATIONS",func() -> void: GameMan.phase=GameMan.PHASE_OPS; GameMan.save_game(); s.go("ops"),true,true)

static func operations(s: NoirShell) -> void:
	s.heading("City Operations","Reserve the crew's energy. Everything settles when the books close.")
	var grid := NoirKit.columns(s.body,s.mobile)
	for v in WorldData.venues():
		if not GameMan.venue_unlocked(v.id): continue
		var c := NoirKit.card(grid,true)
		c.add_child(NoirKit.text(v.name,27,NoirKit.INK,true))
		var ids := GameMan.assigned_to(v.id)
		if ids.is_empty():
			c.add_child(NoirKit.text("No instructions left today.",18,NoirKit.INK))
		else:
			c.add_child(NoirKit.text("%s / %.0f%% odds" % [WorldData.op_label(GameMan.venue_op(v.id)),GameMan.preview_chance(v.id,GameMan.venue_op(v.id),ids)*100],18,NoirKit.INK))
			for cid in ids:
				c.add_child(NoirKit.text(String(GameData.cat_by_id(cid).name),18,NoirKit.INK))
			s.action(c,"RECALL CREW",func() -> void:
				for cid in ids: GameMan.clear_assignment(cid)
				s.refresh())
		s.action(c,"VISIT / ASSIGN",func() -> void: s.venue_id=v.id; s.go("location"))
	var close := NoirKit.card(s.body)
	close.add_child(NoirKit.text("CLOSING TIME",28,NoirKit.PAPER,true))
	close.add_child(NoirKit.text("Resolve assigned jobs, collect protection and holdings income, pay the crew and police, and face any rival response. Then a new day begins."))
	close.add_child(NoirKit.text("Expected payroll: %d T / bribes now: %d T\n%s" % [GameMan.nightly_payout(),GameMan.nightly_bribes(),"Your crew has instructions." if GameMan.any_assigned() else "No jobs assigned. Expenses still apply."],18,NoirKit.PAPER))
	s.action(close,"CLOSE THE BOOKS / END DAY %d" % GameMan.day,func() -> void: GameMan.end_day(); s.go("ledger"),true,true)
	s.action(s.body,"BACK TO MORNING BUSINESS",func() -> void: s.go("morning"))

static func ledger(s: NoirShell) -> void:
	s.heading("Closing the Books","Every favor has a price. Every night leaves a record.")
	var report := GameMan.last_report
	if report.is_empty():
		s.body.add_child(NoirKit.text("No settlement is recorded yet. Assign city operations and close the books to receive your first report."))
		s.action(s.body,"CITY OPERATIONS",func() -> void: s.go("ops"))
		return
	var paper := NoirKit.card(s.body,true)
	paper.add_child(NoirKit.text("SETTLED / DAY %d" % report.day,32,NoirKit.INK,true))
	for pair in [["Job revenue",report.takings],["Protection",report.protection],["Holdings income",report.get("holdings",0)],["Payroll actually paid",-int(report.get("paid_payroll",0))],["Bribes actually paid",-int(report.get("paid_bribes",0))]]:
		var r := NoirKit.row(paper)
		r.add_child(NoirKit.text(pair[0],19,NoirKit.INK))
		var amount := NoirKit.text("%+d T" % int(pair[1]),20,NoirKit.INK)
		amount.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
		r.add_child(amount)
	paper.add_child(HSeparator.new())
	paper.add_child(NoirKit.text("NET CASH CHANGE  /  %+d T" % int(report.net),29,NoirKit.INK,true))
	paper.add_child(NoirKit.text("Includes any cash lost to rival activity.\nRespect +%d / Heat %+.1f" % [report.respect_gain,report.get("heat_change",0)],17,NoirKit.INK))
	if bool(report.unpaid): paper.add_child(NoirKit.text("UNPAID PAYROLL: %d T was due. Loyalty suffered." % report.payout,18,UiKit.INK_RED))
	if int(report.get("paid_bribes",0))<int(report.bribes): paper.add_child(NoirKit.text("BRIBES UNPAID: Police attention increased.",18,UiKit.INK_RED))
	for op in report.ops:
		paper.add_child(HSeparator.new())
		paper.add_child(NoirKit.text("%s / %s / %d T" % [WorldData.venue_by_id(op.venue).name,"SUCCESS" if op.success else "BOTCHED",op.take],20,NoirKit.INK,true))
	for key in ["injuries","levelled","defected"]:
		for cid in report.get(key,[]): paper.add_child(NoirKit.text(key.to_upper()+" / "+String(GameData.cat_by_id(cid).name),18,NoirKit.INK))
	if report.rival!="": paper.add_child(NoirKit.text(report.rival,18,UiKit.INK_RED))
	s.action(s.body,"DAY %d / RETURN TO THE BACK ROOM" % GameMan.day,func() -> void: s.go("home"),true,true)

static func story(s: NoirShell) -> void:
	var beat := s.story_beat
	if beat.is_empty():
		s.heading("The Telephone Is Quiet","There are no messages waiting. Work the city and check back another day.")
		s.action(s.body,"BACK TO THE ROOM",func() -> void: s.go("home"))
		return
	s.heading(beat.title,"PRIVATE BUSINESS / The back room")
	var line: Dictionary = beat.lines[mini(s.story_line,beat.lines.size()-1)]
	var grid := NoirKit.columns(s.body,s.mobile)
	var art := NoirKit.card(grid)
	var portrait := UiKit.body_portrait(line.who,220 if s.mobile else 340)
	portrait.size_flags_horizontal=Control.SIZE_SHRINK_CENTER
	art.add_child(portrait)
	art.add_child(NoirKit.text(GameData.cat_by_id(line.who).name,28,NoirKit.PAPER,true))
	var dialogue := NoirKit.card(grid,true)
	dialogue.add_child(NoirKit.text(s.story_reply if s.story_reply!="" else ("Your call, Jimmy." if s.story_choices else line.text),22,NoirKit.INK))
	if s.story_reply!="":
		s.action(dialogue,"RETURN TO THE BACK ROOM",func() -> void: s.go("home"),true,true)
	elif s.story_choices:
		for i in beat.choices.size():
			var choice: Dictionary=beat.choices[i]
			s.action(dialogue,choice.text,func() -> void:
				s.story_reply=GameMan.resolve_beat(beat.id,i)
				if s.story_reply=="": s.notify("Choice unavailable.")
				else: s.refresh()
			,GameMan.treats+int(choice.get("treats",0))>=0)
	else:
		s.action(dialogue,"CONTINUE",func() -> void:
			if s.story_line<beat.lines.size()-1: s.story_line+=1
			elif not beat.choices.is_empty(): s.story_choices=true
			else: GameMan.resolve_beat(beat.id,-1); s.go("home"); return
			s.refresh()
		,true,true)
	# Reading a letter never consumes it. Leaving resumes from its first line.
	s.action(s.body,"LEAVE THE MESSAGE FOR LATER",func() -> void: s.go("home"))
