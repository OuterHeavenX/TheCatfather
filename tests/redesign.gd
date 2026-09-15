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
	var fixture := FileAccess.get_file_as_string("res://tests/fixtures/legacy_unversioned.cfg")
	var file := FileAccess.open(GameMan.SAVE_PATH,FileAccess.WRITE)
	file.store_string(fixture)
	file.close()
	check(GameMan.load_game(),"unversioned fixture loads")
	check(GameMan.day==7 and GameMan.treats==531 and GameMan.respect==11,"legacy finances preserved")
	check(GameMan.cats.jimmy_twotimes.gear=="crowbar" and GameMan.cats.jimmy_twotimes.venue=="blind_pig","legacy IDs, gear and assignments preserved")
	check(GameMan.story_flags.has("paid_nicky") and GameMan.align=="don","legacy story preserved")
	check(GameMan.journal.is_empty() and GameMan.last_report.is_empty(),"version 0 new fields default safely")
	GameMan.save_game()
	var cfg := ConfigFile.new()
	cfg.load(GameMan.SAVE_PATH)
	check(int(cfg.get_value("game","save_version",-1))==1,"explicit schema version written")
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
	for resolution in [Vector2i(360,800),Vector2i(390,844),Vector2i(844,390),Vector2i(768,1024),Vector2i(1440,900)]:
		get_tree().root.size=resolution
		await get_tree().process_frame
		await get_tree().process_frame
		for page in ["home","city","district","location","racket","crew","profile","recruit","gym","fence","empire","news","morning","ops","ledger","story","more"]:
			shell.go(page)
			await get_tree().process_frame
			await get_tree().process_frame
			var width := shell.get_viewport_rect().size.x
			check(shell.body.size.x<=width and shell.body.get_combined_minimum_size().x<=width-20,"%s fits %s" % [page,resolution])
			check(touch_targets(shell),"%s touch targets %s" % [page,resolution])
	main_scene.queue_free()
	await get_tree().process_frame
	print("REDESIGN OK" if failures.is_empty() else "REDESIGN FAILED: "+str(failures))
	get_tree().quit(0 if failures.is_empty() else 1)

func touch_targets(node: Node) -> bool:
	if node is Button and node.visible and node.size.y<43: return false
	for child in node.get_children():
		if not touch_targets(child): return false
	return true
