class_name Node extends RigidBody2D

signal moved(new_global_position: Vector2)
signal about_to_be_deleted()

var visual_settings: Resource = null
#@onready var visual_settings := preload("res://settings/visual_settings.tres")
var _last_global_position: Vector2 = Vector2.INF

func _ready():
	
	_last_global_position = global_position
	
	assert(visual_settings != null)
	
	# Apply collision shape
	var collision_circle := CircleShape2D.new()
	collision_circle.radius = visual_settings.node_width / 2
	$CollisionShape.shape = collision_circle
	
	# Draw sprite
	$Sprite.draw_color = visual_settings.blue
	$Sprite.draw_radius = visual_settings.node_width/2
	$Sprite.queue_redraw()
	
	input_pickable = true    # allow physics body to get _input_event
	
func _input_event(viewport, event, shape_idx):
	"""
	Handles input on a node, such as mouse presses.
	"""
	if event is InputEventMouseButton:
		# Deletion
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			queue_free()

func _deferred_set_spawn_pos(p: Vector2) -> void:
	global_position = p
	#set_sleeping(true)
	$Sprite.queue_redraw()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		emit_signal("about_to_be_deleted")
	
func _physics_process(_delta: float):
	# emit moved only if position actually changed
	var gp := global_position
	if gp != _last_global_position:
		_last_global_position = gp
		emit_signal("moved", gp)
