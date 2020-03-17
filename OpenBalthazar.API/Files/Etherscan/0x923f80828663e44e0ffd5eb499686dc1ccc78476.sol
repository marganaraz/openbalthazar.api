[{"SourceCode":"pragma solidity ^0.5.8;\r\n\r\ncontract NEST_MiningSave {\r\n    \r\n    IBMapping mappingContract;                      \r\n    ERC20 nestContract;                             \r\n    \r\n    constructor (address map) public {\r\n        mappingContract = IBMapping(address(map));              \r\n        nestContract = ERC20(address(mappingContract.checkAddress(\u0022nest\u0022)));            \r\n    }\r\n    \r\n    function changeMapping(address map) public onlyOwner {\r\n        mappingContract = IBMapping(address(map));              \r\n        nestContract = ERC20(address(mappingContract.checkAddress(\u0022nest\u0022)));            \r\n    }\r\n    \r\n    function turnOut(uint256 amount, address to) public onlyMiningCalculation returns(uint256) {\r\n        uint256 leftNum = nestContract.balanceOf(address(this));\r\n        if (leftNum \u003E= amount) {\r\n            nestContract.transfer(to, amount);\r\n            return amount;\r\n        } else {\r\n            return 0;\r\n        }\r\n    }\r\n    \r\n    modifier onlyOwner(){\r\n        require(mappingContract.checkOwners(msg.sender) == true);\r\n        _;\r\n    }\r\n\r\n    modifier onlyMiningCalculation(){\r\n        require(address(mappingContract.checkAddress(\u0022miningCalculation\u0022)) == msg.sender);\r\n        _;\r\n    }\r\n    \r\n}\r\n\r\n\r\ncontract ERC20 {\r\n    function totalSupply() public view returns (uint supply);\r\n    function balanceOf( address who ) public view returns (uint value);\r\n    function allowance( address owner, address spender ) public view returns (uint _allowance);\r\n\r\n    function transfer( address to, uint256 value) external;\r\n    function transferFrom( address from, address to, uint value) public returns (bool ok);\r\n    function approve( address spender, uint value ) public returns (bool ok);\r\n\r\n    event Transfer( address indexed from, address indexed to, uint value);\r\n    event Approval( address indexed owner, address indexed spender, uint value);\r\n}\r\n\r\n\r\ncontract IBMapping {\r\n\tfunction checkAddress(string memory name) public view returns (address contractAddress);\r\n\tfunction checkOwners(address man) public view returns (bool);\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022turnOut\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022map\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeMapping\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022map\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"NEST_MiningSave","CompilerVersion":"v0.5.9\u002Bcommit.e560f70d","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000005e7db2ffc5b2c7c47103e4f21c702bc402603fbf","Library":"","SwarmSource":"bzzr://8ef23e042968a0b22fbba4e2f8ad3a3ba988e63220c9d4e77ebe977119cc9879"}]