extends Control

class_name Notes

@export var debugSpawn : bool
@export var spawn : float
@export var remove : float
@export var speed : float
var note = preload("res://Scenes/Note.tscn")
var timer = 0

func _process(delta):
	if debugSpawn:
		if timer <= 0:
			spawnNote(null)
			timer = 2
		else:
			timer -= delta
			
	for child in get_children():
		var y = child.position.y + speed * delta
		if y >= remove:
			child.queue_free()
			$"../Goal".change_score(-1)
		else:
			child.position = Vector2(child.position.x, y)

func reset():
	timer = 0
	for child in get_children():
		child.queue_free()
		
func get_fall_duration():
	var distanceToGoal = $"../Goal".position.y - spawn
	return distanceToGoal / speed
	
func spawnNote(eventAsset):
	var new_note = note.instantiate()
	new_note.eventToPlay = eventAsset
	new_note.position = Vector2(960, spawn - new_note.scale.y)
	add_child(new_note)

