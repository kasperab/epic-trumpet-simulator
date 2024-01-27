extends Label

@export var duration = 1
@export var endY = -100
var time : float
var startY : float

# Called when the node enters the scene tree for the first time.
func _ready():
	startY = position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if(time > duration):
		get_parent().queue_free()
		return
		
	position.y = startY + (endY - startY) * (time / duration)
	label_settings.font_color.a = ((duration - time) / duration)
