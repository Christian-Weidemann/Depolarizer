extends Node2D
class_name Background

@export var visual_settings: VisualSettings

func _ready():
	
	self.visible = false
	
	var background_rectangle := ColorRect.new()
	
		# Set anchors to full stretch
	background_rectangle.anchor_left = 0.0
	background_rectangle.anchor_top = 0.0
	background_rectangle.anchor_right = 1.0
	background_rectangle.anchor_bottom = 1.0
	
	background_rectangle.color = visual_settings.black  # background_color
	
	background_rectangle.mouse_filter = Control.MOUSE_FILTER_IGNORE  	# Make the ColorRect ignore mouse so it doesn't consume clicks
	
	add_child(background_rectangle)

func set_background_color(background_color_to_set):
	$ColorRect.color = background_color_to_set

		
