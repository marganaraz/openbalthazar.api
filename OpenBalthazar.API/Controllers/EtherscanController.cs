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
        private string DEVELOPMENT_PATH = "/bin/Debug/netcoreapp3.1/";
        private readonly IConfiguration _configuration;
        private IHostingEnvironment _hostingEnvironment;
        private IHttpContextAccessor _httpContextAccessor;

        public EtherscanController(IConfiguration configuration, IHostingEnvironment hostingEnvironment, IHttpContextAccessor httpContextAccessor)
        {
            _configuration = configuration;
            _hostingEnvironment = hostingEnvironment;
            _httpContextAccessor = httpContextAccessor;
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

            // Tomo los idiomas desde el navegador
            var userLangs = _httpContextAccessor.HttpContext.Request.Headers["Accept-Language"].ToString();

            // Leo el contrato de disco
            string smartContract = System.IO.File.ReadAllText(path);

            // Lo deserializo
            var result = JsonSerializer.Deserialize<List<EtherscanSmartContract>>(smartContract);

            // Determino donde se almacenan las librerias 
            string folderPath = string.Empty;

            if (_hostingEnvironment.IsDevelopment())
            {
                folderPath = DEVELOPMENT_PATH;
            }
            else
            {
                folderPath = "/";
            }

            // Lo analizo y retorno los resultados
            ILanguage language = LanguageFactory.GetInstance(_hostingEnvironment.ContentRootPath + folderPath, "sol", userLangs);

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

        [HttpGet("scanAll")]
        public ActionResult ScanAll()
        {
            // Armo la ruta completa al archivo CSV
            string csvFilePath = _hostingEnvironment.ContentRootPath + "/Files/Etherscan/verifiedcontractaddress.csv";

            // Arreglo que contiene el contenido del archivo CSV de a un registro por indice
            string[] csvFile = System.IO.File.ReadAllLines(csvFilePath);

            EtherscanResultado resultado = new EtherscanResultado();
            Dictionary<string, int> rules = new Dictionary<string, int>();

            resultado.Files = csvFile.Length;

            // Por cada renglon del archivo CSV
            foreach (string f in csvFile)
            {
                // Resultado con errores
                List<Error> errores = new List<Error>();

                // Separo el contenido en columnas
                string[] columns = f.Split(',');

                // Obtengo la la direccion ETH del smart contract
                string address = columns[1].Substring(1, columns[1].Length - 2);

                try
                {
                    // Armo el path al archivol SOL
                    string smartContractPath = _hostingEnvironment.ContentRootPath + "/Files/Etherscan/" + address + ".sol";

                    // Leo el contrato de disco
                    string smartContract = System.IO.File.ReadAllText(smartContractPath);

                    // Lo deserializo
                    var smartContractContent = JsonSerializer.Deserialize<List<EtherscanSmartContract>>(smartContract);

                    // Tomo los idiomas desde el navegador
                    var userLangs = _httpContextAccessor.HttpContext.Request.Headers["Accept-Language"].ToString();

                    // Determino donde se almacenan las librerias 
                    string folderPath = string.Empty;

                    if (_hostingEnvironment.IsDevelopment())
                    {
                        folderPath = DEVELOPMENT_PATH;
                    }
                    else
                    {
                        folderPath = "/";
                    }

                    // Instancia el motor de analisis
                    ILanguage language = LanguageFactory.GetInstance(_hostingEnvironment.ContentRootPath + folderPath, "sol", userLangs);

                    // Paso el codigo del contrato
                    language.Code = smartContractContent[0].SourceCode;

                    // Lo escaneo
                    language.Scan();

                    bool tieneError = false;
                    int errors = 0;
                    int warnings = 0;

                    // Por cada regla muestro los resultados
                    foreach (ILanguageRule rule in language.Rules)
                    {
                        foreach (int l in rule.Lines)
                        {
                            if(!rules.ContainsKey(rule.Name))
                            {
                                rules.Add(rule.Name, 1);
                            }
                            else
                            {
                                rules[rule.Name]++;
                            }

                            errores.Add(new Error(address, l, rule.Error, rule.Name));

                            if (rule.Severity.Equals(Severity.Error)) errors++;
                            else if (rule.Severity.Equals(Severity.Warning)) warnings++;

                            tieneError = true;
                        }
                    }

                    if (tieneError)
                    {
                        resultado.FilesErrors++;
                        resultado.FilesWithErrors.Add(new EtherscanFile(address, errores, errors, warnings));
                    }
                }
                catch(Exception ex)
                {
                    //errores.Add(new Error(address, 0, "El archivo no se pudo parsear", "JSON"));
                }
            }

            resultado.Rules = rules;

            // y lo retorno
            return Ok(resultado);
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

        public class EtherscanResultado
        {
            public int Files { get; set; }
            public int FilesErrors { get; set; }
            public List<EtherscanFile> FilesWithErrors { get; set; } = new List<EtherscanFile>();
            public Dictionary<string, int> Rules { get; set; }
        }

        public class EtherscanFile
        {
            public string Filename { get; set; }
            public int Errors { get; set; }
            public int Warnings { get; set; }
            public List<Error> ErrorsList { get; set; }

            public EtherscanFile(string fileName, List<Error> errorsList, int error, int warnings)
            {
                Filename = fileName;
                ErrorsList = errorsList;
                Errors = error;
                Warnings = warnings;
            }
        }

        public class Error
        {
            public string FileName { get; set; }
            public int Line { get; set; } = 0;
            public string ErrorMsg { get; set; } = string.Empty;
            public string Rule { get; set; } = string.Empty;
            public string Url { get; set; }

            public Error(string address, int line, string errorMsg, string rule)
            {
                FileName = address + ".sol";
                Line = line;
                ErrorMsg = errorMsg;
                Rule = rule;
                Url = string.Format("<a href='api/scanner/GetCode?address={0}' target=”_blank”></a>", address);
            }
        }
    }
}