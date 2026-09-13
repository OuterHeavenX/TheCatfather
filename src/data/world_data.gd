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
# "price" is what the Fence asks for one. Zero means it is not for sale at any
# price and can only be taken off somebody.
static func items() -> Array:
	return [
		{"id": "intel", "name": "Speakeasy Intel", "kind": "use", "stat": "heat", "power": 14,
			"price": 90,
			"desc": "Word from the bar. Buys off the beat cop — cuts HEAT."},
		{"id": "crate", "name": "Smuggler's Crate", "kind": "use", "stat": "treats", "power": 70,
			"price": 0,
			"desc": "Whatever's inside, it sells. Straight treats."},
		{"id": "salmon", "name": "Grade-A Salmon", "kind": "use", "stat": "heal", "power": 1,
			"price": 120,
			"desc": "Patches up one wounded cat on the spot."},
		{"id": "catnip_tin", "name": "Tin of Catnip", "kind": "use", "stat": "train", "power": 2,
			"price": 60,
			"desc": "Doubles what the next session at the gym puts on."},
		{"id": "cigars", "name": "Box of Cigars", "kind": "use", "stat": "loyalty", "power": 10,
			"price": 150,
			"desc": "Passed around the back room. +10 loyalty, every cat on the books."},
		{"id": "silk_suit", "name": "Silk Suit", "kind": "gear", "stat": "charm", "power": 1,
			"price": 190,
			"desc": "Cut to flatter. +1 CHARM."},
		{"id": "crowbar", "name": "Crowbar", "kind": "gear", "stat": "muscle", "power": 1,
			"price": 160,
			"desc": "Persuasion, in iron. +1 MUSCLE."},
		{"id": "rubber_soles", "name": "Rubber Soles", "kind": "gear", "stat": "sneak", "power": 1,
			"price": 150,
			"desc": "Not a sound on a tin roof. +1 SNEAK."},
		{"id": "brass_knuckles", "name": "Brass Knuckles", "kind": "gear", "stat": "muscle", "power": 2,
			"price": 380,
			"desc": "Ends the conversation early. +2 MUSCLE."},
		{"id": "burglar_kit", "name": "Burglar's Kit", "kind": "gear", "stat": "sneak", "power": 2,
			"price": 420,
			"desc": "Picks, wax, a stethoscope. +2 SNEAK."},
		{"id": "pinstripe_suit", "name": "Pinstripe & Homburg", "kind": "gear", "stat": "charm", "power": 2,
			"price": 440,
			"desc": "Nobody argues with a cat dressed like this. +2 CHARM."},
	]


## What the Fence hands over for one, before the day's price drift.
static func sell_value(item_id: String) -> int:
	var item := item_by_id(item_id)
	if item.is_empty():
		return 0
	var listed := int(item.get("price", 0))
	if listed <= 0:
		listed = int(item.get("power", 0)) * 10 + 40
	return int(round(float(listed) * 0.55))


# ---------------------------------------------------------------- the gym

## Three regimens, one per stat. Training is bought with a cat's energy and
## your money, and every point already trained makes the next one cost more
## and give less — the ceiling is time, not treats.
static func regimens() -> Array:
	return [
		{"id": "muscle", "name": "The Heavy Bag", "stat": "muscle",
			"desc": "Sandbag in a cellar. Nothing clever about it."},
		{"id": "sneak", "name": "The Fire Escapes", "stat": "sneak",
			"desc": "Six floors up, in the dark, carrying something."},
		{"id": "charm", "name": "Etiquette Lessons", "stat": "charm",
			"desc": "Which fork, whose hand, how long to hold a look."},
	]


# ---------------------------------------------------------------- holdings

## Bought once, paid out every night, and each one bends a rule of the game.
static func properties() -> Array:
	return [
		{"id": "flophouse", "name": "The Flophouse", "cost": 620, "income": 16,
			"perk": "Everyone sleeps in. +1 ENERGY a day for every cat.",
			"req_respect": 0},
		{"id": "garage", "name": "Cassoni's Garage", "cost": 940, "income": 24,
			"perk": "Somewhere to put the cars. +12% on every job in The Racket.",
			"req_respect": 8},
		{"id": "bathhouse", "name": "The Bathhouse", "cost": 1240, "income": 18,
			"perk": "Steam and a doctor who asks nothing. Wounds heal a day sooner.",
			"req_respect": 14},
		{"id": "social_club", "name": "The Social Club", "cost": 1750, "income": 34,
			"perk": "A room to plan in. +3 NERVE a night and a higher ceiling.",
			"req_respect": 22},
		{"id": "back_room_bank", "name": "The Back-Room Bank", "cost": 2900, "income": 62,
			"perk": "Money that was never anywhere. HEAT falls 4 faster a night.",
			"req_respect": 32},
	]


static func property_by_id(property_id: String) -> Dictionary:
	for pr in properties():
		if String(pr["id"]) == property_id:
			return pr
	return {}


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


## Ink trade sign, shown while a venue is still locked.
static func venue_icon(venue_id: String) -> String:
	return "res://assets/ui/gen/venue/%s.png" % venue_id


## Painted scene, shown once the venue is workable.
static func venue_scene(venue_id: String) -> String:
	return "res://assets/ui/gen/venue/scene_%s.png" % venue_id


static func op_label(op: String) -> String:
	return "SHAKEDOWN" if op == OP_SHAKEDOWN else "COLLECTION"
