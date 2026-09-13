class_name GameData
extends RefCounted

# Roster, traits and standing for Pawfellas.

const TINT_WHITE = Color(1.0, 1.0, 1.0)
const TINT_SILVER = Color(0.80, 0.80, 0.92)
const TINT_DARK = Color(0.50, 0.42, 0.46)
const TINT_GINGER = Color(1.0, 0.72, 0.50)
const TINT_CREAM = Color(1.0, 0.90, 0.75)

const TRAIT_NAMES = {
	"never_injured": "Never Squeals — never gets hurt on a job",
	"lucky": "Lucky Claws — better odds on every job",
	"unlucky": "Wrong Side of the Door — injury-prone",
	"double_treats": "Two-Times — +25% treats on a successful job",
	"dog_bonus": "Dog-Hater — edge on shakedowns",
	"velvet_touch": "Velvet Touch — +25% treats on collections",
}

const ROLE_LABELS = {
	"boss": "BOSS — not for hire",
	"player": "YOU",
	"muscle": "MUSCLE",
	"specialist": "SPECIALIST",
	"informant": "INFORMANT",
	"crew": "",
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
		{"id": "al_catpone", "name": "Al Catpone", "flavor": "The undisputed boss of the living room rug.", "muscle": 7, "sneak": 5, "charm": 9, "portrait": "mob/head/al_catpone", "tint": TINT_WHITE, "trait": "", "role": "muscle", "recruitable": true},
		{"id": "don_corlemeowne", "name": "Don Corle-meow-ne", "flavor": "Gives offers the dog simply can't refuse.", "muscle": 6, "sneak": 7, "charm": 10, "portrait": "mob/head/don_corlemeowne", "tint": TINT_WHITE, "trait": "", "role": "boss", "recruitable": false},
		{"id": "johnny_tightlips", "name": "Johnny \"Tight-Lips\"", "flavor": "Never squeals. Not at the vet, not ever.", "muscle": 5, "sneak": 8, "charm": 4, "portrait": "mob/head/johnny_tightlips", "tint": TINT_WHITE, "trait": "never_injured", "role": "informant", "recruitable": true},
		{"id": "sonny_hammer", "name": "Sonny \"The Hammer\"", "flavor": "Crushes his kibble. Swats toys with maximum aggression.", "muscle": 9, "sneak": 3, "charm": 3, "portrait": "mob/head/sonny_hammer", "tint": TINT_WHITE, "trait": "", "role": "muscle", "recruitable": true},
		{"id": "sammy_bull", "name": "Sammy \"The Bull\"", "flavor": "Shoulders the door, shoulders the blame. Built like a fridge.", "muscle": 10, "sneak": 2, "charm": 4, "portrait": "sit_02", "tint": TINT_DARK, "trait": "", "role": "muscle", "recruitable": true},
		{"id": "jimmy_twotimes", "name": "Jimmy \"Two-Times\"", "flavor": "Meows every command twice: \"Treats! Treats!\"", "muscle": 4, "sneak": 4, "charm": 7, "portrait": "mob/head/jimmy_twotimes", "tint": TINT_WHITE, "trait": "double_treats", "role": "player", "recruitable": false},
		{"id": "lefty_ruggiero", "name": "Lefty \"Ruggiero\"", "flavor": "Always caught on the wrong side of a closed door.", "muscle": 5, "sneak": 3, "charm": 5, "portrait": "mob/head/lefty_ruggiero", "tint": TINT_WHITE, "trait": "unlucky", "role": "informant", "recruitable": true},
		{"id": "lucky_clawciano", "name": "Lucky Claw-ciano", "flavor": "Somehow always lands on his feet after a bad jump.", "muscle": 5, "sneak": 6, "charm": 6, "portrait": "mob/head/lucky_clawciano", "tint": TINT_WHITE, "trait": "lucky", "role": "specialist", "recruitable": true},
		{"id": "frankie_fastpaws", "name": "Frankie \"The Lefty\"", "flavor": "Lightning-fast on the escape. Gone before the lock clicks.", "muscle": 7, "sneak": 8, "charm": 4, "portrait": "mob/head/frankie_fastpaws", "tint": TINT_WHITE, "trait": "", "role": "specialist", "recruitable": true},
		{"id": "vinnie_hook", "name": "Vinnie \"The Hook\"", "flavor": "Belly-rub him past three seconds and find out.", "muscle": 8, "sneak": 5, "charm": 3, "portrait": "mob/head/vinnie_hook", "tint": TINT_WHITE, "trait": "", "role": "muscle", "recruitable": true},
		{"id": "bugsy_meowsie", "name": "Bugsy Meow-sie", "flavor": "Starts the 3AM zoomies. A beautiful wild card.", "muscle": 6, "sneak": 9, "charm": 6, "portrait": "mob/head/bugsy_meowsie", "tint": TINT_WHITE, "trait": "", "role": "informant", "recruitable": true},
		{"id": "nicky_squeaker", "name": "Nicky \"The Squeaker\"", "flavor": "Looks tough. Speaks only in tiny meows.", "muscle": 2, "sneak": 5, "charm": 8, "portrait": "mob/head/nicky_squeaker", "tint": TINT_WHITE, "trait": "", "role": "informant", "recruitable": true},
		{"id": "mobby_weasel", "name": "Mobby \"The Weasel\" DeNiro", "flavor": "Into the pantry and out again. Never seen.", "muscle": 3, "sneak": 9, "charm": 6, "portrait": "mob/head/mobby_weasel", "tint": TINT_WHITE, "trait": "", "role": "specialist", "recruitable": true},
		{"id": "carmela", "name": "Carmela", "flavor": "The real boss. Runs everything behind the scenes.", "muscle": 6, "sneak": 7, "charm": 9, "portrait": "sit_01", "tint": TINT_CREAM, "trait": "", "role": "boss", "recruitable": false},
		{"id": "bella_blade", "name": "Bella \"The Blade\"", "flavor": "Small, sleek, shockingly sharp claws.", "muscle": 8, "sneak": 8, "charm": 5, "portrait": "sit_04", "tint": TINT_SILVER, "trait": "", "role": "crew", "recruitable": true},
		{"id": "ma_barker", "name": "Ma Barker", "flavor": "One glance keeps every pet in line.", "muscle": 7, "sneak": 4, "charm": 8, "portrait": "sit_03", "tint": TINT_WHITE, "trait": "", "role": "crew", "recruitable": true},
		{"id": "bonnie_parker", "name": "Bonnie Parker", "flavor": "Your hair ties? Gone. Your socks? Gone.", "muscle": 4, "sneak": 9, "charm": 6, "portrait": "sit_happy_02", "tint": TINT_GINGER, "trait": "", "role": "crew", "recruitable": true},
		{"id": "griselda_widow", "name": "Griselda \"The Black Widow\"", "flavor": "Rules the high back of the couch like a throne.", "muscle": 7, "sneak": 6, "charm": 8, "portrait": "sit_01", "tint": TINT_DARK, "trait": "", "role": "crew", "recruitable": true},
		{"id": "vikki_velvet", "name": "Vikki \"The Velvet Touch\"", "flavor": "Aggressive purring extorts extra wet food.", "muscle": 3, "sneak": 6, "charm": 9, "portrait": "sit_happy_01", "tint": TINT_CREAM, "trait": "velvet_touch", "role": "crew", "recruitable": true},
		{"id": "connie_don", "name": "Connie \"The Don\"", "flavor": "Quiet, scheming, enforces lap-nap privileges.", "muscle": 6, "sneak": 8, "charm": 7, "portrait": "sit_03", "tint": TINT_DARK, "trait": "", "role": "crew", "recruitable": true},
		{"id": "rosie_red", "name": "Rosie \"The Red\"", "flavor": "Fierce ginger. Takes zero nonsense from the dog.", "muscle": 8, "sneak": 5, "charm": 6, "portrait": "sit_02", "tint": TINT_GINGER, "trait": "dog_bonus", "role": "crew", "recruitable": true},
		{"id": "penny_pickpocket", "name": "Penny \"The Pickpocket\"", "flavor": "Knocks coins off tables into hidden spots.", "muscle": 4, "sneak": 9, "charm": 5, "portrait": "sit_happy_02", "tint": TINT_WHITE, "trait": "", "role": "crew", "recruitable": true},
		{"id": "lucia_scarfo", "name": "Lady \"Lucia\" Scarfo", "flavor": "Sweet outside. Ruthless enforcer inside.", "muscle": 8, "sneak": 6, "charm": 7, "portrait": "sit_04", "tint": TINT_CREAM, "trait": "", "role": "crew", "recruitable": true},
		{"id": "trixie_twotoes", "name": "Trixie \"Two-Toes\"", "flavor": "Polydactyl queen of the neighborhood block.", "muscle": 6, "sneak": 7, "charm": 8, "portrait": "sit_01", "tint": TINT_SILVER, "trait": "", "role": "crew", "recruitable": true},
		{"id": "sophia_squeeze", "name": "Sophia \"The Squeeze\"", "flavor": "Demands hugs, strictly on her terms.", "muscle": 5, "sneak": 5, "charm": 9, "portrait": "sit_happy_01", "tint": TINT_GINGER, "trait": "", "role": "crew", "recruitable": true},
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


static func role_name(role_key: String) -> String:
	return String(ROLE_LABELS.get(role_key, ""))


static func is_recruitable(cat_id: String) -> bool:
	var d := cat_by_id(cat_id)
	if d.is_empty():
		return false
	return bool(d.get("recruitable", true))


static func player_cat_ids() -> Array:
	var out: Array = []
	for c in cats():
		if String(c.get("role", "")) == "player":
			out.append(String(c["id"]))
	return out


static func trait_name(trait_key: String) -> String:
	return String(TRAIT_NAMES.get(trait_key, ""))


## Standing in the underworld, by respect.
static func rank_name(respect: int) -> String:
	if respect >= 90:
		return "Don of the House"
	if respect >= 70:
		return "Underboss"
	if respect >= 50:
		return "Capo"
	if respect >= 30:
		return "Made Cat"
	if respect >= 12:
		return "Soldier"
	return "Street Runner"


## Next rank up and the respect it takes, for progress display.
static func next_rank(respect: int) -> Array:
	for g in [12, 30, 50, 70, 90]:
		if respect < g:
			return [rank_name(g), g]
	return ["", 100]
