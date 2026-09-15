extends Node
## GameMan — autoload: empire state, the day cycle, and story progression
## for Pawfellas.

signal state_changed
signal day_resolved(report: Dictionary)

const SAVE_VERSION := 2
const TUTORIAL_LAST_STEP := 8

const SAVE_PATH := "user://pawfellas_save.cfg"

const PHASE_DESK := "desk"
const PHASE_OPS := "ops"
const PHASE_LEDGER := "ledger"

const STARTER_CREW := ["jimmy_twotimes", "al_catpone", "bugsy_meowsie", "penny_pickpocket"]

const MAX_LEVEL := 5
const XP_PER_LEVEL := 40
const WOUND_DAYS := 2

## Energy is a cat's day. A job takes most of it; a session at the gym or a
## run at The Racket takes the rest. Nobody does everything in one day.
const ENERGY_BASE := 8
const JOB_ENERGY := 4
const TRAIN_ENERGY := 3

## Nerve is yours, not theirs. It is the ceiling on how much crime the whole
## house can get up to before morning.
const NERVE_BASE_MAX := 10
const NERVE_REGEN := 4

const TRAIN_GAIN := 0.30
const TRAIN_FALLOFF := 0.45
const TRAIN_FLOOR := 0.05
const TRAIN_FEE := 12

var day: int = 1
var phase: String = PHASE_DESK
var treats: int = 240
var respect: int = 0
var heat: float = 0.0
var tension: float = 20.0
var payout_level: int = 1
var started: bool = false

var nerve: int = NERVE_BASE_MAX

var tariffs: Dictionary = {}
var venues: Dictionary = {}
var cats: Dictionary = {}
var stash: Dictionary = {}
var properties: Array = []
var prices: Dictionary = {}
var crime_xp: Dictionary = {}

var story_seen: Array = []
var story_flags: Array = []
var align: String = ""

var last_report: Dictionary = {}
var journal: Array = []
var save_error: int = OK
var tutorial_step: int = 0
var tutorial_complete: bool = false


func _ready() -> void:
	randomize()


# ---------------------------------------------------------------- save / load

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func new_game() -> void:
	day = 1
	phase = PHASE_DESK
	treats = 240
	respect = 0
	heat = 0.0
	tension = 20.0
	payout_level = 1
	nerve = NERVE_BASE_MAX
	started = true
	story_seen.clear()
	story_flags.clear()
	align = ""
	last_report = {}
	journal.clear()
	tutorial_step = 0
	tutorial_complete = false

	tariffs.clear()
	for g in WorldData.goods():
		tariffs[String(g["id"])] = 1

	venues.clear()
	for v in WorldData.venues():
		venues[String(v["id"])] = {"controlled": false, "unrest": 0.0}

	stash.clear()
	properties.clear()
	crime_xp.clear()
	_roll_prices()

	cats.clear()
	for c in GameData.cats():
		var cid := String(c["id"])
		cats[cid] = _fresh_cat(cid in STARTER_CREW)
	save_game()
	state_changed.emit()


func _fresh_cat(hired: bool) -> Dictionary:
	return {
		"hired": hired,
		"level": 1,
		"xp": 0,
		"loyalty": 60,
		"wounded_days": 0,
		"gear": "",
		"venue": "",
		"op": "",
		"energy": ENERGY_BASE + 1,
		"jail_days": 0,
		"boosted": false,
		"train": {"muscle": 0.0, "sneak": 0.0, "charm": 0.0},
	}


func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game", "save_version", SAVE_VERSION)
	cfg.set_value("game", "last_report", last_report)
	cfg.set_value("game", "journal", journal)
	cfg.set_value("game", "tutorial_step", tutorial_step)
	cfg.set_value("game", "tutorial_complete", tutorial_complete)
	cfg.set_value("game", "day", day)
	cfg.set_value("game", "phase", phase)
	cfg.set_value("game", "treats", treats)
	cfg.set_value("game", "respect", respect)
	cfg.set_value("game", "heat", heat)
	cfg.set_value("game", "tension", tension)
	cfg.set_value("game", "payout_level", payout_level)
	cfg.set_value("game", "started", started)
	cfg.set_value("game", "tariffs", tariffs)
	cfg.set_value("game", "venues", venues)
	cfg.set_value("game", "cats", cats)
	cfg.set_value("game", "stash", stash)
	cfg.set_value("game", "nerve", nerve)
	cfg.set_value("game", "properties", properties)
	cfg.set_value("game", "prices", prices)
	cfg.set_value("game", "crime_xp", crime_xp)
	cfg.set_value("story", "seen", story_seen)
	cfg.set_value("story", "flags", story_flags)
	cfg.set_value("story", "align", align)
	save_error = cfg.save(SAVE_PATH)


