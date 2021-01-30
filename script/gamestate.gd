extends Node

# Game settings ----------------------------------------------------------------

# Set the global settings
var music_volume = -50
var sfx_volume = 100

# try to determine whether we are on a mobile or desktop device (for controls)
var device_type = 0

# Network parameters -----------------------------------------------------------
# Default game port
const DEFAULT_PORT = 10567

# Max number of players
const MAX_PEERS = 12

# Name for my player
var player_name = "The Warrior"
var player_ship = "Vostok"

# Names for remote players in id:name format
var players = {}
var player_ships = {}

var ready = false

var player_scene = preload("res://player.tscn").instance()

# Signals to let lobby GUI know what's going on
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

func get_volume():
	return music_volume

# Callback from SceneTree
func _player_connected(id):
	# This is not used in this demo, because _connected_ok is called for clients
	# on success and will do the job.
	pass

# Callback from SceneTree
func _player_disconnected(id):
	if get_tree().is_network_server():
		if has_node("/root/world"): # Game is in progress
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
		else: # Game is not in progress
			# If we are the server, send to the new dude all the already registered players
			unregister_player(id)
			for p_id in players:
				# Erase in the server
				rpc_id(p_id, "unregister_player", id)

# Callback from SceneTree, only for clients (not server)
func _connected_ok():
	# Registration of a client beings here, tell everyone that we are here
	rpc("register_player", get_tree().get_network_unique_id(), player_name, player_ship)
	emit_signal("connection_succeeded")

# Callback from SceneTree, only for clients (not server)
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()

# Callback from SceneTree, only for clients (not server)
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")

# Lobby management functions

remote func register_player(id, new_player_name, new_player_ship):
	if get_tree().is_network_server():
		# If we are the server, let everyone know about the new player
		rpc_id(id, "register_player", 1, player_name, player_ship) # Send myself to new dude
		for p_id in players: # Then, for each remote player
			rpc_id(id, "register_player", p_id, players[p_id], player_ships[p_id]) # Send player to new dude
			rpc_id(p_id, "register_player", id, new_player_name, new_player_ship) # Send new dude to player

	players[id] = new_player_name
	player_ships[id] = new_player_ship
	emit_signal("player_list_changed")

remote func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")

remote func pre_start_game(spawn_points):
	# Adds gameworld to the tree, and HIDES the lobby (maybe you can add clients after gamestart?)
	var world = load("res://sol.tscn").instance()
	get_tree().get_root().add_child(world)

	get_tree().get_root().get_node("lobby").queue_free()

	#get_tree().get_root().get_node("lobby").hide()

	#var player_scene = load("res://player.tscn")

	# Puts all the players in their starting positions in the game.
	for p_id in spawn_points:
		var spawn_pos = get_tree().get_nodes_in_group("spawn_point")[p_id].get_global_position()
		print("Spawn pos: ", spawn_pos)
		#var spawn_pos = world.get_node("spawn_points/" + str(spawn_points[p_id]))
		#var player_scene = load("res://player.tscn")
		var player = player_scene

		player.set_name(str(p_id)) # Use unique ID as node name
		player.set_global_position(spawn_pos)
		player.set_network_master(p_id) #set unique id as master

		if p_id == get_tree().get_network_unique_id():
			# If node for this peer id, set name
			player.set_player_name(player_name,player_ship)
		else:
			# Otherwise set name from peer
			player.set_player_name(players[p_id], player_ships[p_id])

		world.get_node("players").add_child(player)
		ready = true


	if not get_tree().is_network_server():
		# Tell server we are ready to start
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()

remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!

var players_ready = []

remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()

func host_game(new_player_name, new_player_ship):
	player_name = new_player_name
	player_ship = new_player_ship
	
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)

func join_game(ip, new_player_name, new_player_ship):
	player_name = new_player_name
	player_ship = new_player_ship
	
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)

func get_player_list():
	return players.values()

func get_player_name():
	return player_name

func begin_game():
	assert(get_tree().is_network_server())

	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	# Call to pre-start game with the spawn points
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)

	pre_start_game(spawn_points)

func end_game():
	if has_node("/root/world"): # Game is in progress
		# End it
		get_node("/root/world").queue_free()

	emit_signal("game_ended")
	players.clear()
	get_tree().set_network_peer(null) # End networking

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
