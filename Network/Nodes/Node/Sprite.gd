extends Node2D

var draw_color := Color(0.8, 0.8, 0.8)
var draw_radius := 5
var is_selected := false

func _ready():
	visible = true
	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, draw_radius, draw_color)
	queue_redraw()
