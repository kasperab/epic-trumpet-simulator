extends Node3D

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

var sequence: Array[NoteData]
@export var testAsset: EventAsset

@export var notesController : Notes
@export var startBeat : int = 16

var noteFallBeatDuration : float

func dir_contents(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

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
			print(eventAsset.path)
			var eventName = eventAsset.path.replace(sequenceEventPrefix, "")
			var metaData = eventName.split("-")
			var note = NoteData.new()
			note.soundEvent = eventAsset
			note.beatPos = float(metaData[1]) / 100
			note.duration = float(metaData[2]) / 100
			note.note = int(metaData[3])
			sequence.append(note)
	
	var sortFunc = func (first : NoteData, second : NoteData):
		return first.beatPos < second.beatPos
		
	sequence.sort_custom(sortFunc)
	for note in sequence:
		print(note.beatPos)

func _ready():
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

func _process(delta):
	time += delta
	#print(get_beat_pos())
	if(sequence.size() > 0):
		var event = sequence[0].soundEvent
		var beatPos = sequence[0].beatPos + startBeat - noteFallBeatDuration
		if(get_beat_pos() >= beatPos):
			notesController.spawnNote(event, noteMapping[sequence[0].note])
			#print("play at ", get_beat_pos())
			#FMODRuntime.play_one_shot(testAsset)
			sequence.remove_at(0)
	
func time_to_beat(seconds):
	var bps = tempo / 60
	var interval = 1 / bps
	return seconds / interval
	
func get_beat_pos():
	var subPos = min(time_to_beat(time), 1)
	
	return beatCounter + subPos
	
