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
    /// <summary>
    /// Chequea la regla que verifica la existencia de los identificadores <tx><.><origin>
    /// La regla debe controlar en las sentencias (por ejemplo require(tx.origin == owner))
    /// o en las estructuras condicionales como if(msg.sender == tx.origin)
    /// </summary>
    public class ReentrancyRule : ILanguageRule
    {
        public ReentrancyRule(ILanguage parent)
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
                        name = "ReentrancyRule";
                        break;
                    case Language.Portugues:
                        name = "ReentrancyRule";
                        break;
                    case Language.English:
                    default:
                        name = "ReentrancyRule";
                        break;
                }
                return name;
            }
        }

        public ILanguage Parent { get; private set; }

        public Severity Severity
        {
            get { return Severity.Error; }
        }

        public string Error
        {
            get
            {
                string error = string.Empty;
                switch (Parent.Language)
                {
                    case Language.Spanish:
                        error = "Evite usar call";
                        break;
                    case Language.Portugues:
                        error = "Noa use call";
                        break;
                    case Language.English:
                    default:
                        error = "Avoid use call";
                        break;
                }
                return error;
            }
        }

        public IList<int> Lines { get; set; } = new List<int>();

        /// <summary>
        /// Metodo que verifica el patron de codigo <tx><.><origin>
        /// </summary>
        /// <returns>true si el proceso se completo con exito, de otra manera false.</returns>
        public bool Scan()
        {
            bool resultado = true;

            try
            {
                Lines = new List<int>();
                AntlrInputStream inputStream = new AntlrInputStream(Parent.Code);
                SolidityLexer solidityLexer = new SolidityLexer(inputStream);
                CommonTokenStream commonTokenStream = new CommonTokenStream(solidityLexer);
                SolidityParser solidityParser = new SolidityParser(commonTokenStream);

                IParseTree tree = solidityParser.sourceUnit();

                string treestring = tree.ToStringTree();
                Console.Error.Write(treestring);


                // <expression>
                //blockStatement/*/
                /// prog / func, -> all funcs under prog at root
                //    / prog/*, -> all children of prog at root
                //    /*/func, -> all func kids of any root node
                //    prog, -> prog must be root node
                //    / prog, -> prog must be root node
                //     /*, -> any root
                //     *, -> any root
                //     //ID, -> any ID in tree
                //     //expr/primary/ID, -> any ID child of a primary under any expr
                //     //body//ID, -> any ID under a body
                //     //'return', -> any 'return' literal in tree
                //     //primary/*, -> all kids of any primary
                //     //func/*/stat, -> all stat nodes grandkids of any func node
                //    / prog / func / 'def', -> all def literal kids of func kid of prog
                //         //stat/';', -> all ';' under any stat node
                //         //expr/primary/!ID, -> anything but ID under primary under any expr node
                //         //expr/!primary, -> anything but primary under any expr node
                //         //!*, -> nothing anywhere
                //         / !*, -> nothing at root

                // expression -> <expression>.call.value(<functionCallArguments>)
                ParseTreePattern pattern = solidityParser.CompileParseTreePattern("<expression>.<identifier>(<functionCallArguments>)", SolidityParser.RULE_expression);
                IList<ParseTreeMatch> matches = pattern.FindAll(tree, "//expression");

                //Console.Write(pattern.ToString());

                // Por cada "tx.origin" detectada, debo obtener la linea de codigo donde se identifico
                foreach (ParseTreeMatch match in matches)
                {
                    // Llamo a la funcion que contiene la sentencia
                    //IParseTree parent = match.Tree.Parent.Parent;

                    //ParseTreePattern patternAsignacion = solidityParser.CompileParseTreePattern("<expression> = <expression>", SolidityParser.RULE_expression);
                    //IList<ParseTreeMatch> matches2 = patternAsignacion.FindAll(parent, "//expression");

                if(match.Get("identifier").GetText().Equals("send") || match.Get("identifier").GetText().Equals("value"))
                    {
                        if (match.Tree is ParserRuleContext)
                        {
                            Lines.Add(((ParserRuleContext)match.Tree).Start.Line);
                        }
                    }
                }

                // Despues de encontrar un match debe ver si hay una asignacion
            }
            catch (Exception ex)
            {
                resultado = false;
            }

            return resultado;
        }
    }
}
