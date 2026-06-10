using Cap.Core.Simulation.Entities;
using Godot;

namespace Cap.Godot.CoreBridge;

/// <summary>
/// Godot-facing wrapper that exposes Core machine state to GDScript visualizers.
/// </summary>
[GlobalClass]
public partial class SimulationMachineHandle : RefCounted
{
    private readonly SimulationMachine _machine;

    internal SimulationMachineHandle(SimulationMachine machine)
    {
        _machine = machine;
    }

    public int State => (int)_machine.State;

    public float ProcessingProgressPercent => _machine.ProcessingProgressPercent;

    public bool IsRunning => _machine.State == MachineOperationalState.Running;

    public string StateLabel => _machine.State switch
    {
        MachineOperationalState.Running => "Processing",
        _ => _machine.State.ToString()
    };

    public bool TryInjectInput(string itemId, int count) => _machine.TryInjectInput(itemId, count);
}
