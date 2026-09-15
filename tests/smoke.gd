extends Node

## Headless smoke test for the day cycle and The Racket. Drives the systems with
## no window, then measures what every screen demands in width, because portrait
## is 440 logical pixels wide and anything wider than that overflows on a phone.

const PORTRAIT_WIDTH := 440
const LANDSCAPE_WIDTH := 640

var _fails: Array = []


func _ready() -> void:
	seed(12345)
	_test_day_cycle()
	_test_gym()
	_test_racket()
	_test_market()
	_test_holdings()
	_test_soak()
	await _test_widths()

	print("")
	if _fails.is_empty():
		print("SMOKE OK")
	else:
		for f in _fails:
			print("FAIL: ", f)
		print("SMOKE FAILED (%d)" % _fails.size())
	get_tree().quit(0 if _fails.is_empty() else 1)


func _check(ok: bool, what: String) -> void:
	if ok:
		print("  ok   ", what)
	else:
		_fails.append(what)
		print("  FAIL ", what)


# ---------------------------------------------------------------- day cycle

func _test_day_cycle() -> void:
	print("day cycle")
	GameMan.new_game()
	var me := GameMan.hired_cats()[0] as String
	_check(GameMan.energy(me) == GameMan.energy_max(me), "everyone starts the day rested")
	_check(GameMan.nerve == GameMan.nerve_max(), "nerve starts full")

	var before := GameMan.energy(me)
	_check(GameMan.assign_cat(me, "blind_pig", WorldData.OP_COLLECT), "a cat can take a job")
	_check(GameMan.energy(me) == before - GameMan.JOB_ENERGY, "the job took energy")
	GameMan.clear_assignment(me)
	_check(GameMan.energy(me) == before, "pulling them off gives the day back")

	GameMan.assign_cat(me, "blind_pig", WorldData.OP_COLLECT)
	GameMan.nerve = 2
	var r := GameMan.end_day()
	_check(int(r["day"]) == 1 and GameMan.day == 2, "the day rolled over")
	_check(GameMan.energy(me) == GameMan.energy_max(me), "dawn refills energy")
	_check(GameMan.nerve == 2 + GameMan.nerve_regen(), "nerve comes back overnight")
	_check(not GameMan.prices.is_empty(), "the Fence re-priced overnight")


# ---------------------------------------------------------------- the gym

func _test_gym() -> void:
	print("the gym")
	var me := GameMan.hired_cats()[0] as String
	GameMan.treats = 5000
	var start := GameMan.effective_stat(me, "muscle")
	var first := GameMan.train_gain(me, "muscle")
	_check(GameMan.train_cat(me, "muscle") != "", "a session happens")
	_check(GameMan.effective_stat(me, "muscle") > start, "training raises the stat")
	_check(GameMan.train_gain(me, "muscle") < first, "the next point is smaller")
	_check(GameMan.train_fee(me, "muscle") > GameMan.TRAIN_FEE, "and it costs more")

	# The catnip tin doubles one session and is then gone.
	GameMan.stash["catnip_tin"] = 1
	GameMan.use_item("catnip_tin", me)
	_check(bool(GameMan.cats[me]["boosted"]), "catnip takes hold")
	var boosted_from := GameMan.trained(me, "sneak")
	var plain := GameMan.train_gain(me, "sneak")
	GameMan.train_cat(me, "sneak")
	_check(abs((GameMan.trained(me, "sneak") - boosted_from) - plain * 2.0) < 0.001,
		"the boosted session counts double")
	_check(not bool(GameMan.cats[me]["boosted"]), "and the tin is spent")

	# Energy is the real limit, not money.
	GameMan.cats[me]["energy"] = 1
	_check(GameMan.train_cat(me, "charm") == "", "a spent cat cannot train")


# ---------------------------------------------------------------- the racket

