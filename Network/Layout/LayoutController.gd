extends Node2D

@export var enabled: bool = true
@export var repulsion_strength: float = 3000000.0   # bigger = stronger push
@export var repulsion_distance: float = 300.0    # distance at which repulsion falls off
@export var attraction_strength: float = 500.0     # pull toward center
@onready var attraction_center: Vector2 = get_viewport().get_visible_rect().size * 0.5       # world center for attraction
@export var max_impulse: float = 200.0
@export var max_speed: float = 600.0
@export var jitter_strength: float = 100.0        # initial random kick

@onready var nodes := $"../Nodes"
@onready var edges := $"../Edges"


var _initialized := false

func _ready() -> void:
	
	_initialized = true
	
	assert(nodes != null, "LayoutController: Nodes container not found.")
	assert(edges != null, "LayoutController: Edges container not found.")

func _physics_process(delta: float) -> void:
	if not enabled:
		return
		
	if not nodes:
		print("No nodes found")
		return

	var bodies := nodes.get_children()

	var count := bodies.size()

	# precompute positions
	var positions := []
	for b in bodies:
		positions.append(b.global_position)

	# For each body compute combined force from neighbors
	for i in range(count):
		var bi : NetworkNode = bodies[i]
		if not bi:
			continue
			
		var force := Vector2.ZERO

		# Sum all repulsion force vectors from other nodes
		for j in range(count):
			if i == j:
				continue
			force += _repel_from(positions[i], positions[j])

		# Attraction to center (weak spring)
		var to_center : Vector2 = attraction_center - positions[i]
		force += to_center * (attraction_strength / max(1.0, to_center.length()))

		# Clamp impulse and apply to body
		if force.length() > 0.001:
			var impulse := force * delta
			if impulse.length() > max_impulse:
				impulse = impulse.normalized() * max_impulse
			# Use apply_central_impulse for immediate effect
			bi.apply_central_impulse(impulse)

			# Clamp velocity to avoid explosion
			if bi.linear_velocity.length() > max_speed:
				bi.linear_velocity = bi.linear_velocity.normalized() * max_speed

func _repel_from(a: Vector2, b: Vector2) -> Vector2:
	"""
	Calculates force vector for repulsion of node at position a from node at position b.
	"""
	# Direction from b to a
	var dir := a - b
	var dist := dir.length()

	# Handle coincident or extremely close points: return a random small push
	if dist <= 0.001:
		var jitter := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
		return jitter.normalized() * repulsion_strength * 0.1

	# Soften distance to avoid extreme forces from very small distances
	var softened: float = clamp(dist, 1.0, repulsion_distance)

	# Inverse-square falloff with configurable strength
	var strength := repulsion_strength / (softened * softened)

	# Optionally taper force to zero near repulsion_distance for smooth cutoff
	if dist > repulsion_distance:
		var t := (dist - repulsion_distance) / repulsion_distance
		strength *= max(0.0, 1.0 - t)  # linear taper beyond repulsion_distance

	return dir.normalized() * strength

#func randf_range(minv: float, maxv: float) -> float:
#	return lerp(minv, maxv, randf())