func load_game() -> bool:
	if not has_save():
		return false
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return false
	var loaded_version := int(cfg.get_value("game", "save_version", 0))
	if loaded_version > SAVE_VERSION:
		return false
	# Version 0 (unversioned) saves acquire an empty journal and ledger.
	last_report = cfg.get_value("game", "last_report", {})
	journal = cfg.get_value("game", "journal", [])
	day = int(cfg.get_value("game", "day", 1))
	phase = String(cfg.get_value("game", "phase", PHASE_DESK))
	treats = int(cfg.get_value("game", "treats", 240))
	respect = int(cfg.get_value("game", "respect", 0))
	heat = float(cfg.get_value("game", "heat", 0.0))
	tension = float(cfg.get_value("game", "tension", 20.0))
	payout_level = int(cfg.get_value("game", "payout_level", 1))
	started = bool(cfg.get_value("game", "started", false))
	tariffs = cfg.get_value("game", "tariffs", {})
	venues = cfg.get_value("game", "venues", {})
	cats = cfg.get_value("game", "cats", {})
	stash = cfg.get_value("game", "stash", {})
	nerve = int(cfg.get_value("game", "nerve", NERVE_BASE_MAX))
	properties = cfg.get_value("game", "properties", [])
	prices = cfg.get_value("game", "prices", {})
	crime_xp = cfg.get_value("game", "crime_xp", {})
	story_seen = cfg.get_value("story", "seen", [])
	story_flags = cfg.get_value("story", "flags", [])
	align = String(cfg.get_value("story", "align", ""))
	# The guided tour was introduced in schema 2. Do not interrupt established
	# empires; only a new game starts it automatically. It can always be replayed.
	if loaded_version >= 2:
		tutorial_step = clampi(int(cfg.get_value("game", "tutorial_step", 0)), 0, TUTORIAL_LAST_STEP)
		tutorial_complete = bool(cfg.get_value("game", "tutorial_complete", false))
	else:
		tutorial_step = TUTORIAL_LAST_STEP
		tutorial_complete = true

	# Fill in anything a save predates.
	for g in WorldData.goods():
		var gid := String(g["id"])
		if not tariffs.has(gid):
			tariffs[gid] = 1
	for v in WorldData.venues():
		var vid := String(v["id"])
		if not venues.has(vid):
			venues[vid] = {"controlled": false, "unrest": 0.0}
	for c in GameData.cats():
		var cid := String(c["id"])
		if not cats.has(cid):
			cats[cid] = _fresh_cat(false)
	for pid in GameData.player_cat_ids():
		cats[pid]["hired"] = true
	# A save from before The Racket has none of the new per-cat fields.
	var blank := _fresh_cat(false)
	for cid2 in cats.keys():
		for key in ["energy", "jail_days", "boosted", "train"]:
			if not cats[cid2].has(key):
				cats[cid2][key] = blank[key] if key != "train" else blank[key].duplicate()
	if prices.is_empty():
		_roll_prices()
	state_changed.emit()
	return true


func tutorial_active() -> bool:
	return started and not tutorial_complete


func set_tutorial_step(value: int) -> void:
	tutorial_step = clampi(value, 0, TUTORIAL_LAST_STEP)
	tutorial_complete = false
	save_game()
	state_changed.emit()


func complete_tutorial() -> void:
	tutorial_step = TUTORIAL_LAST_STEP
	tutorial_complete = true
	save_game()
	state_changed.emit()


func restart_tutorial() -> void:
	tutorial_step = 0
	tutorial_complete = false
	save_game()
	state_changed.emit()


func erase_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)


# ---------------------------------------------------------------- story

func pending_beat() -> Dictionary:
	for b in StoryData.beats():
		var bid := String(b["id"])
		if bid in story_seen:
			continue
		if day < int(b["day"]):
			continue
		if respect < int(b.get("req_respect", 0)):
			continue
		var need_align := String(b.get("req_align", ""))
		if need_align != "" and need_align != align:
			continue
		return b
	return {}


func resolve_beat(beat_id: String, choice_index: int) -> String:
	var b := StoryData.beat_by_id(beat_id)
	if b.is_empty() or beat_id in story_seen or String(pending_beat().get("id", "")) != beat_id:
		return ""
	var reply := ""
	var choices: Array = b.get("choices", [])
	if not choices.is_empty() and (choice_index < 0 or choice_index >= choices.size()):
		return ""
	if choice_index >= 0 and choice_index < choices.size():
		var ch: Dictionary = choices[choice_index]
		if treats + int(ch.get("treats", 0)) < 0:
			return ""
		treats += int(ch.get("treats", 0))
		heat = clampf(heat + float(ch.get("heat", 0)), 0.0, 100.0)
		tension = clampf(tension + float(ch.get("tension", 0)), 0.0, 100.0)
		var a := String(ch.get("align", ""))
		if a != "":
			align = a
		var f := String(ch.get("flag", ""))
		if f != "" and not f in story_flags:
			story_flags.append(f)
		reply = String(ch.get("reply", ""))
	if not beat_id in story_seen:
		story_seen.append(beat_id)
	save_game()
	state_changed.emit()
	return reply


