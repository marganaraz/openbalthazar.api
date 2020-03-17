[{"SourceCode":"pragma solidity 0.6.2;\r\n\r\n\r\ninterface SmartWallet {\r\n    function migrateSaiToDai() external;\r\n}\r\n\r\n\r\ncontract Sainnihilator {\r\n    function migrateAll(SmartWallet[] calldata wallets) external {\r\n        for (uint256 i = 0; i \u003C wallets.length; i\u002B\u002B) {\r\n            if (gasleft() \u003C 500000) break;\r\n            try wallets[i].migrateSaiToDai() {} catch {}\r\n        }\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract SmartWallet[]\u0022,\u0022name\u0022:\u0022wallets\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022migrateAll\u0022,\u0022outputs\u0022:[],\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"Sainnihilator","CompilerVersion":"v0.6.2\u002Bcommit.bacdbe57","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"ipfs://bbff08d5cef6bbcbe101be0258b8726b35c2a0955a1f6688607f2bf9a332298c"}]