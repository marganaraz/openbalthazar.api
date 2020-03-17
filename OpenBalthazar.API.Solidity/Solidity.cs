using System;
using System.Collections.Generic;
using OpenBalthazar.API.Core;
using OpenBalthazar.API.Solidity.Rules;

namespace OpenBalthazar.API.Solidity
{
    public class Solidity : ILanguage
    {
        private IList<ILanguageRule> rules = new List<ILanguageRule>();
        private bool initRules = false;

        public Solidity()
        {

        }

        public string Name
        {
            get { return "Solidity"; }
        }

        public Language Language { get; set; } = Language.English;

        public string Code { get; set; } = string.Empty;

        public bool Scan()
        {
            bool resultado = true;

            try
            {
                foreach (ILanguageRule rule in Rules)
                {
                    rule.Scan();
                }
            }
            catch (Exception ex)
            {
                resultado = false;
            }
            return resultado;
        }

        public IList<ILanguageRule> Rules
        {
            get
            {
                if (!initRules)
                {
                    // Agrego las reglas por defecto
                    //rules.Add(new TxOriginRule(this));

                    //rules.Add(new EqualsBalanceRule(this));

                    //rules.Add(new TimestampDependenceRule(this));

                    rules.Add(new ReentrancyRule(this));

                    initRules = true;
                }

                return rules;
            }
        }
    }
}
