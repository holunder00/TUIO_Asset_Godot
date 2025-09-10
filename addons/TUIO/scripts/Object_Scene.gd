extends Node2D

@export var size = 50  #quad size
@export var rect_color = Color(1, 0, 0)  # Red color
@export var line_width = 4.0

@onready var w = get_viewport_rect().size[0]
@onready var h = get_viewport_rect().size[1]

var my_object : TUIOObject
var object_set = false

func _ready():
	get_tree().get_root().size_changed.connect(_on_resize)
	# Make sure to call update() to trigger the _draw() function
	queue_redraw()

func _on_resize():
	w = get_viewport_rect().size[0]
	h = get_viewport_rect().size[1]

func _process(delta: float):
	if object_set:
		#print(myCursor.getPosVector())
		position = my_object.get_pos_screen(w, h)
		rotation = my_object.get_angle()
		#queue_redraw()
	pass
	

func _draw():
	#draw_set_transform(Vector2(0,0), my_object.get_angle())
	draw_rect(Rect2(-size/2.0,-size/2.0,size, size), rect_color, false, line_width, true)
	$ID_Label.text = str(my_object.get_marker_ID())
	# Draw a filled circle at (0,0) with the specified radius and color
	#draw_circle(Vector2.ZERO, circle_radius, circle_color, false, 8.0, true)

func set_object(_object:TUIOObject):
	my_object = _object
	object_set = true
	pass
