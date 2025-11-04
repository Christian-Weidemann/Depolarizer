extends RigidBody2D
class_name NetworkNode

signal selected(node)
signal deselected(node)
signal moved(new_global_position: Vector2)
signal about_to_be_deleted()

@export_group("Nodes Accessed in Script")
@export var visual_settings: VisualSettings
@export var collision_shape: CollisionShape2D
@export var sprite: Node2D

var _selected := false

var _last_global_position := Vector2.INF

var node_color: Color

func _ready():
	
	_last_global_position = global_position
		
	assert(visual_settings != null)
	
	# Apply collision shape
	var collision_circle := CircleShape2D.new()
	collision_circle.radius = visual_settings.node_width / 2
	collision_shape.shape = collision_circle
	
	# Draw sprite
	node_color = visual_settings.node_gradient.sample(randf())
	sprite.draw_color = node_color
	sprite.draw_radius = visual_settings.node_width / 2
	sprite.queue_redraw()
	
	input_pickable = true    # allow physics body to get _input_event
	
func _input_event(_viewport, event, _shape_idx):
	"""
	Handles input on a node, such as mouse presses.
	"""
	if event is InputEventMouseButton:
		# Deletion
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			queue_free()

func _deferred_set_spawn_pos(p: Vector2) -> void:
	global_position = p
	sprite.queue_redraw()
	
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		emit_signal("about_to_be_deleted")
	
func _physics_process(_delta) -> void:
	# emit "moved" signal if position changed
	if global_position != _last_global_position:
		_last_global_position = global_position
		emit_signal("moved")

func select() -> void:
	if _selected:
		return
	_selected = true
	sprite.draw_color.ok_hsl_l(visual_settings.selection_lightness_reduction)  # Reduce lightness
	emit_signal("selected", self)

func deselect() -> void:
	if not _selected:
		return
	_selected = false
	sprite.draw_color = node_color
	emit_signal("deselected", self)

func toggle_selection() -> void:
	if _selected:
		deselect()
	else:
		select()
		
# Input via Area2D child: implement _input_event to receive clicks
# Ensure this Node2D has an Area2D child named "ClickArea" with a CollisionShape2D
func _on_ClickArea_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		toggle_selection()

func _on_about_to_be_deleted() -> void:
	emit_signal("about_to_be_deleted")


