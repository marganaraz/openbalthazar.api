using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Security.Claims;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Etherscan.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.Mvc;
using OpenBalthazar.API.Core;
using OpenBalthazar.API.Models;

namespace OpenBalthazar.API.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class ScannerController : ControllerBase
    {
        private IHostingEnvironment _hostingEnvironment;
        private IHttpContextAccessor _httpContextAccessor;

        public ScannerController(IHostingEnvironment hostingEnvironment, IHttpContextAccessor httpContextAccessor)
        {
            _hostingEnvironment = hostingEnvironment;
            _httpContextAccessor = httpContextAccessor;
        }

        [HttpPost("scan")]
        public async Task<IActionResult> Scan([FromForm]ScanView view)
        {
            string code = view.code;
            string path = view.path;
            try
            {
                // Tengo que guardar el archivo
                //string[] lines = code.Split("\r\n");
                //System.IO.File.WriteAllLines(path, lines);
                System.IO.File.WriteAllText(path, code);

                // En base a la extension, levanto por REFLECTION el analizador correcto
                string ext = path.Substring(path.LastIndexOf(".") + 1, path.Length - 1 - path.LastIndexOf("."));

                if (!(ext.Equals("sol") || ext.Equals("vy")))
                {
                    ext += "sol";
                }

                var userLangs = _httpContextAccessor.HttpContext.Request.Headers["Accept-Language"].ToString();
                var firstLang = userLangs.Split(',').FirstOrDefault();
                var defaultLang = string.IsNullOrEmpty(firstLang) ? "en" : firstLang;

                Language idiom = Language.English;

                if (defaultLang.ToLower().Contains("es"))
                {
                    idiom = Language.Spanish;
                }
                else if (defaultLang.ToLower().Contains("en"))
                {
                    idiom = Language.English;
                }
                else if (defaultLang.ToLower().Contains("pt"))
                {
                    idiom = Language.Portugues;
                }

                string folderPath = string.Empty;

                if(_hostingEnvironment.IsDevelopment())
                {
                    folderPath = "/bin/Debug/netcoreapp3.1/";
                }
                else
                {
                    folderPath = "/";
                }
                ILanguage language = LanguageFactory.GetInstance(_hostingEnvironment.ContentRootPath + folderPath, ext);

                language.Code = System.IO.File.ReadAllText(path);
                language.Language = idiom;

                language.Scan();
                //StringBuilder sb = new StringBuilder();
                List<Resultado> resultado = new List<Resultado>();

                // Por cada regla muestro los resultados
                foreach (ILanguageRule rule in language.Rules)
                {
                    foreach (int l in rule.Lines)
                    {
                        resultado.Add(new Resultado(l, rule.Name, rule.Error, rule.Severity.ToString().ToLower()));
                        //sb.AppendFormat("<li><a href='#' onclick='mark({1} - 1)'>Line {1} - {2}</a>: {3}.</li>", l, rule.Name, rule.Error);
                    }

                    //if (rule.Lines.Count == 0) sb.AppendFormat("<li>No se encontraron coincidencias con el patron {0}</li>", rule.Name);
                }

                return Ok(resultado);
            }
            catch(Exception ex)
            {
                return BadRequest(ex.Message);
            }
            
        }

        [HttpGet("GetCode")]
        public ActionResult GetCode(string address)
        {
            // En base a la extension, levanto por REFLECTION el analizador correcto
            //string ext = path.Substring(path.LastIndexOf(".") + 1, path.Length - 1 - path.LastIndexOf("."));


            //if (!(ext.Equals("sol") || ext.Equals("vy")))
            //{
            //    ext += "sol";
            //}

            var lang = Request.HttpContext.Features.Get<IRequestCultureFeature>();
            var dos = _httpContextAccessor.HttpContext.Request.Headers["Accept-Language"];
            //Request.Headers[]

            string idioma = "es";// Request.HttpContext.Features.Get<IRequestCultureFeature>().ToString(); //Request.UserLanguages[0];

            Language idiom = Language.English;

            if (idioma.ToLower().Contains("es"))
            {
                idiom = Language.Spanish;
            }
            else if (idioma.ToLower().Contains("en"))
            {
                idiom = Language.English;
            }
            else if (idioma.ToLower().Contains("pt"))
            {
                idiom = Language.Portugues;
            }

            ILanguage language = LanguageFactory.GetInstance(_hostingEnvironment.ContentRootPath + "/bin/Debug/netcoreapp3.1/", "sol");

            string path = _hostingEnvironment.ContentRootPath + "/Files/Etherscan/" + address + ".sol";

            string smartContract = System.IO.File.ReadAllText(path);

            // Lo deserializo
            var result = JsonSerializer.Deserialize<List<EtherscanSmartContract>>(smartContract);

            language.Code = result[0].SourceCode;


            language.Language = idiom;

            //language.Scan();
            //StringBuilder sb = new StringBuilder();

            //// Por cada regla muestro los resultados
            //foreach (ILanguageRule rule in language.Rules)
            //{
            //    foreach (int l in rule.Lines)
            //    {
            //        sb.AppendFormat("<li><a href='#' onclick='mark({1} - 1)'>Line {1} - {2}</a>: {3}.</li>", l, rule.Name, rule.Error);
            //    }

            //    if (rule.Lines.Count == 0) sb.AppendFormat("<li>No se encontraron coincidencias con el patron {0}</li>", rule.Name);
            //}

            return Ok(result[0].SourceCode);
        }
    }

    public class ScanView
    {
        public string path { get; set; }
        public string code { get; set; }
    }
}