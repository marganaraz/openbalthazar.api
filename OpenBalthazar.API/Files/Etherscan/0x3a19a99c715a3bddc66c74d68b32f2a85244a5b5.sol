[{"SourceCode":"pragma solidity ^0.5.13;\r\n\r\ncontract Implementation {\r\n  event ImplementationLog(uint256 gas);\r\n\r\n  function() external payable {\r\n    emit ImplementationLog(gasleft());\r\n  }\r\n}\r\n\r\ncontract Delegator {\r\n  event DelegatorLog(uint256 gas);\r\n\r\n  Implementation public implementation;\r\n\r\n  constructor() public {\r\n    implementation = new Implementation();\r\n  }\r\n\r\n  function () external payable {\r\n    emit DelegatorLog(gasleft());\r\n\r\n    address _impl = address(implementation);\r\n    assembly {\r\n      let ptr := mload(0x40)\r\n      calldatacopy(ptr, 0, calldatasize)\r\n      let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)\r\n    }\r\n\r\n    emit DelegatorLog(gasleft());\r\n  }\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022gas\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022DelegatorLog\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022implementation\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract Implementation\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"Delegator","CompilerVersion":"v0.5.13\u002Bcommit.5b0b510c","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://e621c5599aa852a70613fee6a8a4bc027b250e7babd465c4858af9a58384d02c"}]