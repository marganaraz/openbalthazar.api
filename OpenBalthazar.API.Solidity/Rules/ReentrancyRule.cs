﻿using Antlr4.Runtime;
using Antlr4.Runtime.Tree;
using Antlr4.Runtime.Tree.Pattern;
using OpenBalthazar.API.Core;
using OpenBalthazar.API.Solidity.g4;
using System;
using System.Collections.Generic;
using System.Text;
using static OpenBalthazar.API.Solidity.g4.SolidityParser;

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
                Lines.Clear();

                AntlrInputStream inputStream = new AntlrInputStream(Parent.Code);
                SolidityLexer solidityLexer = new SolidityLexer(inputStream);
                CommonTokenStream commonTokenStream = new CommonTokenStream(solidityLexer);
                SolidityParser solidityParser = new SolidityParser(commonTokenStream);

                IParseTree tree = solidityParser.sourceUnit();

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

                // expression -> <expression>.<identifier>(<functionCallArguments>)
                ParseTreePattern pattern = solidityParser.CompileParseTreePattern("<expression>.<identifier>(<functionCallArguments>)", SolidityParser.RULE_expression);
                IList<ParseTreeMatch> matches = pattern.FindAll(tree, "//expression");

                foreach (ParseTreeMatch match in matches)
                {
                    // 
                    if(match.Get("identifier").GetText().Equals("send") || match.Get("identifier").GetText().Equals("transfer") || (match.Get("identifier").GetText().Equals("value") && match.Get("expression").GetText().EndsWith("call")))
                    {
                        IParseTree parentTree = match.Tree;
                        //if (match.Tree is ParserRuleContext)
                        //{
                        //    Lines.Add(((ParserRuleContext)match.Tree).Start.Line);
                        //}

                        // Tengo que decidir sobre que nodo trabajar!
                        //if(match.Tree.Parent is IfStatementContext)
                        //{
                        //    // Si es un IF solo tengo que tomar el STATEMENT por TRUE
                        //    parentTree = match.Tree.Parent.GetChild(4);
                        //    // Para que no me tome los ifs
                        //    //break;
                        //}
                        //else
                        //{
                            IParseTree parentTreeNode = match.Tree.Parent;
                            while(parentTreeNode is ExpressionContext)
                            {
                                parentTreeNode = parentTreeNode.Parent;
                            }
                            string type = parentTreeNode.GetType().ToString();
                            string parentType = parentTreeNode.Parent.GetType().ToString();

                            if (parentTreeNode is IfStatementContext)
                            {
                                parentTree = parentTreeNode.GetChild(4);
                            }
                            else if (parentTreeNode.Parent is SimpleStatementContext)
                            {
                                IParseTree parseTreeSimple = parentTreeNode.Parent;
                                while (parseTreeSimple is SimpleStatementContext || parseTreeSimple is StatementContext)
                                {
                                    parseTreeSimple = parseTreeSimple.Parent;
                                }

                                parentTree = parseTreeSimple;
                                string tyy = parentTree.GetType().ToString();
                            }
                        //}


                        ParseTreePattern patternAsignacion = solidityParser.CompileParseTreePattern("<expression> = <expression>", SolidityParser.RULE_expression);
                        IList<ParseTreeMatch> matches2 = patternAsignacion.FindAll(parentTree, "//expression");

                        foreach (ParseTreeMatch match2 in matches2)
                        {
                            if(match2.Tree is ParserRuleContext)
                            {
                                int math2Line = ((ParserRuleContext)match2.Tree).Start.Line;
                                int mathLine = ((ParserRuleContext)match.Tree).Start.Line;

                                if (math2Line > mathLine)
                                {
                                    Lines.Add(((ParserRuleContext)match2.Tree).Start.Line);
                                }
                            }
                            
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
