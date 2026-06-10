using Cap.Core.Data;

namespace Cap.Core.Simulation.Entities;

public enum MachineOperationalState
{
    Idle,
    LoadingMaterials,
    Running,
    OutputBlocked
}

public sealed class SimulationMachine : ITickable
{
    private readonly Dictionary<string, int> _inputBuffer = new();
    private readonly Dictionary<string, int> _outputBuffer = new();
    private int _currentProgressTicks;

    public RecipeDefinition? Recipe { get; set; }

    public MachineOperationalState State { get; private set; } = MachineOperationalState.Idle;

    public float ProcessingProgressPercent =>
        Recipe is { DurationInTicks: > 0 }
            ? (float)_currentProgressTicks / Recipe.DurationInTicks * 100f
            : 0f;

    public IReadOnlyDictionary<string, int> InputBuffer => _inputBuffer;

    public IReadOnlyDictionary<string, int> OutputBuffer => _outputBuffer;

    public void OnTick(long currentTick)
    {
        switch (State)
        {
            case MachineOperationalState.Idle:
            case MachineOperationalState.LoadingMaterials:
                TryStartProcessing();
                break;

            case MachineOperationalState.Running:
                AdvanceProcessing();
                break;

            case MachineOperationalState.OutputBlocked:
                break;
        }
    }

    public bool TryInjectInput(string itemId, int count)
    {
        if (count <= 0 || Recipe is null || State == MachineOperationalState.Running)
            return false;

        if (!IsRecipeInput(itemId))
            return false;

        _inputBuffer.TryGetValue(itemId, out var current);
        _inputBuffer[itemId] = current + count;

        if (State == MachineOperationalState.Idle && !HasSufficientInputs())
            State = MachineOperationalState.LoadingMaterials;

        return true;
    }

    public bool TryExtractOutput(string itemId, int count, out int extractedCount)
    {
        extractedCount = 0;

        if (count <= 0 || !_outputBuffer.TryGetValue(itemId, out var available) || available <= 0)
            return false;

        extractedCount = Math.Min(count, available);
        var remaining = available - extractedCount;

        if (remaining <= 0)
            _outputBuffer.Remove(itemId);
        else
            _outputBuffer[itemId] = remaining;

        if (State == MachineOperationalState.OutputBlocked && !HasAnyOutput())
            State = MachineOperationalState.Idle;

        return extractedCount > 0;
    }

    private void TryStartProcessing()
    {
        if (Recipe is null || !HasSufficientInputs())
        {
            if (Recipe is not null && State == MachineOperationalState.Idle)
                State = MachineOperationalState.LoadingMaterials;

            return;
        }

        ConsumeInputs();
        _currentProgressTicks = 0;
        State = MachineOperationalState.Running;
    }

    private void AdvanceProcessing()
    {
        if (Recipe is null)
        {
            State = MachineOperationalState.Idle;
            return;
        }

        _currentProgressTicks++;

        if (_currentProgressTicks < Recipe.DurationInTicks)
            return;

        foreach (var output in Recipe.Outputs)
        {
            _outputBuffer.TryGetValue(output.ItemId, out var current);
            _outputBuffer[output.ItemId] = current + output.Amount;
        }

        _currentProgressTicks = 0;
        State = MachineOperationalState.OutputBlocked;
    }

    private bool HasSufficientInputs()
    {
        if (Recipe is null)
            return false;

        foreach (var input in Recipe.Inputs)
        {
            if (!_inputBuffer.TryGetValue(input.ItemId, out var amount) || amount < input.Amount)
                return false;
        }

        return true;
    }

    private void ConsumeInputs()
    {
        if (Recipe is null)
            return;

        foreach (var input in Recipe.Inputs)
        {
            _inputBuffer[input.ItemId] -= input.Amount;

            if (_inputBuffer[input.ItemId] <= 0)
                _inputBuffer.Remove(input.ItemId);
        }
    }

    private bool IsRecipeInput(string itemId)
    {
        if (Recipe is null)
            return false;

        foreach (var input in Recipe.Inputs)
        {
            if (input.ItemId == itemId)
                return true;
        }

        return false;
    }

    private bool HasAnyOutput()
    {
        foreach (var _ in _outputBuffer.Values)
            return true;

        return false;
    }
}
