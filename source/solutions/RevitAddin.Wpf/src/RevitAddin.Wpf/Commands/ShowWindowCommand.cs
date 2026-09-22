using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using RevitAddin.Wpf.ViewModels;
using RevitAddin.Wpf.Views;

namespace RevitAddin.Wpf.Commands;

[Transaction(TransactionMode.Manual)]
public class ShowWindowCommand : IExternalCommand
{
    public Result Execute(ExternalCommandData commandData, ref string message, ElementSet elements)
    {
        var viewModel = new MainWindowViewModel();
        var window = new MainWindow { DataContext = viewModel };
        window.Show();

        return Result.Succeeded;
    }
}
