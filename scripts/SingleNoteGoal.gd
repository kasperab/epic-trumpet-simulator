extends NinePatchRect
	
func trigger_area_exit(area : Area2D):
	area_exit.emit(area)

signal area_exit(area : Area2D)