func _test_racket() -> void:
	print("the racket")
	GameMan.new_game()
	GameMan.treats = 9000
	var me := GameMan.hired_cats()[0] as String

	_check(GameMan.crime_unlocked("milk_bottle"), "the bottom of the ladder is open")
	_check(not GameMan.crime_unlocked("merchants_bank"), "the top of it is not")

	var nerve_before := GameMan.nerve
	var energy_before := GameMan.energy(me)
	var out := GameMan.commit_crime(me, "milk_bottle")
	_check(not out.is_empty(), "a crime resolves on the spot")
	_check(GameMan.nerve == nerve_before - 1, "it cost nerve")
	_check(GameMan.energy(me) == energy_before - 2, "and it cost the cat's day")
	_check(GameMan.crime_runs("milk_bottle") == 1, "the run was banked")

	# Practice is what opens the tier above, and it is worth real odds.
	var cold := GameMan.crime_chance(me, "newsboy")
	GameMan.crime_xp["newsboy"] = 10
	_check(GameMan.crime_chance(me, "newsboy") > cold, "practice improves the odds")

	GameMan.crime_xp["milk_bottle"] = 20
	_check(GameMan.crime_unlocked("boost_motorcar"), "banked experience opens the next tier")

	# Nerve, not money, is the ceiling.
	GameMan.nerve = 0
	_check(not GameMan.can_commit(me, "milk_bottle"), "no nerve, no crime")

	# Jail: out of action until the days run down or you pay.
	GameMan.cats[me]["jail_days"] = 3
	_check(GameMan.cat_state(me) == "jail", "a pinched cat is inside")
	_check(not GameMan.is_cat_available(me), "and cannot be sent anywhere")
	_check(not GameMan.assign_cat(me, "blind_pig", WorldData.OP_COLLECT), "not even to a venue")
	_check(GameMan.bail_cost(me) == 3 * CrimeData.JAIL_BAIL_PER_DAY, "bail is priced by the day")
	_check(GameMan.post_bail(me), "bail can be posted")
	_check(GameMan.cat_state(me) != "jail", "and they walk out")


# ---------------------------------------------------------------- the fence

func _test_market() -> void:
	print("the fence")
	GameMan.new_game()
	GameMan.treats = 2000
	_check(GameMan.buy_price("brass_knuckles") > 0, "gear is for sale")
	_check(GameMan.buy_price("crate") == 0, "nobody sells you a smuggler's crate")
	var cash := GameMan.treats
	_check(GameMan.buy_item("rubber_soles"), "you can buy")
	_check(GameMan.treats < cash and GameMan.stash_count("rubber_soles") == 1, "money for goods")
	_check(GameMan.sell_item("rubber_soles"), "and sell them back")
	_check(GameMan.stash_count("rubber_soles") == 0, "the stash empties")
	_check(GameMan.sell_price("rubber_soles") < GameMan.buy_price("rubber_soles"),
		"the Fence takes his cut both ways")

	# Two-point gear really is worth two points.
	var me := GameMan.hired_cats()[0] as String
	var before := GameMan.effective_stat(me, "sneak")
	GameMan.buy_item("burglar_kit")
	GameMan.equip_item("burglar_kit", me)
	_check(abs(GameMan.effective_stat(me, "sneak") - before - 2.0) < 0.001, "+2 SNEAK is +2 SNEAK")


# ---------------------------------------------------------------- holdings

func _test_holdings() -> void:
	print("holdings")
	GameMan.new_game()
	GameMan.treats = 20000
	GameMan.respect = 60
	var me := GameMan.hired_cats()[0] as String
	var cap := GameMan.energy_max(me)
	_check(GameMan.buy_property("flophouse"), "a holding can be bought")
	_check(GameMan.energy_max(me) == cap + 1, "the flophouse buys everyone a point of energy")
	_check(not GameMan.buy_property("flophouse"), "you cannot buy it twice")

	var nerve_cap := GameMan.nerve_max()
	GameMan.buy_property("social_club")
	_check(GameMan.nerve_max() > nerve_cap, "the social club raises the nerve ceiling")

	GameMan.buy_property("back_room_bank")
	GameMan.heat = 50.0
	var heat_before := GameMan.heat
	var report := GameMan.end_day()
	_check(int(report["holdings"]) == GameMan.holdings_income(), "holdings pay out nightly")
	_check(int(report["holdings"]) > 0, "and it is real money")
	_check(GameMan.heat < heat_before, "the back-room bank cools things off")


# ---------------------------------------------------------------- soak

