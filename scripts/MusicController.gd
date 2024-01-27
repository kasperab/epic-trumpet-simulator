extends Node3D

var callable: Callable = Callable(self, "beat_callback")

@export var recordMode: bool
@export var backgroundMusic: EventAsset
var instance: EventInstance
var time: float = 0
var beatCounter: int = -1

@export var tempo: float = 130
@export var eventSequence: Array[EventAsset]
@export var beatPosSequence: Array[float]
@export var testAsset: EventAsset

@export var notesController : Notes
@export var startBeat : int = 16

var noteFallBeatDuration : float

func _ready():
	if(beatPosSequence.size() != eventSequence.size()):
		push_error("Beat Pos and Event sequence arrays need to have identical counts!")
		
	instance = FMODRuntime.create_instance(backgroundMusic)
	instance.start()
	instance.set_callback(callable, FMODStudioModule.FMOD_STUDIO_EVENT_CALLBACK_TIMELINE_BEAT)
	
	noteFallBeatDuration = time_to_beat(notesController.get_fall_duration())

func beat_callback(args):
	if args.properties.beat:
		tempo = args.properties.tempo
		#print("beat!", beatCounter, tempo)
		beatCounter += 1
		time = 0
		
func _input(event):
	if !recordMode:
		return;
		
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			FMODRuntime.play_one_shot(testAsset)
			print("Play at ", get_beat_pos())

func _process(delta):
	time += delta
	#print(get_beat_pos())
	if(eventSequence.size() > 0):
		var event = eventSequence[0]
		var beatPos = beatPosSequence[0] + startBeat - noteFallBeatDuration
		if(get_beat_pos() >= beatPos):
			notesController.spawnNote(testAsset)
			#print("play at ", get_beat_pos())
			#FMODRuntime.play_one_shot(testAsset)
			eventSequence.remove_at(0)
			beatPosSequence.remove_at(0)
	
func time_to_beat(seconds):
	var bps = tempo / 60
	var interval = 1 / bps
	return seconds / interval
	
func get_beat_pos():
	var subPos = min(time_to_beat(time), 1)
	
	return beatCounter + subPos
	
