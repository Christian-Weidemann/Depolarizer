extends Line2D

@export var endpoint_a: NodePath
@export var endpoint_b: NodePath

var _a_ref: Node = null
var _b_ref: Node = null

var visual_settings: Resource = null
var color: Color = Color(1, 1, 1)

func _ready() -> void:

	# try resolve NodePaths if exported from editor; if created at runtime, Main will assign refs via set_endpoints
	if endpoint_a != NodePath(""):
		_a_ref = get_node_or_null(endpoint_a)
	if endpoint_b != NodePath(""):
		_b_ref = get_node_or_null(endpoint_b)
	
	# Connect each endpoint’s signals: moved and about_to_be_deleted.
	if _a_ref:
		_a_ref.connect("moved", Callable(self, "_on_endpoint_moved"))
		_a_ref.connect("about_to_be_deleted", Callable(self, "_on_endpoint_deleted"))
	if _b_ref:
		_b_ref.connect("moved", Callable(self, "_on_endpoint_moved"))
		_b_ref.connect("about_to_be_deleted", Callable(self, "_on_endpoint_deleted"))

	# Set visual settings
	global_scale = Vector2.ONE
	set_width(visual_settings.edge_width)
	set_default_color(visual_settings.edge_color)
	set_antialiased(true)
	_update_points()

func set_endpoints(node_a: Node, node_b: Node) -> void:
	_disconnect_all()
	_a_ref = node_a
	_b_ref = node_b
	if _a_ref:
		_a_ref.connect("moved", Callable(self, "_on_endpoint_moved"))
		_a_ref.connect("about_to_be_deleted", Callable(self, "_on_endpoint_deleted"))
	if _b_ref:
		_b_ref.connect("moved", Callable(self, "_on_endpoint_moved"))
		_b_ref.connect("about_to_be_deleted", Callable(self, "_on_endpoint_deleted"))
	_update_points()

func _on_endpoint_moved(new_pos: Vector2) -> void:
	_update_points()

func _on_endpoint_deleted() -> void:
	queue_free()  # auto remove edge if any endpoint is deleted

func _update_points() -> void:
	if _a_ref and _b_ref:
		# use global positions so edge draws correctly regardless of parent transforms
		var a_pos : Vector2 = _a_ref.global_position
		var b_pos : Vector2 = _b_ref.global_position
		
		# convert world points into this Line2D's local space
		var local_a := to_local(a_pos)
		var local_b := to_local(b_pos)
		set_points([local_a, local_b])
		visible = true
	else:
		visible = false

func _disconnect_all() -> void:
	if _a_ref:
		if _a_ref.is_connected("moved", Callable(self, "_on_endpoint_moved")):
			_a_ref.disconnect("moved", Callable(self, "_on_endpoint_moved"))
		if _a_ref.is_connected("about_to_be_deleted", Callable(self, "_on_endpoint_deleted")):
			_a_ref.disconnect("about_to_be_deleted", Callable(self, "_on_endpoint_deleted"))
	if _b_ref:
		if _b_ref.is_connected("moved", Callable(self, "_on_endpoint_moved")):
			_b_ref.disconnect("moved", Callable(self, "_on_endpoint_moved"))
		if _b_ref.is_connected("about_to_be_deleted", Callable(self, "_on_endpoint_deleted")):
			_b_ref.disconnect("about_to_be_deleted", Callable(self, "_on_endpoint_deleted"))
