using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Etherscan;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;

namespace OpenBalthazar.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class EtherscanController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public EtherscanController(IConfiguration configuration)
        {
            _configuration = configuration;
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
            EtherscanClient client = new EtherscanClient(_configuration.GetSection("Etherscan.ApiKey").Value, _configuration.GetSection("Etherscan.URL").Value, _configuration.GetSection("Proxy").Value);

            return Ok(client.GetSmartContract(address)[0].SourceCode);
        }

    }
}