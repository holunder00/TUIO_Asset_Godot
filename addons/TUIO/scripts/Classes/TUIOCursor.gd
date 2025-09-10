class_name TUIOCursor

var id = -1
var vec = Vector2(-1, -1)


func _init(_id:int = 0, _vec:Vector2 = Vector2()):
	id = _id
	vec = _vec
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	pass

func update_position(_vec:Vector2 = Vector2()):
	vec = _vec
	pass
	
func get_pos_vector():
	return vec
	pass

func get_pos_screen(_width:float, _height:float):
	var screenPos = Vector2(vec.x*_width, vec.y*_height)
	return screenPos
	pass
	
func get_ID():
	return id
	pass
