extends Node
## GameMan — autoload: state, save/load, heist engine for The Catfather.

signal heist_resolved(result: Dictionary)
signal state_changed

const SAVE_PATH := "user://catfather_save.cfg"
const WOUND_REST_SECONDS := 90.0

const STARTER_CREW := ["jimmy_twotimes", "al_catpone", "bugsy_meowsie", "penny_pickpocket"]

var treats: int = 100
var respect: int = 0
var started: bool = false
var cats: Dictionary = {}
var active_heists: Array = []
var pending_results: Array = []

var _tick_accum := 0.0


func _ready() -> void:
	randomize()


func _process(delta: float) -> void:
	if not started:
		return
	_tick_accum += delta
	if _tick_accum >= 0.5:
		_tick_accum = 0.0
		tick()


func now() -> float:
	return Time.get_unix_time_from_system()


# ---------------------------------------------------------------- save / load

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func new_game() -> void:
	treats = 100
	respect = 0
	started = true
	cats.clear()
	active_heists.clear()
	pending_results.clear()
	for c in GameData.cats():
		var cid := String(c["id"])
		cats[cid] = {
			"hired": cid in STARTER_CREW,
			"state": "ready",
			"wounded_until": 0.0,
			"heist_id": "",
		}
	save_game()
	state_changed.emit()


func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game", "treats", treats)
	cfg.set_value("game", "respect", respect)
	cfg.set_value("game", "started", started)
	cfg.set_value("game", "cats", cats)
	cfg.set_value("game", "active_heists", active_heists)
	cfg.set_value("game", "pending_results", pending_results)
	cfg.save(SAVE_PATH)


func load_game() -> bool:
	if not has_save():
		return false
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return false
	treats = int(cfg.get_value("game", "treats", 100))
	respect = int(cfg.get_value("game", "respect", 0))
	started = bool(cfg.get_value("game", "started", false))
	cats = cfg.get_value("game", "cats", {})
	active_heists = cfg.get_value("game", "active_heists", [])
	pending_results = cfg.get_value("game", "pending_results", [])
	for c in GameData.cats():
		var cid := String(c["id"])
		if not cats.has(cid):
			cats[cid] = {"hired": false, "state": "ready", "wounded_until": 0.0, "heist_id": ""}
	for pid in GameData.player_cat_ids():
		cats[pid]["hired"] = true
	state_changed.emit()
	return true


func erase_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)


# ---------------------------------------------------------------- cats

func cat_state(cat_id: String) -> String:
	var c: Dictionary = cats[cat_id]
	if String(c["state"]) == "wounded" and now() >= float(c["wounded_until"]):
		c["state"] = "ready"
		c["wounded_until"] = 0.0
		c["heist_id"] = ""
		save_game()
	return String(c["state"])


func is_cat_available(cat_id: String) -> bool:
	return bool(cats[cat_id]["hired"]) and cat_state(cat_id) == "ready"


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


func wound_remaining(cat_id: String) -> float:
	return maxf(0.0, float(cats[cat_id]["wounded_until"]) - now())


# ---------------------------------------------------------------- heists

func stat_value(cat_id: String, stat: String) -> float:
	var d := GameData.cat_by_id(cat_id)
	match stat:
		"muscle":
			return float(d["muscle"])
		"sneak":
			return float(d["sneak"])
		"charm":
			return float(d["charm"])
		"muscle_charm":
			return (float(d["muscle"]) + float(d["charm"])) * 0.5
		"all":
			return (float(d["muscle"]) + float(d["sneak"]) + float(d["charm"])) / 3.0
	return 0.0


func heist_locked(heist_id: String) -> bool:
	var h := GameData.heist_by_id(heist_id)
	return respect < int(h.get("req_respect", 0))


