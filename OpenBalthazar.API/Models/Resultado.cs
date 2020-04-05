﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace OpenBalthazar.API.Models
{
    public class Resultado
    {
        public int LineNumber { get; set; }
        public string RuleName { get; set; }
        public string RuleError { get; set; }
        public string Severity { get; set; }

        public Resultado(int line, string rule, string error, string severity)
        {
            LineNumber = line;
            RuleName = rule;
            RuleError = error;
            Severity = severity;
        }
    }
}
