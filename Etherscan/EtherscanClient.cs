using Etherscan.Models;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Net;
using System.Text;

namespace Etherscan
{
    public class EtherscanClient
    {
        private string apiKey { get; set; }
        private string url { get; set; }
        private string proxy { get; set; }

        public EtherscanClient(string apiKey, string url, string proxy)
        {
            this.apiKey = apiKey;
            this.url = url;
            this.proxy = proxy;
        }

        public RestRequest GetRestRequest(String module, String action)
        {
            var request = new RestRequest("/api");
            request.AddQueryParameter("module", module);
            request.AddQueryParameter("action", action);
            request.AddQueryParameter("apikey", apiKey);

            return request;
        }

        public T ExecuteAsGet<T>(RestRequest request)
        {
            var rest = new RestClient(url);
            
            if(!string.IsNullOrEmpty(proxy)) rest.Proxy = new WebProxy(proxy);

            var response = rest.ExecuteAsGet<EtherscanResponse<T>>(request, "GET");

            return response.Data.Result;
        }
    }
}