# ---------------------------------------------------------------- crew

func hired_cats() -> Array:
	var out: Array = []
	for c in GameData.cats():
		var cid := String(c["id"])
		if bool(cats[cid]["hired"]):
			out.append(cid)
	return out


func recruitable_cats() -> Array:
	var out: Array = []
	for c in GameData.cats():
		var cid := String(c["id"])
		if not GameData.is_recruitable(cid):
			continue
		if not bool(cats[cid]["hired"]):
			out.append(cid)
	return out


func cat_state(cat_id: String) -> String:
	var c: Dictionary = cats[cat_id]
	if int(c.get("jail_days", 0)) > 0:
		return "jail"
	if int(c["wounded_days"]) > 0:
		return "wounded"
	if String(c["venue"]) != "":
		return "assigned"
	return "ready"


func is_cat_available(cat_id: String) -> bool:
	return bool(cats[cat_id]["hired"]) \
		and int(cats[cat_id]["wounded_days"]) == 0 \
		and int(cats[cat_id].get("jail_days", 0)) == 0


func hire_cat(cat_id: String) -> bool:
	if not cats.has(cat_id):
		return false
	if not GameData.is_recruitable(cat_id):
		return false
	if bool(cats[cat_id]["hired"]):
		return false
	var cost := GameData.cat_cost(cat_id)
	if treats < cost:
		return false
	treats -= cost
	cats[cat_id]["hired"] = true
	save_game()
	state_changed.emit()
	return true


## Base stat plus experience and equipped gear.
func effective_stat(cat_id: String, stat: String) -> float:
	var d := GameData.cat_by_id(cat_id)
	if d.is_empty():
		return 0.0
	var base := 0.0
	match stat:
		"muscle":
			base = float(d["muscle"])
		"sneak":
			base = float(d["sneak"])
		"charm":
			base = float(d["charm"])
		"muscle_charm":
			base = (float(d["muscle"]) + float(d["charm"])) * 0.5
		"all":
			base = (float(d["muscle"]) + float(d["sneak"]) + float(d["charm"])) / 3.0
	base += float(int(cats[cat_id]["level"]) - 1) * 0.5
	base += trained(cat_id, stat)
	var gear_id := String(cats[cat_id]["gear"])
	if gear_id != "":
		var item := WorldData.item_by_id(gear_id)
		if not item.is_empty() and String(item["kind"]) == "gear":
			if String(item["stat"]) == stat:
				base += float(item["power"])
			elif stat == "muscle_charm" and String(item["stat"]) in ["muscle", "charm"]:
				base += float(item["power"]) * 0.5
			elif stat == "all":
				base += float(item["power"]) / 3.0
	return base


func xp_to_next(cat_id: String) -> int:
	return int(cats[cat_id]["level"]) * XP_PER_LEVEL


func add_xp(cat_id: String, amount: int) -> bool:
	var c: Dictionary = cats[cat_id]
	if int(c["level"]) >= MAX_LEVEL:
		return false
	c["xp"] = int(c["xp"]) + amount
	var levelled := false
	while int(c["level"]) < MAX_LEVEL and int(c["xp"]) >= xp_to_next(cat_id):
		c["xp"] = int(c["xp"]) - xp_to_next(cat_id)
		c["level"] = int(c["level"]) + 1
		levelled = true
	return levelled


## What this cat expects to be paid each night.
func cat_cut(cat_id: String) -> int:
	var d := GameData.cat_by_id(cat_id)
	if d.is_empty():
		return 0
	var base := 5 + int(cats[cat_id]["level"]) * 3
	if String(d.get("role", "")) == "muscle":
		base += 6
	elif String(d.get("role", "")) == "specialist":
		base += 3
	return base


func nightly_payout() -> int:
	var total := 0
	for cid in hired_cats():
		total += cat_cut(cid)
	return int(round(float(total) * WorldData.PAYOUT_MULT[payout_level]))


func nightly_bribes() -> int:
	return int(round(heat * WorldData.HEAT_BRIBE_PER_POINT))


# ---------------------------------------------------------------- energy

## A cat's whole day, in points. Levels and a bed of their own buy more of it.
func energy_max(cat_id: String) -> int:
	var e := ENERGY_BASE + int(cats[cat_id]["level"])
	if has_property("flophouse"):
		e += 1
	return e


func energy(cat_id: String) -> int:
	return clampi(int(cats[cat_id].get("energy", 0)), 0, energy_max(cat_id))


func spend_energy(cat_id: String, amount: int) -> bool:
	if energy(cat_id) < amount:
		return false
	cats[cat_id]["energy"] = energy(cat_id) - amount
	return true


func nerve_max() -> int:
	return NERVE_BASE_MAX + (3 if has_property("social_club") else 0)


func nerve_regen() -> int:
	return NERVE_REGEN + (3 if has_property("social_club") else 0)


