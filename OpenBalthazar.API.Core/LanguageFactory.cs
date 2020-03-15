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

        public static ILanguage GetInstance(string root, string ext)
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
            }

            return language;
        }
    }
}
