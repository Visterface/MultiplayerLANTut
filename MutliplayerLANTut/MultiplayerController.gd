extends Control

@export var Address = "127.0.0.1"
@export var port = 8910
var peer
# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connected_to_server.connect(connection_failed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# gets called on the server and clients
func peer_connected(id):
	print("player connected" + str(id))
# gets called on the server and clients
func peer_disconnected(id):
	print("player disconnected" + str(id))
# gets called only from clients
func connected_to_server():
	print("connected to server")
	send_player_information.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())
# gets called only from clients
func connection_failed():
	print("connection failed")

@rpc("any_peer")
func send_player_information(name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name": name,
			"id": id,
			"score": 0
		}
	if multiplayer.is_server():
		for i in GameManager.Players:
			send_player_information.rpc(GameManager.Players[i].name, i)
@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://testscene.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_host_pressed():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	if error != OK:
		print("can not host: "+ error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Wainting for players")
	send_player_information($LineEdit.text, multiplayer.get_unique_id())
	
func _on_join_pressed():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

func _on_start_game_pressed():
	start_game.rpc()
	pass # Replace with function body.