# ---------------------------------------------------------------- the gym

## Points put on at the gym, on top of whatever the cat was born with.
func trained(cat_id: String, stat: String) -> float:
	var t: Dictionary = cats[cat_id].get("train", {})
	match stat:
		"muscle", "sneak", "charm":
			return float(t.get(stat, 0.0))
		"muscle_charm":
			return (float(t.get("muscle", 0.0)) + float(t.get("charm", 0.0))) * 0.5
		"all":
			return (float(t.get("muscle", 0.0)) + float(t.get("sneak", 0.0))
				+ float(t.get("charm", 0.0))) / 3.0
	return 0.0


## Each point already trained makes the next one smaller. The wall is real.
func train_gain(cat_id: String, stat: String) -> float:
	var have := trained(cat_id, stat)
	return maxf(TRAIN_FLOOR, TRAIN_GAIN / (1.0 + have * TRAIN_FALLOFF))


func train_fee(cat_id: String, stat: String) -> int:
	return TRAIN_FEE + int(round(trained(cat_id, stat) * 26.0))


## Returns a line for the gym to print, or "" if the session could not happen.
func train_cat(cat_id: String, stat: String) -> String:
	if not is_cat_available(cat_id):
		return ""
	var fee := train_fee(cat_id, stat)
	if treats < fee or energy(cat_id) < TRAIN_ENERGY:
		return ""
	treats -= fee
	spend_energy(cat_id, TRAIN_ENERGY)
	var gain := train_gain(cat_id, stat)
	var boosted := bool(cats[cat_id].get("boosted", false))
	if boosted:
		gain *= 2.0
		cats[cat_id]["boosted"] = false
	var t: Dictionary = cats[cat_id]["train"]
	t[stat] = float(t.get(stat, 0.0)) + gain
	add_xp(cat_id, 3)
	save_game()
	state_changed.emit()
	var who := String(GameData.cat_by_id(cat_id)["name"])
	var line := "%s put on %+.2f %s." % [who, gain, GameData.STAT_LABELS.get(stat, stat)]
	if boosted:
		line += " The catnip did its work."
	return line


# ---------------------------------------------------------------- the racket

func crime_runs(crime_id: String) -> int:
	return int(crime_xp.get(crime_id, 0))


## Experience banked across every crime in a tier — the key to the tier above.
func tier_xp(tier: int) -> int:
	var total := 0
	for c in CrimeData.crimes_in_tier(tier):
		var cd := CrimeData.crime_by_id(String(c["id"]))
		total += crime_runs(String(c["id"])) * int(cd["xp"])
	return total


func crime_unlocked(crime_id: String) -> bool:
	var c := CrimeData.crime_by_id(crime_id)
	if c.is_empty():
		return false
	var tier := int(c["tier"])
	if tier == 0:
		return true
	return tier_xp(tier - 1) >= CrimeData.TIER_REQ[tier]


## Odds for one cat on one crime. Doing the same job over and over is what
## makes it safe; nothing else moves the number this much.
func crime_chance(cat_id: String, crime_id: String) -> float:
	var c := CrimeData.crime_by_id(crime_id)
	if c.is_empty() or cat_id == "":
		return 0.0
	var power := effective_stat(cat_id, String(c["stat"]))
	var trait_key := String(GameData.cat_by_id(cat_id).get("trait", ""))
	if trait_key == "lucky":
		power += 1.5
	var practice := minf(0.22, float(crime_runs(crime_id)) * 0.022)
	var base := 0.42 + 0.075 * (power - float(c["difficulty"])) + practice
	base -= heat / 400.0
	return clampf(base, 0.05, 0.95)


func crime_pay_range(crime_id: String) -> Vector2i:
	var c := CrimeData.crime_by_id(crime_id)
	if c.is_empty():
		return Vector2i.ZERO
	var pay: Array = c["pay"]
	var m := 1.12 if has_property("garage") else 1.0
	return Vector2i(int(round(float(pay[0]) * m)), int(round(float(pay[1]) * m)))


func can_commit(cat_id: String, crime_id: String) -> bool:
	var c := CrimeData.crime_by_id(crime_id)
	if c.is_empty() or not crime_unlocked(crime_id):
		return false
	if not is_cat_available(cat_id):
		return false
	return nerve >= int(c["nerve"]) and energy(cat_id) >= int(c["energy"])


