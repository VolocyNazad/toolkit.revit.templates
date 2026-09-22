using Autodesk.Revit.UI;
using RevitAddin.Wpf.Commands;

namespace RevitAddin.Wpf;

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
        var panel = application.CreateRibbonPanel("RevitAddin.Wpf");

        using var buttonData = new PushButtonData(
            nameof(ShowWindowCommand),
            "Show\nWindow",
            typeof(Application).Assembly.Location,
            typeof(ShowWindowCommand).FullName);

        panel.AddItem(buttonData);
    }
}
