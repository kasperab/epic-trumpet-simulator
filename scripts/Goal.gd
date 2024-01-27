extends HBoxContainer

class_name Goal

@export var musicController : MusicController
@export var initialScore = 10
var score
var combo = 1
var inGame = false

func _ready():
	score = initialScore
	update_ui()
	
func _process(delta):
	if ($"../Notes".get_child_count() == 0 && musicController.is_sequence_empty() && inGame):
		finish_game(true)

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
	else:
		score += points
		combo = 1
		
	if score <= 0:
		finish_game(false)
		
	update_ui()
		
func update_ui():
		$"../Score".text = str(score)
		if(combo > 1):
			$"../Combo".text = "x" + str(combo)
		else:
			$"../Combo".text = ""
			
func start_game():
	musicController.start()
	inGame = true
		
func finish_game(victory):
	score = initialScore
	update_ui()
	$"../Notes".reset()
	$"../../Menu".show_menu(victory)
	musicController.reset()
	inGame = false