## Crimes resolve the moment you commit them — this is the loop inside the day.
func commit_crime(cat_id: String, crime_id: String) -> Dictionary:
	if not can_commit(cat_id, crime_id):
		return {}
	var c := CrimeData.crime_by_id(crime_id)
	nerve -= int(c["nerve"])
	spend_energy(cat_id, int(c["energy"]))
	var chance := crime_chance(cat_id, crime_id)
	crime_xp[crime_id] = crime_runs(crime_id) + 1
	var success := randf() < chance
	var out := {
		"crime": crime_id, "cat": cat_id, "success": success, "chance": chance,
		"take": 0, "jailed": 0, "levelled": false, "text": "",
	}

	if success:
		var r := crime_pay_range(crime_id)
		var take := r.x + randi() % maxi(1, r.y - r.x + 1)
		if String(GameData.cat_by_id(cat_id).get("trait", "")) == "double_treats":
			take = int(round(float(take) * 1.25))
		treats += take
		out["take"] = take
		heat = clampf(heat + float(c["heat"]), 0.0, 100.0)
		out["text"] = "Clean. %+d treats." % take
	else:
		heat = clampf(heat + maxf(0.0, float(c["heat"])) * 0.6 + 2.0, 0.0, 100.0)
		out["text"] = CrimeData.fumble(crime_id)
		var jail_risk := float(c["jail"])
		if String(GameData.cat_by_id(cat_id).get("trait", "")) == "unlucky":
			jail_risk += 0.10
		if randf() < jail_risk:
			var days := 2 + int(c["tier"]) / 2
			cats[cat_id]["jail_days"] = days
			out["jailed"] = days
			cats[cat_id]["venue"] = ""
			cats[cat_id]["op"] = ""

	record_event(String(c["name"]).to_upper() + (" — CLEAN GETAWAY" if success else " — TROUBLE"), String(GameData.cat_by_id(cat_id)["name"]) + ": " + String(out["text"]))
	out["levelled"] = add_xp(cat_id, int(c["xp"]) * (2 if success else 1))
	save_game()
	state_changed.emit()
	return out


func bail_cost(cat_id: String) -> int:
	return int(cats[cat_id].get("jail_days", 0)) * CrimeData.JAIL_BAIL_PER_DAY


## Money talks to a desk sergeant the same as to anyone else.
func post_bail(cat_id: String) -> bool:
	var cost := bail_cost(cat_id)
	if cost <= 0 or treats < cost:
		return false
	treats -= cost
	cats[cat_id]["jail_days"] = 0
	save_game()
	state_changed.emit()
	return true


# ---------------------------------------------------------------- the fence

## Prices drift overnight, so the Fence is somewhere you watch, not a shop.
func _roll_prices() -> void:
	prices.clear()
	for item in WorldData.items():
		prices[String(item["id"])] = snappedf(randf_range(0.78, 1.28), 0.01)


func price_mod(item_id: String) -> float:
	return float(prices.get(item_id, 1.0))


func buy_price(item_id: String) -> int:
	var item := WorldData.item_by_id(item_id)
	var listed := int(item.get("price", 0))
	if listed <= 0:
		return 0
	return maxi(1, int(round(float(listed) * price_mod(item_id))))


func sell_price(item_id: String) -> int:
	return maxi(1, int(round(float(WorldData.sell_value(item_id)) * price_mod(item_id))))


func buy_item(item_id: String) -> bool:
	var cost := buy_price(item_id)
	if cost <= 0 or treats < cost:
		return false
	treats -= cost
	stash[item_id] = stash_count(item_id) + 1
	save_game()
	state_changed.emit()
	return true


func sell_item(item_id: String) -> bool:
	if stash_count(item_id) <= 0:
		return false
	stash[item_id] = stash_count(item_id) - 1
	treats += sell_price(item_id)
	save_game()
	state_changed.emit()
	return true


# ---------------------------------------------------------------- holdings

func has_property(property_id: String) -> bool:
	return property_id in properties


func can_buy_property(property_id: String) -> bool:
	var pr := WorldData.property_by_id(property_id)
	if pr.is_empty() or has_property(property_id):
		return false
	return respect >= int(pr["req_respect"]) and treats >= int(pr["cost"])


func buy_property(property_id: String) -> bool:
	if not can_buy_property(property_id):
		return false
	var pr := WorldData.property_by_id(property_id)
	treats -= int(pr["cost"])
	properties.append(property_id)
	record_event("NEW KEYS IN THE FAMILY", String(pr["name"]) + " joins the books. " + String(pr["perk"]))
	# A bed and a bath do their work from the moment you hold the keys.
	if property_id == "flophouse":
		for cid in hired_cats():
			cats[cid]["energy"] = energy_max(cid)
	save_game()
	state_changed.emit()
	return true


func holdings_income() -> int:
	var total := 0
	for pid in properties:
		var pr := WorldData.property_by_id(String(pid))
		if not pr.is_empty():
			total += int(pr["income"])
	return total


# ---------------------------------------------------------------- desk phase

func set_tariff(good_id: String, level: int) -> void:
	tariffs[good_id] = clampi(level, 0, WorldData.TARIFF_LABELS.size() - 1)
	save_game()
	state_changed.emit()


func cycle_tariff(good_id: String) -> void:
	set_tariff(good_id, (int(tariffs[good_id]) + 1) % WorldData.TARIFF_LABELS.size())


func set_payout(level: int) -> void:
	payout_level = clampi(level, 0, WorldData.PAYOUT_LABELS.size() - 1)
	save_game()
	state_changed.emit()


