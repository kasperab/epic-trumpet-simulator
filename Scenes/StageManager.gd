extends Node3D

class_name StageManager

@export var mainCamera : Camera3D
@export var speed : float = 10

@export var fovModifier : float = -10
var fov : float
var progress : float = 0
var timer : float = 0
var trigger = true

@export var scaleAmount = 1.1
var scaleDuration = 0.1
var scaleTime = 0
var scaleUp = false
var scaleDown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	fov = mainCamera.fov
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timer > 0:
		timer -= delta
		if timer <= 0:
			timer = 0
			trigger = true
	
	if trigger:
		if progress < 1:
			progress += delta * speed
		else:
			progress = 1
			trigger = false
	else:
		if progress > 0:
			progress -= delta * speed
		else:
			progress = 0
			
	mainCamera.fov = fov + fovModifier * progress
	
	if scaleUp or scaleDown:
		var trumpet = $"main_character/RootNode/main_character_legs/main_character_legless/trumpet_main"
		if scaleUp:
			scaleTime = scaleDuration
			scaleUp = false
		elif scaleDown:
			scaleTime -= delta
			if(scaleTime <= 0):
				scaleTime = 0
				scaleDown = false
				
		var currentScale = 1 + (scaleAmount - 1) * (scaleTime / scaleDuration)
		trumpet.scale = Vector3(1, 1, currentScale)

func trigger_beat(beatDuration : float):
	timer = beatDuration - (1/speed)
	
func on_note_start():
	scaleUp = true
	
func on_note_end():
	scaleDown = true
