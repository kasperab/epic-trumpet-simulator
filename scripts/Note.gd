extends Control

@export var clickRect : Control
@export var holdRect : Control
@export var scaleModifier = 0.2
@export var duration = 0.05

var isClick : bool = false
var eventToPlay : EventAsset
var points : float
var scored : bool = false

var baseScale : float
var scaleUp = false
var scaleDown = false

var time : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	baseScale = scale.x
	pass # Replace with function body.
	
func _process(delta):
	if scaleUp:
		time += delta
		if time >= duration:
			time = duration
			scaleUp = false
	elif scaleDown:
		time -= delta
		if time <= 0:
			time = 0
			scaleDown = false
			
		modulate.a = time / duration
	
	var progress = time / duration
	var currentScaleModifier = scaleModifier * progress
	scale.x = baseScale + currentScaleModifier

func set_click():
	isClick = true
	holdRect.hide()
	clickRect.show()
	
func on_click():
	scaleUp = true
	
func on_score():
	scored = true
	scaleDown = true
