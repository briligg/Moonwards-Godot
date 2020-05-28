extends Reference
class_name ResourceSignals

const name = "Resources"

# To be used with the queue based resource manager
const RESOURCE_REQUESTED: String = "resource_requested"
signal resource_requested

const RESOURCE_LOADED: String = "resource_loaded"
signal resource_loaded(resource, res_name)

const LOADING_PROGRESSED: String = "loading_progressed"
signal loading_progressed(progress)
