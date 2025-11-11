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
var _input_ready := false

var _last_global_position := Vector2.INF

var node_color: Color

var degree := 0

func _ready():
	
	input_pickable = false	
	
	_last_global_position = global_position
		
	assert(visual_settings != null)
	
	# Apply collision radius
	collision_shape.shape.radius = visual_settings.node_width / 2
	
	# Draw sprite
	node_color = visual_settings.node_gradient.sample(randf())
	sprite.draw_color = node_color
	sprite.draw_radius = visual_settings.node_width / 2
	sprite.queue_redraw()
	
	# Delay input readiness to avoid selection upon spawn
	await get_tree().create_timer(0.1).timeout
	input_pickable = true
	_input_ready = true
	
func _input_event(_viewport, event, _shape_idx):
	"""
	Handles input on a node, such as mouse presses.
	"""
	if not _input_ready:
		return
	if event is InputEventMouseButton and event.is_pressed():
		
		# Deletion
		if event.button_index == MOUSE_BUTTON_RIGHT:
			queue_free()
			
		# Selection/Deselection
		if event.button_index == MOUSE_BUTTON_LEFT:
			toggle_selection()

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
	print("node selected")
	if _selected:
		return
	_selected = true
	sprite.draw_color = sprite.draw_color.darkened(visual_settings.selection_darkening)  # Reduce lightness
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
		
func _on_about_to_be_deleted() -> void:
	emit_signal("about_to_be_deleted")


