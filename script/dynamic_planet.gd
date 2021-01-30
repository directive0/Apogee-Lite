extends Node2D
export var object_name = "Default Planet"
export var resource_type = 0
export var gravity_set = 40



# Called when the node enters the scene tree for the first time.
func _ready():
	$gravity.gravity = gravity_set
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_tree().get_nodes_in_group("star").size() > 0:
		#var angle = global_position.angle_to_point(get_tree().get_nodes_in_group("star")[0].global_position)
		var angle = get_tree().get_nodes_in_group("star")[-1].global_position.angle_to_point(global_position)# + 3.14159
		#var angle = get_angle_to(get_tree().get_nodes_in_group("star")[0].global_position)
		$shadow_pivot.set_global_rotation(angle)
		#print(get_tree().get_nodes_in_group("star").size())

#	pass
