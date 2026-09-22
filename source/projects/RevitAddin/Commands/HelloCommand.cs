using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;

namespace RevitAddin.Commands;

[Transaction(TransactionMode.Manual)]
public class HelloCommand : IExternalCommand
{
    public Result Execute(ExternalCommandData commandData, ref string message, ElementSet elements)
    {
        TaskDialog.Show("RevitAddin", "Hello from RevitAddin!");
        return Result.Succeeded;
    }
}
