extends HBoxContainer

class_name Goal

@export var musicController : MusicController
@export var initialScore = 10
@onready var health = $"../Health"
var score
var combo = 1
var playing : Array[Control]
var inGame = false

func _ready():
	score = initialScore
	update_ui()
	for _child in get_children():
		playing.append(null)

func _process(delta):
	if ($"../Notes".get_child_count() == 0 && musicController.is_sequence_empty() && inGame):
		finish_game(true)

func _input(event):
	var index = 0
	for child in get_children():
		if event.is_action_pressed(child.name):
			var correct_press = false
			if child.get_node("Area2D").has_overlapping_areas():
				for area in child.get_node("Area2D").get_overlapping_areas():
					var note = area.get_parent()
					var y = note.position.y + note.size.y * note.scale.y
					if y >= position.y and y <= position.y + size.y:
						correct_press = true
						playing[index] = note
						var eventAsset : EventAsset = area.get_parent().eventToPlay
						if(eventAsset):
							FMODRuntime.play_one_shot(eventAsset)
			if not correct_press:
				change_score(-1)
		elif event.is_action_released(child.name) and playing[index]:
			if playing[index].position.y >= position.y:
				change_score(1)
			else:
				change_score(-1)
			playing[index].queue_free()
			playing[index] = null
		index += 1

func change_score(points):
	if points > 0:
		score += points * combo
		combo += 1
		health.value += points
	else:
		combo = 1
		health.value += points

	if health.value <= 0:
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
	health.value = health.max_value
	update_ui()
	$"../Notes".reset()
	$"../../Menu".show_menu(victory)
	musicController.reset()
	inGame = false

func _on_area_2d_area_exited(area):
	if playing.has(area.get_parent()):
		playing[playing.find(area.get_parent())] = null
		change_score(1)
	else:
		change_score(-1)
	area.get_parent().queue_free()
