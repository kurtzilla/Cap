namespace Cap.Core.Simulation;

public class SimulationClock
{
    public long CurrentTick { get; private set; }

    public event Action<long>? OnTickBroadcast;

    public void StepSimulation()
    {
        CurrentTick++;
        OnTickBroadcast?.Invoke(CurrentTick);
    }
}
