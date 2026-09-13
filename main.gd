class_name Main
extends Control

var screens: Dictionary = {}
var current: Control = null


func _ready() -> void:
	_add_screen("title", TitleScreen.new())
	_add_screen("story", StoryScreen.new())
	_add_screen("desk", DeskScreen.new())
	_add_screen("ops", OpsScreen.new())
	_add_screen("ledger", LedgerScreen.new())
	_add_screen("crew", CrewScreen.new())
	_add_screen("recruit", RecruitScreen.new())
	show_screen("title")


func _add_screen(screen_name: String, screen: Control) -> void:
	screen.set("main", self)
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.visible = false
	add_child(screen)
	screens[screen_name] = screen


func show_screen(screen_name: String) -> void:
	if current != null:
		current.visible = false
	current = screens[screen_name]
	current.visible = true
	if current.has_method("refresh"):
		current.call("refresh")
