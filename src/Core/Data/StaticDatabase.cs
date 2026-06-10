namespace Cap.Core.Data;

public static class StaticDatabase
{
    public static readonly IReadOnlyDictionary<string, ItemDefinition> Items =
        new Dictionary<string, ItemDefinition>
        {
            ["IronOre"] = new("IronOre", "Iron Ore", CargoType.BulkSolid),
            ["IronPlate"] = new("IronPlate", "Iron Plate", CargoType.BulkSolid),
        };

    public static readonly IReadOnlyDictionary<string, RecipeDefinition> Recipes =
        new Dictionary<string, RecipeDefinition>
        {
            ["SmeltIron"] = new(
                RecipeId: "SmeltIron",
                Inputs: [new ItemStack("IronOre", 2)],
                Outputs: [new ItemStack("IronPlate", 1)],
                DurationInTicks: 20),
        };
}
