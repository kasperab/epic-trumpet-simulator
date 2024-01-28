extends Control

@export var container : Control
@export var clickRect : Control
@export var holdRect : Control

@export var labelMiss : Label
@export var labelLowAccuracy : Label

@export var scaleModifier = 0.2
@export var duration = 0.05
@export var fadeInDuration = 0.5

var isClick : bool = false
var eventToPlay : EventDescription
var points : float

var isMiss : bool = true
var isPerfect : bool = false

var hit : bool = false
var scored : bool = false

var baseScale : float
var scaleUp = false
var scaleDown = false

var time : float = 0
var fadeIn : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	baseScale = scale.x
	pass # Replace with function body.
	
func _process(delta):
	if fadeIn < fadeInDuration:
		fadeIn += delta
		if(fadeIn >= fadeInDuration):
			fadeIn = fadeInDuration
			
		modulate.a = fadeIn / fadeInDuration
		
	if scaleUp:
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
	
	if isMiss:
		labelMiss.show()
	elif !isPerfect:
		labelLowAccuracy.show()
	
func get_length():
	return container.size.y * container.scale.y
	
func set_length(length):
	container.scale.y = length
