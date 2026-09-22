using Autodesk.Revit.UI;
using RevitAddin.Commands;

namespace RevitAddin;

/// <summary>
///     Plugin entry point: creates a tab/panel on the Revit ribbon.
/// </summary>
public class Application : IExternalApplication
{
    public Result OnStartup(UIControlledApplication application)
    {
        ArgumentNullException.ThrowIfNull(application);
        CreateRibbonPanel(application);
        return Result.Succeeded;
    }

    public Result OnShutdown(UIControlledApplication application)
    {
        return Result.Succeeded;
    }

    private static void CreateRibbonPanel(UIControlledApplication application)
    {
        var panel = application.CreateRibbonPanel("RevitAddin");

        using var buttonData = new PushButtonData(
            nameof(HelloCommand),
            "Hello",
            typeof(Application).Assembly.Location,
            typeof(HelloCommand).FullName);

        panel.AddItem(buttonData);
    }
}
