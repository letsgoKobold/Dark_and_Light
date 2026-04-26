extends Node

var bgm_event: FmodEvent = null
var suppress_snapshot: FmodEvent = null
var events: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	
	FmodServer.load_bank("res://fmod/DarkAndLight/Build/Desktop/Master.strings.bank", FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
	FmodServer.load_bank("res://fmod/DarkAndLight/Build/Desktop/Master.bank", FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
	#atmo_event = FmodServer.create_event_instance("event:/Atmo")
	play_bgm("BGM")

func play_bgm(eventName, stop_mode = 0):
	
	#stop_bgm(stop_mode)
	bgm_event = FmodServer.create_event_instance("event:/" + eventName)
	bgm_event.start()
	
func stop_bgm(stop_mode = 0):
	if bgm_event != null:
		bgm_event.stop(stop_mode)

func play_one_shot(eventName, obj_transform = null):
	var sfx_event: FmodEvent = FmodServer.create_event_instance("event:/" + eventName)
	if obj_transform != null:
		sfx_event.set_3d_attributes(obj_transform)
	sfx_event.start()
	sfx_event.release()
	
func play_event(eventName, stop_mode = 0):
	
	if events.has(eventName):
		if events[eventName].get_playback_state() == FmodServer.FMOD_STUDIO_PLAYBACK_PLAYING:
			return
			#events[eventName].stop(stop_mode)
	
	events[eventName] = FmodServer.create_event_instance("event:/" + eventName)
	events[eventName].start()

func stop_event(eventName, stop_mode = 0):
	
	if !events.has(eventName):
		return
		
	if events[eventName] != null:
		events[eventName].stop(stop_mode)
	
func set_parameter(eventName, parameter_name, value):
	
	if !events.has(eventName):
		return
	
	if events[eventName] != null:
		events[eventName].set_parameter_by_name(parameter_name, value)
		
func set_global_parameter(parameter_name, value):
	FmodServer.set_global_parameter_by_name(parameter_name, value)

func pause():
	FmodServer.pause_all_events()
	
func unpause():
	FmodServer.unpause_all_events()
	
func stop_all(stop_mode = 0):
	stop_bgm()
	for event_name in events.keys():
		print("stopped " + event_name)
		stop_event(event_name, stop_mode)
		
func suppress_bgm(suppress):
	
	if suppress:
		stop_non_one_shots()
		if suppress_snapshot != null:
			if suppress_snapshot.get_playback_state() == FmodServer.FMOD_STUDIO_PLAYBACK_PLAYING:
				return
		suppress_snapshot = FmodServer.create_event_instance("snapshot:/Suppress")
		suppress_snapshot.start()
	else:
		if suppress_snapshot != null:
			if suppress_snapshot.get_playback_state() != FmodServer.FMOD_STUDIO_PLAYBACK_PLAYING:
				return
		suppress_snapshot.stop(0)
		
func stop_non_one_shots(stop_mode = 0):
	for event_name in events.keys():
		print("stopped " + event_name)
		stop_event(event_name, stop_mode)
		
