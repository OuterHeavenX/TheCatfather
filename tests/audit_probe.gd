extends Node
## Diagnostic characterization, not a green regression suite. Prints actual
## behavior for the inheritance audit. Only run with isolated APPDATA; the
## companion runner enforces isolation before launching this scene.

func _ready() -> void:
	if not "/.audit/" in OS.get_user_data_dir().replace("\\", "/"):
		push_error("Audit probe requires isolated .audit user data")
		get_tree().quit(2)
		return
	seed(1928)
	GameMan.new_game()
	var cid := "jimmy_twotimes"
	var cfg := ConfigFile.new()
	cfg.load(GameMan.SAVE_PATH)
	print("SAVE version present: ", cfg.has_section_key("game", "save_version"))
	# A synthetic pre-Racket save: preserve the actual current day-cycle fields,
	# remove only fields introduced by 4f01e37. This is not a real player's save.
	for key in ["nerve", "properties", "prices", "crime_xp"]:
		cfg.erase_section_key("game", key)
	var old_cats: Dictionary = cfg.get_value("game", "cats")
	for cat in old_cats.values():
		for key in ["energy", "jail_days", "boosted", "train"]:
			cat.erase(key)
	cfg.set_value("game", "cats", old_cats)
	cfg.save(GameMan.SAVE_PATH)
	print("SAVE pre-Racket migration: ", GameMan.load_game(), " energy=", GameMan.energy(cid), " train=", GameMan.cats[cid]["train"])
	GameMan.treats = 1234
	GameMan.train_cat(cid, "sneak")
	var before := GameMan.cats.duplicate(true)
	var cash := GameMan.treats
	GameMan.save_game()
	GameMan.cats.clear()
	GameMan.treats = 0
	print("SAVE round trip: ", GameMan.load_game(), " cats_equal=", GameMan.cats == before, " cash_equal=", GameMan.treats == cash)
	GameMan.new_game()
	var preview := GameMan.crime_chance(cid, "milk_bottle")
	var crime := GameMan.commit_crime(cid, "milk_bottle")
	print("CRIME preview=", preview, " resolved_chance=", crime["chance"])
	GameMan.new_game()
	GameMan.treats = 0
	var report := GameMan.end_day()
	print("LEDGER zero cash actual_delta=", GameMan.treats, " net=", report["net"], " payout=", report["payout"], " unpaid=", report["unpaid"])
	GameMan.new_game()
	GameMan.treats = 0
	GameMan.resolve_beat("squeaker", 0)
	print("STORY unaffordable choice cash=", GameMan.treats)
	GameMan.resolve_beat("squeaker", 0)
	print("STORY duplicate choice cash=", GameMan.treats)
	GameMan.new_game()
	GameMan.assign_cat(cid, "blind_pig", WorldData.OP_COLLECT)
	var first_energy := GameMan.energy(cid)
	var repeated := GameMan.assign_cat(cid, "blind_pig", WorldData.OP_COLLECT)
	GameMan.clear_assignment(cid)
	print("ASSIGN repeated accepted=", repeated, " first_energy=", first_energy, " after_clear=", GameMan.energy(cid), " max=", GameMan.energy_max(cid))
	GameMan.new_game()
	GameMan.treats = 1000
	GameMan.spend_energy(cid, 8)
	GameMan.buy_property("flophouse")
	print("HOLDING purchase energy=", GameMan.energy(cid), " max=", GameMan.energy_max(cid))
	GameMan.prices["crate"] = 1.0
	print("FENCE crate sell=", GameMan.sell_price("crate"), " use=", WorldData.item_by_id("crate")["power"])
	for item in WorldData.items():
		if int(item["price"]) == 0:
			continue
		var iid := String(item["id"])
		GameMan.prices[iid] = 0.78
		var cheapest := GameMan.buy_price(iid)
		GameMan.prices[iid] = 1.28
		print("FENCE ", iid, " min_buy=", cheapest, " max_sell=", GameMan.sell_price(iid))
	GameMan.new_game()
	GameMan.end_day()
	GameMan.last_report = {}
	GameMan.load_game()
	print("SAVE ledger retained after reload: ", not GameMan.last_report.is_empty())
	await _layout_probe()
	print("AUDIT PROBE COMPLETE: observations above are not pass assertions")
	get_tree().quit()

func _layout_probe() -> void:
	GameMan.new_game()
	GameMan.treats = 20000
	GameMan.respect = 60
	var main_scene := load("res://main.tscn").instantiate() as Main
	get_tree().root.add_child.call_deferred(main_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	main_scene.show_screen("ops")
	var ops: OpsScreen = main_scene.current
	ops._picking_venue = "blind_pig"
	ops._picking_op = WorldData.OP_COLLECT
	ops.refresh()
	await get_tree().process_frame
	await get_tree().process_frame
	print("LAYOUT ops picker min=", _width(ops))
	for cid in GameMan.recruitable_cats():
		GameMan.cats[cid]["hired"] = true
	for cid in GameMan.hired_cats():
		GameMan.assign_cat(cid, "blind_pig", WorldData.OP_COLLECT)
	ops._picking_venue = ""
	ops.refresh()
	await get_tree().process_frame
	await get_tree().process_frame
	print("LAYOUT full assignment min=", _width(ops))
	GameMan.end_day()
	main_scene.show_screen("ledger")
	await get_tree().process_frame
	await get_tree().process_frame
	print("LAYOUT populated ledger min=", _width(main_scene.current))
	main_scene.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame

func _width(node: Node) -> float:
	var child_width := 0.0
	for child in node.get_children():
		child_width = maxf(child_width, _width(child))
	if node is ScrollContainer or not node is Control:
		return child_width
	if node is MarginContainer:
		child_width += node.get_theme_constant("margin_left") + node.get_theme_constant("margin_right")
	return maxf(child_width, node.get_combined_minimum_size().x)
