using OpenBalthazar.API.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;

namespace OpenBalthazar.API.Core
{
    public class LanguageFactory
    {
        private static ILanguage language;

        public static ILanguage GetInstance(string root, string ext, string userLangs)
        {
            if(language == null)
            {
                string assembleName = string.Empty;
                string typeName = string.Empty;

                switch (ext)
                {
                    case "sol":
                        assembleName = "OpenBalthazar.API.Solidity.dll";
                        typeName = "OpenBalthazar.API.Solidity.Solidity";
                        break;

                    case "vy":
                        assembleName = "Vyper.dll";
                        typeName = "Vyper.Vyper";
                        break;
                    default:
                        assembleName = "OpenBalthazar.API.Solidity.dll";
                        typeName = "OpenBalthazar.API.Solidity.Solidity";
                        break;
                }

                Assembly assembly = Assembly.LoadFrom(root + assembleName);
                Type sol = assembly.GetType(typeName);

                language = Activator.CreateInstance(sol) as ILanguage;

                // Seteo el idioma que corresponde
                var firstLang = userLangs.Split(',').FirstOrDefault();
                var defaultLang = string.IsNullOrEmpty(firstLang) ? "en" : firstLang;

                Language idiomEnum = Language.English;

                if (defaultLang.ToLower().Contains("es"))
                {
                    idiomEnum = Language.Spanish;
                }
                else if (defaultLang.ToLower().Contains("en"))
                {
                    idiomEnum = Language.English;
                }
                else if (defaultLang.ToLower().Contains("pt"))
                {
                    idiomEnum = Language.Portugues;
                }

                language.Language = idiomEnum;
            }

            return language;
        }
    }
}
