using System;
using System.Collections.Generic;
using System.Linq;
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
        #region Members

            private string DEVELOPMENT_PATH = "/bin/Debug/netcoreapp3.1/";
            private IHostingEnvironment _hostingEnvironment;
            private IHttpContextAccessor _httpContextAccessor;

        #endregion

        #region Constructor

            public ScannerController(IHostingEnvironment hostingEnvironment, IHttpContextAccessor httpContextAccessor)
            {
                _hostingEnvironment = hostingEnvironment;
                _httpContextAccessor = httpContextAccessor;
            }

        #endregion

        #region Scanner

            [HttpPost("scan")]
            public async Task<IActionResult> Scan([FromForm]ScanView view)
            {
                try
                {
                    // Tengo que guardar el archivo
                    System.IO.File.WriteAllText(view.Path, view.Code);

                    // En base a la extension, levanto por REFLECTION el analizador correcto
                    string ext = view.Path.Substring(view.Path.LastIndexOf(".") + 1, view.Path.Length - 1 - view.Path.LastIndexOf("."));

                    if (!(ext.Equals("sol") || ext.Equals("vy")))
                    {
                        ext += "sol";
                    }

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

                    // Obtengo la instancia del scanner
                    ILanguage language = LanguageFactory.GetInstance(_hostingEnvironment.ContentRootPath + folderPath, ext, userLangs);

                    // Asigno el contenido
                    language.Code = System.IO.File.ReadAllText(view.Path);
                    
                    // Ejecuto el analisis 
                    language.Scan();
                    List<ScannerResultado> resultado = new List<ScannerResultado>();

                    // Por cada regla muestro los resultados
                    foreach (ILanguageRule rule in language.Rules)
                    {
                        foreach (int l in rule.Lines)
                        {
                            resultado.Add(new ScannerResultado(l, rule.Name, rule.Error, rule.Severity.ToString().ToLower()));
                        }
                    }

                    return Ok(resultado);
                }
                catch (Exception ex)
                {
                    return BadRequest(ex.Message);
                }

            }

        #endregion

        #region Utils

        [AllowAnonymous]
            [HttpGet("GetCode")]
            public ActionResult GetCode(string address)
            {
                ILanguage language = LanguageFactory.GetInstance(_hostingEnvironment.ContentRootPath + "/bin/Debug/netcoreapp3.1/", "sol", _httpContextAccessor.HttpContext.Request.Headers["Accept-Language"]);

                string path = _hostingEnvironment.ContentRootPath + "/Files/Etherscan/" + address + ".sol";

                string smartContract = System.IO.File.ReadAllText(path);

                // Lo deserializo
                var result = JsonSerializer.Deserialize<List<EtherscanSmartContract>>(smartContract);

                language.Code = result[0].SourceCode;

                return Ok(result[0].SourceCode);
            }


        #endregion
    }
}