extends ColorRect

func _ready():
	get_tree().paused = true

func _on_play_pressed():
	get_tree().paused = false
	hide()

func show_menu():
	get_tree().paused = true
	show()
