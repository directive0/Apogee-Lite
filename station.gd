extends RigidBody2D

var in_area = []
var lastcheck = false
var generating = false
var from_player
var fuel = 100
var hull = 100
var planet

func _ready():
	$expire.start()

func _physics_process(delta):
	if is_network_master():
		var touching = $Area2D.get_overlapping_areas()
		var orbiting = 0
		
		for body in touching:
			if body.is_in_group("planet"):
				planet = body
				orbiting += 1
				
		if orbiting > 0:
			if lastcheck == false:
				#print("planet detected!")
				$expire.stop()
				generating = true
				$generate.start()
				lastcheck = true
		else:
			if lastcheck == true:
				#print("no planet detected!")
				$generate.stop()
				$expire.start()		
				lastcheck = false

func done():
	queue_free()


func _on_expire_timeout():
	queue_free()
	pass # Replace with function body.
