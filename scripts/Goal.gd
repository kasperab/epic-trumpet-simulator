extends HBoxContainer

class_name Goal

@export var musicController : MusicController
@export var stageManager : StageManager

@export var victorySound : EventAsset
@export var loseSound : EventAsset

@onready var health = $"../Health"

var difficultyPreset : DifficultyPreset
var score
var combo = 1
var playing : Array[Control]
var inGame = false

var pointPopUp = preload("res://Scenes/PointLabel.tscn")

func _ready():
	score = 0
	update_ui()
	var num = 1
	for child in get_children():
		playing.append(null)
		child.get_node("NinePatchRect/Label").text = str(num)
		num += 1

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
					
					if(playing[index] != note and !note.hit and startY > lastStartY):
						lastStartY = startY
						lastNote = note
					
			if lastNote:
				lastNote.hit = true
				var distToY = abs(lastStartY - position.y)
				lastNote.points = 0
				var accuracyIndex = -1
				for threshold in difficultyPreset.accuracyThresholds:
					if distToY > threshold:
						break
					accuracyIndex += 1
				
				if accuracyIndex > -1:
					lastNote.points = difficultyPreset.accuracyPoints[accuracyIndex]
					
					playing[index] = lastNote
					var eventAsset : EventDescription = lastNote.eventToPlay
					if eventAsset:
						var playbackInstance = eventAsset.create_instance()
						playbackInstance.start()
						playbackInstance.release()
						
					lastNote.on_click()
					stageManager.on_note_start()
					
					if lastNote.isClick:
						change_score(lastNote.points)
						lastNote.on_score()
						stageManager.on_note_end()
					else:
						child.get_node("Particles").emitting = true
				else:
					lastNote.scored = true
					miss()

		elif event.is_action_released(child.name) and playing[index] and not playing[index].scored:
			if playing[index].position.y >= position.y:
				change_score(playing[index].points)
			else:
				miss()
			
			playing[index].on_score()
			stageManager.on_note_end()
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
	health.value = health.max_value
	musicController.start()
	inGame = true
	update_ui()
	$"../../Stage/CharacterControl".start()

func finish_game(victory):
	if victory:
		FMODRuntime.play_one_shot(victorySound)
	else:
		FMODRuntime.play_one_shot(loseSound)
	
	health.value = health.max_value
	update_ui()
	$"../Notes".reset()
	$"../../Menu".show_menu(victory)
	musicController.reset()
	inGame = false
	$"../../Stage/CharacterControl".stop()

func _on_area_2d_area_exited(area):
	if playing.has(area.get_parent()):
		var index = playing.find(area.get_parent()) 
		if(!playing[index].scored):
			var points = playing[index].points
			change_score(points)
			playing[index].on_score()
			stageManager.on_note_end()
			get_children()[index].get_node("Particles").emitting = false
		
		playing[index] = null
	elif !area.get_parent().hit:
		miss()
		
	area.get_parent().queue_free()
	
func set_difficulty(preset : DifficultyPreset):
	difficultyPreset = preset
	$"../Notes".speed = difficultyPreset.speed
	musicController.useTrackCount = difficultyPreset.numTracks
	musicController.update_fall_duration()
