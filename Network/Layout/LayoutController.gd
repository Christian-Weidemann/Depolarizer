extends Node2D
class_name LayoutController

@onready var LayoutSettings: Resource = preload('LayoutSettings.tres')

@onready var nodes: Node2D = get_node("../../Nodes")
@onready var edges: Node2D = get_node("../../Edges")
@onready var network: Network = get_node("../../../Network")

@onready var attraction_center: Vector2 = Vector2.ZERO

@onready var node_impulses: PackedVector2Array = []
@onready var node_positions: PackedVector2Array = []

# Variables for adaptive linear damping
var min_damping := 0.0
var current_damping := min_damping
var max_damping := 0.0
var damping_growth_rate := 0.0 
var damping_timer := 0.0
var last_node_count := 0
var last_edge_count := 0

func _ready() -> void:
	
	# Set attraction to current viewport center, updates with viewport size change
	_update_attraction_center()  
	get_viewport().connect("size_changed", Callable(self, "_update_attraction_center"))

func _physics_process(delta: float) -> void:
	"""
	Runs each physics step to compute forces acting on nodes.
	"""
	if not LayoutSettings.enabled:
		return
	
	var bodies := nodes.get_children()
	var number_of_nodes := bodies.size()
	var number_of_edges := edges.get_child_count()
	
	# TEMPORAL LINEAR DAMPING
	min_damping = LayoutSettings.min_linear_damp
	max_damping = LayoutSettings.max_linear_damp
	damping_growth_rate = LayoutSettings.damping_growth_rate
	
	if number_of_nodes != last_node_count or number_of_edges != last_edge_count:
		damping_timer = 0.0
		current_damping = LayoutSettings.min_linear_damp
		last_node_count = number_of_nodes
		last_edge_count = number_of_edges
	else:
		var damping_step: float = damping_growth_rate * (delta ** 0.5)  # Linear damp grows quadratic with time
		damping_timer += delta
		current_damping = clamp(current_damping + damping_step, min_damping, max_damping)
	for node in bodies:
		node.linear_damp = current_damping

	# Precompute positions of nodes and center of mass
	var center_of_mass := Vector2.ZERO
	node_positions.resize(number_of_nodes)
	for i in range(number_of_nodes):
		var pos: Vector2 = bodies[i].global_position
		node_positions[i] = pos
		center_of_mass += pos
	center_of_mass /= number_of_nodes
	var network_to_center: Vector2 = (attraction_center - center_of_mass)
	
	# Store physics step force vector for each node
	node_impulses.resize(number_of_nodes)
	node_impulses.fill(Vector2.ZERO)
	
	# NODE LOOP
	for node_a_index in range(number_of_nodes):
		var node_a_position := node_positions[node_a_index]
		
		# Loop over each pair of nodes
		for node_b_index in range(node_a_index + 1, number_of_nodes):
			
			var node_b_position := node_positions[node_b_index]
			var direction := node_a_position - node_b_position  # Direction vector from b to a
			var distance := direction.length()
			direction = direction.normalized()  # normalize direction for force calculations

			# Repulsion forces
			if distance < LayoutSettings.repulsion_cutoff_distance:
				var repel_force := _repel_from(direction, distance)
				node_impulses[node_a_index] += repel_force
				node_impulses[node_b_index] -= repel_force
			
			# Edge attraction
			var edge_key := network.edge_key(bodies[node_a_index], bodies[node_b_index])
			if network.edge_map.has(edge_key):
				var edge_attraction_force := _edge_attraction(direction, distance)
				node_impulses[node_a_index] -= edge_attraction_force
				node_impulses[node_b_index] += edge_attraction_force
			
		# Central attraction force
		node_impulses[node_a_index] += network_to_center * LayoutSettings.central_attraction_scaling * network_to_center.length()
		
		# Scale by delta this physics step
		node_impulses[node_a_index] *= delta
			
		# Limit maximum impulse
		node_impulses[node_a_index] = node_impulses[node_a_index].limit_length(LayoutSettings.max_impulse)
		
		# Apply repulsion impulse to node
		bodies[node_a_index].apply_central_impulse(node_impulses[node_a_index])	

func _edge_attraction(direction: Vector2, distance: float) -> Vector2:
	"""
	Calculates force vector for attraction of node at position a to connected node at position b.
	"""	
	var attraction_strength: float = distance * distance  # Attraction is distance squared 
	
	return direction * attraction_strength * LayoutSettings.edge_attraction
	

func _repel_from(direction: Vector2, distance: float) -> Vector2:
	"""
	Calculates force vector for repulsion of node at position a from node at position b.
	"""
	# Repulsion falls off with inverse square distance
	var repulsion_strength: float = LayoutSettings.max_repulsion_strength / (distance * distance)  
	return direction * repulsion_strength

func _update_attraction_center():
	attraction_center = get_viewport().get_visible_rect().size * 0.5

func reset() -> void:
	"""
	Resets the state of the LayoutController.
	Use when restarting the network.
	"""
	damping_timer = 0.0
	last_node_count = 0
	last_edge_count = 0
	LayoutSettings.enabled = true










