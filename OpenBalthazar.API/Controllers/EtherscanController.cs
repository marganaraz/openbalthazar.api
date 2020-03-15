using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Etherscan;
using Etherscan.Models;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System.Text.Json;
using OpenBalthazar.API.Core;
using System.Text;

namespace OpenBalthazar.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class EtherscanController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private IHostingEnvironment _hostingEnvironment;

        public EtherscanController(IConfiguration configuration, IHostingEnvironment hostingEnvironment)
        {
            _configuration = configuration;
            _hostingEnvironment = hostingEnvironment;
        }

        [HttpGet("GetBalance")]
        public ActionResult GetBalance()
        {
            EtherscanClient client = new EtherscanClient(_configuration.GetSection("Etherscan.ApiKey").Value, _configuration.GetSection("Etherscan.URL").Value, _configuration.GetSection("Proxy").Value);

            return Ok(client.GetAccountBalance("0x8868f4E40773ecFFfbE78Aa3537e9f4c91221241"));
        }

        [HttpGet("scan")]
        public ActionResult Scan(string address)
        {
            // Armo la ruta completa al archivo
            string path = _hostingEnvironment.ContentRootPath + "/Files/Etherscan/" + address + ".sol";

            // Si el contrato no existe en disco, primero voy a leerlo a Etherscan
            if (!System.IO.File.Exists(path))
            {
                // Instancio el cliente de la API Etherscan
                EtherscanClient client = new EtherscanClient(_configuration.GetSection("Etherscan.ApiKey").Value, _configuration.GetSection("Etherscan.URL").Value, _configuration.GetSection("Proxy").Value);

                // Obtengo el resultado JSON
                List<EtherscanSmartContract> contratos = client.GetSmartContract(address);
                
                // Lo serializo
                var texto = JsonSerializer.Serialize(contratos);

                // Lo almaceno en disco
                System.IO.File.AppendAllText(path, texto);
            }

            // Leo el contrato de disco
            string smartContract = System.IO.File.ReadAllText(path);

            // Lo deserializo
            var result = JsonSerializer.Deserialize<List<EtherscanSmartContract>>(smartContract);

            // Lo analizo y retorno los resultados
            ILanguage language = LanguageFactory.GetInstance(_hostingEnvironment.ContentRootPath + "/bin/Debug/netcoreapp3.1/", "sol");

            language.Code = result[0].SourceCode;

            language.Scan();
            StringBuilder sb = new StringBuilder();
            List<Error> errores = new List<Error>();

            // Por cada regla muestro los resultados
            foreach (ILanguageRule rule in language.Rules)
            {
                foreach (int l in rule.Lines)
                {
                    errores.Add(new Error(l, rule.Error, rule.Name));
                    //sb.AppendFormat("<li><a href='#' onclick='mark({1} - 1)'>Line {1} - {2}</a>: {3}.</li>", l, rule.Name, rule.Error);
                }

                //if (rule.Lines.Count == 0) sb.AppendFormat("<li>No se encontraron coincidencias con el patron {0}</li>", rule.Name);
            }

            // y lo retorno
            return Ok(errores);
        }

        public class Error
        {
            public int Line { get; set; } = 0;
            public string ErrorMsg { get; set; } = string.Empty;
            public string Rule { get; set; } = string.Empty;

            public Error(int line, string errorMsg, string rule)
            {
                Line = line;
                ErrorMsg = errorMsg;
                Rule = rule;
            }
        }
    }
}