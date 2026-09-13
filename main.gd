class_name Main
extends Control

## Screen router, plus the responsive base resolution.
##
## The UI is authored for a 640x360 landscape box. On a phone held upright
## that base stretches to roughly 640x1390 logical pixels: the UI renders tiny
## and strands its content at the top of a very tall, mostly empty screen.
## Portrait therefore gets its own narrower base, which scales the same widgets
## up by about 1.6x and leaves far less dead space.

const BASE_LANDSCAPE := Vector2i(640, 360)
const BASE_PORTRAIT := Vector2i(400, 700)

var screens: Dictionary = {}
var current: Control = null

var _base: Vector2i = BASE_LANDSCAPE


func _ready() -> void:
	get_tree().root.size_changed.connect(_apply_base_resolution)
	_apply_base_resolution()

	_add_screen("title", TitleScreen.new())
	_add_screen("story", StoryScreen.new())
	_add_screen("desk", DeskScreen.new())
	_add_screen("ops", OpsScreen.new())
	_add_screen("ledger", LedgerScreen.new())
	_add_screen("crew", CrewScreen.new())
	_add_screen("recruit", RecruitScreen.new())
	show_screen("title")


## True when the drawing area is taller than it is wide.
func is_portrait() -> bool:
	var v := get_viewport_rect().size
	return v.y > v.x


func _apply_base_resolution() -> void:
	var win := get_tree().root
	var size := win.size
	var want := BASE_PORTRAIT if size.y > size.x else BASE_LANDSCAPE
	if want == _base:
		return
	_base = want
	win.content_scale_size = want
	# Layouts that branch on orientation have to be rebuilt, not just resized.
	if current != null and current.has_method("refresh"):
		current.call("refresh")


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
