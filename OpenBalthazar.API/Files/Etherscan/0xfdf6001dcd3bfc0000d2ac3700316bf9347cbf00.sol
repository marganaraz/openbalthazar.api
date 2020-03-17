[{"SourceCode":"pragma solidity 0.5.11; // optimization runs: 200, evm version: petersburg\r\n\r\n\r\ninterface DharmaSmartWalletFactoryV1Interface {\r\n  function newSmartWallet(address userSigningKey) external returns (address wallet);\r\n}\r\n\r\n\r\ninterface DharmaSmartWalletImplementationV0Interface {\r\n  function setUserSigningKey(\r\n    address userSigningKey,\r\n    uint256 minimumActionGas,\r\n    bytes calldata userSignature,\r\n    bytes calldata dharmaSignature\r\n  ) external;\r\n  function getUserSigningKey() external view returns (address userSigningKey);\r\n}\r\n\r\n\r\n/**\r\n * A contract to update the user signing key on a smart wallet deployed or\r\n * counterfactually determined by a DharmaSmartWalletFactoryV1 contract, using\r\n * an existing smart wallet or deploying the smart wallet if necessary. Note\r\n * that this helper only supports V1 smart wallet factories - future versions\r\n * have similar functionality included directly, which improves reliability and\r\n * efficiency.\r\n */\r\ncontract SmartWalletFactoryV1UserSigningKeyUpdater {\r\n  function updateUserSigningKey(\r\n    address smartWallet,\r\n    DharmaSmartWalletFactoryV1Interface smartWalletFactory,\r\n    address currentUserSigningKey,\r\n    address newUserSigningKey,\r\n    uint256 minimumActionGas,\r\n    bytes calldata userSignature,\r\n    bytes calldata dharmaSignature\r\n  ) external returns (\r\n    DharmaSmartWalletImplementationV0Interface wallet\r\n  ) {\r\n    // Deploy a new smart wallet if needed. Factory emits a corresponding event.\r\n    wallet = _deployNewSmartWalletIfNeeded(\r\n      smartWalletFactory, currentUserSigningKey, smartWallet\r\n    );\r\n\r\n    // Set new user signing key. Smart wallet emits a corresponding event.\r\n    wallet.setUserSigningKey(\r\n      newUserSigningKey, minimumActionGas, userSignature, dharmaSignature\r\n    );\r\n  }\r\n\r\n  function _deployNewSmartWalletIfNeeded(\r\n    DharmaSmartWalletFactoryV1Interface smartWalletFactory,\r\n    address userSigningKey,\r\n    address expectedSmartWallet\r\n  ) internal returns (\r\n    DharmaSmartWalletImplementationV0Interface smartWallet\r\n  ) {\r\n    // Only deploy if a smart wallet doesn\u0027t already exist at expected address.\r\n    uint256 size;\r\n    assembly { size := extcodesize(expectedSmartWallet) }\r\n    if (size == 0) {\r\n      // Deploy the smart wallet.\r\n      smartWallet = DharmaSmartWalletImplementationV0Interface(\r\n        smartWalletFactory.newSmartWallet(userSigningKey)\r\n      );\r\n    } else {\r\n      // Reuse the supplied smart wallet address. Note that this helper does\r\n      // not perform an extcodehash check, meaning that a contract that is\r\n      // not actually a smart wallet may be supplied instead.\r\n      smartWallet = DharmaSmartWalletImplementationV0Interface(\r\n        expectedSmartWallet\r\n      );\r\n\r\n      // Ensure that the smart wallet in question has the right key.\r\n      require(\r\n        smartWallet.getUserSigningKey() == userSigningKey,\r\n        \u0022Existing user signing key differs from supplied current signing key.\u0022\r\n      );\r\n    }\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022smartWallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022contract DharmaSmartWalletFactoryV1Interface\u0022,\u0022name\u0022:\u0022smartWalletFactory\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022currentUserSigningKey\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newUserSigningKey\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022minimumActionGas\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022userSignature\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022dharmaSignature\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022updateUserSigningKey\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract DharmaSmartWalletImplementationV0Interface\u0022,\u0022name\u0022:\u0022wallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"SmartWalletFactoryV1UserSigningKeyUpdater","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://b0b341f3c9ee4c09cee2a5814368a8edd4c03c91d261d84ffee53f75cca8493b"}]