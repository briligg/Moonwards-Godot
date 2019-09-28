extends Tabs

const modes : Array = [
	"Windowed",
	"Borderless",
	"Fullscreen"
	]
	
onready var Quality : MenuButton = $Main/Row3/Video/ModelQuality/Quality
onready var Resolution : MenuButton = $Main/Row3/Video/Resolution/Resolution
onready var UpdateCheck : CheckBox = $Main/Row1/Updating/UpdateCheck
onready var FPSSlider : HSlider = $Main/Row3/Video/FPSLimit/FPSSlider
onready var FPSSpin : SpinBox = $Main/Row3/Video/FPSLimit/FPSSpin
onready var ScreenMode : MenuButton =  $Main/Row3/Video/Resolution/ScreenMode

var resolutions : Array = [
	Vector2(640, 480),
	Vector2(800, 600),
	Vector2(960, 720),
	Vector2(1024, 576),
	Vector2(1152, 648),
	Vector2(1280, 720),
	Vector2(1366, 768),
	Vector2(1600, 900),
	Vector2(1920, 1080),
	Vector2(2560, 1440)
	]
var current_resolution : int = -1
var current_mode : int = 0

func _ready() -> void:
	Resolution.get_popup().connect("id_pressed", self, "_on_Resolution_change")
	ScreenMode.get_popup().connect("id_pressed", self, "_on_ScreenMode_change")
	Quality.get_popup().connect("id_pressed", self, "_on_Detail_change")
	UpdateCheck.pressed = options.get("updater/client", "check_at_startup", true)
	
	var res_width = options.get("resolution", "width", resolutions[current_resolution].x)
	var res_height = options.get("resolution", "height", resolutions[current_resolution].y)
	var mode = options.get("resolution", "mode", "Windowed")
	
	for mode_index in modes.size():
		if modes[mode_index] == mode:
			current_mode = mode_index
	
	for resolution_index in resolutions.size():
		var resolution = resolutions[resolution_index]
		Resolution.get_popup().add_item(str(resolution.x, " x ", resolution.y))
		if resolution.x == res_width and resolution.y == res_height:
			current_resolution = resolution_index
	
	if current_resolution == -1:
		Resolution.get_popup().add_item(str(OS.window_size.x, " x ", OS.window_size.y))
		resolutions.append(OS.window_size)
		current_resolution = resolutions.size() - 1
	
	ScreenMode.text = mode
	Resolution.text = Resolution.get_popup().get_item_text(current_resolution)

func _on_Detail_change(id : int) -> void:
	Quality.text = Quality.get_popup().get_item_text(id)

func _on_Resolution_change(id : int) -> void:
	
	current_resolution = id
	Resolution.text = Resolution.get_popup().get_item_text(current_resolution)
	options.set("resolution", resolutions[current_resolution].x, "width")
	options.set("resolution", resolutions[current_resolution].y, "height")
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	options.load_graphics_settings()
	options.save()
	
func _on_UpdateCheck_pressed() -> void:
	if UpdateCheck.pressed:
		options.set("updater/client", true, "check_at_startup")
	else:
		options.set("updater/client", false, "check_at_startup")

func _on_ScreenMode_change(id : int) -> void:
	
	options.set("resolution", modes[id], "mode")
	ScreenMode.text = modes[id]
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	options.load_graphics_settings()
	options.save()

func _on_FPSSpin_value_changed(value : int) -> void:
	FPSSlider.value = value


func _on_FPSSlider_value_changed(value : int) -> void:
	FPSSpin.value = value