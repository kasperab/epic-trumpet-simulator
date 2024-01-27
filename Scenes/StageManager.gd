extends Node3D

@export var mainCamera : Camera3D
@export var speed : float = 10

@export var fovModifier : float = -10
var fov : float
var progress = 0
var trigger = true


# Called when the node enters the scene tree for the first time.
func _ready():
	fov = mainCamera.fov
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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

func trigger_beat():
	trigger = true
