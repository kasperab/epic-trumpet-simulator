extends ColorRect

@export var goal : Goal

@export var easyPreset : DifficultyPreset
@export var mediumPreset : DifficultyPreset
@export var epicPreset : DifficultyPreset

func _on_play_pressed():
	goal.start_game()
	hide()

func show_menu(victory):
	show()
	$"Victory".visible = victory

func play_easy():
	goal.set_difficulty(easyPreset)
	_on_play_pressed()

func play_medium():
	goal.set_difficulty(mediumPreset)
	_on_play_pressed()

func play_epic():
	goal.set_difficulty(epicPreset)
	_on_play_pressed()
	
