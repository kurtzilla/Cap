extends Camera3D

const MIN_DISTANCE := 4.0
const MAX_DISTANCE := 24.0
const DEFAULT_DISTANCE := 8.0
const DEFAULT_ORBIT_TARGET := Vector3(0.0, 0.5, 0.0)
const DEFAULT_YAW := deg_to_rad(40.0)
const DEFAULT_PITCH := deg_to_rad(-28.0)
const ZOOM_STEP := 1.0
const PAN_SPEED := 10.0
const ROTATE_SPEED := deg_to_rad(90.0)
const MOUSE_PAN_SENSITIVITY := 0.01

var _orbit_target := DEFAULT_ORBIT_TARGET
var _distance := DEFAULT_DISTANCE
var _yaw := DEFAULT_YAW
var _pitch := DEFAULT_PITCH


func _ready() -> void:
	current = true
	_update_transform()


func _process(delta: float) -> void:
	var changed := false

	var pan_input := Input.get_vector(
		"camera_pan_left",
		"camera_pan_right",
		"camera_pan_forward",
		"camera_pan_back"
	)
	if pan_input != Vector2.ZERO:
		var ground_axes := _ground_basis_vectors()
		var forward: Vector3 = ground_axes[0]
		var right: Vector3 = ground_axes[1]
		var pan_scale := _distance / DEFAULT_DISTANCE
		_orbit_target += (forward * pan_input.y + right * pan_input.x) * PAN_SPEED * pan_scale * delta
		changed = true

	if Input.is_action_pressed("camera_rotate_left"):
		_yaw += ROTATE_SPEED * delta
		changed = true
	elif Input.is_action_pressed("camera_rotate_right"):
		_yaw -= ROTATE_SPEED * delta
		changed = true

	if changed:
		_update_transform()


func reset_to_default() -> void:
	_orbit_target = DEFAULT_ORBIT_TARGET
	_distance = DEFAULT_DISTANCE
	_yaw = DEFAULT_YAW
	_pitch = DEFAULT_PITCH
	_update_transform()


func _unhandled_key_input(event: InputEvent) -> void:
	if _is_camera_reset_pressed(event):
		reset_to_default()
		get_viewport().set_input_as_handled()


func _is_camera_reset_pressed(event: InputEvent) -> bool:
	if event.is_action_pressed("camera_reset_view"):
		return true
	if not event is InputEventKey:
		return false
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo or not key_event.ctrl_pressed:
		return false
	return key_event.physical_keycode in [KEY_HOME, KEY_PAGEUP] or key_event.keycode in [KEY_HOME, KEY_PAGEUP]


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		if button_event.pressed:
			if button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_distance = maxf(MIN_DISTANCE, _distance - ZOOM_STEP)
				_update_transform()
			elif button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_distance = minf(MAX_DISTANCE, _distance + ZOOM_STEP)
				_update_transform()
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var motion_event := event as InputEventMouseMotion
		var ground_axes := _ground_basis_vectors()
		var right: Vector3 = ground_axes[1]
		var forward: Vector3 = ground_axes[0]
		var pan_scale := _distance * MOUSE_PAN_SENSITIVITY
		_orbit_target -= (
			right * motion_event.relative.x + forward * motion_event.relative.y
		) * pan_scale
		_update_transform()


func _ground_basis_vectors() -> Array[Vector3]:
	var forward := Vector3(sin(_yaw), 0.0, cos(_yaw))
	var right := Vector3(cos(_yaw), 0.0, -sin(_yaw))
	return [forward, right]


func _update_transform() -> void:
	var offset := Vector3(
		cos(_pitch) * sin(_yaw),
		-sin(_pitch),
		cos(_pitch) * cos(_yaw)
	) * _distance
	position = _orbit_target + offset
	look_at(_orbit_target, Vector3.UP)
