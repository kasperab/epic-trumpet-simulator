extends ColorRect

@export var goal : Goal

func _on_play_pressed():
	goal.start_game()
	hide()

func show_menu(victory):
	show()
	$"Victory".visible = victory
