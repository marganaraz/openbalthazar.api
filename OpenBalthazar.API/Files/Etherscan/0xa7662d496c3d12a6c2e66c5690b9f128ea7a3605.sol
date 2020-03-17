[{"SourceCode":"pragma solidity 0.5.11;\r\n\r\n\r\ninterface DharmaSmartWalletImplementationV0Interface {\r\n    enum ActionType {\r\n        Cancel, SetUserSigningKey, Generic, GenericAtomicBatch, DAIWithdrawal,\r\n        USDCWithdrawal, ETHWithdrawal, DAIBorrow, USDCBorrow\r\n    }\r\n    function getUserSigningKey() external view returns (address userSigningKey);\r\n    function getNonce() external view returns (uint256 nonce);\r\n    function getVersion() external pure returns (uint256 version);\r\n}\r\n\r\n\r\ninterface DharmaKeyRegistryInterface {\r\n    function getKeyForUser(address account) external view returns (address key);\r\n}\r\n\r\n\r\ncontract SetUserSigningKeyActionIDHelper {\r\n    function getSetUserSigningKeyActionID(\r\n        DharmaSmartWalletImplementationV0Interface smartWallet,\r\n        address userSigningKey,\r\n        uint256 minimumActionGas\r\n    ) external view returns (bytes32 actionID) {\r\n        uint256 version = smartWallet.getVersion();\r\n        DharmaKeyRegistryInterface keyRegistry;\r\n        if (version == 2) {\r\n            keyRegistry = DharmaKeyRegistryInterface(\r\n                0x00000000006c7f32F0cD1eA4C1383558eb68802D\r\n            );\r\n        } else {\r\n            keyRegistry = DharmaKeyRegistryInterface(\r\n                0x00000000006c7f32F0cD1eA4C1383558eb68802D\r\n            );\r\n        }\r\n\r\n        actionID = keccak256(\r\n            abi.encodePacked(\r\n                address(smartWallet),\r\n                version,\r\n                smartWallet.getUserSigningKey(),\r\n                keyRegistry.getKeyForUser(address(smartWallet)),\r\n                smartWallet.getNonce(),\r\n                minimumActionGas,\r\n                DharmaSmartWalletImplementationV0Interface.ActionType.SetUserSigningKey,\r\n                abi.encode(userSigningKey)\r\n            )\r\n        );\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract DharmaSmartWalletImplementationV0Interface\u0022,\u0022name\u0022:\u0022smartWallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022userSigningKey\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022minimumActionGas\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getSetUserSigningKeyActionID\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022actionID\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"SetUserSigningKeyActionIDHelper","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://14d1a26b0d58e921f698480da8adc167744a85761a7160000a5353941d5600ff"}]