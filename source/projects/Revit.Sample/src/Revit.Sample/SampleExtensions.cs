using Autodesk.Revit.DB;

namespace Revit.Sample;

/// <summary>
///     TODO: replace with the library's real API.
/// </summary>
public static class SampleExtensions
{
    /// <summary>
    ///     Example extension method over the Revit API.
    /// </summary>
    public static bool TryGetName(this Element element, out string? name)
    {
#if NET6_0_OR_GREATER
        ArgumentNullException.ThrowIfNull(element);
#else
        if (element is null) throw new ArgumentNullException(nameof(element));
#endif
        name = element.Name;
        return !string.IsNullOrEmpty(name);
    }
}
