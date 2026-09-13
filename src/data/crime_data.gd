class_name CrimeData
extends RefCounted

## The Racket: a ladder of solo jobs a single cat runs on the spot, paid for in
## nerve and in that cat's energy. Every run of a crime banks experience in
## that crime, which is what opens the tier above it — money alone never does.

const TIER_NAMES = ["PETTY", "ORGANISED", "SERIOUS", "THE BIG SCORE"]
## Experience banked in a tier before the next one will talk to you.
const TIER_REQ = [0, 14, 46, 120]

const JAIL_BAIL_PER_DAY := 70


static func crimes() -> Array:
	return [
		# ---- tier 0: petty ------------------------------------------------
		{
			"id": "milk_bottle", "tier": 0, "name": "Pinch a Milk Bottle",
			"desc": "Doorstep work. The milkman is slow and the bottles are heavy.",
			"stat": "sneak", "difficulty": 2.0,
			"nerve": 1, "energy": 2, "pay": [9, 18],
			"heat": 0.5, "jail": 0.10, "xp": 2,
		},
		{
			"id": "newsboy", "tier": 0, "name": "Lean on a Newsboy",
			"desc": "He keeps a nickel a paper. You keep the nickel.",
			"stat": "muscle", "difficulty": 2.5,
			"nerve": 1, "energy": 2, "pay": [12, 24],
			"heat": 1.0, "jail": 0.12, "xp": 2,
		},
		{
			"id": "pick_pocket", "tier": 0, "name": "Work the Streetcar",
			"desc": "Crowded boards, loose coats, nobody looking down.",
			"stat": "sneak", "difficulty": 3.5,
			"nerve": 2, "energy": 3, "pay": [20, 38],
			"heat": 1.5, "jail": 0.16, "xp": 3,
		},
		# ---- tier 1: organised ---------------------------------------------
		{
			"id": "boost_motorcar", "tier": 1, "name": "Boost a Motorcar",
			"desc": "Cassoni pays cash for anything with four wheels and no papers.",
			"stat": "sneak", "difficulty": 6.0,
			"nerve": 3, "energy": 4, "pay": [46, 84],
			"heat": 3.0, "jail": 0.20, "xp": 5,
		},
		{
			"id": "numbers_game", "tier": 1, "name": "Run the Numbers",
			"desc": "Sell the whole block a dream at three cents a ticket.",
			"stat": "charm", "difficulty": 6.5,
			"nerve": 3, "energy": 4, "pay": [52, 92],
			"heat": 2.5, "jail": 0.17, "xp": 5,
		},
		{
			"id": "fixed_fight", "tier": 1, "name": "Fix a Prize Fight",
			"desc": "The tabby in the red corner goes down in the fourth. Bet accordingly.",
			"stat": "charm", "difficulty": 8.0,
			"nerve": 4, "energy": 5, "pay": [70, 128],
			"heat": 4.0, "jail": 0.22, "xp": 7,
		},
		# ---- tier 2: serious ------------------------------------------------
		{
			"id": "liquor_truck", "tier": 2, "name": "Hijack a Liquor Truck",
			"desc": "Two miles of bad road and a driver who wants to live.",
			"stat": "muscle", "difficulty": 11.0,
			"nerve": 5, "energy": 6, "pay": [130, 215],
			"heat": 7.0, "jail": 0.26, "xp": 9,
		},
		{
			"id": "crack_safe", "tier": 2, "name": "Crack a Safe",
			"desc": "Claws on the dial, ear to the door. All night if it takes all night.",
			"stat": "sneak", "difficulty": 12.0,
			"nerve": 5, "energy": 6, "pay": [150, 245],
			"heat": 6.0, "jail": 0.28, "xp": 10,
		},
		{
			"id": "alderman", "tier": 2, "name": "Buy an Alderman",
			"desc": "Everyone at City Hall has a price. His is embarrassingly low.",
			"stat": "charm", "difficulty": 10.0,
			"nerve": 4, "energy": 5, "pay": [110, 190],
			"heat": -8.0, "jail": 0.18, "xp": 8,
		},
		# ---- tier 3: the big score ------------------------------------------
		{
			"id": "merchants_bank", "tier": 3, "name": "The Merchants Bank",
			"desc": "Front door, daylight, four minutes. The way it is done properly.",
			"stat": "muscle", "difficulty": 17.0,
			"nerve": 8, "energy": 8, "pay": [340, 540],
			"heat": 16.0, "jail": 0.34, "xp": 14,
		},
		{
			"id": "pier_heist", "tier": 3, "name": "The Pier Nineteen Job",
			"desc": "A whole bonded warehouse, and the night watchman owes you money.",
			"stat": "sneak", "difficulty": 18.0,
			"nerve": 8, "energy": 8, "pay": [380, 600],
			"heat": 13.0, "jail": 0.32, "xp": 15,
		},
		{
			"id": "mayors_letters", "tier": 3, "name": "The Mayor's Letters",
			"desc": "He wrote them himself. That is the beautiful part.",
			"stat": "charm", "difficulty": 15.0,
			"nerve": 7, "energy": 7, "pay": [300, 500],
			"heat": 9.0, "jail": 0.28, "xp": 13,
		},
	]


static func crime_by_id(crime_id: String) -> Dictionary:
	for c in crimes():
		if String(c["id"]) == crime_id:
			return c
	return {}


static func crimes_in_tier(tier: int) -> Array:
	var out: Array = []
	for c in crimes():
		if int(c["tier"]) == tier:
			out.append(c)
	return out


static func tier_name(tier: int) -> String:
	return String(TIER_NAMES[clampi(tier, 0, TIER_NAMES.size() - 1)])


## Flavour for a botched job, so failure reads as a story rather than a dice roll.
static func fumble(crime_id: String) -> String:
	match crime_id:
		"milk_bottle": return "The bottle went over. Half the street heard it."
		"newsboy": return "The kid had an older brother. A much older brother."
		"pick_pocket": return "Wrong coat. The gentleman was a detective."
		"boost_motorcar": return "The engine caught on the third try. The owner caught up on the second."
		"numbers_game": return "Somebody else already had the block. They were not pleased."
		"fixed_fight": return "The tabby forgot the plan and won. So did the bookmakers."
		"liquor_truck": return "The driver wanted to live, but he also wanted to be a hero."
		"crack_safe": return "The dial gave nothing up. The nightwatchman gave plenty."
		"alderman": return "He took the money, then took your name down as well."
		"merchants_bank": return "Four minutes turned into nine. Nine is how long the police take."
		"pier_heist": return "The watchman paid off his debt to somebody else first."
		"mayors_letters": return "The letters were copies. The trap was not."
	return "It went wrong in the usual way."
