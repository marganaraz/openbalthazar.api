[{"SourceCode":"pragma solidity 0.5.11; // optimization runs: 200, evm version: petersburg\r\n\r\n\r\n/**\r\n * @title DharmaUpgradeBeaconPrototypeSmartWallet\r\n * @author 0age\r\n * @notice This contract holds the address of the current implementation for\r\n * Dharma smart wallets and lets a controller update that address in storage.\r\n */\r\ncontract DharmaUpgradeBeaconPrototypeSmartWallet {\r\n  // The implementation address is held in storage slot zero.\r\n  address private _implementation;\r\n\r\n  // The controller that can update the implementation is set as a constant.\r\n  address private constant _CONTROLLER = address(\r\n    0x00000000003284ACb9aDEb78A2dDe0A8499932b9\r\n  );\r\n\r\n  /**\r\n   * @notice In the fallback function, allow only the controller to update the\r\n   * implementation address - for all other callers, return the current address.\r\n   * Note that this requires inline assembly, as Solidity fallback functions do\r\n   * not natively take arguments or return values.\r\n   */\r\n  function () external {\r\n    // Return implementation address for all callers other than the controller.\r\n    if (msg.sender != _CONTROLLER) {\r\n      // Load implementation from storage slot zero into memory and return it.\r\n      assembly {\r\n        mstore(0, sload(0))\r\n        return(0, 32)\r\n      }\r\n    } else {\r\n      // Set implementation - put first word in calldata in storage slot zero.\r\n      assembly { sstore(0, calldataload(0)) }\r\n    }\r\n  }\r\n}","ABI":"[{\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022fallback\u0022}]","ContractName":"DharmaUpgradeBeaconPrototypeSmartWallet","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://b94ff790ec887abc8fd4a249973c6b10a082d9e30c5b6735d4104eba18567344"}]