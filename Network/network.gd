extends Node2D
class_name Network 

@onready var node_scene := preload("./Nodes/Node/node.tscn")
@onready var edge_scene := preload("./Edges/Edge/edge.tscn")

@export_group("Nodes Accessed in Script")
@export var visual_settings: VisualSettings
@export var nodes: Node2D
@export var edges: Node2D

@export var edge_map := {}  # Dictionary storing edges by node id pair

func _ready():
	pass

func _unhandled_input(event):
	"""
	Handles input on network.
	Only need to handle mouse left here, since right-clicking is handled in children.
	"""
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			#if nodes.get_child_count() > 0:
			#	var random_node = nodes.get_child(randi() % nodes.get_child_count())
			#	var new_node = _spawn_node(get_global_mouse_position())
			#	create_edge(random_node, new_node)
			#else:
			var new_node: NetworkNode = _spawn_node(get_global_mouse_position())
			_connect_to_random(new_node)
			#_connect_all(new_node)

func _connect_all(node: NetworkNode) -> void:
	""" Connect node to all other existing nodes. """
	for n in nodes.get_children():
		if n != node:
			create_edge(node, n)
			
func _connect_to_random(node: NetworkNode) -> void:
	""" Connect node to random other node, if exists. """
	var node_array := nodes.get_children()
	
	# Don't connect unless 2 nodes exist
	if node_array.size() < 2:
		return
	
	node_array.shuffle()  # Shuffle node array to randomize edge
	
	for other_node in node_array:
		if other_node != node:
			create_edge(node, other_node)
			return
	
func _spawn_node(pos: Vector2) -> NetworkNode:
	var node = node_scene.instantiate() as NetworkNode
	node.visual_settings = visual_settings
	
	nodes.add_child(node)
	
	node.call_deferred("_deferred_set_spawn_pos", pos)
	
	node.input_pickable = true
	
	return node

func get_edge(node_a: NetworkNode, node_b: NetworkNode) -> NetworkEdge:
	"""
	Returns edge with given node pair. 
	Null if edge doesn't exist.
	"""
	return edge_map.get(edge_key(node_a, node_b), null)
	
func create_edge(node_a: NetworkNode, node_b: NetworkNode) -> NetworkEdge:
	"""
	Create an edge between two node instances.
	"""
	var key := edge_key(node_a, node_b)
	
	if edge_map.has(key):  # Duplicate check
		return edge_map[key]
	
	var edge: NetworkEdge = edge_scene.instantiate()
	edge.visual_settings = visual_settings
	edges.add_child(edge)
	edge.call_deferred("set_endpoints", node_a, node_b)
	
	edge_map[key] = edge  # Add edge to dictionary
	
	return edge
	
func edge_key(node_a: NetworkNode, node_b: NetworkNode) -> String:
	"""
	Returns a string key for an edge between nodes a and b.
	Ordering is always lowest instance id first.
	"""
	var _first_id: int = min(node_a.get_instance_id(), node_b.get_instance_id())
	var _second_id: int = max(node_a.get_instance_id(), node_b.get_instance_id())
	return str(_first_id) + "_" + str(_second_id)
