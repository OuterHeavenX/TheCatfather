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
    return _base.x < 760


static func responsive_size(native_size: Vector2i, css_size: Vector2i = Vector2i.ZERO) -> Vector2i:
    # On high-density mobile browsers Godot's window can be measured in backing
    # pixels (for example 1179 wide on a 393 CSS-pixel iPhone). UI breakpoints
    # and font sizes must use the browser's CSS viewport instead.
    var source := css_size if css_size.x > 0 and css_size.y > 0 else native_size
    var minimum_height := 480 if source.x < 760 else 360
    return Vector2i(clampi(source.x, 320, 1440), clampi(source.y, minimum_height, 1100))


func _css_viewport_size() -> Vector2i:
    if not OS.has_feature("web"):
        return Vector2i.ZERO
    var width := int(JavaScriptBridge.eval(
        "Math.round(window.visualViewport ? window.visualViewport.width : window.innerWidth)",
    ))
    var height := int(JavaScriptBridge.eval(
        "Math.round(window.visualViewport ? window.visualViewport.height : window.innerHeight)",
    ))
    return Vector2i(width, height)

func _apply_base_resolution() -> void:
    var win := get_tree().root
    var want := responsive_size(win.size, _css_viewport_size())
    if want == _base: return
    _base = want
    win.content_scale_size = want
    if is_instance_valid(_shell): _shell.refresh.call_deferred()

func show_screen(screen_name: String) -> void:
    _shell.go(screen_name)
