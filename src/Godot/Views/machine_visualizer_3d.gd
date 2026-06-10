extends Node3D
class_name MachineVisualizer3D

@export var work_mesh: MeshInstance3D
@export var status_label: Label3D
@export var rotation_speed_degrees_per_second: float = 90.0

var machine: SimulationMachineHandle


func _process(delta: float) -> void:
	if machine == null:
		return

	if status_label:
		status_label.text = (
			"State: [%s] - Progress: %.0f%%"
			% [machine.state_label, machine.processing_progress_percent]
		)

	if machine.is_running and work_mesh:
		work_mesh.rotation_degrees.y += rotation_speed_degrees_per_second * delta
