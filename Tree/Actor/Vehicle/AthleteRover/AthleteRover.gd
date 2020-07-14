extends VehicleEntity

# Animation states, more can be added, used by the animation_controller
enum Anim_States {
	NONE,
	RAISE,
	LOWER,
	LIFT_LEG,
}
var anim_state: int = Anim_States.NONE

# used by the animation_controller
var wheels: Array = []


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	wheels = [
		$left_front_wheel,
		$left_mid_wheel,
		$left_back_wheel,
		$right_front_wheel,
		$right_mid_wheel,
		$right_back_wheel,
	]
	
	$RoverInput.connect("jump_pressed", $RoverMovement, "on_jump_pressed")
