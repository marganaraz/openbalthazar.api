[{"SourceCode":"pragma solidity 0.5.11;\r\n\r\n\r\ninterface DharmaSmartWalletFactoryV1Interface {\r\n  function getNextSmartWallet(\r\n    address userSigningKey\r\n  ) external view returns (address wallet);\r\n}\r\n\r\n\r\ninterface DharmaKeyRingFactoryV1Interface {\r\n   function getNextKeyRing(\r\n    address userSigningKey\r\n  ) external view returns (address keyRing);\r\n}\r\n\r\n\r\ninterface DharmaSmartWalletImplementationV0Interface {\r\n  function getUserSigningKey() external view returns (address userSigningKey);\r\n}\r\n\r\n\r\n/**\r\n * @title FactoryFactFinder\r\n * @author 0age\r\n * @notice This contract facilitates determining information on counterfactual\r\n * deployment addresses, as well as current deployment statuses, of Dharma Smart\r\n * Wallet \u002B Dharma Key Ring pairs.\r\n */\r\ncontract FactoryFactFinder {\r\n  DharmaSmartWalletFactoryV1Interface private constant _smartWalletFactory = (\r\n    DharmaSmartWalletFactoryV1Interface(\r\n      0xfc00C80b0000007F73004edB00094caD80626d8D\r\n    )\r\n  );\r\n\r\n  DharmaKeyRingFactoryV1Interface private constant _keyRingFactory = (\r\n    DharmaKeyRingFactoryV1Interface(\r\n      0x00DD005247B300f700cFdfF89C00e2aCC94c7b00\r\n    )\r\n  );\r\n\r\n  /**\r\n   * @notice View function to find the address of the next key ring address that\r\n   * will be deployed when supplying a given initial user signing key. Note that\r\n   * a new value will be returned if a particular user signing key has been used\r\n   * before.\r\n   * @param userSigningKey address The user signing key, supplied as a\r\n   * constructor argument.\r\n   * @return The future address of the next key ring (with the user signing key\r\n   * as its input) and of the next smart wallet (with the key ring address as\r\n   * its input).\r\n   */\r\n  function getNextKeyRingAndSmartWallet(\r\n    address userSigningKey\r\n  ) external view returns (address keyRing, address smartWallet) {\r\n    // Ensure that a user signing key has been provided.\r\n    require(userSigningKey != address(0), \u0022No user signing key supplied.\u0022);\r\n\r\n    // Get the next key ring address based on the signing key.\r\n    keyRing = _keyRingFactory.getNextKeyRing(userSigningKey);\r\n    \r\n    // Determine the next smart wallet address based on the key ring address.\r\n    smartWallet = _smartWalletFactory.getNextSmartWallet(keyRing);\r\n  }\r\n\r\n  /**\r\n   * @notice View function to determine whether a given smart wallet has been\r\n   * deployed as well as whether the corresponding keyring contract still needs\r\n   * to be deployed for the smart wallet.\r\n   * @return Two booleans, indicating if the smart wallet and/or the keyring are\r\n   * deployed or not, and the address of the keyring. Note that keyRing and\r\n   * keyRingDeployed will always return the null address and false in the event\r\n   * that the smart wallet has not been deployed yet.\r\n   */\r\n  function getDeploymentStatuses(\r\n    address smartWallet\r\n  ) external view returns (\r\n    bool smartWalletDeployed,\r\n    bool keyRingDeployed,\r\n    address keyRing\r\n  ) {\r\n    // Ensure that a smart wallet address has been provided.\r\n    require(smartWallet != address(0), \u0022No smart wallet supplied.\u0022);\r\n\r\n    // Determine if the smart wallet has been deployed.\r\n    smartWalletDeployed = _hasContractCode(smartWallet);\r\n    \r\n    // Get keyring address and deployment status if smart wallet is deployed.\r\n    if (smartWalletDeployed) {\r\n      keyRing = DharmaSmartWalletImplementationV0Interface(\r\n        smartWallet\r\n      ).getUserSigningKey();\r\n\r\n      keyRingDeployed = _hasContractCode(keyRing);\r\n    }\r\n  }\r\n\r\n  /**\r\n   * @notice View function for deriving the message hash that must be signed in\r\n   * order to add a new key to a given key ring that has not yet been deployed\r\n   * based on given parameters. Note that V0 does not include a prefix when\r\n   * constructing the message hash.\r\n   * @param keyRing address The yet-to-be-deployed keyring address.\r\n   * @param additionalUserSigningKey address The additional user signing key to\r\n   * add.\r\n   * @return The message hash to sign.\r\n   */\r\n  function getFirstAdminActionHash(\r\n    address keyRing, address additionalUserSigningKey\r\n  ) internal view returns (bytes32 hash) {\r\n    hash = keccak256(\r\n      abi.encodePacked(\r\n        keyRing, uint256(0), uint256(0), uint160(additionalUserSigningKey)\r\n      )\r\n    );\r\n  }\r\n\r\n  /**\r\n   * @notice View function to determine if a given account contains contract\r\n   * code.\r\n   * @return True if a contract is deployed at the address with code.\r\n   */\r\n  function hasContractCode(address target) external view returns (bool) {\r\n    return _hasContractCode(target);\r\n  }\r\n\r\n  /**\r\n   * @notice Internal view function to determine if a given account contains\r\n   * contract code.\r\n   * @return True if a contract is deployed at the address with code.\r\n   */\r\n  function _hasContractCode(address target) internal view returns (bool) {\r\n    uint256 size;\r\n    assembly { size := extcodesize(target) }\r\n    return size \u003E 0;\r\n  }  \r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022smartWallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getDeploymentStatuses\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022smartWalletDeployed\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022keyRingDeployed\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022keyRing\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022hasContractCode\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022userSigningKey\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getNextKeyRingAndSmartWallet\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022keyRing\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022smartWallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"FactoryFactFinder","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://93edc64d584e25e418e376df8b676b7e3a090beda49565ce59495d195a0d7c66"}]