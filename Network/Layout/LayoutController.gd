extends Node2D
class_name LayoutController

@onready var LayoutSettings: Resource = preload('LayoutSettings.tres')

@onready var nodes: Node2D = get_node("../../Nodes")
@onready var edges: Node2D = get_node("../../Edges")
@onready var network: Network = get_node("../../../Network")
@onready var camera: Camera2D = get_node("../../../Camera2D")

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
	
	# Set attraction center to current viewport center 
	_update_attraction_center()
	
	# Updates attraction center on viewport size change signal
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
	if number_of_nodes != last_node_count or number_of_edges != last_edge_count:
		damping_timer = 0.0
		current_damping = LayoutSettings.min_linear_damp
		last_node_count = number_of_nodes
		last_edge_count = number_of_edges
	else:
		var damping_step: float = LayoutSettings.damping_growth_rate * (delta ** 0.5)  # Linear damp grows quadratic with time
		damping_timer += delta
		current_damping = clamp(current_damping + damping_step, LayoutSettings.min_linear_damp, LayoutSettings.max_linear_damp)
	for node in bodies:
		node.linear_damp = current_damping

	# Precompute positions of nodes
	node_positions.resize(number_of_nodes)
	for i in range(number_of_nodes):
		var pos: Vector2 = bodies[i].global_position
		node_positions[i] = pos
	
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
				var repel_force := _repel_from(direction, distance, bodies[node_a_index].degree, bodies[node_b_index].degree)
				node_impulses[node_a_index] -= repel_force
				node_impulses[node_b_index] += repel_force
			
			# Edge attraction
			var edge_key := network.edge_key(bodies[node_a_index], bodies[node_b_index])
			if network.edge_map.has(edge_key):
				var edge_attraction_force := _edge_attraction(direction, distance)
				node_impulses[node_a_index] -= edge_attraction_force
				node_impulses[node_b_index] += edge_attraction_force
			
		# Gravitational force (towards center)
		node_impulses[node_a_index] += _gravity(node_positions[node_a_index], bodies[node_a_index].degree)
		
		# Scale by delta this physics step
		node_impulses[node_a_index] *= delta
			
		# Limit maximum impulse
		node_impulses[node_a_index] = node_impulses[node_a_index].limit_length(LayoutSettings.max_impulse)
		
		# Apply total impulse to node
		bodies[node_a_index].apply_central_impulse(node_impulses[node_a_index])	

func _gravity(pos, degree):
	"""
	Calculates gravity force vector for node with given position and degree.
	"""
	var node_to_center: Vector2 = (attraction_center - pos)
	return node_to_center * (degree + 1) * LayoutSettings.gravity
	
	
func _edge_attraction(direction: Vector2, distance: float) -> Vector2:
	"""
	Calculates attraction force vector betweeon connected nodes, given direction and distance.
	"""	
	var _attraction_force: float = distance
	return direction * _attraction_force
	

func _repel_from(direction: Vector2, distance: float, degree_a, degree_b) -> Vector2:
	"""
	Calculates force vector for repulsion of node at position a from node at position b.
	"""
	var degree_plusone_product: float = (degree_a + 1) * (degree_b + 1)
	var repulsion_force: float = - LayoutSettings.scale * degree_plusone_product / distance 
	return direction * repulsion_force

func _update_attraction_center():
	"""
	Updates center of attraction to be camera center.
	Called in _ready and when viewport size changes (on window resize).
	"""
	attraction_center = Vector2.ZERO

func reset() -> void:
	"""
	Resets the state of the LayoutController.
	Use when restarting the network.
	"""
	damping_timer = 0.0
	last_node_count = 0
	last_edge_count = 0
	LayoutSettings.enabled = true
