extends HBoxContainer

var score = 10
var combo = 1

func _input(event):
	for child in get_children():
		if event.is_action_pressed(child.name):
			if child.get_node("Area2D").has_overlapping_areas():
				change_score(1)
				for area in child.get_node("Area2D").get_overlapping_areas():
					var eventAsset : EventAsset = area.get_parent().eventToPlay
					if(eventAsset):
						FMODRuntime.play_one_shot(eventAsset)
					area.get_parent().queue_free()
			else:
				change_score(-1)

func change_score(points):
	if points > 0:
		score += points * combo
		combo += 1
		$"../Combo".text = "x" + str(combo)
	else:
		score += points
		combo = 1
		$"../Combo".text = ""
	$"../Score".text = str(score)
	if score <= 0:
		score = 10
		$"../Score".text = str(score)
		$"../../Menu".show_menu()
		$"../Notes".reset()
