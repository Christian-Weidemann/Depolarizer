class_name Network extends Node2D

@onready var node_scene := preload("res://Network/Nodes/Node/node.tscn")
@onready var edge_scene := preload("res://Network/Edges/Edge/edge.tscn")
@onready var visual_settings := preload("res://Network/Settings/visual_settings.tres")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			#_spawn_node(get_global_mouse_position())
			spawn_and_connect_all(get_global_mouse_position())

func spawn_and_connect_all(world_pos: Vector2) -> void:
	var new_node := _spawn_node(world_pos)
	# connect to all existing nodes (including those already present)
	# gather current nodes excluding the newly created one
	var nodes_list := []
	for n in $Nodes.get_children():
		if n == new_node:
			continue
		if n is RigidBody2D:
			create_edge(new_node, n)  # create edges to every node found

func _spawn_node(pos: Vector2) -> Node:
	var node = node_scene.instantiate() as RigidBody2D
	#node.freeze = true  # ensure physics won't move node
	node.visual_settings = visual_settings
	node.call_deferred("_deferred_set_spawn_pos", pos)
	$Nodes.add_child(node)
	node.input_pickable = true
	return node

func get_edge(node_a: Node, node_b: Node) -> Line2D:
	"""Check existing edges for same endpoints."""
	for e in $Edges.get_children():
		if e is Line2D:
			# assume Edge.gd exposes _a_ref and _b_ref or endpoint references
			if (e._a_ref == node_a and e._b_ref == node_b) or (e._a_ref == node_b and e._b_ref == node_a):
				return e  # already exists
	return null
	
func create_edge(node_a: Node, node_b: Node) -> Line2D:
	"""
	Create an edge between two node instances.
	"""
	# basic duplicate prevention
	var potential_duplicate = get_edge(node_a, node_b)
	
	if potential_duplicate != null:
		return potential_duplicate
		
	var edge := edge_scene.instantiate() as Line2D
	edge.visual_settings = visual_settings
	$Edges.add_child(edge)
	edge.set_endpoints(node_a, node_b)
	return edge