func cycle_payout() -> void:
	set_payout((payout_level + 1) % WorldData.PAYOUT_LABELS.size())


## Average tariff bite across all goods, as a yield multiplier.
func tariff_multiplier() -> float:
	var sum := 0.0
	var n := 0
	for g in WorldData.goods():
		sum += WorldData.TARIFF_YIELD[int(tariffs[String(g["id"])])]
		n += 1
	if n == 0:
		return 1.0
	return 1.0 + (sum / float(n))


func daily_tension_gain() -> float:
	var sum := 0.0
	for g in WorldData.goods():
		sum += WorldData.TARIFF_TENSION[int(tariffs[String(g["id"])])]
	return sum


# ---------------------------------------------------------------- ops phase

func venue_unlocked(venue_id: String) -> bool:
	var v := WorldData.venue_by_id(venue_id)
	return respect >= int(v.get("req_respect", 0))


func assigned_to(venue_id: String) -> Array:
	var out: Array = []
	for cid in hired_cats():
		if String(cats[cid]["venue"]) == venue_id:
			out.append(cid)
	return out


func venue_op(venue_id: String) -> String:
	var crew := assigned_to(venue_id)
	if crew.is_empty():
		return ""
	return String(cats[crew[0]]["op"])


func assign_cat(cat_id: String, venue_id: String, op: String) -> bool:
	if not cats.has(cat_id) or WorldData.venue_by_id(venue_id).is_empty() or op not in [WorldData.OP_COLLECT, WorldData.OP_SHAKEDOWN]:
		return false
	if String(cats[cat_id]["venue"]) != "":
		return false
	if not is_cat_available(cat_id):
		return false
	if not venue_unlocked(venue_id):
		return false
	var existing := venue_op(venue_id)
	if existing != "" and existing != op:
		return false
	if not spend_energy(cat_id, JOB_ENERGY):
		return false
	cats[cat_id]["venue"] = venue_id
	cats[cat_id]["op"] = op
	save_game()
	state_changed.emit()
	return true


func clear_assignment(cat_id: String) -> void:
	# Pulled off before the day ran, so they get their afternoon back.
	if String(cats[cat_id]["venue"]) != "":
		cats[cat_id]["energy"] = mini(energy_max(cat_id), energy(cat_id) + JOB_ENERGY)
	cats[cat_id]["venue"] = ""
	cats[cat_id]["op"] = ""
	save_game()
	state_changed.emit()


func clear_all_assignments() -> void:
	for cid in cats.keys():
		cats[cid]["venue"] = ""
		cats[cid]["op"] = ""


func any_assigned() -> bool:
	for cid in hired_cats():
		if String(cats[cid]["venue"]) != "":
			return true
	return false


## Odds the UI shows before committing to a job.
func preview_chance(venue_id: String, op: String, crew: Array) -> float:
	var v := WorldData.venue_by_id(venue_id)
	if v.is_empty() or crew.is_empty():
		return 0.0
	var stat: String = String(v["collect_stat"]) if op == WorldData.OP_COLLECT else String(v["shake_stat"])
	var power := 0.0
	for cid in crew:
		power += effective_stat(String(cid), stat)
		var trait_key := String(GameData.cat_by_id(String(cid)).get("trait", ""))
		if trait_key == "lucky":
			power += 1.5
		if trait_key == "dog_bonus" and op == WorldData.OP_SHAKEDOWN:
			power += 2.0
	var difficulty := float(v["difficulty"])
	if op == WorldData.OP_SHAKEDOWN:
		difficulty += 3.0
	var unrest := float(venues[venue_id]["unrest"])
	return clampf(0.5 + 0.07 * (power - difficulty) - unrest / 220.0, 0.08, 0.95)


## Worst and best take for a job before crew traits, for the jobs card.
func yield_range(venue_id: String, op: String) -> Vector2i:
	var v := WorldData.venue_by_id(venue_id)
	if v.is_empty():
		return Vector2i.ZERO
	var top := float(v["base_yield"]) * tariff_multiplier()
	var botched := 0.35
	if op == WorldData.OP_SHAKEDOWN:
		top *= 1.7
		botched = 0.25
	return Vector2i(int(round(top * botched)), int(round(top)))


# ---------------------------------------------------------------- ledger

