extends Node

var failures: Array = []

func check(ok: bool, name: String) -> void:
	print("PASS " if ok else "FAIL ",name)
	if not ok: failures.append(name)

func _ready() -> void:
	if not "/.audit/" in OS.get_user_data_dir().replace("\\","/"):
		push_error("Redesign tests require isolated .audit user data")
		get_tree().quit(2)
		return
	check(Main.responsive_size(Vector2i(1179,2556),Vector2i(393,852))==Vector2i(393,852),"high-density iPhone uses CSS viewport")
	check(Main.responsive_size(Vector2i(2532,1170),Vector2i(844,390))==Vector2i(844,390),"landscape phone keeps its CSS height")
	check(Main.responsive_size(Vector2i(390,844))==Vector2i(390,844),"native viewport remains unchanged")
	check(Main.responsive_size(Vector2i(300,420))==Vector2i(320,480),"minimum mobile layout remains usable")
	var fixture := FileAccess.get_file_as_string("res://tests/fixtures/legacy_unversioned.cfg")
	var file := FileAccess.open(GameMan.SAVE_PATH,FileAccess.WRITE)
	file.store_string(fixture)
	file.close()
	check(GameMan.load_game(),"unversioned fixture loads")
	check(GameMan.day==7 and GameMan.treats==531 and GameMan.respect==11,"legacy finances preserved")
	check(GameMan.cats.jimmy_twotimes.gear=="crowbar" and GameMan.cats.jimmy_twotimes.venue=="blind_pig","legacy IDs, gear and assignments preserved")
	check(GameMan.story_flags.has("paid_nicky") and GameMan.align=="don","legacy story preserved")
	check(GameMan.journal.is_empty() and GameMan.last_report.is_empty(),"version 0 new fields default safely")
	check(GameMan.tutorial_complete,"legacy empire is not interrupted by tutorial")
	GameMan.save_game()
	var cfg := ConfigFile.new()
	cfg.load(GameMan.SAVE_PATH)
	check(int(cfg.get_value("game","save_version",-1))==2,"explicit schema version written")
	GameMan.new_game()
	check(GameMan.tutorial_active() and GameMan.tutorial_step==0,"new empire starts beginner tutorial")
	GameMan.set_tutorial_step(4)
	check(GameMan.load_game() and GameMan.tutorial_step==4 and GameMan.tutorial_active(),"tutorial progress survives reload")
	GameMan.complete_tutorial()
	check(GameMan.load_game() and GameMan.tutorial_complete,"tutorial completion survives reload")
	GameMan.restart_tutorial()
	check(GameMan.tutorial_step==0 and GameMan.tutorial_active(),"tutorial can be replayed")
	GameMan.complete_tutorial()
	GameMan.new_game()
	var cid := "jimmy_twotimes"
	var preview := GameMan.crime_chance(cid,"milk_bottle")
	var result := GameMan.commit_crime(cid,"milk_bottle")
	check(is_equal_approx(preview,result.chance),"crime preview equals resolution")
	check(GameMan.journal.size()==1,"crime records news once")
	GameMan.new_game()
	check(GameMan.assign_cat(cid,"blind_pig","collect"),"venue assignment succeeds")
	var energy := GameMan.energy(cid)
	check(not GameMan.assign_cat(cid,"piazza","collect") and GameMan.energy(cid)==energy,"duplicate reservation cannot spend energy")
	GameMan.clear_assignment(cid)
	check(GameMan.energy(cid)==GameMan.energy_max(cid),"recall restores reservation exactly once")
	GameMan.resolve_beat("summons",-1)
	GameMan.day=2
	GameMan.treats=0
	check(GameMan.resolve_beat("squeaker",0)=="" and GameMan.treats==0 and not GameMan.story_seen.has("squeaker"),"unaffordable story choice rejected")
	GameMan.treats=100
	GameMan.resolve_beat("squeaker",0)
	GameMan.resolve_beat("squeaker",0)
	check(GameMan.treats==70,"story choice paid only once")
	GameMan.new_game()
	GameMan.treats=0
	var cash := GameMan.treats
	var report := GameMan.end_day()
	check(int(report.net)==GameMan.treats-cash and int(report.get("paid_payroll",0))==0,"ledger reports actual cash flow")
	GameMan.last_report={}
	GameMan.journal=[]
	check(GameMan.load_game() and not GameMan.last_report.is_empty() and not GameMan.journal.is_empty(),"ledger and news survive reload")
	for i in 40: GameMan.record_event("Test","Event")
	check(GameMan.journal.size()==24,"journal is bounded")
	GameMan.new_game()
	GameMan.treats=50000
	GameMan.respect=60
	for id in GameMan.recruitable_cats(): GameMan.hire_cat(id)
	for item in WorldData.items(): GameMan.stash[item.id]=2
	GameMan.cats.al_catpone.jail_days=2
	GameMan.cats.bugsy_meowsie.wounded_days=2
	var main_scene := load("res://main.tscn").instantiate() as Main
	add_child(main_scene)
	await get_tree().process_frame
	var shell := main_scene.current as NoirShell
	shell.go("home")
	get_tree().root.size=Vector2i(320,568)
	await get_tree().process_frame
	await get_tree().process_frame
	check(shell.has_node("BeginnerTutorial"),"first-run tutorial appears in the live shell")
	check(touch_targets(shell.get_node("BeginnerTutorial")),"tutorial uses mobile touch targets")
	check(readable_type(shell.get_node("BeginnerTutorial")),"tutorial uses readable mobile type")
	GameMan.complete_tutorial()
	shell.refresh()
	for resolution in [Vector2i(320,568),Vector2i(360,800),Vector2i(390,844),Vector2i(844,390),Vector2i(768,1024),Vector2i(1440,900)]:
		get_tree().root.size=resolution
		await get_tree().process_frame
		await get_tree().process_frame
		for page in ["home","city","district","location","racket","crew","profile","recruit","gym","fence","empire","news","morning","ops","ledger","story","more"]:
			shell.go(page)
			await get_tree().process_frame
			await get_tree().process_frame
			var width := shell.get_viewport_rect().size.x
			var body_minimum := shell.body.get_combined_minimum_size().x
			var fits := shell.body.size.x<=width and body_minimum<=width-20
			if not fits:
				print("WIDTH DETAIL ",page," / ",resolution," body=",shell.body.size.x," minimum=",body_minimum," viewport=",width)
			check(fits,"%s fits %s" % [page,resolution])
			check(touch_targets(shell),"%s touch targets %s" % [page,resolution])
			if resolution.x <= 390:
				check(readable_type(shell),"%s readable type %s" % [page,resolution])
	main_scene.queue_free()
	await get_tree().process_frame
	print("REDESIGN OK" if failures.is_empty() else "REDESIGN FAILED: "+str(failures))
	get_tree().quit(0 if failures.is_empty() else 1)

func touch_targets(node: Node) -> bool:
	if node is Button and node.visible and node.size.y<43: return false
	for child in node.get_children():
		if not touch_targets(child): return false
	return true


func readable_type(node: Node) -> bool:
	if node is Label and node.visible and node.get_theme_font_size("font_size")<16:
		return false
	if node is Button and node.visible and node.get_theme_font_size("font_size")<16:
		return false
	for child in node.get_children():
		if not readable_type(child):
			return false
	return true
