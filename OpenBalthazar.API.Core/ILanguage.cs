using System;
using System.Collections.Generic;
using System.Text;

namespace OpenBalthazar.API.Core
{
    public interface ILanguage
    {
        string Name { get; }
        Language Language { get; set; }
        string Code { get; set; }
        bool Scan();
        IList<ILanguageRule> Rules { get; }
    }

    public enum Language
    {
        Spanish,
        English,
        Portugues
    }
}