func end_day() -> Dictionary:
	var opening_cash := treats
	var opening_heat := heat
	var report := {
		"day": day,
		"ops": [],
		"takings": 0,
		"protection": 0,
		"holdings": 0,
		"payout": 0,
		"bribes": 0,
		"net": 0,
		"respect_gain": 0,
		"loot": [],
		"injuries": [],
		"levelled": [],
		"defected": [],
		"rival": "",
		"unpaid": false,
	}

	# 1. Run every assigned job.
	var mult := tariff_multiplier()
	for v in WorldData.venues():
		var vid := String(v["id"])
		var crew := assigned_to(vid)
		if crew.is_empty():
			continue
		var op := venue_op(vid)
		var chance := preview_chance(vid, op, crew)
		var success := randf() < chance
		var take := 0
		if op == WorldData.OP_COLLECT:
			take = int(round(float(v["base_yield"]) * mult))
			if not success:
				take = int(round(float(take) * 0.35))
			else:
				venues[vid]["unrest"] = maxf(0.0, float(venues[vid]["unrest"]) - 5.0)
		else:
			take = int(round(float(v["base_yield"]) * 1.7 * mult))
			if not success:
				take = int(round(float(take) * 0.25))
			venues[vid]["unrest"] = minf(WorldData.MAX_UNREST, float(venues[vid]["unrest"]) + 14.0)
			heat = clampf(heat + float(v["risk"]) * 16.0, 0.0, 100.0)
			if success:
				var loot_id := String(v["loot"])
				stash[loot_id] = int(stash.get(loot_id, 0)) + 1
				report["loot"].append(loot_id)
		var take_mult := 1.0
		for cid0 in crew:
			var tk := String(GameData.cat_by_id(String(cid0)).get("trait", ""))
			if tk == "double_treats":
				take_mult += 0.25
			if tk == "velvet_touch" and op == WorldData.OP_COLLECT:
				take_mult += 0.25
		take = int(round(float(take) * take_mult))
		if success:
			venues[vid]["controlled"] = true
			report["respect_gain"] = int(report["respect_gain"]) + (3 if op == WorldData.OP_SHAKEDOWN else 2)
		report["takings"] = int(report["takings"]) + take

		# Experience, and the chance of getting hurt doing it.
		for cid in crew:
			var idstr := String(cid)
			if add_xp(idstr, 14 if success else 6):
				report["levelled"].append(idstr)
			var trait_key := String(GameData.cat_by_id(idstr).get("trait", ""))
			var risk := float(v["risk"])
			if op == WorldData.OP_SHAKEDOWN:
				risk += 0.10
			if success:
				risk *= 0.45
			if trait_key == "never_injured":
				risk = 0.0
			elif trait_key == "unlucky":
				risk += 0.12
			if randf() < risk:
				cats[idstr]["wounded_days"] = WOUND_DAYS
				report["injuries"].append(idstr)

		report["ops"].append({
			"venue": vid, "op": op, "crew": crew.duplicate(),
			"success": success, "chance": chance, "take": take,
		})

	# 2. Protection money from blocks you already hold.
	for v in WorldData.venues():
		var vid2 := String(v["id"])
		if not bool(venues[vid2]["controlled"]):
			continue
		var calm := 1.0 - float(venues[vid2]["unrest"]) / 150.0
		report["protection"] = int(report["protection"]) + int(round(float(v["base_yield"]) * 0.30 * mult * maxf(0.2, calm)))

	# 2b. Rent, takings and whatever else the holdings bring in.
	report["holdings"] = holdings_income()
	treats += int(report["takings"]) + int(report["protection"]) + int(report["holdings"])

	# 3. Pay the crew, or don't and find out.
	var payout := nightly_payout()
	report["payout"] = payout
	if treats >= payout:
		treats -= payout
		report["paid_payroll"] = payout
		for cid in hired_cats():
			cats[cid]["loyalty"] = clampi(int(cats[cid]["loyalty"]) + WorldData.PAYOUT_LOYALTY[payout_level], 0, 100)
	else:
		report["unpaid"] = true
		for cid in hired_cats():
			cats[cid]["loyalty"] = clampi(int(cats[cid]["loyalty"]) - 18, 0, 100)

	# 4. Police bribes scale with heat.
	var bribes := nightly_bribes()
	report["bribes"] = bribes
	if treats >= bribes:
		treats -= bribes
		report["paid_bribes"] = bribes
		heat = maxf(0.0, heat - 6.0)
	else:
		heat = clampf(heat + 8.0, 0.0, 100.0)

	report["net"] = int(report["takings"]) + int(report["protection"]) \
		+ int(report["holdings"]) - payout - bribes
	respect = clampi(respect + int(report["respect_gain"]), 0, 100)

	if has_property("back_room_bank"):
		heat = maxf(0.0, heat - 4.0)

	# 5. Tariffs anger the neighbourhood and the other house.
	tension = clampf(tension + daily_tension_gain() - 3.0, 0.0, 100.0)
	for g in WorldData.goods():
		var bump: float = WorldData.TARIFF_UNREST[int(tariffs[String(g["id"])])]
		for v in WorldData.venues():
			var vid3 := String(v["id"])
			if bool(venues[vid3]["controlled"]):
				venues[vid3]["unrest"] = minf(WorldData.MAX_UNREST, float(venues[vid3]["unrest"]) + bump / 3.0)

	# 6. The Alley Syndicate hits back when tension runs hot.
	if tension >= 65.0:
		report["rival"] = _rival_response()
		tension = maxf(0.0, tension - 22.0)

	# 7. Nobody works for a boss who doesn't pay.
	for cid in hired_cats():
		if String(GameData.cat_by_id(cid).get("role", "")) == "player":
			continue
		if int(cats[cid]["loyalty"]) <= 0:
			cats[cid]["hired"] = false
			cats[cid]["gear"] = ""
			report["defected"].append(cid)

	# 8. Roll the day over: sentences served, wounds closing, everyone rested.
	var mend := 2 if has_property("bathhouse") else 1
	for cid in cats.keys():
		if int(cats[cid]["wounded_days"]) > 0 and not cid in report["injuries"]:
			cats[cid]["wounded_days"] = maxi(0, int(cats[cid]["wounded_days"]) - mend)
		if int(cats[cid].get("jail_days", 0)) > 0:
			cats[cid]["jail_days"] = int(cats[cid]["jail_days"]) - 1
	clear_all_assignments()
	for cid in hired_cats():
		cats[cid]["energy"] = energy_max(cid)
	nerve = mini(nerve_max(), nerve + nerve_regen())
	_roll_prices()
	day += 1
	phase = PHASE_DESK
	report["net"] = treats - opening_cash
	report["heat_change"] = heat - opening_heat
	last_report = report
	record_event("THE BOOKS CLOSE", "Day %d: %+d T settled. %d T from protection; %d T from holdings." % [int(report["day"]),int(report["net"]),int(report["protection"]),int(report["holdings"])])
	if String(report["rival"]) != "":
		record_event("ALLEY SYNDICATE MAKES A MOVE", String(report["rival"]))
	save_game()
	day_resolved.emit(report)
	state_changed.emit()
	return report


