@icon("res://addons/TUIO/icons/tuio_logo.svg")
class_name TUIOServer
extends Node

## Server for recieving TUIO messages over UDP. 

## The port over which to recieve messages
@export var port = 3333

## A dictionary containing all recieved messages.
var incoming_messages := {}

var server = UDPServer.new()
var peers: Array[PacketPeerUDP] = []

signal tuio_cursor_event(dataPacket)
signal tuio_object_event(dataPacket)

func _ready():
	server.listen(port)

## Sets the port for the server to listen on.
func listen(new_port):
	port = new_port
	server.listen(port)

func _process(_delta):
	server.poll()
	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		# Keep a reference so we can keep contacting the remote peer.
		peers.append(peer)
	parse()
	

## Parses an OSC packet. This is not intended to be called directly outside of the OSCServer
func parse():
	for peer in peers:
		for l in range(peer.get_available_packet_count()):
			var packet = peer.get_packet()
			
			if packet.get_string_from_ascii() == "#bundle":
				parse_bundle(packet)
				#print("bundle received")
			else:
				#print("packet received")
				parse_message(packet)

func parse_message(packet: PackedByteArray):
	
	var comma_index = packet.find(44)
	var address = packet.slice(0, comma_index).get_string_from_ascii()
	var args = packet.slice(comma_index, packet.size())
	var tags = args.get_string_from_ascii()
	var vals = []

	args = args.slice(ceili((tags.length() + 1) / 4.0) * 4, args.size())
	
	for tag in tags.to_ascii_buffer():
		#print(tags)
		match tag:
			44: #,: comma
				pass
			70: #false
				vals.append(false)
			84: #true
				vals.append(true)
			105: #i: int32
				var val = args.slice(0, 4)
				val.reverse()
				vals.append(val.decode_s32(0))
				args = args.slice(4, args.size())
			102: #f: float32
				var val = args.slice(0, 4)
				val.reverse()
				vals.append(val.decode_float(0))
				args = args.slice(4, args.size())
			115: #s: string
				var val = args.get_string_from_ascii()
				vals.append(val)
				args = args.slice(ceili((val.length() + 1) / 4.0) * 4, args.size())
			98:  #b: blob
				vals.append(args)
			
			
	incoming_messages[address] = vals
	
	if vals is Array and len(vals) == 1:
		vals = vals[0]
	#message_received.emit(address, vals, Time.get_time_string_from_system())


#Handle and parse incoming bundles
func parse_bundle(packet: PackedByteArray):
	#remove "#bundle" header
	packet = packet.slice(8)
	#print(packet)
	var mess_num = []
	var bund_ind = 0
	var messages = []
	
	#Extracting the Timetag not Used at the moment
	#var timetag = packet.slice(0, 8)
	#var seconds = (timetag[0] << 24) | (timetag[1] << 16) | (timetag[2] << 8) | timetag[3]
	#var fraction = (timetag[4] << 24) | (timetag[5] << 16) | (timetag[6] << 8) | timetag[7]
	#var ntp_time = seconds + fraction/float(1 << 32)
	#var unix_time = ntp_time - 2208988800
	#var datetime = Time.get_time_dict_from_unix_time(unix_time)
	#print(timetag)
	#print(datetime)
	
	#Removing 8 Bytes TimeTag
	packet = packet.slice(8)
	
	var my_messages = []
	
	#Split the bundle into Messages
	while packet.size() > 4:
		#Get the next Message size in Number of Bytes
		var size = packet.slice(0, 4)
		size.reverse()
		size = size.decode_s32(0) 
		
		#Remove the 4 bytes used for Message Size
		packet = packet.slice(4)

		#get MessageContent and store in my_messages Array and remove from bundle Packet
		var message_element = packet.slice(0, size)
		my_messages.append(message_element)
		packet = packet.slice(size)

	for message in my_messages:
		var comma_index = message.find(44)
		var address = message.slice(0, comma_index).get_string_from_ascii()
		var args = message.slice(comma_index)
		var type_tags = args.get_string_from_ascii()
		var data_start = ceili((type_tags.length()+1) / 4.0) * 4.0
		args = args.slice(data_start)
				
		#print(address)
		#print(type_tags)
		#print(args.get_string_from_ascii())
		var vals = []
		
		#Extract the data by tags and store in val Array
		for tag in type_tags.to_ascii_buffer():
			match tag:
				44: #,: comma
					pass
				70: #false
					vals.append(false)
					args = args.slice(4, args.size())
				84: #true
					vals.append(true)
					args = args.slice(4, args.size())
					
				105: #i: int32
					var val = args.slice(0, 4)	
					val.reverse()
					vals.append(val.decode_s32(0))
					args = args.slice(4, args.size())
						
				102: #f: float32
					var val = args.slice(0, 4)
					val.reverse()
					vals.append(val.decode_float(0))
					args = args.slice(4, args.size())

				115: #s: string
					var val = args.get_string_from_ascii()
					vals.append(val)
					args = args.slice(ceili((val.length() +1) / 4.0) * 4, args.size())
					
				98:  #b: blob
					vals.append(args)
			
		#print(vals)	
		
		#Emit signals depending on OSC Address
		if address == "/tuio/2Dcur":
			tuio_cursor_event.emit(vals)
		
		if address == "/tuio/2Dobj":
			tuio_object_event.emit(vals)
		#
