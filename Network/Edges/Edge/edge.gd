extends Line2D
class_name NetworkEdge

var node_a: NetworkNode
var node_b: NetworkNode

@export var visual_settings: VisualSettings

var color: Color = Color(1, 1, 1)

func _ready() -> void:

	# Start invisible
	visible = false

	# Set visual settings
	set_width(visual_settings.edge_width)
	set_default_color(visual_settings.edge_color)
	visible = true

func set_endpoints(new_node_a: NetworkNode, new_node_b: NetworkNode) -> void:
	_disconnect_all()
	node_a = new_node_a
	node_b = new_node_b
	
	if node_a:
		node_a.connect("moved", Callable(self, "_on_endpoint_moved"))
		node_a.connect("about_to_be_deleted", Callable(self, "_on_endpoint_deleted"))
	if node_b:
		node_b.connect("moved", Callable(self, "_on_endpoint_moved"))
		node_b.connect("about_to_be_deleted", Callable(self, "_on_endpoint_deleted"))
	
	call_deferred("_update_points")

func _on_endpoint_moved() -> void:
	_update_points()

func _on_endpoint_deleted() -> void:
	queue_free()  # auto delete edge if any endpoint is deleted

func _update_points() -> void:
	
	# convert world points into this Line2D's local space
	var local_a := to_local(node_a.global_position)
	var local_b := to_local(node_b.global_position)
	set_points([local_a, local_b])
	#visible = true
		
func _disconnect_all() -> void:
	if node_a:
		if node_a.is_connected("moved", Callable(self, "_on_endpoint_moved")):
			node_a.disconnect("moved", Callable(self, "_on_endpoint_moved"))
		if node_a.is_connected("about_to_be_deleted", Callable(self, "_on_endpoint_deleted")):
			node_a.disconnect("about_to_be_deleted", Callable(self, "_on_endpoint_deleted"))
	if node_b:
		if node_b.is_connected("moved", Callable(self, "_on_endpoint_moved")):
			node_b.disconnect("moved", Callable(self, "_on_endpoint_moved"))
		if node_b.is_connected("about_to_be_deleted", Callable(self, "_on_endpoint_deleted")):
			node_b.disconnect("about_to_be_deleted", Callable(self, "_on_endpoint_deleted"))

func _physics_process(_delta):
	
	# Avoid updating before nodes exist
	if node_a == null and node_b == null:
		return
		
	# Edge updates its points each physics step to follow node movement.
	_update_points()  
