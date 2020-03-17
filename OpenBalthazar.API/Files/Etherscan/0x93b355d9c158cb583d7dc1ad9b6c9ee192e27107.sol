[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\n\r\ncontract DSGuard {\r\n    function canCall(address src_, address dst_, bytes4 sig) public view returns (bool);\r\n\r\n    function permit(bytes32 src, bytes32 dst, bytes32 sig) public;\r\n    function forbid(bytes32 src, bytes32 dst, bytes32 sig) public;\r\n\r\n    function permit(address src, address dst, bytes32 sig) public;\r\n    function forbid(address src, address dst, bytes32 sig) public;\r\n\r\n}\r\n\r\n\r\ncontract DSGuardFactory {\r\n    function newGuard() public returns (DSGuard guard);\r\n}\r\n\r\n\r\ncontract DSAuthority {\r\n    function canCall(\r\n        address src, address dst, bytes4 sig\r\n    ) public view returns (bool);\r\n}\r\n\r\ncontract DSAuthEvents {\r\n    event LogSetAuthority (address indexed authority);\r\n    event LogSetOwner     (address indexed owner);\r\n}\r\n\r\ncontract DSAuth is DSAuthEvents {\r\n    DSAuthority  public  authority;\r\n    address      public  owner;\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n        emit LogSetOwner(msg.sender);\r\n    }\r\n\r\n    function setOwner(address owner_)\r\n        public\r\n        auth\r\n    {\r\n        owner = owner_;\r\n        emit LogSetOwner(owner);\r\n    }\r\n\r\n    function setAuthority(DSAuthority authority_)\r\n        public\r\n        auth\r\n    {\r\n        authority = authority_;\r\n        emit LogSetAuthority(address(authority));\r\n    }\r\n\r\n    modifier auth {\r\n        require(isAuthorized(msg.sender, msg.sig));\r\n        _;\r\n    }\r\n\r\n    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {\r\n        if (src == address(this)) {\r\n            return true;\r\n        } else if (src == owner) {\r\n            return true;\r\n        } else if (authority == DSAuthority(0)) {\r\n            return false;\r\n        } else {\r\n            return authority.canCall(src, address(this), sig);\r\n        }\r\n    }\r\n}\r\n\r\ncontract MonitorInterface {\r\n    function subscribe(bytes32 _cdpId, uint _minRatio, uint _maxRatio, uint _optimalRatioBoost, uint _optimalRatioRepay) public;\r\n    function unsubscribe(bytes32 _cdpId) public;\r\n}\r\n\r\ncontract ConstantAddressesMainnet {\r\n    address public constant MAKER_DAI_ADDRESS = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;\r\n    address public constant IDAI_ADDRESS = 0x14094949152EDDBFcd073717200DA82fEd8dC960;\r\n    address public constant SOLO_MARGIN_ADDRESS = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;\r\n    address public constant CDAI_ADDRESS = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;\r\n    address public constant KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\r\n    address public constant MKR_ADDRESS = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;\r\n    address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;\r\n    address public constant VOX_ADDRESS = 0x9B0F70Df76165442ca6092939132bBAEA77f2d7A;\r\n    address public constant PETH_ADDRESS = 0xf53AD2c6851052A81B42133467480961B2321C09;\r\n    address public constant TUB_ADDRESS = 0x448a5065aeBB8E423F0896E6c5D525C040f59af3;\r\n    address public constant WALLET_ID = 0x322d58b9E75a6918f7e7849AEe0fF09369977e08;\r\n    address public constant LOGGER_ADDRESS = 0xeCf88e1ceC2D2894A0295DB3D86Fe7CE4991E6dF;\r\n    address public constant OTC_ADDRESS = 0x39755357759cE0d7f32dC8dC45414CCa409AE24e;\r\n\r\n    address public constant KYBER_WRAPPER = 0xAae7ba823679889b12f71D1f18BEeCBc69E62237;\r\n    address public constant UNISWAP_WRAPPER = 0x0aa70981311D60a9521C99cecFDD68C3E5a83B83;\r\n    address public constant ETH2DAI_WRAPPER = 0xd7BBB1777E13b6F535Dec414f575b858ed300baF;\r\n\r\n    address public constant KYBER_INTERFACE = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;\r\n    address public constant UNISWAP_FACTORY = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;\r\n    address public constant FACTORY_ADDRESS = 0x5a15566417e6C1c9546523066500bDDBc53F88C7;\r\n    address public constant PIP_INTERFACE_ADDRESS = 0x729D19f657BD0614b4985Cf1D82531c67569197B;\r\n\r\n    address public constant PROXY_REGISTRY_INTERFACE_ADDRESS = 0x4678f0a6958e4D2Bc4F1BAF7Bc52E8F3564f3fE4;\r\n    address public constant GAS_TOKEN_INTERFACE_ADDRESS = 0x0000000000b3F879cb30FE243b4Dfee438691c04;\r\n\r\n    // Kovan addresses, not used on mainnet\r\n    address public constant COMPOUND_DAI_ADDRESS = 0x25a01a05C188DaCBCf1D61Af55D4a5B4021F7eeD;\r\n    address public constant STUPID_EXCHANGE = 0x863E41FE88288ebf3fcd91d8Dbb679fb83fdfE17;\r\n}\r\n\r\ncontract ConstantAddresses is ConstantAddressesMainnet {\r\n}\r\n\r\n/// @title MonitorProxy handles authorization and interaction with the Monitor contract\r\ncontract MonitorProxy is ConstantAddresses {\r\n\r\n    function subscribe(bytes32 _cup, uint _minRatio, uint _maxRatio, uint _optimalRatioBoost, uint _optimalRatioRepay, address _monitor) public {\r\n        DSGuard guard = DSGuardFactory(FACTORY_ADDRESS).newGuard();\r\n        DSAuth(address(this)).setAuthority(DSAuthority(address(guard)));\r\n\r\n        guard.permit(_monitor, address(this), bytes4(keccak256(\u0022execute(address,bytes)\u0022)));\r\n\r\n        MonitorInterface(_monitor).subscribe(_cup, _minRatio, _maxRatio, _optimalRatioBoost, _optimalRatioRepay);\r\n    }\r\n\r\n    function unsubscribe(bytes32 _cup, address _monitor) public {\r\n        MonitorInterface(_monitor).unsubscribe(_cup);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022WETH_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022CDAI_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022PIP_INTERFACE_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022KYBER_ETH_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022OTC_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022IDAI_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022GAS_TOKEN_INTERFACE_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022VOX_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ETH2DAI_WRAPPER\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022STUPID_EXCHANGE\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022PROXY_REGISTRY_INTERFACE_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MKR_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022FACTORY_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022LOGGER_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MAKER_DAI_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022KYBER_WRAPPER\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022COMPOUND_DAI_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022UNISWAP_FACTORY\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022PETH_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022KYBER_INTERFACE\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_cup\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_minRatio\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_maxRatio\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_optimalRatioBoost\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_optimalRatioRepay\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_monitor\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022subscribe\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022WALLET_ID\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022SOLO_MARGIN_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_cup\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_monitor\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022unsubscribe\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022UNISWAP_WRAPPER\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TUB_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"MonitorProxy","CompilerVersion":"v0.5.1\u002Bcommit.c8a2cb62","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://6435371cb4f155e6e07e632591163105afcc10e22c84c65b547674adc9002d4b"}]