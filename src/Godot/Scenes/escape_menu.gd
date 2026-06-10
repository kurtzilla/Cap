class_name EscapeMenu
extends CanvasLayer

signal opened
signal closed
signal quit_requested

@onready var _resume_button: Button = %ResumeButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_resume_button.pressed.connect(_on_resume_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)


func is_open() -> bool:
	return visible


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return

	if visible:
		_request_close()
	else:
		_request_open()

	get_viewport().set_input_as_handled()


func _request_open() -> void:
	visible = true
	_resume_button.grab_focus()
	opened.emit()


func _request_close() -> void:
	visible = false
	closed.emit()


func _on_resume_pressed() -> void:
	_request_close()


func _on_quit_pressed() -> void:
	quit_requested.emit()
