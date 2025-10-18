extends CanvasLayer

@onready var background_color: Color = Color(0.11, 0.11, 0.11)

func _ready():
	
	
	# Set background as ColorRect
	var bg : ColorRect = ColorRect.new()
	
	bg.name = "ColorRect"
	
		# Set anchors to full stretch
	bg.anchor_left = 0.0
	bg.anchor_top = 0.0
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	
	bg.color = background_color
	
	# Make the ColorRect ignore mouse so it doesn't consume clicks
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	add_child(bg)

func set_background_color(background_color):
	$ColorRect.color = background_color

		
