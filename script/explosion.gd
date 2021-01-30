extends Node2D

# Defines the behaviour of all explosions

# Defines the type of explosion
export var type = "standard"
export var speed = 1




# Called when the node enters the scene tree for the first time.
func _ready():
	$sparks.emitting = true
	$fire.emitting = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
