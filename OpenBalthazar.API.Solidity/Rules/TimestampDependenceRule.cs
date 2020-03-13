﻿using Antlr4.Runtime;
using Antlr4.Runtime.Tree;
using Antlr4.Runtime.Tree.Pattern;
using OpenBalthazar.API.Core;
using OpenBalthazar.API.Solidity.g4;
using System;
using System.Collections.Generic;
using System.Text;

namespace OpenBalthazar.API.Solidity.Rules
{
    /// <summary>
    /// Cheque la regla que verifica la existencia de los identificadores <tx><.><origin>
    /// La regla debe controlar en las sentencias (por ejemplo require(tx.origin == owner))
    /// o en las estructuras condicionales como if(msg.sender == tx.origin)
    /// </summary>
    public class TimestampDependenceRule : ILanguageRule
    {
        /// <summary>
        /// Variable privada donde se almacenan las lineas del codigo fuente donde se encuentran los patrones detectados
        /// </summary>
        private IList<int> lines = new List<int>();

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
                        error = "Evite usar el alias now";
                        break;
                    case Language.Portugues:
                        error = "Noa use now";
                        break;
                    case Language.English:
                    default:
                        error = "Avoid use now alias";
                        break;
                }
                return error;
            }
        }

        public IList<int> Lines
        {
            get { return lines; }
        }

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
                ParseTreePattern pattern = solidityParser.CompileParseTreePattern("now", SolidityParser.RULE_expression);
                IList<ParseTreeMatch> matches = pattern.FindAll(tree, "//expression");

                // Por cada "tx.origin" detectada, debo obtener la linea de codigo donde se identifico
                foreach (ParseTreeMatch match in matches)
                {
                    if (match.Tree is ParserRuleContext)
                    {
                        lines.Add(((ParserRuleContext)match.Tree).Start.Line);
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
