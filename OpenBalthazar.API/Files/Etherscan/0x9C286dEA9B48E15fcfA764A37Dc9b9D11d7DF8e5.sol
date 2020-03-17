[{"SourceCode":"// Geth Wallet is a secure Ethereum Assets Wallet. \r\n/**\r\n * This smart contract code is Copyright 2019 | Geth Wallet (Geth.trade)\r\n *\r\n *Wamlambez Wamnyonyez\r\n\r\n * Licensed under the Apache License, version 2.0: \r\n */\r\n\r\npragma solidity ^0.4.6;\r\n\r\n/**\r\n * Safe unsigned safe math.\r\n *\r\n * https://blog.aragon.one/library-driven-development-in-solidity-2bebcaf88736#.750gwtwli\r\n *\r\n *Adnil was here\r\n * Originally from https://raw.githubusercontent.com/AragonOne/zeppelin-solidity/master/contracts/SafeMathLib.sol\r\n *\r\n * Maintained here until merged to mainline zeppelin-solidity.\r\n *\r\n * Magut was Here\r\n */\r\nlibrary SafeMathLibExt {\r\n\r\n  function times(uint a, uint b) returns (uint) {\r\n    uint c = a * b;\r\n    assert(a == 0 || c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function divides(uint a, uint b) returns (uint) {\r\n    assert(b \u003E 0);\r\n    uint c = a / b;\r\n    assert(a == b * c \u002B a % b);\r\n    return c;\r\n  }\r\n\r\n  function minus(uint a, uint b) returns (uint) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function plus(uint a, uint b) returns (uint) {\r\n    uint c = a \u002B b;\r\n    assert(c\u003E=a);\r\n    return c;\r\n  }\r\n\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022times\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022plus\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022divides\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022a\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022b\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022minus\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022}]","ContractName":"SafeMathLibExt","CompilerVersion":"v0.4.11\u002Bcommit.68ef5810","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://20c944d8375ca14e2c92b14df53c2d044cb99dc30c3ba9f55e2bcde87bd4709b"}]