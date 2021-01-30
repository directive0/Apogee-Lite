extends Control
var subject


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	subject = get_tree().get_nodes_in_group("player")[0]
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ColorRect/VBoxContainer/name.set_text(str(subject.target.object_name))
	
	var distance = subject.get_global_position().distance_to(subject.target.get_global_position())
	var adjusted = distance / 1496
	$ColorRect/VBoxContainer/distance.set_text(str(stepify(adjusted,0.001)) + " AU")
#	pass
