using Antlr4.Runtime;
using Antlr4.Runtime.Tree;
using Antlr4.Runtime.Tree.Pattern;
using OpenBalthazar.API.Core;
using OpenBalthazar.API.Solidity.g4;
using System;
using System.Collections.Generic;
using System.Text;

namespace OpenBalthazar.API.Solidity.Rules
{
    public class EqualsBalanceRule : ILanguageRule
    {
        public EqualsBalanceRule(ILanguage parent)
        {
            Parent = parent;
        }

        public string Name
        {
            get
            {
                string name = string.Empty;
                switch (Parent.Language)
                {
                    case Language.Spanish:
                        name = "EqualsBalanceRule";
                        break;
                    case Language.Portugues:
                        name = "EqualsBalanceRule";
                        break;
                    case Language.English:
                    default:
                        name = "EqualsBalanceRule";
                        break;
                }
                return name;
            }
        }

        public ILanguage Parent { get; private set; }

        public Severity Severity
        {
            get { return Severity.Warning; }
        }

        public string Error
        {
            get
            {
                string error = string.Empty;
                switch (Parent.Language)
                {
                    case Language.Spanish:
                        error = "Evite usar tx.origin";
                        break;
                    case Language.Portugues:
                        error = "Noa use tx.origin";
                        break;
                    case Language.English:
                    default:
                        error = "Avoid use tx.origin";
                        break;
                }
                return error;
            }
        }

        public IList<int> Lines { get; } = new List<int>();

        /// <summary>
        /// Metodo que verifica el patron de codigo <tx><.><origin>
        /// </summary>
        /// <returns>true si el proceso se completo con exito, de otra manera false.</returns>
        public bool Scan()
        {
            bool resultado = true;

            try
            {
                AntlrInputStream inputStream = new AntlrInputStream(Parent.Code);
                SolidityLexer solidityLexer = new SolidityLexer(inputStream);
                CommonTokenStream commonTokenStream = new CommonTokenStream(solidityLexer);
                SolidityParser solidityParser = new SolidityParser(commonTokenStream);

                IParseTree tree = solidityParser.sourceUnit();

                // <expression>
                ParseTreePattern pattern = solidityParser.CompileParseTreePattern("this.balance (== | !=) <expression>", SolidityParser.RULE_expression);
                IList<ParseTreeMatch> matches = pattern.FindAll(tree, "//expression");

                // Por cada "tx.origin" detectada, debo obtener la linea de codigo donde se identifico
                foreach (ParseTreeMatch match in matches)
                {
                    if (match.Tree is ParserRuleContext)
                    {
                        Lines.Add(((ParserRuleContext)match.Tree).Start.Line);
                    }
                }
            }
            catch (Exception ex)
            {
                resultado = false;
            }

            return resultado;
        }
    }
}
