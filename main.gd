class_name Main
extends Control

## All player-facing views share one responsive shell. Legacy screen classes
## remain available for reference; gameplay continues through GameMan.
var current: Control
var screens: Dictionary = {}
var _shell: NoirShell
var _base := Vector2i.ZERO

func _ready() -> void:
    get_tree().root.size_changed.connect(_apply_base_resolution)
    _apply_base_resolution()
    _shell = NoirShell.new()
    _shell.main = self
    _shell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(_shell)
    current = _shell
    show_screen("title")

func is_portrait() -> bool:
    return get_viewport_rect().size.x < 760

func _apply_base_resolution() -> void:
    var win := get_tree().root
    var want := Vector2i(clampi(win.size.x, 360, 1440), clampi(win.size.y, 360, 1100))
    if want == _base: return
    _base = want
    win.content_scale_size = want
    if is_instance_valid(_shell): _shell.refresh.call_deferred()

func show_screen(screen_name: String) -> void:
    _shell.go(screen_name)
