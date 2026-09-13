class_name GameData
extends RefCounted

# Static roster + heist definitions for The Catfather.

const TINT_WHITE = Color(1.0, 1.0, 1.0)
const TINT_SILVER = Color(0.80, 0.80, 0.92)
const TINT_DARK = Color(0.50, 0.42, 0.46)
const TINT_GINGER = Color(1.0, 0.72, 0.50)
const TINT_CREAM = Color(1.0, 0.90, 0.75)

const TRAIT_NAMES = {
	"never_injured": "Never Squeals — cannot be injured",
	"lucky": "Lucky Claws — better odds on heists",
	"unlucky": "Wrong Side of the Door — injury-prone",
	"double_treats": "Two-Times — +25% treats on success",
	"dog_bonus": "Dog-Hater — edge on dog jobs",
	"velvet_touch": "Velvet Touch — +25% treats on charm jobs",
}

const STAT_LABELS = {
	"sneak": "SNEAK",
	"muscle": "MUSCLE",
	"charm": "CHARM",
	"muscle_charm": "MUSCLE + CHARM",
	"all": "ALL STATS",
}


static func cats() -> Array:
	return [
		{"id": "al_catpone", "name": "Al Catpone", "flavor": "The undisputed boss of the living room rug.", "muscle": 7, "sneak": 5, "charm": 9, "portrait": "mob/head/al_catpone", "tint": TINT_WHITE, "trait": ""},
		{"id": "don_corlemeowne", "name": "Don Corle-meow-ne", "flavor": "Gives offers the dog simply can't refuse.", "muscle": 6, "sneak": 7, "charm": 10, "portrait": "mob/head/don_corlemeowne", "tint": TINT_WHITE, "trait": ""},
		{"id": "johnny_tightlips", "name": "Johnny \"Tight-Lips\"", "flavor": "Never squeals. Not at the vet, not ever.", "muscle": 5, "sneak": 8, "charm": 4, "portrait": "mob/head/johnny_tightlips", "tint": TINT_WHITE, "trait": "never_injured"},
		{"id": "sonny_hammer", "name": "Sonny \"The Hammer\"", "flavor": "Crushes his kibble. Swats toys with maximum aggression.", "muscle": 9, "sneak": 3, "charm": 3, "portrait": "mob/head/sonny_hammer", "tint": TINT_WHITE, "trait": ""},
		{"id": "jimmy_twotimes", "name": "Jimmy \"Two-Times\"", "flavor": "Meows every command twice: \"Treats! Treats!\"", "muscle": 4, "sneak": 4, "charm": 7, "portrait": "mob/head/jimmy_twotimes", "tint": TINT_WHITE, "trait": "double_treats"},
		{"id": "lefty_ruggiero", "name": "Lefty \"Ruggiero\"", "flavor": "Always caught on the wrong side of a closed door.", "muscle": 5, "sneak": 3, "charm": 5, "portrait": "mob/head/lefty_ruggiero", "tint": TINT_WHITE, "trait": "unlucky"},
		{"id": "lucky_clawciano", "name": "Lucky Claw-ciano", "flavor": "Somehow always lands on his feet after a bad jump.", "muscle": 5, "sneak": 6, "charm": 6, "portrait": "mob/head/lucky_clawciano", "tint": TINT_WHITE, "trait": "lucky"},
		{"id": "frankie_fastpaws", "name": "Frankie \"Fast-Paws\"", "flavor": "Batters toy mice faster than the eye can see.", "muscle": 7, "sneak": 8, "charm": 4, "portrait": "mob/head/frankie_fastpaws", "tint": TINT_WHITE, "trait": ""},
		{"id": "vinnie_hook", "name": "Vinnie \"The Hook\"", "flavor": "Belly-rub him past three seconds and find out.", "muscle": 8, "sneak": 5, "charm": 3, "portrait": "mob/head/vinnie_hook", "tint": TINT_WHITE, "trait": ""},
		{"id": "bugsy_meowsie", "name": "Bugsy Meow-sie", "flavor": "Starts the 3AM zoomies. A beautiful wild card.", "muscle": 6, "sneak": 9, "charm": 6, "portrait": "mob/head/bugsy_meowsie", "tint": TINT_WHITE, "trait": ""},
		{"id": "nicky_squeaker", "name": "Nicky \"The Squeaker\"", "flavor": "Looks tough. Speaks only in tiny meows.", "muscle": 2, "sneak": 5, "charm": 8, "portrait": "mob/head/nicky_squeaker", "tint": TINT_WHITE, "trait": ""},
		{"id": "mobby_weasel", "name": "Mobby \"The Weasel\" DeNiro", "flavor": "Into the pantry and out again. Never seen.", "muscle": 3, "sneak": 9, "charm": 6, "portrait": "mob/head/mobby_weasel", "tint": TINT_WHITE, "trait": ""},
		{"id": "carmela", "name": "Carmela", "flavor": "The real boss. Runs everything behind the scenes.", "muscle": 6, "sneak": 7, "charm": 9, "portrait": "sit_01", "tint": TINT_CREAM, "trait": ""},
		{"id": "bella_blade", "name": "Bella \"The Blade\"", "flavor": "Small, sleek, shockingly sharp claws.", "muscle": 8, "sneak": 8, "charm": 5, "portrait": "sit_04", "tint": TINT_SILVER, "trait": ""},
		{"id": "ma_barker", "name": "Ma Barker", "flavor": "One glance keeps every pet in line.", "muscle": 7, "sneak": 4, "charm": 8, "portrait": "sit_03", "tint": TINT_WHITE, "trait": ""},
		{"id": "bonnie_parker", "name": "Bonnie Parker", "flavor": "Your hair ties? Gone. Your socks? Gone.", "muscle": 4, "sneak": 9, "charm": 6, "portrait": "sit_happy_02", "tint": TINT_GINGER, "trait": ""},
		{"id": "griselda_widow", "name": "Griselda \"The Black Widow\"", "flavor": "Rules the high back of the couch like a throne.", "muscle": 7, "sneak": 6, "charm": 8, "portrait": "sit_01", "tint": TINT_DARK, "trait": ""},
		{"id": "vikki_velvet", "name": "Vikki \"The Velvet Touch\"", "flavor": "Aggressive purring extorts extra wet food.", "muscle": 3, "sneak": 6, "charm": 9, "portrait": "sit_happy_01", "tint": TINT_CREAM, "trait": "velvet_touch"},
		{"id": "connie_don", "name": "Connie \"The Don\"", "flavor": "Quiet, scheming, enforces lap-nap privileges.", "muscle": 6, "sneak": 8, "charm": 7, "portrait": "sit_03", "tint": TINT_DARK, "trait": ""},
		{"id": "rosie_red", "name": "Rosie \"The Red\"", "flavor": "Fierce ginger. Takes zero nonsense from the dog.", "muscle": 8, "sneak": 5, "charm": 6, "portrait": "sit_02", "tint": TINT_GINGER, "trait": "dog_bonus"},
		{"id": "penny_pickpocket", "name": "Penny \"The Pickpocket\"", "flavor": "Knocks coins off tables into hidden spots.", "muscle": 4, "sneak": 9, "charm": 5, "portrait": "sit_happy_02", "tint": TINT_WHITE, "trait": ""},
		{"id": "lucia_scarfo", "name": "Lady \"Lucia\" Scarfo", "flavor": "Sweet outside. Ruthless enforcer inside.", "muscle": 8, "sneak": 6, "charm": 7, "portrait": "sit_04", "tint": TINT_CREAM, "trait": ""},
		{"id": "trixie_twotoes", "name": "Trixie \"Two-Toes\"", "flavor": "Polydactyl queen of the neighborhood block.", "muscle": 6, "sneak": 7, "charm": 8, "portrait": "sit_01", "tint": TINT_SILVER, "trait": ""},
		{"id": "sophia_squeeze", "name": "Sophia \"The Squeeze\"", "flavor": "Demands hugs, strictly on her terms.", "muscle": 5, "sneak": 5, "charm": 9, "portrait": "sit_happy_01", "tint": TINT_GINGER, "trait": ""},
	]


