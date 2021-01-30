extends RigidBody2D

# Basic player script with Network calls

const MOTION_SPEED = 90.0

# these variables define the position of this object for all other peers
puppet var slave_pos = Vector2()
puppet var slave_motion = 0
puppet var slave_rotation = 0.0

var object_name

# Ship behaviour variables 
var current_anim = ""
var prev_bombing = false
var prev_missiling = false
var bomb_index = 0
var missile_index = 0
var spinforce = 15
var brake_spin = 0.1
var rotvel = 0
var loaded_weapon = 0
var throttle = 0


var hulltype 
var exploded = false
var burnrate = 0.1
var fuel = 100
var current_fuel
var max_fuel = 100
var hull = 100
var current_hull 
var current_damage = 0


# Ship status variables.
var engine_on = false
var slv_engine_on = false

# game status variables
var tech_level = 0



export var stunned = false
#export var test = false

var zoom = 1
var zoom_grain = 10
var max_zoom = 400
var min_zoom = 0.01



var vostok_hull = load("res://ships/vostok.tscn")
var soyuz_hull
var apollo_hull
var dragon_hull = load("res://ships/dragon2.tscn")
var shenzhou_hull
var spaceshuttle_hull



var station_object = preload("res://station.tscn")
var missile_object = preload("res://scenes/missile.tscn")
var explosion_object = preload("res://scenes/explosion.tscn")

var ship_name = ""
var ship_type = "Vostok"

var gravity
var motion
var target
var target_index = 0
var current_motion 

sync func explode():
	var boom = explosion_object.instance()
	boom.position = position
	boom.rotation = rotation + deg2rad(90)
	
	if has_node("main_hull"):
		$main_hull.queue_free()
		
	get_node("../..").add_child(boom)
	set_mode(1)
	$Indicator.set_visible(false)
	exploded = true
	var respawn_panel = load("res://scenes/you_died.tscn")
	get_tree().get_nodes_in_group("UI")[0].add_child(respawn_panel.instance())

# Use sync because it will be called everywhere
sync func deploy(bomb_name, pos, by_who):
	var bomb
	if loaded_weapon == 0:
		bomb = missile_object.instance()
	if loaded_weapon == 1:
		bomb = station_object.instance()
		
	bomb.set_name(bomb_name) # Ensure unique name for the bomb
	bomb.position = pos
	bomb.from_player = by_who
	bomb.rotation = rotation + deg2rad(90)
	bomb.linear_velocity = current_motion
	
	
	# No need to set network mode to bomb, will be owned by master by default
	get_node("../..").add_child(bomb)

	

func _ready():
	object_name = ship_name
	#set_global_position(get_tree().get_nodes_in_group("spawn_point")[0].get_global_position())
	# checks to see if we are on the computer that is actually in control of this node.
	if is_network_master():
		$Camera2D._set_current(true)
		$Camera2D.set_as_toplevel(true)
		$Camera2D.add_to_group("camera")
		add_to_group("player")
	else:
		add_to_group("target")
		$UI_Overlay.queue_free()
		$Camera2D.queue_free()
		$Indicator.queue_free()
		$path_tracker.queue_free()

	change_shiptype(ship_type)

	$main_hull/plume.set_visible(false)

	slave_pos = position
	
func _integrate_forces(state):

	current_motion = state.get_linear_velocity()

	if not is_network_master():
		position = slave_pos
		set_rotation(slave_rotation)
	else:
		gravity = state.get_total_gravity() 
		motion = state.get_linear_velocity()

func _process(delta):
	if is_network_master():
		query_target()



func _physics_process(delta):
	
	print(rotation)
	# zero out the motion and torque settings for this frame
	var motion = 0.0
	var torque = 0.0
	
	if not exploded:
		if is_network_master():
			# handles camera zoom level-----------------------------------------------
			#zoom(delta)
			# handles ship status ----------------------------------------------------
			throttle()
			check_damage()
			#todo change move player to "fire engine" or something.
			motion = move_player()
			
			torque = rotate_player()
			# ------------------------------------------------------------------------
	
			# handles weapons --------------------------------------------------------
			var firing = Input.is_action_pressed("fire_weapon")
	
	
			#Checks to see if a bomb is not already being deployed
			if firing and not prev_bombing:
				#if not then make a new bomb with a name made of the ships name and the unique ID of the bomb
				var bomb_name = get_name() + str(bomb_index)
	
				var bomb_pos = position
				var bomb_rot = rotation
				rpc("deploy", bomb_name, bomb_pos, get_tree().get_network_unique_id())
	
			prev_bombing = firing
			# ------------------------------------------------------------------------
			
			# transfer the information for this ship to the server info to be used for puppets on other machines
			rset("slave_motion", motion)
			rset("slave_pos", position)
			rset("slave_rotation", get_rotation())
			rset("slv_engine_on", engine_on)
		else:
			position = slave_pos
			set_rotation(slave_rotation)
			motion = slave_motion
			engine_on = slv_engine_on
			rotation = slave_rotation
	
	
		
		var motioned = Vector2(motion,0).rotated(get_rotation()) 
	
		apply_impulse(Vector2(0,0), motioned)
		apply_torque_impulse(torque)
		
		if not is_network_master():
			slave_pos = position # To avoid jitter

func change_shiptype(ship):
	
	if has_node("main_hull"):
		$main_hull.queue_free()
		
	if ship == "Vostok":
		hulltype = vostok_hull.instance()
		
	if ship == "Dragon":
		hulltype = dragon_hull.instance()
	
	if not has_node("main_hull"):
		hulltype = dragon_hull.instance()
		hulltype.set_name("main_hull")
		add_child(hulltype)

