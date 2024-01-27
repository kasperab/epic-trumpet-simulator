extends Control

var score = 0

func _input(event):
	for child in get_children():
		if event.is_action_pressed(child.name):
			if child.get_node("Area2D").has_overlapping_areas():
				score += 1
				$"../Score".text = str(score)
				for area in child.get_node("Area2D").get_overlapping_areas():
					area.get_parent().queue_free()
