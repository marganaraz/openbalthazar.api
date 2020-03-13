using System;
using System.Collections.Generic;
using System.Text;

namespace OpenBalthazar.API.Core
{
    public interface ILanguageRule
    {
        string Name { get; }
        Severity Severity { get; }
        string Error { get; }
        IList<int> Lines { get; }
        ILanguage Parent { get; }
        bool Scan();
    }

    public enum Severity
    {
        Info,
        Warning,
        Error
    }
}
