extends Node2D

@onready var nodes: Node2D = get_node("Network/Nodes")
@onready var edges: Node2D = get_node("Network/Edges")

@onready var layout_controller: = get_node("Network/Layout/LayoutController")

func _ready():
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		restart_network()

func restart_network() -> void:
	"""
	Restarts the network by clearing nodes and edges, and resetting layout controller.
	"""
	for node in nodes.get_children():
		node.queue_free()
	for edge in edges.get_children():
		edge.queue_free()
		
	layout_controller.reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	

