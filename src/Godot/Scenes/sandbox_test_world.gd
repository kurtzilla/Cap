extends Node3D


func _ready() -> void:
	_setup_scene_lighting()

	var machine: SimulationMachineHandle = GodotTickDriver.create_machine("SmeltIron")
	machine.try_inject_input("IronOre", 50)

	var visualizer := _build_machine_visualizer(machine)
	add_child(visualizer)


func _setup_scene_lighting() -> void:
	var camera := Camera3D.new()
	camera.position = Vector3(4.0, 3.0, 6.0)
	camera.look_at(Vector3.ZERO)
	add_child(camera)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45.0, 45.0, 0.0)
	add_child(sun)


func _build_machine_visualizer(machine: SimulationMachineHandle) -> MachineVisualizer3D:
	var visualizer := MachineVisualizer3D.new()
	visualizer.machine = machine

	var work_mesh := MeshInstance3D.new()
	work_mesh.mesh = BoxMesh.new()
	work_mesh.mesh.size = Vector3(1.5, 1.0, 1.5)
	visualizer.add_child(work_mesh)
	visualizer.work_mesh = work_mesh

	var status_label := Label3D.new()
	status_label.text = "State: [Idle] - Progress: 0%"
	status_label.position = Vector3(0.0, 2.0, 0.0)
	status_label.pixel_size = 0.01
	status_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	visualizer.add_child(status_label)
	visualizer.status_label = status_label

	return visualizer
