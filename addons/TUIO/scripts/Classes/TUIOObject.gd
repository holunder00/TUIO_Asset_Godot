class_name TUIOObject


var session_id = -1
var marker_id = -1
var pos = Vector2(-1, -1)
var angle = 0.0
var marker_id_set = false

func _init(_session_id:int = 0, _vec:Vector2 = Vector2()):
	session_id = _session_id
	pos = _vec


func update_position(_vec:Vector2):
	pos = _vec
		
func get_pos_vector():
	return pos

func get_pos_screen(_width:float, _height:float):
	var screenPos = Vector2(pos.x*_width, pos.y*_height)
	return screenPos

func get_angle():
	#var angle = 360/2*PI * angle
	#print(angle)
	return angle

func set_marker_ID(_id:int):
	marker_id = _id
	marker_id_set = true

func set_angle(_angle:float):
	angle = _angle


func get_marker_ID():
	return marker_id

func set_session_ID(_session_id:int):
	session_id = _session_id

func get_session_ID():
	return session_id
	
