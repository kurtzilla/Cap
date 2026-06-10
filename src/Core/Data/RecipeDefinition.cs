namespace Cap.Core.Data;

public sealed record RecipeDefinition(
    string RecipeId,
    ItemStack[] Inputs,
    ItemStack[] Outputs,
    int DurationInTicks);
