extends Control

var score = 0
var combo = 1

func _input(event):
	for child in get_children():
		if event.is_action_pressed(child.name):
			if child.get_node("Area2D").has_overlapping_areas():
				change_score(1)
				for area in child.get_node("Area2D").get_overlapping_areas():
					area.get_parent().queue_free()
			else:
				change_score(-1)

func change_score(points):
	score += points * combo
	$"../Score".text = str(score)
	if points > 0:
		combo += 1
		$"../Combo".text = "x" + str(combo)
	else:
		combo = 1
		$"../Combo".text = ""
