@icon("res://addons/TUIO/icons/tuio_logo.svg")
class_name TUIOCursorHandler_Instantinate
extends Node2D

@onready var font: Font = preload("res://addons/TUIO/Arial.ttf")

@export var cursor_scene : PackedScene

var tuio_cursors := {}

@onready var w = get_viewport_rect().size[0]
@onready var h = get_viewport_rect().size[1]


func _ready() -> void:
	get_tree().get_root().size_changed.connect(_on_resize)

func _on_resize():
	w = get_viewport_rect().size[0]
	h = get_viewport_rect().size[1]

func _on_tuio_server_tuio_cursor_event(dataPacket: Variant) -> void:
	decode_tuio(dataPacket)
	
func decode_tuio(vals):
	#print(vals)
	if vals[0] == "alive":		
		
		#Delete all Cursors if alive Message contains no ID's (Reset of TUIO)
		if vals.size() == 1 and tuio_cursors.size() > 0:
			#print("Reset all")
			var childs = get_children()
				#print(childs)
			for child in childs:
				child.queue_free()
			tuio_cursors.clear()

		vals.remove_at(0)
		
		for i in vals:
			if not tuio_cursors.has(i): #Adding a TUIOCursor if it does not exist
				tuio_cursors[i] = TUIOCursor.new(i, Vector2(-1.0, -1.0))
				var new_cursor_object = cursor_scene.instantiate()
				
				new_cursor_object.position = tuio_cursors.get(i).get_pos_screen(w, h)
				new_cursor_object.set_cursor(tuio_cursors[i])
				add_child(new_cursor_object)
		
		#Check for Alive Cursors and remove died ones
		
				
			
		for t in tuio_cursors:
			var alive = false
			for i in vals:
				if i == t:
					alive = true
			
			if not alive:
				
				var childs = get_children()
				#print(childs)
				for child in childs:
					if child.my_cursor == tuio_cursors.get(t):
						print("Deleting Cursor ID:")
						print(child.my_cursor.get_ID())
						child.queue_free()
				tuio_cursors.erase(t)
				
	
	
	else: 

		if vals[0] == "set" and tuio_cursors.has(vals[1]):
			tuio_cursors.get(vals[1]).update_position(Vector2(vals[2], vals[3]))

			




func _on_audio_stream_player_draw_audio(audioData: Variant) -> void:
	#print(audioData.size())
	print("Audio")
	pass # Replace with function body.
