class_name Network extends Node2D

@onready var node_scene := preload("./Nodes/Node/node.tscn")
@onready var edge_scene := preload("./Edges/Edge/edge.tscn")
@onready var visual_settings := preload("./Settings/visual_settings.tres")

@onready var nodes : Node2D = get_node("Nodes")
@onready var edges : Node2D = get_node("Edges")


func _ready():
	pass

func _unhandled_input(event):
	"""
	Handles input on network.
	Only need to handle mouse left here, since right-clicking is handled in children.
	"""
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if nodes.get_child_count() > 0:
				var random_node = nodes.get_child(randi() % nodes.get_child_count())
				var new_node = _spawn_node(get_global_mouse_position())
				create_edge(random_node, new_node)
			else:
				_spawn_node(get_global_mouse_position())
			#_connect_all(new_node)

func _connect_all(node: NetworkNode) -> void:
	# connect node to all other existing nodes
	for n in nodes.get_children():
		if n != node:
			create_edge(node, n)

func _spawn_node(pos: Vector2) -> NetworkNode:
	var node = node_scene.instantiate() as NetworkNode
	node.visual_settings = visual_settings
	
	nodes.add_child(node)
	
	node.call_deferred("_deferred_set_spawn_pos", pos)
	
	node.input_pickable = true
	
	return node

func get_edge(node_a: NetworkNode, node_b: NetworkNode) -> NetworkEdge:
	"""Check existing edges for same endpoints."""
	for e in edges.get_children():
		# assume Edge.gd exposes _a_ref and _b_ref or endpoint references
		if (e._a_ref == node_a and e._b_ref == node_b) or (e._a_ref == node_b and e._b_ref == node_a):
			return e  # already exists
	return null
	
func create_edge(node_a: NetworkNode, node_b: NetworkNode) -> NetworkEdge:
	"""
	Create an invisible edge between two node instances.
	"""
	# basic duplicate prevention
	var potential_duplicate = get_edge(node_a, node_b)
	if potential_duplicate != null:
		print("Duplicate edge detected")
		return potential_duplicate
		
	var edge := edge_scene.instantiate() as NetworkEdge
	edge.visual_settings = visual_settings
	edges.add_child(edge)
	edge.set_endpoints(node_a, node_b)
	edge.antialiased = true
	return edge
