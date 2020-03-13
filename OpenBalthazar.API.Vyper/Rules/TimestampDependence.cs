using Antlr4.Runtime;
using Antlr4.Runtime.Tree;
using Antlr4.Runtime.Tree.Pattern;
using OpenBalthazar.API.Core;
using OpenBalthazar.API.Vyper.g4;
using System;
using System.Collections.Generic;

namespace OpenBalthazar.API.Vyper
{
    /// <summary>
    /// Cheque la regla que verifica la existencia de los identificadores <tx><.><origin>
    /// La regla debe controlar en las sentencias (por ejemplo require(tx.origin == owner))
    /// o en las estructuras condicionales como if(msg.sender == tx.origin)
    /// </summary>
    public class TimestampDependenceRule : ILanguageRule
    {
        public TimestampDependenceRule(ILanguage parent)
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
                        name = "TimestampDependenceRule";
                        break;
                    case Language.Portugues:
                        name = "TimestampDependenceRule";
                        break;
                    case Language.English:
                    default:
                        name = "TimestampDependenceRule";
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
                        error = "Evite usar block.timestamp";
                        break;
                    case Language.Portugues:
                        error = "Noa use block.timestamp";
                        break;
                    case Language.English:
                    default:
                        error = "Avoid use block.timestamp";
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
                ViperLexer vyperLexer = new ViperLexer(inputStream);
                CommonTokenStream commonTokenStream = new CommonTokenStream(vyperLexer);
                ViperParser vyperParser = new ViperParser(commonTokenStream);

                IParseTree tree = vyperParser.file_input();

                // <expression>
                ParseTreePattern pattern = vyperParser.CompileParseTreePattern("block.timestamp", ViperParser.RULE_expr);
                IList<ParseTreeMatch> matches = pattern.FindAll(tree, "//expr");

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
