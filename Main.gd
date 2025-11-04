extends Node2D

@onready var layout_controller: LayoutController = get_node("Network/Layout/LayoutController")
@onready var nodes: Node2D = get_node("Network/Nodes")
@onready var edges: Node2D = get_node("Network/Edges")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
	

