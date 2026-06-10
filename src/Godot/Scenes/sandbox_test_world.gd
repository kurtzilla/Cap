extends Node3D

@onready var machine_root: Node3D = $MachineRoot
@onready var escape_menu = $EscapeMenu


func _ready() -> void:
	escape_menu.opened.connect(_pause_game)
	escape_menu.closed.connect(_resume_game)
	escape_menu.quit_requested.connect(_on_escape_menu_quit)

	var visualizer := _build_machine_visualizer()
	machine_root.add_child(visualizer)
	call_deferred("_wire_machine", visualizer)


func _pause_game() -> void:
	get_tree().paused = true
	GodotTickDriver.Pause()


func _resume_game() -> void:
	get_tree().paused = false
	GodotTickDriver.SetSpeed1x()


func _on_escape_menu_quit() -> void:
	get_tree().quit()


func _wire_machine(visualizer: MachineVisualizer3D) -> void:
	var machine: SimulationMachineHandle = GodotTickDriver.create_machine("SmeltIron")
	machine.try_inject_input("IronOre", 50)
	visualizer.machine = machine


func _build_machine_visualizer() -> MachineVisualizer3D:
	var visualizer := MachineVisualizer3D.new()
	visualizer.position = Vector3(0.0, 0.5, 0.0)

	var work_mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(1.5, 1.0, 1.5)
	work_mesh.mesh = box_mesh

	var work_material := StandardMaterial3D.new()
	work_material.albedo_color = Color(0.9, 0.45, 0.1)
	work_mesh.material_override = work_material

	visualizer.add_child(work_mesh)
	visualizer.work_mesh = work_mesh

	var status_label := Label3D.new()
	status_label.text = "State: [Idle] - Progress: 0%"
	status_label.position = Vector3(0.0, 1.2, 0.0)
	status_label.font_size = 32
	status_label.pixel_size = 0.02
	status_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	status_label.outline_size = 4
	visualizer.add_child(status_label)
	visualizer.status_label = status_label

	return visualizer
