using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.Mvc;
using OpenBalthazar.API.Core;

namespace OpenBalthazar.API.Controllers
{
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
        [HttpGet("scan")]
        public ActionResult Scan(string path, string code)
        {
            // En base a la extension, levanto por REFLECTION el analizador correcto
            string ext = path.Substring(path.LastIndexOf(".") + 1, path.Length - 1 - path.LastIndexOf("."));
            

            if (!(ext.Equals("sol") || ext.Equals("vy")))
            {
                ext += "sol";
            }

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

            ILanguage language = LanguageFactory.GetInstance(_hostingEnvironment.ContentRootPath + "/bin/Debug/netcoreapp3.1/", ext);

            language.Code = code;
            language.Language = idiom;

            language.Scan();
            StringBuilder sb = new StringBuilder();

            // Por cada regla muestro los resultados
            foreach (ILanguageRule rule in language.Rules)
            {
                foreach (int l in rule.Lines)
                {
                    sb.AppendFormat("<li><a href='#' onclick='mark({1} - 1)'>Line {1} - {2}</a>: {3}.</li>", l, rule.Name, rule.Error);
                }

                if (rule.Lines.Count == 0) sb.AppendFormat("<li>No se encontraron coincidencias con el patron {0}</li>", rule.Name);
            }

            return Ok(language.Rules);
        }
    }
}