static func cat_by_id(cat_id: String) -> Dictionary:
	for c in cats():
		if String(c["id"]) == cat_id:
			return c
	return {}


static func cat_cost(cat_id: String) -> int:
	var d := cat_by_id(cat_id)
	if d.is_empty():
		return 0
	var total := int(d["muscle"]) + int(d["sneak"]) + int(d["charm"])
	return clampi(total * 5, 40, 140)


static func trait_name(trait_key: String) -> String:
	return String(TRAIT_NAMES.get(trait_key, ""))


static func heists() -> Array:
	return [
		{"id": "pantry_raid", "name": "Pantry Raid", "desc": "Hit the pantry shelves before the human wakes up.", "stat": "sneak", "difficulty": 8, "min_cats": 1, "max_cats": 2, "duration": 45.0, "reward_t": 40, "reward_r": 4, "injury": 0.15, "req_respect": 0, "show_dog": false},
		{"id": "zoomies_3am", "name": "3AM Zoomies Distraction", "desc": "Bugsy's specialty: pure chaos at 3AM while the crew slips past.", "stat": "sneak", "difficulty": 10, "min_cats": 1, "max_cats": 2, "duration": 60.0, "reward_t": 55, "reward_r": 5, "injury": 0.15, "req_respect": 0, "show_dog": false},
		{"id": "hair_tie_hijack", "name": "Hair Tie Hijack", "desc": "Penny's classic: hair ties and socks, gone without a trace.", "stat": "sneak", "difficulty": 12, "min_cats": 1, "max_cats": 2, "duration": 75.0, "reward_t": 70, "reward_r": 7, "injury": 0.20, "req_respect": 0, "show_dog": false},
		{"id": "couch_turf", "name": "Couch Turf Takeover", "desc": "Take the high back of the couch by force.", "stat": "muscle", "difficulty": 14, "min_cats": 2, "max_cats": 2, "duration": 90.0, "reward_t": 95, "reward_r": 10, "injury": 0.25, "req_respect": 0, "show_dog": false},
		{"id": "shakedown_dog", "name": "Shake Down the Dog", "desc": "The dog has been hoarding treats. Time to collect.", "stat": "muscle_charm", "difficulty": 18, "min_cats": 2, "max_cats": 3, "duration": 120.0, "reward_t": 150, "reward_r": 15, "injury": 0.35, "req_respect": 0, "show_dog": true},
		{"id": "kibble_score", "name": "The Big Kibble Score", "desc": "The motherlode: the bulk kibble vault. Bring your best crew.", "stat": "all", "difficulty": 24, "min_cats": 3, "max_cats": 3, "duration": 180.0, "reward_t": 260, "reward_r": 25, "injury": 0.40, "req_respect": 40, "show_dog": false},
	]


static func heist_by_id(heist_id: String) -> Dictionary:
	for h in heists():
		if String(h["id"]) == heist_id:
			return h
	return {}


static func turf_name(respect: int) -> String:
	if respect >= 100:
		return "The Whole House"
	if respect >= 80:
		return "The Bedroom"
	if respect >= 60:
		return "The Pantry"
	if respect >= 40:
		return "The Kitchen"
	if respect >= 20:
		return "The Couch"
	return "The Living Room Rug"


static func next_turf(respect: int) -> Array:
	var gates := [20, 40, 60, 80, 100]
	for g in gates:
		if respect < g:
			return [turf_name(g), g]
	return ["", 100]
