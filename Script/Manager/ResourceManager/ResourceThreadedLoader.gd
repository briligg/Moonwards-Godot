extends Node
class_name ResourceThreadedLoader

signal finished_loading(res)
signal _thread_finished

onready var thread: Thread 
onready var mutex: Mutex 

var _debug: bool = true

var loader
var res_path: String

func _init(path: String):
	loader = ResourceLoader.load_interactive(path)
	res_path = path

func get_scene() -> PackedScene:
	return loader.get_resource()
	
func load_async():
	thread = Thread.new()
	thread.start(self, "_load_threaded")

	yield(self, "_thread_finished")
	thread.wait_to_finish()
	
	var res = loader.get_resource()
	emit_signal("finished_loading", res)
	self.queue_free()
	
func _load_threaded(_userdata):
	_process_load()

func _process_load():
	while true:
		var err = loader.poll()
		if err == OK:
			Signals.Resources.call_deferred("emit_signal", 
					Signals.Resources.LOADING_PROGRESSED,
					float(loader.get_stage()) / loader.get_stage_count() * 100)
			if _debug:
				print(float(loader.get_stage()) / loader.get_stage_count() * 100)
		elif err == ERR_FILE_EOF: # Finished loading.
			call_deferred("emit_signal", "_thread_finished")
			print("Loaded file %s" %res_path)			
			break
		else: # error during loading
#			show_error()
			print("Load Thread error %s" %err)
			break


func _exit_tree():
	# Wait until it exits.
	# Thread must be joined, for portability.
	thread.wait_to_finish()
