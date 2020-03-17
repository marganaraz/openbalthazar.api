[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\ncontract Discount {\r\n\r\n    address public owner;\r\n    mapping (address =\u003E CustomServiceFee) public serviceFees;\r\n\r\n    uint constant MAX_SERVICE_FEE = 400;\r\n\r\n    struct CustomServiceFee {\r\n        bool active;\r\n        uint amount;\r\n    }\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    function isCustomFeeSet(address _user) public view returns (bool) {\r\n        return serviceFees[_user].active;\r\n    }\r\n\r\n    function getCustomServiceFee(address _user) public view returns (uint) {\r\n        return serviceFees[_user].amount;\r\n    }\r\n\r\n    function setServiceFee(address _user, uint _fee) public {\r\n        require(msg.sender == owner, \u0022Only owner\u0022);\r\n        require(_fee \u003E= MAX_SERVICE_FEE || _fee == 0);\r\n\r\n        serviceFees[_user] = CustomServiceFee({\r\n            active: true,\r\n            amount: _fee\r\n        });\r\n    }\r\n\r\n    function disableServiceFee(address _user) public {\r\n        require(msg.sender == owner, \u0022Only owner\u0022);\r\n\r\n        serviceFees[_user] = CustomServiceFee({\r\n            active: false,\r\n            amount: 0\r\n        });\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022serviceFees\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022active\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getCustomServiceFee\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isCustomFeeSet\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022disableServiceFee\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_fee\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setServiceFee\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"Discount","CompilerVersion":"v0.5.1\u002Bcommit.c8a2cb62","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://e01d1da344cda8f05c5f8e55a546444ca95c707bb76c197e4c0b53cffcc72ba8"}]