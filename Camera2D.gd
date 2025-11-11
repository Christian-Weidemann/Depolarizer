extends Camera2D

@export var zoom_step := 0.12
@export var min_zoom := 0.25
@export var max_zoom := 3.0
@export var smooth := false
@export var zoom_speed := 8.0

@onready var layout_controller: LayoutController = get_node("Network/Layout/LayoutController")

var target_scale := 1.0
var dragging := false
var drag_start := Vector2.ZERO

func _ready() -> void:
	make_current()
	target_scale = zoom.x

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_scale = clamp(target_scale * (1.0 - zoom_step), min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_scale = clamp(target_scale * (1.0 + zoom_step), min_zoom, max_zoom)

	elif event is InputEventMouseMotion and dragging:
		var world_now := get_global_mouse_position()
		global_position += (drag_start - world_now)
		drag_start = world_now

func _zoom_at_screen_pos(factor: float, screen_pos: Vector2) -> void:
	var world_before := get_global_mouse_position()
	target_scale = clamp(target_scale * factor, min_zoom, max_zoom)
	zoom = Vector2.ONE * target_scale

func _process(delta: float) -> void:
	if not smooth:
			zoom = Vector2.ONE * target_scale
			return
	var current := zoom.x
	if abs(current - target_scale) < 0.0001:
		return
	var t := 1.0 - pow(0.001, delta * 6)  # frame-rate independent smoothing factor (exponential)
	var new_scale: float = lerp(current, target_scale, t)
	zoom = Vector2.ONE * new_scale
			
	if is_instance_valid(layout_controller):
		global_position = layout_controller.attraction_center
