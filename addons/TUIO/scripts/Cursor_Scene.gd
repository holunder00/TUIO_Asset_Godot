extends Node2D

@export var circle_radius = 50  # Circle radius
@export var circle_color = Color(1, 0, 0)  # Red color
@export var circle_line_width = 8.0

@onready var w = get_viewport_rect().size[0]
@onready var h = get_viewport_rect().size[1]

var my_cursor : TUIOCursor
var cursor_set = false

func _ready():
	get_tree().get_root().size_changed.connect(_on_resize)
	# Make sure to call update() to trigger the _draw() function
	queue_redraw()

func _on_resize():
	w = get_viewport_rect().size[0]
	h = get_viewport_rect().size[1]

func _process(delta: float):
	if cursor_set:
		#print(myCursor.getPosVector())
		position = my_cursor.get_pos_screen(w, h)
	pass
	

func _draw():
	# Draw a filled circle at (0,0) with the specified radius and color
	draw_circle(Vector2.ZERO, circle_radius, circle_color, false, circle_line_width, true)

func set_cursor(_cursor:TUIOCursor):
	my_cursor = _cursor
	$ID_Label.text = str(my_cursor.get_ID())
	cursor_set = true
	pass
	
	