func _rival_response() -> String:
	var held: Array = []
	for v in WorldData.venues():
		var vid := String(v["id"])
		if bool(venues[vid]["controlled"]):
			held.append(vid)
	if held.is_empty():
		var loss := mini(treats, 40)
		treats -= loss
		return "Alley Syndicate collectors worked your blocks before you did. Lost %d treats." % loss
	var target := String(held[randi() % held.size()])
	var v2 := WorldData.venue_by_id(target)
	if randf() < 0.5:
		venues[target]["controlled"] = false
		venues[target]["unrest"] = minf(WorldData.MAX_UNREST, float(venues[target]["unrest"]) + 20.0)
		return "%s threw in with the Alley Syndicate. You no longer hold it." % String(v2["name"])
	venues[target]["unrest"] = minf(WorldData.MAX_UNREST, float(venues[target]["unrest"]) + 30.0)
	return "Carmela's cats leaned on %s all night. Unrest way up." % String(v2["name"])


# ---------------------------------------------------------------- stash

func stash_count(item_id: String) -> int:
	return int(stash.get(item_id, 0))


func equip_item(item_id: String, cat_id: String) -> bool:
	var item := WorldData.item_by_id(item_id)
	if item.is_empty() or String(item["kind"]) != "gear":
		return false
	if stash_count(item_id) <= 0:
		return false
	var old := String(cats[cat_id]["gear"])
	if old != "":
		stash[old] = stash_count(old) + 1
	stash[item_id] = stash_count(item_id) - 1
	cats[cat_id]["gear"] = item_id
	save_game()
	state_changed.emit()
	return true


func use_item(item_id: String, cat_id: String = "") -> String:
	var item := WorldData.item_by_id(item_id)
	if item.is_empty() or String(item["kind"]) != "use":
		return ""
	if stash_count(item_id) <= 0:
		return ""
	var msg := ""
	match String(item["stat"]):
		"heat":
			heat = maxf(0.0, heat - float(item["power"]))
			msg = "Heat down %d." % int(item["power"])
		"treats":
			treats += int(item["power"])
			msg = "Sold on. +%d treats." % int(item["power"])
		"heal":
			if cat_id == "" or int(cats[cat_id]["wounded_days"]) <= 0:
				return ""
			cats[cat_id]["wounded_days"] = 0
			msg = "%s is back on their paws." % String(GameData.cat_by_id(cat_id)["name"])
		"train":
			if cat_id == "" or bool(cats[cat_id].get("boosted", false)):
				return ""
			cats[cat_id]["boosted"] = true
			msg = "%s is wired. Next session counts double." % String(GameData.cat_by_id(cat_id)["name"])
		"loyalty":
			for cid in hired_cats():
				cats[cid]["loyalty"] = clampi(int(cats[cid]["loyalty"]) + int(item["power"]), 0, 100)
			msg = "Cigars all round. Loyalty +%d across the books." % int(item["power"])
		_:
			return ""
	stash[item_id] = stash_count(item_id) - 1
	save_game()
	state_changed.emit()
	return msg


func record_event(title: String, body: String) -> void:
	journal.append({"day": day, "title": title, "body": body})
	while journal.size() > 24:
		journal.pop_front()