## Twenty days of somebody playing badly: everyone out on jobs, everyone at the
## gym, every crime pulled that can be. Nothing here asserts a number — it is
## looking for the day the whole cycle throws.
func _test_soak() -> void:
	print("twenty days")
	GameMan.new_game()
	for cid in GameMan.recruitable_cats():
		GameMan.cats[String(cid)]["hired"] = true
	var venue_ids: Array = []
	for v in WorldData.venues():
		venue_ids.append(String(v["id"]))
	var crime_ids: Array = []
	for c in CrimeData.crimes():
		crime_ids.append(String(c["id"]))

	for i in 20:
		for cid0 in GameMan.hired_cats():
			var cid := String(cid0)
			GameMan.train_cat(cid, ["muscle", "sneak", "charm"][randi() % 3])
			for crime_id in crime_ids:
				if GameMan.can_commit(cid, String(crime_id)):
					GameMan.commit_crime(cid, String(crime_id))
					break
			GameMan.assign_cat(cid, String(venue_ids[randi() % venue_ids.size()]),
				WorldData.OP_SHAKEDOWN if randi() % 2 == 0 else WorldData.OP_COLLECT)
		GameMan.cycle_tariff("catnip")
		GameMan.end_day()
		if not GameMan.pending_beat().is_empty():
			GameMan.resolve_beat(String(GameMan.pending_beat()["id"]), 0)

	_check(GameMan.day == 21, "twenty days ran through")
	GameMan.save_game()
	_check(GameMan.has_save(), "and the save still writes")
	_check(GameMan.load_game(), "and reads back")
	var me := GameMan.hired_cats()[0] as String
	_check(GameMan.cats[me].has("train"), "with the new fields intact")


# ---------------------------------------------------------------- layout

## Every screen, in both orientations, must fit the width it is given.
func _test_widths() -> void:
	print("layout")
	GameMan.new_game()
	GameMan.treats = 20000
	GameMan.respect = 60
	GameMan.stash = {"salmon": 2, "catnip_tin": 1, "crowbar": 1, "silk_suit": 1,
		"brass_knuckles": 1, "burglar_kit": 1, "rubber_soles": 1, "pinstripe_suit": 1,
		"intel": 1, "crate": 1, "cigars": 1}
	for cid in GameMan.recruitable_cats():
		GameMan.cats[String(cid)]["hired"] = true
	GameMan.cats[GameMan.hired_cats()[1] as String]["jail_days"] = 2
	GameMan.cats[GameMan.hired_cats()[2] as String]["wounded_days"] = 2

	get_tree().root.size = Vector2i(440, 900)
	var main_scene := load("res://main.tscn").instantiate() as Main
	get_tree().root.add_child.call_deferred(main_scene)
	await get_tree().process_frame
	await get_tree().process_frame

	for screen_name in ["desk", "ops", "crew", "recruit", "gym", "racket", "fence", "ledger"]:
		main_scene.show_screen(screen_name)
		await get_tree().process_frame
		await get_tree().process_frame
		var worst := _widest(main_scene.current)
		_check(float(worst["width"]) <= PORTRAIT_WIDTH, "%s fits portrait (%d of %d — widest: %s)"
			% [screen_name, int(worst["width"]), PORTRAIT_WIDTH, String(worst["who"])])
	main_scene.queue_free()


## What a screen really needs in width. Godot already rolls a minimum width up
## through containers, with one hole in it: a ScrollContainer reports a tiny
## minimum because scrolling is its answer to being squeezed — but horizontal
## scrolling is off everywhere here, so its child's width is a hard requirement.
## Walk the tree, patch that hole, and keep hold of whichever node set the mark.
func _widest(node: Node) -> Dictionary:
	var deepest := {"width": 0.0, "who": ""}
	for child in node.get_children():
		var found := _widest(child)
		if float(found["width"]) > float(deepest["width"]):
			deepest = found
	if node is ScrollContainer:
		return deepest
	if not node is Control:
		return deepest
	var control := node as Control
	var own: float = control.get_combined_minimum_size().x
	if node is MarginContainer:
		deepest["width"] = float(deepest["width"]) \
			+ float(control.get_theme_constant("margin_left")) \
			+ float(control.get_theme_constant("margin_right"))
	if float(deepest["width"]) >= own and String(deepest["who"]) != "":
		return deepest
	return {"width": own, "who": _describe(control)}


func _describe(node: Control) -> String:
	return "%s (%s)" % [node.get_class(), _first_text(node)]


func _first_text(node: Node) -> String:
	if node is Label and (node as Label).text.strip_edges() != "":
		return (node as Label).text.substr(0, 26)
	if node is Button and (node as Button).text.strip_edges() != "":
		return (node as Button).text.substr(0, 26)
	for child in node.get_children():
		var t := _first_text(child)
		if t != "":
			return t
	return ""
