class_name StoryData
extends RefCounted

# Story beats for Pawfellas. A beat fires on the morning of the first day that
# clears its "day" and "req_respect" gates. Choices set alignment and flags,
# which later beats read.

const ALIGN_DON = "don"
const ALIGN_CARMELA = "carmela"
const ALIGN_SELF = "self"


static func beats() -> Array:
	return [
		{
			"id": "summons", "day": 1, "req_respect": 0, "req_align": "",
			"title": "Chapter I — The Missing Nip",
			"lines": [
				{"who": "don_corlemeowne", "text": "Jimmy. Sit. You know why you're here."},
				{"who": "jimmy_twotimes", "text": "The shipment. The shipment, Don."},
				{"who": "don_corlemeowne", "text": "Forty crates of grade-A off the Kelso dock. Gone between the tide and the truck. My truce with the Alley Syndicate is nine years old and it is currently held together by nothing but my good manners."},
				{"who": "don_corlemeowne", "text": "Find my nip. Run the blocks while you do it — a cat with no income is a cat with no ears on the street."},
				{"who": "jimmy_twotimes", "text": "Consider it found. Consider it found."},
			],
			"choices": [],
		},
		{
			"id": "squeaker", "day": 2, "req_respect": 0, "req_align": "",
			"title": "Chapter II — The Squeaker's Price",
			"lines": [
				{"who": "nicky_squeaker", "text": "I might've seen a truck. Little truck. Wrong plates."},
				{"who": "jimmy_twotimes", "text": "Might've. Might've."},
				{"who": "nicky_squeaker", "text": "Memory's a delicate thing, Jimmy. Runs better on wet food."},
			],
			"choices": [
				{
					"text": "Buy the little rat his dinner. (-30 treats)",
					"treats": -30, "heat": 0, "tension": 0, "align": "", "flag": "paid_nicky",
					"reply": "Salmon pate, the good tin. Nicky talks for eleven minutes without breathing: the truck went east, toward the fish market, riding low.",
				},
				{
					"text": "Hold him upside down and shake.",
					"treats": 0, "heat": 6, "tension": 0, "align": "", "flag": "shook_nicky",
					"reply": "He squeaks it all out — east, toward the fish market, riding low — then bolts. Word gets around that you strong-arm informants. The beat cops take an interest.",
				},
			],
		},
		{
			"id": "docks", "day": 4, "req_respect": 0, "req_align": "",
			"title": "Chapter III — Salt and Rope",
			"lines": [
				{"who": "mobby_weasel", "text": "In and out of the fishmonger's back room, boss. Nobody saw me. Nobody ever does."},
				{"who": "mobby_weasel", "text": "Empty crates. Our crates. But the rope on 'em is Alley rope — that green-flecked stuff they splice down on Mott Street."},
				{"who": "jimmy_twotimes", "text": "So Carmela robbed us. Carmela robbed us?"},
				{"who": "mobby_weasel", "text": "That's what the rope says. Rope don't always say the truth, though. Rope says what somebody tied it to say."},
			],
			"choices": [],
		},
		{
			"id": "lady_calls", "day": 6, "req_respect": 0, "req_align": "",
			"title": "Chapter IV — A Lady Calls",
			"lines": [
				{"who": "carmela", "text": "You've been asking about green rope, Mr. Two-Times. Ask me instead. I'll charge you less than Nicky does."},
				{"who": "jimmy_twotimes", "text": "You're a long way off your blocks."},
				{"who": "carmela", "text": "I lost eleven crates the same night you lost forty. Somebody is walking us both into a war and selling tickets. Come to the Blind Pig at midnight and I'll show you the manifest."},
			],
			"choices": [
				{
					"text": "Midnight it is.",
					"treats": 0, "heat": 0, "tension": -10, "align": "", "flag": "met_carmela",
					"reply": "She keeps her word and her distance. The manifest is real: both shipments booked through the same freight agent, a tailor's cousin on Prince Street. Tension eases — for now.",
				},
				{
					"text": "I don't drink with people who rob me.",
					"treats": 0, "heat": 0, "tension": 12, "align": "", "flag": "refused_carmela",
					"reply": "You send back her invitation with a claw mark through it. The Alley Syndicate reads that exactly how you'd expect. Her collectors start working your blocks an hour early.",
				},
			],
		},
		{
			"id": "the_lefty", "day": 8, "req_respect": 0, "req_align": "",
			"title": "Chapter V — The Lefty Runs",
			"lines": [
				{"who": "frankie_fastpaws", "text": "Tailed the freight agent six blocks. He made me at the fourth."},
				{"who": "frankie_fastpaws", "text": "Didn't matter. Nobody catches the Lefty. He ducked into the tailor's, came out with a ledger under his coat, and put it in a mail drop on Prince."},
				{"who": "jimmy_twotimes", "text": "And the ledger?"},
				{"who": "frankie_fastpaws", "text": "Still in the drop. I don't do locks, Jimmy. I do distance."},
			],
			"choices": [],
		},
		{
			"id": "ledger", "day": 10, "req_respect": 0, "req_align": "",
			"title": "Chapter VI — A Name in the Ledger",
			"lines": [
				{"who": "vinnie_hook", "text": "Lock came off clean. Didn't even wake the dog."},
				{"who": "vinnie_hook", "text": "Every crate, both syndicates, signed out to the same account. Paid in advance. Paid in cash."},
				{"who": "jimmy_twotimes", "text": "Signed by who? Signed by who?"},
				{"who": "vinnie_hook", "text": "That's the thing, Jimmy. It's one of ours. Signature's a paw-print. Left paw."},
			],
			"choices": [],
		},
		{
			"id": "open_door", "day": 12, "req_respect": 0, "req_align": "",
			"title": "Chapter VII — The Door That Was Open",
			"lines": [
				{"who": "lefty_ruggiero", "text": "I want you to hear it from me, Jimmy. I was on the Kelso dock that night. Third watch."},
				{"who": "lefty_ruggiero", "text": "I got stuck behind the freight door. Same as always. Everybody laughs. And while I was stuck, somebody walked forty crates past me and I couldn't do a thing but watch."},
				{"who": "jimmy_twotimes", "text": "Who, Lefty. Who."},
				{"who": "lefty_ruggiero", "text": "He wore the Don's ring. I'm not saying it was the Don. I'm saying somebody with the Don's ring wanted a war, and wanted us both blaming the rope."},
			],
			"choices": [],
		},
		{
			"id": "three_ways", "day": 14, "req_respect": 0, "req_align": "",
			"title": "Chapter VIII — Three Ways to End It",
			"lines": [
				{"who": "jimmy_twotimes", "text": "So that's the shape of it. Somebody inside staged a robbery to start a war, and both houses walked right into it."},
				{"who": "jimmy_twotimes", "text": "Which means whoever's left standing when the shooting stops was never going to be the one who started it. Which means it's my call now. My call."},
			],
			"choices": [
				{
					"text": "Take it to the Don. He's earned the truth.",
					"treats": 0, "heat": -10, "tension": -25, "align": ALIGN_DON, "flag": "",
					"reply": "You lay it out on his desk — rope, ledger, ring. The old cat is quiet a long time. Then: \"You could have used this against me. Remember that I know you didn't.\" The Claw-stra Nostra closes ranks behind you.",
				},
				{
					"text": "Take it to Carmela. She was straight with you.",
					"treats": 0, "heat": -6, "tension": -30, "align": ALIGN_CARMELA, "flag": "",
					"reply": "She reads the ledger twice and slides it back. \"Neither of us was robbed, Jimmy. We were both invoiced.\" The Alley Syndicate stands down, and her collectors start calling you sir.",
				},
				{
					"text": "Take it for yourself. Both houses are bleeding.",
					"treats": 120, "heat": 14, "tension": 18, "align": ALIGN_SELF, "flag": "",
					"reply": "You sell the ledger's silence to the freight agent and let both houses keep swinging. It pays like nothing you've ever run. It also means everyone who matters now has a reason to find you.",
				},
			],
		},
		{
			"id": "end_don", "day": 16, "req_respect": 0, "req_align": ALIGN_DON,
			"title": "Chapter IX — Consigliere",
			"lines": [
				{"who": "don_corlemeowne", "text": "The ring belonged to my nephew. He is in Jersey now, permanently, and we will not discuss it again."},
				{"who": "don_corlemeowne", "text": "The blocks you've been running are yours. Not to collect. To keep."},
				{"who": "jimmy_twotimes", "text": "Just like that. Just like that."},
				{"who": "don_corlemeowne", "text": "Nothing is ever just like that, Jimmy. But yes. Just like that."},
			],
			"choices": [],
		},
		{
			"id": "end_carmela", "day": 16, "req_respect": 0, "req_align": ALIGN_CARMELA,
			"title": "Chapter IX — The Alley Crown",
			"lines": [
				{"who": "carmela", "text": "The freight agent has retired. The nephew with the ring has retired. It was a very busy Tuesday."},
				{"who": "carmela", "text": "The old cat keeps his house and his dignity, and I keep everything east of the market. You keep the part nobody can take — both of us owe you."},
				{"who": "jimmy_twotimes", "text": "That's a dangerous thing to be owed by two syndicates."},
				{"who": "carmela", "text": "It's the only safe thing there is, in this city."},
			],
			"choices": [],
		},
		{
			"id": "end_self", "day": 16, "req_respect": 0, "req_align": ALIGN_SELF,
			"title": "Chapter IX — Don of the House",
			"lines": [
				{"who": "jimmy_twotimes", "text": "Took eleven days for the two oldest houses in this city to chew each other down to the collar."},
				{"who": "jimmy_twotimes", "text": "Took one more for the blocks to notice who was still standing at the fish market with the books in his paw."},
				{"who": "jimmy_twotimes", "text": "They call me Don now. Don. Say it twice, it sticks."},
			],
			"choices": [],
		},
	]


static func beat_by_id(beat_id: String) -> Dictionary:
	for b in beats():
		if String(b["id"]) == beat_id:
			return b
	return {}
