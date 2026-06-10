using Cap.Core.Data;
using Cap.Core.Simulation;
using Cap.Core.Simulation.Entities;
using Godot;

namespace Cap.Godot.CoreBridge;

/// <summary>
/// Autoload bridge that converts Godot's variable frame delta time into fixed Core simulation ticks.
/// </summary>
public partial class GodotTickDriver : Node
{
    private const float BaseSecondsPerTick = 0.1f;

    private readonly SimulationClock _simulationClock = new();
    private readonly List<ITickable> _tickables = [];
    private float _tickAccumulator;

    /// <summary>
    /// Real-time seconds between Core simulation steps. Default 0.1 s yields 10 ticks per second at 1x speed.
    /// </summary>
    [Export]
    public float SecondsPerTick { get; set; } = BaseSecondsPerTick;

    public SimulationClock SimulationClock => _simulationClock;

    public bool IsPaused { get; private set; }

    public override void _Ready()
    {
        _simulationClock.OnTickBroadcast += DispatchTickables;
    }

    public override void _ExitTree()
    {
        _simulationClock.OnTickBroadcast -= DispatchTickables;
    }

    public SimulationMachineHandle CreateMachine(string recipeId) =>
        CreateMachineInternal(recipeId);

    // Explicit snake_case entry point for GDScript interop.
    public SimulationMachineHandle create_machine(string recipeId) =>
        CreateMachineInternal(recipeId);

    private SimulationMachineHandle CreateMachineInternal(string recipeId)
    {
        var machine = new SimulationMachine
        {
            Recipe = StaticDatabase.Recipes[recipeId]
        };
        Register(machine);
        return new SimulationMachineHandle(machine);
    }

    public void Register(ITickable tickable)
    {
        if (!_tickables.Contains(tickable))
            _tickables.Add(tickable);
    }

    public void Unregister(ITickable tickable)
    {
        _tickables.Remove(tickable);
    }

    public override void _Process(double delta)
    {
        if (IsPaused)
        {
            return;
        }

        // Godot reports elapsed wall-clock time since the last frame. We accumulate that time until
        // it reaches one simulation step, then advance the Core clock and carry the remainder forward.
        // Multiple ticks can run in a single frame after a long hitch; leftover time is never discarded.
        _tickAccumulator += (float)delta;

        while (_tickAccumulator >= SecondsPerTick)
        {
            _tickAccumulator -= SecondsPerTick;
            _simulationClock.StepSimulation();
        }
    }

    public void Pause()
    {
        IsPaused = true;
    }

    public void SetSpeed1x()
    {
        IsPaused = false;
        SecondsPerTick = BaseSecondsPerTick;
    }

    public void SetSpeed2x()
    {
        IsPaused = false;
        SecondsPerTick = BaseSecondsPerTick / 2f;
    }

    public void SetSpeed4x()
    {
        IsPaused = false;
        SecondsPerTick = BaseSecondsPerTick / 4f;
    }

    private void DispatchTickables(long currentTick)
    {
        foreach (var tickable in _tickables)
            tickable.OnTick(currentTick);
    }
}
