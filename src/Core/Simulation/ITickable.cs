namespace Cap.Core.Simulation;

public interface ITickable
{
    void OnTick(long currentTick);
}
