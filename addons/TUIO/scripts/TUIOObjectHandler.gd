@icon("res://addons/TUIO/icons/tuio_logo.svg")
class_name TUIOObjectHandler
extends Node2D


@onready var font: Font = preload("res://addons/TUIO/Arial.ttf")

@export var object_scene : PackedScene

var tuio_objects := {}

@onready var w = get_viewport_rect().size[0]
@onready var h = get_viewport_rect().size[1]


func _on_tuio_server_tuio_object_event(dataPacket: Variant) -> void:
	#print("Object Decode")
	decode_TUIO(dataPacket)
	pass # Replace with function body.

func decode_TUIO(vals):
	#print(vals)
	if vals[0] == "alive":		
		
		#Delete all Cursors if alive Message contains no ID's (Reset of TUIO)
		if vals.size() == 1 and tuio_objects.size() > 0:
			#print("Reset all")
			var childs = get_children()
			#print(childs)
			for child in childs:
				child.queue_free()
			tuio_objects.clear()

		vals.remove_at(0)
		
		for i in vals:
			if not tuio_objects.has(i): #Adding a TUIOCursor if it does not exist
				tuio_objects[i] = TUIOObject.new(i, Vector2(-1.0, -1.0))
				var new_object = object_scene.instantiate()
				
				new_object.position = tuio_objects.get(i).get_pos_screen(w, h)
				new_object.set_object(tuio_objects[i])
				add_child(new_object)
				#	print("Added Child")
		
		#Check for Alive Cursors and remove died ones
		
		for t in tuio_objects:
			#print(tuio_objects.size())
			var alive = false
			#print(get_child_count())
			for i in vals:
				if i == t:
					alive = true
			if not alive:	
				var childs = get_children()
				#print(childs)
				for child in childs:
					if child.my_object == tuio_objects.get(t):
						child.queue_free()
				tuio_objects.erase(t)
			
	else: 
		if vals[0] == "set" and tuio_objects.has(vals[1]) and vals.size() > 5:
			#print(vals)
			if not tuio_objects.get(vals[1]).marker_id_set:
				tuio_objects.get(vals[1]).set_marker_ID(int(vals[2]))
				
			tuio_objects.get(vals[1]).update_position(Vector2(vals[3], vals[4]))
			tuio_objects.get(vals[1]).set_angle(vals[5])
			#tuioCursors[vals[1]] = Vector2(vals[2], vals[3])
	
	queue_redraw()
			
