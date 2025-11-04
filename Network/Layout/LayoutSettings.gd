extends Resource
class_name LayoutSetting

# Toggles LayoutController's effects
@export var enabled: bool = true

# Maximum repulsion between any pair of nodes. Repulsion scales down with square of distance between nodes.
@export var max_repulsion_strength: float = 2000000.0

# Maximum distance at which nodes repel each other.
@export var repulsion_cutoff_distance: float = 300.0

# Scale of attraction of network to viewport center.
@export var central_attraction_scaling: float = 500.0

# Maximum node impulse. Helps avoid explosions.
@export var max_impulse: float = 200.0

# Minimum linear damp of nodes.
@export var min_linear_damp: float = 10.0

# Maximum linear damp of nodes.
@export var max_linear_damp: float = 100.0

# Scales damping each physics step.
@export var damping_growth_rate: float = 2.0

# Attraction scaling of a node to neighbor.
@export var edge_attraction: float = 0.5