func start_heist(heist_id: String, cat_ids: Array) -> bool:
	var h := GameData.heist_by_id(heist_id)
	if h.is_empty():
		return false
	if heist_locked(heist_id):
		return false
	if cat_ids.size() < int(h["min_cats"]) or cat_ids.size() > int(h["max_cats"]):
		return false
	for cid in cat_ids:
		if not is_cat_available(String(cid)):
			return false
	for cid in cat_ids:
		cats[String(cid)]["state"] = "on_heist"
		cats[String(cid)]["heist_id"] = heist_id
	active_heists.append({
		"heist_id": heist_id,
		"cat_ids": cat_ids.duplicate(),
		"ends_at": now() + float(h["duration"]),
		"duration": float(h["duration"]),
	})
	save_game()
	state_changed.emit()
	return true


func tick() -> void:
	if active_heists.is_empty() and pending_results.is_empty():
		return
	var done: Array = []
	for h in active_heists:
		if now() >= float(h["ends_at"]):
			done.append(h)
	for h in done:
		active_heists.erase(h)
		var result := resolve_heist(h)
		pending_results.append(result)
		heist_resolved.emit(result)
	if not done.is_empty():
		save_game()
		state_changed.emit()


func preview_chance(heist_id: String, cat_ids: Array) -> float:
	var hd := GameData.heist_by_id(heist_id)
	var power := 0.0
	var luck_bonus := 0.0
	for cid in cat_ids:
		var idstr := String(cid)
		power += stat_value(idstr, String(hd["stat"]))
		var trait_key := String(GameData.cat_by_id(idstr).get("trait", ""))
		if trait_key == "lucky":
			luck_bonus += 0.08
		if trait_key == "dog_bonus" and heist_id == "shakedown_dog":
			luck_bonus += 0.10
	return clampf(0.5 + 0.06 * (power - float(hd["difficulty"])) + luck_bonus, 0.10, 0.95)


func resolve_heist(h: Dictionary) -> Dictionary:
	var hd := GameData.heist_by_id(String(h["heist_id"]))
	var cat_ids: Array = (h["cat_ids"] as Array).duplicate()
	var chance := preview_chance(String(h["heist_id"]), cat_ids)
	var target := clampi(roundi(chance * 20.0), 2, 19)
	var roll := randi_range(1, 20)
	var success := roll <= target

	var treats_won := 0
	var respect_won := 0
	if success:
		treats_won = int(hd["reward_t"])
		respect_won = int(hd["reward_r"])
		var mult := 1.0
		for cid in cat_ids:
			var trait_key := String(GameData.cat_by_id(String(cid)).get("trait", ""))
			if trait_key == "double_treats":
				mult += 0.25
			if trait_key == "velvet_touch" and String(hd["stat"]) in ["charm", "muscle_charm", "all"]:
				mult += 0.25
		treats_won = int(roundf(treats_won * mult))

	var injury_risk := float(hd["injury"])
	if success:
		injury_risk *= 0.5
	var injuries: Array = []
	for cid in cat_ids:
		var idstr := String(cid)
		var trait_key := String(GameData.cat_by_id(idstr).get("trait", ""))
		var risk := injury_risk
		if trait_key == "never_injured":
			risk = 0.0
		if trait_key == "unlucky":
			risk += 0.15
		if randf() < risk:
			injuries.append(idstr)
			cats[idstr]["state"] = "wounded"
			cats[idstr]["wounded_until"] = now() + WOUND_REST_SECONDS
			cats[idstr]["heist_id"] = ""
		else:
			cats[idstr]["state"] = "ready"
			cats[idstr]["heist_id"] = ""

	if success:
		treats += treats_won
		respect = mini(100, respect + respect_won)

	return {
		"heist_id": String(h["heist_id"]),
		"cat_ids": cat_ids,
		"success": success,
		"roll": roll,
		"target": target,
		"chance": chance,
		"treats_won": treats_won,
		"respect_won": respect_won,
		"injuries": injuries,
	}


func pop_result() -> Dictionary:
	if pending_results.is_empty():
		return {}
	var r: Dictionary = pending_results.pop_front()
	save_game()
	return r
