extends CanvasLayer

var background_color: Color = Color(0.11, 0.11, 0.11)

func _ready():
	# Set background
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0)
	
	# Set anchors to full stretch
	bg.anchor_left = 0.0
	bg.anchor_top = 0.0
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	
	add_child(bg)
	
	bg.z_index = -100  # ensure it's behind everything else

func set_background_color(background_color):
	$ColorRect.color = background_color
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
