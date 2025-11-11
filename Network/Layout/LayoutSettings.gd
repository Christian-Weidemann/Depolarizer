extends Resource
class_name LayoutSetting

# Toggles LayoutController's effects
@export var enabled: bool = true

# Scale of attraction of network to center.
@export var gravity := 0.1 :
	get:
		return gravity
	set(value):
		gravity = value
		emit_changed()

# Maximum node impulse. Helps avoid explosions.
@export var max_impulse: int = 200

@export var scale: float = 0.5 :
	get:
		return scale
	set(value):
		scale = value
		emit_changed()

@export_group("Temporal damping settings")
@export var min_linear_damp: int = 10
@export var max_linear_damp: int = 100
@export var damping_growth_rate: float = 2.0


