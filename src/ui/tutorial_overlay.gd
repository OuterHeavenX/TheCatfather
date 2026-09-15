class_name TutorialOverlay
extends Control

## A first-run, no-cost tour of the real interface. Each step is saved so a
## browser refresh never forces the player back to the beginning.
const STEPS := [
	{
		"page": "home",
		"title": "Welcome to the Family",
		"body": "You are Jimmy \u201cTwo-Times.\u201d The Don\u2019s catnip shipment is missing, the truce is fraying, and this back room is where your empire begins.",
		"button": "SHOW ME THE BASICS",
	},
	{
		"page": "home",
		"title": "Read the Room",
		"body": "Cash buys training, gear, bail, and holdings. Each cat spends Energy. The family spends Nerve on crimes. Heat brings police pressure. Respect opens doors across New York.",
		"button": "OPEN THE CITY",
	},
	{
		"page": "city",
		"title": "The City Is Your Board",
		"body": "Districts hold businesses, jobs, and story meetings. Respect unlocks new neighborhoods. Start in Little Italy, where Jimmy already knows the streets.",
		"button": "ENTER LITTLE ITALY",
	},
	{
		"page": "district",
		"title": "Every District Has Work",
		"body": "Visit locations to learn what they offer. The Alley Gym and Fence also live in Little Italy. For now, pay a call on the Blind Pig.",
		"button": "VISIT THE BLIND PIG",
	},
	{
		"page": "location",
		"title": "Locations Are Business",
		"body": "Collections are steadier; shakedowns pay more and cause trouble. Assigning a cat reserves Energy. City operations resolve only when you close the books.",
		"button": "SEE THE RACKET",
	},
	{
		"page": "racket",
		"title": "Crime Takes Nerve",
		"body": "Racket jobs resolve immediately and spend both Nerve and a cat\u2019s Energy. Practice raises that crime\u2019s odds and unlocks harder tiers. Watch the success chance and Heat risk.",
		"button": "MEET THE FAMILY",
	},
	{
		"page": "crew",
		"title": "Cats Make the Crew",
		"body": "Muscle, Sneak, Charm, traits, gear, loyalty, injuries, and jail time all matter. Pick the right cat for the work and leave somebody ready for the next opportunity.",
		"button": "REVIEW THE EMPIRE",
	},
	{
		"page": "empire",
		"title": "Build Something That Lasts",
		"body": "Holdings pay at day\u2019s end and change the rules: more Energy, stronger Racket jobs, faster recovery, extra Nerve, or lower Heat. Growth creates new choices.",
		"button": "LEARN THE DAILY RHYTHM",
	},
	{
		"page": "more",
		"title": "Run the Day Your Way",
		"body": "Set Morning Business, work locations, train or commit crimes, then open City Operations and Close the Books. The Ledger advances the day, restores resources, pays holdings, and records consequences. Calls and headlines tell you what changed.",
		"button": "START JIMMY\u2019S FIRST DAY",
	},
]

var shell: NoirShell


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()


func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.025, 0.022, 0.78)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var safe := MarginContainer.new()
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var base_margin := 12 if shell.mobile else 24
	for side in ["left", "right", "top", "bottom"]:
		var inset := 0
		if OS.has_feature("web"):
			inset = int(JavaScriptBridge.eval("parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--safe-" + side + "')) || 0"))
		safe.add_theme_constant_override("margin_" + side, base_margin + inset)
	add_child(safe)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 0)
	safe.add_child(stack)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(spacer)

	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = minf(620.0, maxf(260.0, get_viewport_rect().size.x - float(base_margin * 2)))
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.add_theme_stylebox_override("panel", UiKit._tex_style("parchment_framed.png", 14, 18, 18))
	stack.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)
	var step := clampi(GameMan.tutorial_step, 0, STEPS.size() - 1)
	var data: Dictionary = STEPS[step]
	var progress := NoirKit.text("JIMMY\u2019S FIRST DAY  \u2022  STEP %d OF %d" % [step + 1, STEPS.size()], 16, NoirKit.RED, true)
	progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(progress)
	content.add_child(NoirKit.text(String(data.title).to_upper(), 27, NoirKit.INK, true))
	content.add_child(NoirKit.text(String(data.body), 18, NoirKit.INK))
	var next := NoirKit.button(String(data.button), _advance, true)
	next.custom_minimum_size.y = 56
	content.add_child(next)
	var skip := NoirKit.button("SKIP TOUR  /  Replay anytime from More", _skip)
	skip.add_theme_font_size_override("font_size", 16)
	content.add_child(skip)


func _advance() -> void:
	var next_step := GameMan.tutorial_step + 1
	if next_step >= STEPS.size():
		GameMan.complete_tutorial()
		shell.go("home")
		return
	GameMan.set_tutorial_step(next_step)
	_prepare_context(next_step)
	shell.go(String(STEPS[next_step].page))


func _prepare_context(step: int) -> void:
	if step == 3:
		shell.district_id = "little_italy"
	elif step == 4:
		shell.district_id = "little_italy"
		shell.venue_id = "blind_pig"


func _skip() -> void:
	GameMan.complete_tutorial()
	shell.refresh()
