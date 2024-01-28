extends Node

@onready var main = $"../../Stage/main_character_legs/AnimationPlayer"
@onready var synth = $"../../Stage/synth_character"
@onready var synth_end = synth.position.x
@onready var synth_start = synth_end - 10
@onready var bongo = $"../../Stage/bongo_character"
@onready var bongo_end = bongo.position.x
@onready var bongo_start = bongo_end + 10
@onready var crowd = $"../../Stage/Crowd"
var time
var index
var slide_time = 2
@onready var timings = [
	[14.5, synth, synth_start, synth_end, null],
	[38.5, bongo, bongo_start, bongo_end, null]
]

func _ready():
	stop()

func _process(delta):
	if index < timings.size():
		time += delta
		if time >= timings[index][0]:
			timings[index][4] = create_tween()
			timings[index][4].tween_property(timings[index][1], "position", Vector3(timings[index][3], timings[index][1].position.y, timings[index][1].position.z), slide_time)
			index += 1

func start():
	time = 0
	index = 0
	main.play()
	for char in crowd.get_children():
		char.get_node("AnimationPlayer").play()

func stop():
	index = timings.size()
	main.stop()
	for char in crowd.get_children():
		char.get_node("AnimationPlayer").pause()
	for timing in timings:
		timing[1].position = Vector3(timing[2], timing[1].position.y, timing[1].position.z)
		if timing[4]:
			timing[4].kill()
			timing[4] = null
