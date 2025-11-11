extends Resource
class_name LayoutSetting

# Toggles LayoutController's effects
@export var enabled: bool = true

# Maximum distance at which nodes repel each other.
@export var repulsion_cutoff_distance: int = 300

# Scale of attraction of network to center.
@export var gravity: float = 100

# Maximum node impulse. Helps avoid explosions.
@export var max_impulse: int = 200

@export var scale: float = 0.5

@export_group("Temporal damping settings")
@export var min_linear_damp: int = 10
@export var max_linear_damp: int = 100
@export var damping_growth_rate: float = 2.0


