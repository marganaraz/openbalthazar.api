using Etherscan.Models;
using System;
using System.Collections.Generic;
using System.Text;

namespace Etherscan
{
    public static class SmartContractExtension
    {
        public static List<EtherscanSmartContract> GetSmartContract(this EtherscanClient etherscan, string address)
        {
            var request = etherscan.GetRestRequest("contract", "getsourcecode");
            request.AddQueryParameter("address", address);

            return etherscan.ExecuteAsGet<List<EtherscanSmartContract>>(request);
        }
    }
}
