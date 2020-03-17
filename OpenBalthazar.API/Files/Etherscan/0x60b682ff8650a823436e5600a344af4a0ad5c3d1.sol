[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\ncontract HTMLBodyColor {\r\n    \r\n    string private _body;\r\n    \r\n    constructor(string memory color) public {\r\n        _body = string(abi.encodePacked(\u0022body{background-color:\u0022, color,\u0022;}\u0022));\r\n    }\r\n    \r\n    function read() public view returns(string memory) {\r\n        return _body;\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022color\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022read\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"HTMLBodyColor","CompilerVersion":"v0.5.13\u002Bcommit.5b0b510c","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000066f72616e67650000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://98ba12b28e65b3301adba25bc6e8eea3b2157e7d1f55fe95e37d110c8d2be041"}]