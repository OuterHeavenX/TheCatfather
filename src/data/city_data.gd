class_name CityData
extends RefCounted

## The map is a presentation of existing venue progression. Control and unrest
## remain in GameMan.venues; there is no duplicate territory simulation.
static func districts() -> Array:
	return [
		{"id":"little_italy","name":"Little Italy","tag":"The family starts here","respect":0,"venues":["blind_pig","piazza"],"color":Color("697852")},
		{"id":"tenements","name":"The Tenements","tag":"Quiet doors. Useful friends.","respect":4,"venues":["hardware"],"color":Color("9b865e")},
		{"id":"docks","name":"The Docks","tag":"Ships come and go. Secrets stay.","respect":10,"venues":["fishmonger"],"color":Color("587a83")},
		{"id":"midtown","name":"Midtown","tag":"Money talks. Dress accordingly.","respect":16,"venues":["tailor"],"color":Color("965b47")},
		{"id":"uptown","name":"Uptown","tag":"Beyond your present reach","respect":-1,"venues":[],"color":Color("686268")},
	]

static func district(id: String) -> Dictionary:
	for d in districts():
		if d.id == id: return d
	return districts()[0]

static func for_venue(id: String) -> Dictionary:
	for d in districts():
		if id in d.venues: return d
	return districts()[0]

static func unlocked(id: String) -> bool:
	var d := district(id)
	return int(d.respect) >= 0 and GameMan.respect >= int(d.respect)

static func description(id: String) -> String:
	return String({"blind_pig":"Behind a heavy door, the jazz is soft and the conversations softer. A collection buys tomorrow's quiet; a shakedown leaves a mark.","piazza":"Fruit under striped awnings. Crates under the counter. Every morning brings another truck and another opportunity.","hardware":"Locks, pipes and tools. The proprietor knows exactly which customers have no intention of repairing anything.","fishmonger":"Salt hangs in the air. Iced salmon arrives before dawn, alongside cargo nobody puts on the manifest.","tailor":"Fine wool, silk linings and the careful silence of a shop that dresses both sides of a feud."}.get(id,""))

static func headlines() -> Array:
	var out: Array = []
	for event in GameMan.journal:
		out.push_front(event)
	if GameMan.heat >= 35:
		out.push_front({"day":GameMan.day,"title":"POLICE WATCH THE BLOCKS","body":"Police attention stands at %d. More heat reduces the family's chances in The Racket." % GameMan.heat})
	if GameMan.tension >= 50:
		out.append({"day":GameMan.day,"title":"TRUCE UNDER STRAIN","body":"The two houses are watching one another. Steep tariffs may bring an Alley Syndicate response."})
	out.append({"day":GameMan.day,"title":"THE PRICE OF CATNIP","body":"The Fence asks %d T for a tin today, %+.0f%% against its usual price. Quotations change when the books close." % [GameMan.buy_price("catnip_tin"),(GameMan.price_mod("catnip_tin")-1)*100]})
	if out.size() == 1:
		out.push_front({"day":GameMan.day,"title":"FORTY CRATES. NO ANSWERS.","body":"An imported catnip shipment has vanished. The Claw-stra Nostra and the Alley Syndicate maintain an uneasy silence."})
	return out.slice(0,12)
