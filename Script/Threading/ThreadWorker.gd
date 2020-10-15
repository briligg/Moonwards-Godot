extends Node
class_name ThreadWorker

var counter = 0
var mutex
var semaphore
var thread
var exit_thread = false

var _work_queue = []

# The thread will start here.
func _ready():
	mutex = Mutex.new()
	semaphore = Semaphore.new()
	exit_thread = false

	thread = Thread.new()
	thread.start(self, "_thread_function")

func queue_thread_work(fref: FuncRef):
	mutex.lock()
	_work_queue.append(fref)
	mutex.unlock()
	semaphore.post()

func _thread_function(userdata):
	while true:
		semaphore.wait() # Wait until posted.

		mutex.lock()
		var should_exit = exit_thread # Protect with Mutex.
		mutex.unlock()

		if should_exit:
			break

		mutex.lock()
		for fref in _work_queue:
			fref.call_func()
		_work_queue.clear()
		mutex.unlock()

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	if !thread.is_active():
		return
	# Set exit condition to true.
	mutex.lock()
	exit_thread = true # Protect with Mutex.
	mutex.unlock()

	# Unblock by posting.
	semaphore.post()

	# Wait until it exits.
	thread.wait_to_finish()

	# Print the counter.
	print("Counter is: ", counter)
