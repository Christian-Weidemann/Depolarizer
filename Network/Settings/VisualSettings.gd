@tool
extends Resource
class_name VisualSettings

@export var node_width: int = 30
@export var edge_width: int = 30

@export var red: Color = Color(211,49,49)
@export var blue: Color = Color(66,102,194,255)
@export var node_gradient := Gradient.new()

@export var selection_darkening: float = 0.5

@export var edge_color: Color = Color(190,190,190)

@export var black: Color = Color(30,30,30)
@export var white: Color = Color(248,248,248)

func _init():
	node_gradient.add_point(0.0, red)
	node_gradient.add_point(1.0, blue)