func query_target():
	var targets = get_tree().get_nodes_in_group("target")
	target = targets[target_index]
	#print(targets[target_index].object_name)
	#print("targets.size is ", targets.size())
	#print("targets.index is ", target_index)
	
	if Input.is_action_just_pressed("target_up"):
		target_index += 1
		if target_index > (targets.size()-1):
			target_index = (targets.size() - 1)
	if Input.is_action_just_pressed("target_down"):
		target_index -= 1
		if target_index < 0:
			target_index = 0
	#print(targets)


func rotate_left():
	rotation = -spinforce
	apply_torque_impulse(rotation)
	
func rotate_right():
	rotation = spinforce
	apply_torque_impulse(rotation)
	
func rotate_player():
	var rotation = 0.0
	if Input.is_action_pressed("move_left"):
		rotation = -spinforce
	if Input.is_action_pressed("move_right"):
		rotation = spinforce
	if Input.is_action_pressed("move_down"):
		auto_brake()
		rotation = rotvel
	return rotation
	
func throttle():
	
	if engine_on:
		$main_hull/plume.set_visible(true)
		if throttle > 0:
			$main_hull/plume.scale.y = 0.239 * (throttle / 100)
	else:
		$main_hull/plume.set_visible(false)
		$main_hull/plume.scale.y = 0.239
		
func burn():
	var motion = 0
	fuel -= burnrate
	motion += 3
	engine_on = true
	
func move_player():
	var motion = 0
	engine_on = false

	if Input.is_action_pressed("move_up"):
		fuel -= burnrate
		motion += 3
		engine_on = true
		
	if Input.is_action_pressed("move_down"):
		pass
		
	if throttle > 0:
		engine_on = true
		motion += 3 * (throttle / 100)
		fuel -= burnrate * (throttle / 100)
		
	return motion

func zoom(delta):
	var zoomit = zoom_grain * ((zoom*.10) * delta)
	if zoom < min_zoom:
		zoom = min_zoom
	if zoom > max_zoom:
		zoom = max_zoom
	
	var adjust = Vector2(zoom,zoom)
	if Input.is_action_pressed("zoom_out") or Input.is_action_just_released("zoom_out"):
		zoom += zoomit
	if Input.is_action_pressed("zoom_in") or Input.is_action_just_released("zoom_in"):
		zoom -= zoomit
	
	#$Camera2D.set_zoom(adjust)



puppet func damage():
	pass
	
	# get where we were hit
	# take damage to that area
	
	
master func hit(by_who):
	if stunned:
		return
	rpc("damage") # hit puppets
	damage() # Stun master - could use sync to do both at once

func set_player_name(new_name,shiptype = "Vostok"):
	get_node("label").set_text(new_name)
	ship_type = shiptype

func check_damage():
	for item in $damage.get_overlapping_areas():
		if item.is_in_group("corona") and hull > 0:
			hull -= 1

			if hull == 0:
				explode()
				var touching = $Area2D.get_overlapping_areas()

		if item.is_in_group("planet"):
			fuel += 1
			if fuel > max_fuel:
				fuel = max_fuel
	#if current_damage == 0:
		#if hull <= 50:
			#current_damage
			#var smoke = load("res://scenes/continous_smoke.tscn")
			#add_child(smoke.instance())
		

func launch_missile():
			# handles weapons --------------------------------------------------------
		var missiling = Input.is_action_pressed("set_bomb")


		#Checks to see if a bomb is not already being deployed
		if missiling and not prev_missiling:
			#if not then make a new bomb with a name made of the ships name and the unique ID of the bomb
			var missile_name = get_name() + str(missile_index)

			var missile_pos = position
			var bomb_rot = rotation
			rpc("launch_missile", missile_name, position, get_tree().get_network_unique_id())

		prev_missiling = missiling
		# ------------------------------------------------------------------------

func come_to_heading(heading):

	# if the heading we need to come to does not equal our current rotation
	var degangle = get_facing()
	var difference = abs(heading - degangle)

	if difference > deg2rad(180):
		rotvel -= spinforce
	else:
		if degangle > heading:
			rotvel -= brake_spin
		if degangle < heading:
			rotvel += brake_spin

	var error = deg2rad(2.5)
	var fine_error = deg2rad(1)
	if degangle > (heading - error) and degangle < (heading + error):
		if rotvel != 0:
			rotvel = 0

		if degangle > (heading - fine_error) and degangle < (heading + fine_error):
			#print("heading is finally:",heading)
			var currentrotation = get_rotation()
			currentrotation = heading
			set_rotation(currentrotation)
			#print("rotation is finally:", currentrotation.y)
		
	return rotvel

func auto_brake():
	
	var motion = current_motion
	var origin = Vector2()
	var rotater = motion.angle_to_point(origin)
	
	var desired_angle = origin.angle_to_point(motion)
	#print(get_facing()," + ",desired_angle)
	if get_facing() != desired_angle:
		come_to_heading(desired_angle)
	return rotvel

func get_facing():
	var facing = get_rotation()
	#print("facing = ", facing)
	return facing

func respawn():
	current_fuel = fuel
	current_hull = hull
	exploded = false
	change_shiptype(ship_type)
	set_global_position(get_tree().get_nodes_in_group("spawn_point")[0].get_global_position())
	set_mode(0)
	$Indicator.set_visible(true)
	pass
