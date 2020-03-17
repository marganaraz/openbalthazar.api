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
                    errores.Add(new Error(address + ".sol", l, rule.Error, rule.Name));
                    //sb.AppendFormat("<li><a href='#' onclick='mark({1} - 1)'>Line {1} - {2}</a>: {3}.</li>", l, rule.Name, rule.Error);
                }

                //if (rule.Lines.Count == 0) sb.AppendFormat("<li>No se encontraron coincidencias con el patron {0}</li>", rule.Name);
            }

            // y lo retorno
            return Ok(errores);
        }

        [HttpGet("scan_all")]
        public ActionResult ScanAll()
        {
            // Armo la ruta completa al archivo
            string filePath = _hostingEnvironment.ContentRootPath + "/Files/Etherscan/verifiedcontractaddress.csv";

            string[] allFile = System.IO.File.ReadAllLines(filePath);

            List<Error> errores = new List<Error>();

            foreach (string f in allFile)
            {
                string[] columns = f.Split(',');

                string address = columns[1].Substring(1, columns[1].Length - 2);

                try
                {
                    string smartContractPath = _hostingEnvironment.ContentRootPath + "/Files/Etherscan/" + address + ".sol";

                    // Leo el contrato de disco
                    string smartContract = System.IO.File.ReadAllText(smartContractPath);

                    // Lo deserializo
                    var result = JsonSerializer.Deserialize<List<EtherscanSmartContract>>(smartContract);

                    // Lo analizo y retorno los resultados
                    ILanguage language = LanguageFactory.GetInstance(_hostingEnvironment.ContentRootPath + "/bin/Debug/netcoreapp3.1/", "sol");

                    language.Code = result[0].SourceCode;

                    language.Scan();
                    StringBuilder sb = new StringBuilder();


                    // Por cada regla muestro los resultados
                    foreach (ILanguageRule rule in language.Rules)
                    {
                        foreach (int l in rule.Lines)
                        {
                            errores.Add(new Error(address + ".sol", l, rule.Error, rule.Name));
                            //sb.AppendFormat("<li><a href='#' onclick='mark({1} - 1)'>Line {1} - {2}</a>: {3}.</li>", l, rule.Name, rule.Error);
                        }

                        //if (rule.Lines.Count == 0) sb.AppendFormat("<li>No se encontraron coincidencias con el patron {0}</li>", rule.Name);
                    }

                    if (errores.Count == 3) break;
                }
                catch(Exception ex)
                {
                    errores.Add(new Error(address + ".sol", 0, "El archivo no se pudo parsear", "JSON"));
                }
            }

            // y lo retorno
            return Ok(errores);
        }

        [HttpGet("read_all")]
        public ActionResult ReadAll()
        {
            // Armo la ruta completa al archivo
            string filePath = _hostingEnvironment.ContentRootPath + "/Files/Etherscan/verifiedcontractaddress.csv";

            // Si el contrato no existe en disco, primero voy a leerlo a Etherscan
            
            if (System.IO.File.Exists(filePath))
            {
                string[] allFile = System.IO.File.ReadAllLines(filePath);

                // por cada archivo, verifdico si existe
                foreach(string f in allFile)
                {
                    string[] columns = f.Split(',');

                    string address = columns[1].Substring(1, columns[1].Length - 2);

                    string smartContractPath = _hostingEnvironment.ContentRootPath + "/Files/Etherscan/" + address + ".sol";

                    if (!System.IO.File.Exists(smartContractPath)) 
                    {
                        // Instancio el cliente de la API Etherscan
                        EtherscanClient client = new EtherscanClient(_configuration.GetSection("Etherscan.ApiKey").Value, _configuration.GetSection("Etherscan.URL").Value, _configuration.GetSection("Proxy").Value);

                        // Obtengo el resultado JSON
                        List<EtherscanSmartContract> contratos = client.GetSmartContract(address);

                        // Lo serializo
                        var texto = JsonSerializer.Serialize(contratos);

                        // Lo almaceno en disco
                        System.IO.File.AppendAllText(smartContractPath, texto);
                    }                
                }
            }
            else
            {
                //Error
            }

            
            return Ok();
        }

        public class Error
        {
            public string FileName { get; set; }
            public int Line { get; set; } = 0;
            public string ErrorMsg { get; set; } = string.Empty;
            public string Rule { get; set; } = string.Empty;

            public Error(string fileName, int line, string errorMsg, string rule)
            {
                FileName = fileName;
                Line = line;
                ErrorMsg = errorMsg;
                Rule = rule;
            }
        }
    }
}