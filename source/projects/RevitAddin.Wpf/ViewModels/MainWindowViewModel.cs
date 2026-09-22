using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;

namespace RevitAddin.Wpf.ViewModels;

public partial class MainWindowViewModel : ObservableObject
{
    [ObservableProperty]
    private string _greeting = "RevitAddin.Wpf started";

    [RelayCommand]
    private void Refresh()
    {
        Greeting = $"Updated: {DateTime.Now:T}";
    }
}
