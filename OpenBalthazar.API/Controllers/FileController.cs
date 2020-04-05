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
    public class FileController : ControllerBase
    {
        private IHostingEnvironment _hostingEnvironment;

        public FileController(IHostingEnvironment hostingEnvironment)
        {
            _hostingEnvironment = hostingEnvironment;
        }

        [HttpGet("getByUser")]
        public async Task<IActionResult> GetByUser()
        {
            // Que usuario es
            var claimsIdentity = this.User.Identity as ClaimsIdentity;

            // Tengo que buscar en Files/Users/{user!}
            // Si no tiene nada, tengo que crear la carpeta y crearle un archivo en blanco
            string userName = claimsIdentity.Name.Split('@')[0];
            string path = _hostingEnvironment.ContentRootPath + "/Files/Users/" + userName;

            if (!System.IO.Directory.Exists(path))
            {
                System.IO.Directory.CreateDirectory(path);

                System.IO.File.AppendAllLines(path + "/new.sol", new string[] { "pragma solidity", "contract" });
            }

            string[] files = System.IO.Directory.GetFiles(path);

            return Ok(files);
        }

        [HttpGet("getFile")]
        public async Task<IActionResult> GetFile(string path)
        {
            if(System.IO.File.Exists(path))
            {
                string files = System.IO.File.ReadAllText(path);
                return Ok(files);
            }
            else
            {
                return BadRequest();
            }
        }

        [HttpGet("new")]
        public async Task<IActionResult> NewFile(string name)
        {
            var claimsIdentity = this.User.Identity as ClaimsIdentity;
            string userName = claimsIdentity.Name.Split('@')[0];
            string path = _hostingEnvironment.ContentRootPath + "/Files/Users/" + userName + "/" + name;

            if (!System.IO.File.Exists(path))
            {
                System.IO.File.Create(path);
                return Ok();
            }
            else
            {
                return BadRequest("Filename already exists.");
            }
        }

        [HttpGet("delete")]
        public async Task<IActionResult> Delete(string path)
        {
            if (System.IO.File.Exists(path))
            {
                System.IO.File.Delete(path);
                return Ok();
            }
            else
            {
                return BadRequest("File not exists.");
            }
        }

        [HttpGet("rename")]
        public async Task<IActionResult> Rename(string path, string name)
        {
            if (System.IO.File.Exists(path))
            {
                // Que usuario es
                var claimsIdentity = this.User.Identity as ClaimsIdentity;

                // Tengo que buscar en Files/Users/{user!}
                // Si no tiene nada, tengo que crear la carpeta y crearle un archivo en blanco
                string userName = claimsIdentity.Name.Split('@')[0];
                string currentPath = _hostingEnvironment.ContentRootPath + "/Files/Users/" + userName + "/";

                System.IO.File.Move(path, currentPath + name);
                return Ok();
            }
            else
            {
                return BadRequest("File not exists.");
            }
        }
    }
}