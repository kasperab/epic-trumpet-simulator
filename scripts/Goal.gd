extends HBoxContainer

class_name Goal

@export var musicController : MusicController
@onready var health = $"../Health"

@export var accuracyThresholds : Array[int]
@export var accuracyPoints : Array[int]
var score
var combo = 1
var playing : Array[Control]
var inGame = false

var pointPopUp = preload("res://Scenes/PointLabel.tscn")

func _ready():
	score = 0
	update_ui()
	for _child in get_children():
		playing.append(null)

func _process(_delta):
	if ($"../Notes".get_child_count() == 0 && musicController.is_sequence_empty() && inGame):
		finish_game(true)

func _input(event):
	var index = 0
	for child in get_children():
		if event.is_action_pressed(child.name):
			var correct_press = false
			var lastStartY = 0
			var lastNote = null
			
			if child.get_node("Area2D").has_overlapping_areas():
				for area in child.get_node("Area2D").get_overlapping_areas():
					var note = area.get_parent()
					var startY = note.position.y + note.size.y * note.scale.y
					
					if(startY > lastStartY):
						lastStartY = startY
						lastNote = note
					
			if lastNote:
				var distToY = abs(lastStartY - position.y)
				lastNote.points = 0
				var accuracyIndex = -1
				for threshold in accuracyThresholds:
					if distToY > threshold:
						break
					accuracyIndex += 1
				
				if accuracyIndex > -1:
					lastNote.points = accuracyPoints[accuracyIndex]
					
					playing[index] = lastNote
					var eventAsset : EventAsset = lastNote.eventToPlay
					if(eventAsset):
						FMODRuntime.play_one_shot(eventAsset)
					child.get_node("Particles").emitting = true
					correct_press = true

			if not correct_press:
				miss()
		elif event.is_action_released(child.name) and playing[index]:
			if playing[index].position.y >= position.y:
				change_score(playing[index].points)
			else:
				miss()
			
			playing[index].scored = true
			child.get_node("Particles").emitting = false
		index += 1
		
func miss():
	combo = 1
	health.value -= 1

	if health.value <= 0:
		finish_game(false)
		
	update_ui()

func change_score(points):
	var pointInstance = pointPopUp.instantiate()
	pointInstance.get_child(0).text = str(points)
	$"../PointLabelArea".add_child(pointInstance)
	
	score += points * combo
	combo += 1
	health.value += 1

	update_ui()

func update_ui():
		$"../Score".text = str(score)
		if(combo > 1):
			$"../Combo".text = "x" + str(combo)
		else:
			$"../Combo".text = ""

func start_game():
	score = 0
	combo = 1
	musicController.start()
	inGame = true

func finish_game(victory):
	health.value = health.max_value
	update_ui()
	$"../Notes".reset()
	$"../../Menu".show_menu(victory)
	musicController.reset()
	inGame = false

func _on_area_2d_area_exited(area):
	if playing.has(area.get_parent()):
		var index = playing.find(area.get_parent()) 
		if(!playing[index].scored):
			var points = playing[index].points
			change_score(points)
			get_children()[index].get_node("Particles").emitting = false
		
		playing[index] = null
	else:
		miss()
		
	area.get_parent().queue_free()
