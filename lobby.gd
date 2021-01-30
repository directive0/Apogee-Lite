extends Control

func _ready():
	# Called every time the node is added to the scene.
	print("trying gamestate")
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	print("Succeeded")
	print("trying again")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	print("Succeeded")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")

func _on_host_pressed():
	print("host was pressed")
	# checks to make sure SOME kind of name has been selected.
	if get_node("connect/VBoxContainer/name").text == "":
		get_node("connect/VBoxContainer/error_label").text = "Invalid name!"
		return

	# Hide the connection window and display the players window
	get_node("connect").hide()
	get_node("players").show()
	get_node("connect/VBoxContainer/error_label").text = ""

	var player_name = get_node("connect/VBoxContainer/name").text
	var player_ship = get_node("connect/VBoxContainer/OptionButton").get_item_text(get_node("connect/VBoxContainer/OptionButton").selected)
	gamestate.host_game(player_name,player_ship)
	refresh_lobby()

func _on_join_pressed():
	if get_node("connect/VBoxContainer/name").text == "":
		get_node("connect/VBoxContainer/error_label").text = "Invalid name!"
		return

	var ip = get_node("connect/VBoxContainer/ip").text
	if not ip.is_valid_ip_address():
		get_node("connect/VBoxContainer/error_label").text = "Invalid IPv4 address!"
		return

	get_node("connect/VBoxContainer/error_label").text=""
	get_node("connect/VBoxContainer/host").disabled = true
	get_node("connect/VBoxContainer/join").disabled = true

	var player_name = get_node("connect/VBoxContainer/name").text
	var player_ship = get_node("connect/VBoxContainer/OptionButton").get_item_text(get_node("connect/VBoxContainer/OptionButton").selected)
	gamestate.join_game(ip, player_name,player_ship)
	# refresh_lobby() gets called by the player_list_changed signal

func _on_connection_success():
	get_node("connect").hide()
	get_node("players").show()

func _on_connection_failed():
	get_node("connect/VBoxContainer/host").disabled = false
	get_node("connect/VBoxContainer/join").disabled = false
	get_node("connect/VBoxContainer/error_label").set_text("Connection failed.")

func _on_game_ended():
	show()
	get_node("connect").show()
	get_node("players").hide()
	get_node("connect/VBoxContainer/host").disabled = false
	get_node("connect/VBoxContainer/join").disabled

func _on_game_error(errtxt):
	get_node("error").dialog_text = errtxt
	get_node("error").popup_centered_minsize()

func refresh_lobby():
	var players = gamestate.get_player_list()
	players.sort()
	get_node("players/VBoxContainer/list").clear()
	get_node("players/VBoxContainer/list").add_item(gamestate.get_player_name() + " (You)")
	for p in players:
		get_node("players/VBoxContainer/list").add_item(p)

	get_node("players/VBoxContainer/start").disabled = not get_tree().is_network_server()

func _on_start_pressed():
	print("can't win em all!")
	gamestate.begin_game()
	#$AudioStreamPlayer.stop()
	#$sol_system.queue_free()


func _on_info_button_pressed():
	add_child(load("res://scenes/info_pane.tscn").instance())




func _on_TextureButton_pressed():
	gamestate.begin_game()
	#$AudioStreamPlayer.stop()
	#$sol_system.queue_free()
	pass # Replace with function body.
