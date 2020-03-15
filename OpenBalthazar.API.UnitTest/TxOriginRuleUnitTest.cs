using Microsoft.VisualStudio.TestTools.UnitTesting;
using OpenBalthazar.API.Core;
using OpenBalthazar.API.Solidity.Rules;
using System;

namespace OpenBalthazar.API.UnitTest
{
    [TestClass]
    public class TxOriginRuleUnitTest
    {

        [TestMethod]
        public void TxOriginRuleTestMethod()
        {
            // Obtengo el directorio de la app
            string currentDirectory = AppDomain.CurrentDomain.SetupInformation.ApplicationBase;
            
            // Obtengo el archivo para testear
            string file = System.IO.File.ReadAllText(currentDirectory + @"\Files\TxOriginRuleContract.sol");

            // Obtengo el motor de analisis
            ILanguage language = LanguageFactory.GetInstance(currentDirectory, "sol");

            // Seteo el codigo fuente
            language.Code = file;

            // Escaneo
            //language.Scan();
            
            // Por cada regla muestro los resultados
            int i = 0;
            foreach (ILanguageRule rule in language.Rules)
            {
                if(rule is TxOriginRule)
                {
                    foreach (int l in rule.Lines)
                    {
                        i++;
                    }
                }
               
            }

            Assert.IsTrue(i == 1);
        }
    }
}
