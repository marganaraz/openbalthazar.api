using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;

namespace OpenBalthazar.API.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class FileController : ControllerBase
    {
        #region Members

            private IHostingEnvironment _hostingEnvironment;

        #endregion

        #region Constructor

            public FileController(IHostingEnvironment hostingEnvironment)
            {
                _hostingEnvironment = hostingEnvironment;
            }

        #endregion

        #region List Methods

            /// <summary>
            /// Returns all files from user's folder
            /// </summary>
            /// <returns></returns>
            [HttpGet("getByUser")]
            public async Task<IActionResult> GetByUser()
            {
                // Que usuario es
                var claimsIdentity = this.User.Identity as ClaimsIdentity;

                // Tengo que buscar en Files/Users/{user!}
                string userName = claimsIdentity.Name.Split('@')[0];

                // Directorio del usuario
                string path = _hostingEnvironment.ContentRootPath + "/Files/Users/" + userName;

                if (!System.IO.Directory.Exists(path))
                {
                    System.IO.Directory.CreateDirectory(path);
                    
                    string helloWorldPath = _hostingEnvironment.ContentRootPath + "/Files/Library/HelloWorld.sol";
                    string helloWorldUserPath = path + "/HelloWorld.sol";
                    
                    System.IO.File.Copy(helloWorldPath, helloWorldUserPath);
                }

                string[] files = System.IO.Directory.GetFiles(path);

                return Ok(files);
            }

            /// <summary>
            /// Get file content at @path
            /// </summary>
            /// <param name="path"></param>
            /// <returns></returns>
            [HttpGet("getFile")]
            public async Task<IActionResult> GetFile(string path)
            {
                if (System.IO.File.Exists(path))
                {
                    string files = System.IO.File.ReadAllText(path);
                    return Ok(files);
                }
                else
                {
                    return BadRequest("File not exists.");
                }
            }

        #endregion

        #region Crud Methods

            /// <summary>
            /// Create a new file on disk.
            /// </summary>
            /// <param name="name"></param>
            /// <returns></returns>
            [HttpGet("new")]
            public async Task<IActionResult> NewFile(string name)
            {
                var claimsIdentity = this.User.Identity as ClaimsIdentity;

                string userName = claimsIdentity.Name.Split('@')[0];

                string path = _hostingEnvironment.ContentRootPath + "/Files/Users/" + userName + "/" + name;

                if (!System.IO.File.Exists(path))
                {
                    System.IO.File.WriteAllText(path, string.Empty);
                    return Ok();
                }
                else
                {
                    return BadRequest("Filename already exists.");
                }
            }

            /// <summary>
            /// Delete a file at @path from disk
            /// </summary>
            /// <param name="path"></param>
            /// <returns></returns>
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

            /// <summary>
            /// Rename a file at @path with @name
            /// </summary>
            /// <param name="path"></param>
            /// <param name="name"></param>
            /// <returns></returns>
            [HttpGet("rename")]
            public async Task<IActionResult> Rename(string path, string name)
            {
                if (System.IO.File.Exists(path))
                {
                    // Que usuario es
                    var claimsIdentity = this.User.Identity as ClaimsIdentity;

                    // Tengo que buscar en Files/Users/{user!}
                    string userName = claimsIdentity.Name.Split('@')[0];

                    // Local path 
                    string currentPath = _hostingEnvironment.ContentRootPath + "/Files/Users/" + userName + "/";

                    System.IO.File.Move(path, currentPath + name);
                    return Ok();
                }
                else
                {
                    return BadRequest("File not exists.");
                }
            }


        #endregion

    }
}