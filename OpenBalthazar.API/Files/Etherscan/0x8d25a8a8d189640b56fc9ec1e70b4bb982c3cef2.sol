[{"SourceCode":"pragma solidity ^0.5.8;\r\npragma experimental ABIEncoderV2;\r\n\r\ninterface CTokenInterface {\r\n    function exchangeRateStored() external view returns (uint);\r\n    function borrowRatePerBlock() external view returns (uint);\r\n    function supplyRatePerBlock() external view returns (uint);\r\n    function borrowBalanceStored(address) external view returns (uint);\r\n\r\n    function balanceOf(address) external view returns (uint);\r\n}\r\n\r\ninterface OrcaleComp {\r\n    function getUnderlyingPrice(address) external view returns (uint);\r\n}\r\n\r\ninterface RegistryInterface {\r\n    function proxies(address owner) external view returns (address);\r\n}\r\n\r\n\r\ncontract DSMath {\r\n\r\n    function add(uint x, uint y) internal pure returns (uint z) {\r\n        require((z = x \u002B y) \u003E= x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    function mul(uint x, uint y) internal pure returns (uint z) {\r\n        require(y == 0 || (z = x * y) / y == x, \u0022math-not-safe\u0022);\r\n    }\r\n\r\n    uint constant WAD = 10 ** 18;\r\n\r\n    function wmul(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, y), WAD / 2) / WAD;\r\n    }\r\n\r\n    function wdiv(uint x, uint y) internal pure returns (uint z) {\r\n        z = add(mul(x, WAD), y / 2) / y;\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract Helpers is DSMath {\r\n\r\n    /**\r\n     * @dev get ethereum address for trade\r\n     */\r\n    function getAddressETH() public pure returns (address eth) {\r\n        eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\r\n    }\r\n\r\n    /**\r\n     * @dev get Compound Comptroller Address\r\n     */\r\n    function getComptrollerAddress() public pure returns (address troller) {\r\n        troller = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;\r\n        // troller = 0x2EAa9D77AE4D8f9cdD9FAAcd44016E746485bddb; // Rinkeby\r\n        // troller = 0x3CA5a0E85aD80305c2d2c4982B2f2756f1e747a5; // Kovan\r\n    }\r\n\r\n    /**\r\n     * @dev get Compound Orcale Address\r\n     */\r\n    function getOracleAddress() public pure returns (address oracle) {\r\n        oracle = 0xe7664229833AE4Abf4E269b8F23a86B657E2338D;\r\n    }\r\n\r\n    /**\r\n     * @dev get Compound Comptroller Address\r\n     */\r\n    function getInstaRegistry() public pure returns (address addr) {\r\n        addr = 0x498b3BfaBE9F73db90D252bCD4Fa9548Cd0Fd981;\r\n    }\r\n\r\n    struct CompData {\r\n        uint tokenPrice;\r\n        uint exchangeRateCurrent;\r\n        uint balanceOfUser;\r\n        uint balanceOfWallet;\r\n        uint borrowBalanceCurrentUser;\r\n        uint borrowBalanceCurrentWallet;\r\n        uint supplyRatePerBlock;\r\n        uint borrowRatePerBlock;\r\n    }\r\n}\r\n\r\n\r\ncontract InstaCompRead is Helpers {\r\n    function getCompTokenData(address owner, address[] memory cAddress) public view returns (CompData[] memory) {\r\n        address userWallet = RegistryInterface(getInstaRegistry()).proxies(owner);\r\n        CompData[] memory tokensData = new CompData[](cAddress.length);\r\n        for (uint i = 0; i \u003C cAddress.length; i\u002B\u002B) {\r\n            CTokenInterface cToken = CTokenInterface(cAddress[i]);\r\n            tokensData[i] = CompData(\r\n                OrcaleComp(getOracleAddress()).getUnderlyingPrice(cAddress[i]),\r\n                cToken.exchangeRateStored(),\r\n                cToken.balanceOf(owner),\r\n                cToken.balanceOf(userWallet),\r\n                cToken.borrowBalanceStored(owner),\r\n                cToken.borrowBalanceStored(userWallet),\r\n                cToken.supplyRatePerBlock(),\r\n                cToken.borrowRatePerBlock()\r\n            );\r\n        }\r\n        return tokensData;\r\n    }\r\n\r\n    function getProxyAddress(address owner) public view returns (address proxy) {\r\n        proxy = RegistryInterface(getInstaRegistry()).proxies(owner);\r\n    }\r\n\r\n    function getTokenData(address owner, address cAddress) public view returns (\r\n        uint tokenPrice,\r\n        uint exRate,\r\n        uint balUser,\r\n        uint balWallet,\r\n        uint borrowBalUser,\r\n        uint borrowBalWallet,\r\n        uint supplyRate,\r\n        uint borrowRate\r\n    )\r\n    {\r\n        address userWallet = RegistryInterface(getInstaRegistry()).proxies(owner);\r\n        tokenPrice = OrcaleComp(getOracleAddress()).getUnderlyingPrice(cAddress);\r\n        CTokenInterface cToken = CTokenInterface(cAddress);\r\n        exRate = cToken.exchangeRateStored();\r\n        balUser = cToken.balanceOf(owner);\r\n        balWallet = cToken.balanceOf(userWallet);\r\n        borrowBalUser = cToken.borrowBalanceStored(owner);\r\n        borrowBalWallet = cToken.borrowBalanceStored(userWallet);\r\n        supplyRate = cToken.supplyRatePerBlock();\r\n        borrowRate = cToken.borrowRatePerBlock();\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022cAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getTokenData\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022tokenPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022exRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022balUser\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022balWallet\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022borrowBalUser\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022borrowBalWallet\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022supplyRate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022borrowRate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getComptrollerAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022troller\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getInstaRegistry\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022cAddress\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022getCompTokenData\u0022,\u0022outputs\u0022:[{\u0022components\u0022:[{\u0022name\u0022:\u0022tokenPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022exchangeRateCurrent\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022balanceOfUser\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022balanceOfWallet\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022borrowBalanceCurrentUser\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022borrowBalanceCurrentWallet\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022supplyRatePerBlock\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022borrowRatePerBlock\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022tuple[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAddressETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022eth\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getOracleAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022oracle\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getProxyAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022proxy\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"InstaCompRead","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://82d7555fd5cdf1094040c8da1ffdbef1a2e0c0e3391f1778ef800e01069edb95"}]