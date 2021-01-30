extends HBoxContainer
var subject


func _ready():
	subject = get_tree().get_nodes_in_group("player")[0]

func _process(delta):
	if subject.loaded_weapon == 0:
		$missile.set_modulate(Color(1, 1, 1))
		$station.set_modulate(Color(1, 1, 1, 0.27451))
	if subject.loaded_weapon == 1:
		$station.set_modulate(Color(1, 1, 1))
		$missile.set_modulate(Color(1, 1, 1, 0.27451))



func _on_press_missile_pressed():
	subject.loaded_weapon = 0



func _on_press_station_pressed():
	subject.loaded_weapon = 1

