class_name WorldData
extends RefCounted

# Venues, tariffs and loot for the Pawfellas day cycle.

# Tariff rates are an index 0-3 shared by every good.
const TARIFF_LABELS = ["OFF", "LOW", "FAIR", "STEEP"]
const TARIFF_YIELD = [0.0, 0.18, 0.34, 0.55]
const TARIFF_TENSION = [0.0, 1.0, 2.5, 5.0]
const TARIFF_UNREST = [0.0, 0.5, 1.5, 3.5]

# Payout levels: what you cut the crew in for each night.
const PAYOUT_LABELS = ["SKIMMED", "FAIR", "GENEROUS"]
const PAYOUT_MULT = [0.5, 1.0, 1.6]
const PAYOUT_LOYALTY = [-9, 2, 6]

const OP_COLLECT = "collect"
const OP_SHAKEDOWN = "shakedown"

const MAX_UNREST = 100.0
const HEAT_BRIBE_PER_POINT = 1.4


static func goods() -> Array:
	return [
		{"id": "catnip", "name": "Imported Catnip", "blurb": "Grade-A, straight off the docks."},
		{"id": "salmon", "name": "Fancy Salmon", "blurb": "Iced crates. Moves fast, spoils faster."},
		{"id": "furniture", "name": "Leather Furniture", "blurb": "Scratchable luxury. Heavy margins."},
	]


static func venues() -> Array:
	return [
		{
			"id": "blind_pig", "name": "The Blind Pig Bar",
			"yield_label": "High Cash Flow", "risk_label": "Moderate",
			"base_yield": 46, "difficulty": 9, "risk": 0.30,
			"collect_stat": "charm", "shake_stat": "muscle_charm",
			"loot": "intel", "perk": "Speakeasy intel; bribes the local alley cats",
			"req_respect": 0,
		},
		{
			"id": "piazza", "name": "Piazza Fruit Market",
			"yield_label": "Moderate Cash Flow", "risk_label": "Low",
			"base_yield": 30, "difficulty": 6, "risk": 0.14,
			"collect_stat": "charm", "shake_stat": "muscle",
			"loot": "crate", "perk": "Exotic shipping crates; smuggler hideouts",
			"req_respect": 0,
		},
		{
			"id": "fishmonger", "name": "The Docks Fishmonger",
			"yield_label": "High Food Supplies", "risk_label": "High",
			"base_yield": 54, "difficulty": 12, "risk": 0.42,
			"collect_stat": "sneak", "shake_stat": "muscle",
			"loot": "salmon", "perk": "Grade-A salmon; patches up a wounded cat",
			"req_respect": 10,
		},
		{
			"id": "tailor", "name": "Luxury Tailor Shop",
			"yield_label": "Rare Items", "risk_label": "Low",
			"base_yield": 26, "difficulty": 8, "risk": 0.16,
			"collect_stat": "charm", "shake_stat": "muscle_charm",
			"loot": "silk_suit", "perk": "Silk suits and hats; +1 CHARM for the wearer",
			"req_respect": 16,
		},
		{
			"id": "hardware", "name": "The Corner Hardware Store",
			"yield_label": "Low Cash Flow", "risk_label": "Low",
			"base_yield": 20, "difficulty": 5, "risk": 0.12,
			"collect_stat": "sneak", "shake_stat": "muscle",
			"loot": "crowbar", "perk": "Crowbars and pipes; +1 MUSCLE for the wearer",
			"req_respect": 4,
		},
	]


# "gear" is equipped to one cat for a permanent stat bump.
# "use" is spent from the stash for an immediate effect.
static func items() -> Array:
	return [
		{"id": "intel", "name": "Speakeasy Intel", "kind": "use", "stat": "heat", "power": 14,
			"desc": "Word from the bar. Buys off the beat cop — cuts HEAT."},
		{"id": "crate", "name": "Smuggler's Crate", "kind": "use", "stat": "treats", "power": 70,
			"desc": "Whatever's inside, it sells. Straight treats."},
		{"id": "salmon", "name": "Grade-A Salmon", "kind": "use", "stat": "heal", "power": 1,
			"desc": "Patches up one wounded cat on the spot."},
		{"id": "silk_suit", "name": "Silk Suit", "kind": "gear", "stat": "charm", "power": 1,
			"desc": "Cut to flatter. +1 CHARM."},
		{"id": "crowbar", "name": "Crowbar", "kind": "gear", "stat": "muscle", "power": 1,
			"desc": "Persuasion, in iron. +1 MUSCLE."},
	]


static func venue_by_id(venue_id: String) -> Dictionary:
	for v in venues():
		if String(v["id"]) == venue_id:
			return v
	return {}


static func item_by_id(item_id: String) -> Dictionary:
	for i in items():
		if String(i["id"]) == item_id:
			return i
	return {}


static func good_by_id(good_id: String) -> Dictionary:
	for g in goods():
		if String(g["id"]) == good_id:
			return g
	return {}


## Risk as filled diamonds out of five, for the jobs card.
static func risk_pips(risk: float) -> int:
	if risk < 0.15:
		return 1
	if risk < 0.20:
		return 2
	if risk < 0.28:
		return 3
	if risk < 0.36:
		return 4
	return 5


static func venue_icon(venue_id: String) -> String:
	return "res://assets/ui/gen/venue/%s.png" % venue_id


static func op_label(op: String) -> String:
	return "SHAKEDOWN" if op == OP_SHAKEDOWN else "COLLECTION"
