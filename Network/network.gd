extends Node2D
class_name Network 

@onready var node_scene := preload("./Nodes/Node/node.tscn")
@onready var edge_scene := preload("./Edges/Edge/edge.tscn")

@export var enabled: bool = true

@export var edge_map := {}  # Dictionary storing edges by node id pair

@export_group("Nodes Accessed in Script")
@export var visual_settings: VisualSettings
@export var nodes: Node2D
@export var edges: Node2D

func _ready():
	pass

func _unhandled_input(event):
	"""
	Handles input on network.
	Only need to handle mouse left here, since right-clicking is handled in children.
	"""
	if not enabled:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			#if nodes.get_child_count() > 0:
			#	var random_node = nodes.get_child(randi() % nodes.get_child_count())
			#	var new_node = _spawn_node(get_global_mouse_position())
			#	create_edge(random_node, new_node)
			#else:
			var nodes_array := shuffled_nodes()
			var new_node: NetworkNode = spawn_node(get_global_mouse_position())
			
			preferential_attachment_connection(new_node, nodes_array, 5)
			#connect_to_random(new_node, (randi() % 2) + 1)
			#_connect_all(new_node)

func preferential_attachment_connection(node: NetworkNode, nodes_array, max_edges):
	"""
	Connects node to nodes in nodes_array with probability proportional to their degree.
	Minimum new edges are 1 and maximum new edges is max_edges.
	"""
	var new_edges := 0
	
	for other_node in nodes_array:

		var edge_probability: float = other_node.degree / (edge_map.size() + 1)  # Adding 1 to avoid division by 0 and enable connection to disconnected nodes
		if edge_probability > randf():
			create_edge(node, other_node)
			new_edges += 1
		if new_edges == max_edges:
			return
	if node.degree == 0 and nodes_array != []:
		create_edge(node, nodes_array.pick_random())

func connect_all(node: NetworkNode) -> void:
	""" Connect node to all other existing nodes. """
	for n in nodes.get_children():
		if n != node:
			create_edge(node, n)
			
func shuffled_nodes() -> Array[Node]:
	var nodes_array: Array = nodes.get_children()
	nodes_array.shuffle()
	return nodes_array

func connect_to_random(node: NetworkNode, n: int) -> void:
	""" Connect node to n random other nodes, if exist. """
	var node_array := shuffled_nodes()
	node_array.erase(node)  # Want only other nodes
	n = min(node_array.size(), n)  # Cap n at number of existing nodes
	for other_node in range(n):
		create_edge(node, node_array[other_node])

func spawn_node(pos: Vector2) -> NetworkNode:
	var node = node_scene.instantiate() as NetworkNode
	node.visual_settings = visual_settings
	nodes.add_child(node)
	pos += Vector2(randf_range(-1,1), randf_range(-1,1))  # Slightly randomly shift spawn pos to avoid layout bugs
	node.call_deferred("_deferred_set_spawn_pos", pos)
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
	
	node_a.degree += 1
	node_b.degree += 1
	
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
