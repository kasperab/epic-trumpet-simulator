extends Node3D

class_name MusicController

var callable: Callable = Callable(self, "beat_callback")

class NoteData:
	var soundEvent : EventAsset
	var beatPos : float
	var duration : float
	var note : int

@export var backgroundMusic: EventAsset
var instance: EventInstance
var time: float = 0
var beatCounter: int = -1

@export var tempo: float = 130

@export var sequenceName = "test"
@export var noteMapping : Array[int] = [2, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 1]

var sequenceData: Array[NoteData]
var currentSequence: Array[NoteData]
var playbackInstance: EventInstance
@export var testAsset: EventAsset

@export var notesController : Notes
@export var startBeat : int = 16

@export var minDuration : float = 0.25
@export var durationQuanta : float = 1
@export var durationAdjustment : float = -0.125

signal on_beat

var noteFallBeatDuration : float

func list_files_in_directory(path):
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()

		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif not file.begins_with("."):
				files.append(file)

		dir.list_dir_end()

		return files
	else:
		push_error("Directory with event assets", path, " not found!")
		return null

func _enter_tree():
	var eventPath = "res://addons/FMOD/editor/resources/events"
	var eventList = list_files_in_directory(eventPath)
	var sequenceEventPrefix = "event:/" + sequenceName + "/"
	
	for event in eventList:
		var eventAsset : FMODAsset = ResourceLoader.load(eventPath + "/" + event)
		if(eventAsset.path.begins_with(sequenceEventPrefix)):
			var eventName = eventAsset.path.replace(sequenceEventPrefix, "")
			var metaData = eventName.split("-")
			var note = NoteData.new()
			note.soundEvent = eventAsset
			note.beatPos = float(metaData[1]) / 100
			note.duration = float(metaData[2]) / 100
			note.note = int(metaData[3])
			sequenceData.append(note)
	
	var sortFunc = func (first : NoteData, second : NoteData):
		return first.beatPos < second.beatPos
		
	sequenceData.sort_custom(sortFunc)

func _ready():
	playbackInstance = FMODRuntime.create_instance(backgroundMusic)
	playbackInstance.set_callback(callable, FMODStudioModule.FMOD_STUDIO_EVENT_CALLBACK_TIMELINE_BEAT)
	
	noteFallBeatDuration = time_to_beat(notesController.get_fall_duration())
	
	reset()
	
func start():
	playbackInstance.start()
	
func reset():
	currentSequence = sequenceData.duplicate()
	playbackInstance.stop(FMODStudioModule.FMOD_STUDIO_STOP_IMMEDIATE)
	beatCounter = -1

func _process(delta):
	time += delta
	
	if(currentSequence.size() > 0):
		var beatPos = currentSequence[0].beatPos + startBeat - noteFallBeatDuration
		if(get_beat_pos() >= beatPos):
			#var duration = currentSequence[0].duration + durationAdjustment
			#duration = round(duration / durationQuanta) * durationQuanta
			#duration = max(duration, minDuration)
			var duration = currentSequence[0].duration
			duration = int(duration / durationQuanta) * durationQuanta
			duration = max(duration, minDuration) + durationAdjustment
			notesController.spawnNote(currentSequence[0].soundEvent, noteMapping[currentSequence[0].note], beat_to_time(duration))
			currentSequence.remove_at(0)
			

func beat_callback(args):
	if args.properties.beat:
		tempo = args.properties.tempo
		beatCounter += 1
		time = 0
		call_deferred("emit_signal", "on_beat")
	
func time_to_beat(seconds):
	var bps = tempo / 60
	var interval = 1 / bps
	return seconds / interval
	
func beat_to_time(beatPos):
	var bps = tempo / 60
	var interval = 1 / bps
	return beatPos * interval
	
func get_beat_pos():
	var subPos = min(time_to_beat(time), 1)
	return beatCounter + subPos
	
func is_sequence_empty():
	return currentSequence.is_empty()
