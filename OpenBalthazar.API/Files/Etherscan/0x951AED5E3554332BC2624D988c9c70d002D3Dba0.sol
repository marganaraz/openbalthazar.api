[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\nlibrary SafeMathLib {\r\n  function times(uint a, uint b) public pure returns (uint) {\r\n    uint c = a * b;\r\n    require(a == 0 || c / a == b, \u0027Overflow detected\u0027);\r\n    return c;\r\n  }\r\n\r\n  function minus(uint a, uint b) public pure returns (uint) {\r\n    require(b \u003C= a, \u0027Underflow detected\u0027);\r\n    return a - b;\r\n  }\r\n\r\n  function plus(uint a, uint b) public pure returns (uint) {\r\n    uint c = a \u002B b;\r\n    require(c\u003E=a \u0026\u0026 c\u003E=b, \u0027Overflow detected\u0027);\r\n    return c;\r\n  }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022times\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022plus\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022minus\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"SafeMathLib","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://99bcda2d77f647b462c2087cd6765033d9846b54741779f1cc3cc938e197a708"}]