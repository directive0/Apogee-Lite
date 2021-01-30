extends Camera2D
export (NodePath) var target

var target_return_enabled = true
var target_return_rate = 0.1
var min_zoom = 0.3
var max_zoom = 400
var zoom_sensitivity = 20
var zoom_speed = 0.05

var events = {}
var last_drag_distance = 0

func _physics_process(delta):
	zoom(delta)
	print(zoom)
	if target and target_return_enabled and events.size() == 0:
		position = lerp(position, get_node(target).position, target_return_rate)

func zoom(delta):
	var zoomit = zoom_sensitivity * ((zoom*.10) * delta)
	if zoom < Vector2(min_zoom, min_zoom):
		zoom = Vector2(min_zoom, min_zoom)
	if zoom > Vector2(max_zoom, max_zoom):
		zoom = Vector2(max_zoom, max_zoom)
	
	var adjust = zoom
	if Input.is_action_pressed("zoom_out") or Input.is_action_just_released("zoom_out"):
		zoom += zoomit
	if Input.is_action_pressed("zoom_in") or Input.is_action_just_released("zoom_in"):
		zoom -= zoomit
	
	set_zoom(zoom)

func _unhandled_input(event):
	
	if event is InputEventScreenTouch:
		#print("event detected")
		if event.pressed:
			events[event.index] = event
		else:
			events.erase(event.index)
	
	if event is InputEventScreenDrag:
		events[event.index] = event
		if events.size() == 1:
			
			position -= event.relative * zoom.x
		elif events.size() == 2:
			var drag_distance = events[0].position.distance_to(events[1].position)
			if abs(drag_distance - last_drag_distance) > zoom_sensitivity:
				var new_zoom = (1 + zoom_speed) if drag_distance < last_drag_distance else (1 - zoom_speed)
				new_zoom = clamp(zoom.x * new_zoom, min_zoom, max_zoom)
				zoom = Vector2.ONE * new_zoom
				last_drag_distance = drag_distance

#func zoom(delta):
#	var zoomit = zoom_sensitivity * ((zoom*.10) * delta)
#	if zoom < min_zoom:
#		zoom = min_zoom
#	if zoom > max_zoom:
#		zoom = max_zoom
#
#	var adjust = Vector2(zoom,zoom)
#	if Input.is_action_pressed("zoom_out") or Input.is_action_just_released("zoom_out"):
#		zoom += zoomit
#	if Input.is_action_pressed("zoom_in") or Input.is_action_just_released("zoom_in"):
#		zoom -= zoomit
#
#	set_zoom(adjust)
