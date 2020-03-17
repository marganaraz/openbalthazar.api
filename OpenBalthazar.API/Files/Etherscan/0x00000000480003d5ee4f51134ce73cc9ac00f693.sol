[{"SourceCode":"pragma solidity 0.5.11; // optimization runs: 200, evm version: petersburg\r\n\r\n\r\n/**\r\n * @title AdharmaKeyRingImplementation\r\n * @author 0age\r\n * @notice The Adharma Key Ring is an emergency implementation that can be\r\n * immediately upgraded to by the Upgrade Beacon Controller Manager in the event\r\n * of a critical-severity exploit, or after a 90-day period of inactivity by\r\n * Dharma. It gives the user direct, sole custody and control over issuing calls\r\n * from their keyring, using any of their Admin or Dual keys, until the Upgrade\r\n * Beacon Controller Manager issues another upgrade to the implementation\r\n * contract.\r\n */\r\ncontract AdharmaKeyRingImplementation {\r\n  event KeyModified(address indexed key, bool standard, bool admin);\r\n\r\n  enum KeyType {\r\n    None,\r\n    Standard,\r\n    Admin,\r\n    Dual\r\n  }\r\n\r\n  struct AdditionalKeyCount {\r\n    uint128 standard;\r\n    uint128 admin;\r\n  }\r\n\r\n  struct AdditionalThreshold {\r\n    uint128 standard;\r\n    uint128 admin;\r\n  }\r\n\r\n  // WARNING: DO NOT REMOVE OR REORDER STORAGE WHEN WRITING NEW IMPLEMENTATIONS!\r\n\r\n  // Track all keys as an address (as uint160) =\u003E key type mapping in slot zero.\r\n  mapping (uint160 =\u003E KeyType) private _keys;\r\n\r\n  // Track the nonce in slot 1 so that actions cannot be replayed. Note that\r\n  // proper nonce management must be managed by the implementing contract when\r\n  // using \u0060isValidSignature\u0060, as it is a static method and cannot change state.\r\n  uint256 private _nonce;\r\n\r\n  // Track the total number of standard and admin keys in storage slot 2.\r\n  AdditionalKeyCount private _additionalKeyCounts;\r\n\r\n  // Track the required threshold standard and admin actions in storage slot 3.\r\n  AdditionalThreshold private _additionalThresholds;\r\n\r\n  // END STORAGE DECLARATIONS - DO NOT REMOVE OR REORDER STORAGE ABOVE HERE!\r\n\r\n  // Keep the initializer function on the contract in case a keyring has not yet\r\n  // been deployed but an account it controls still contains user funds.\r\n  function initialize(\r\n    uint128 adminThreshold,\r\n    uint128 executorThreshold,\r\n    address[] calldata keys,\r\n    uint8[] calldata keyTypes // 1: standard, 2: admin, 3: dual\r\n  ) external {\r\n    // Ensure that this function is only callable during contract construction.\r\n    assembly { if extcodesize(address) { revert(0, 0) } }\r\n\r\n    uint128 adminKeys;\r\n    uint128 executorKeys;\r\n\r\n    require(keys.length \u003E 0, \u0022Must supply at least one key.\u0022);\r\n\r\n    require(adminThreshold \u003E 0, \u0022Admin threshold cannot be zero.\u0022);\r\n\r\n    require(executorThreshold \u003E 0, \u0022Executor threshold cannot be zero.\u0022);\r\n\r\n    require(\r\n      keys.length == keyTypes.length,\r\n      \u0022Length of keys array and keyTypes arrays must be the same.\u0022\r\n    );\r\n\r\n    for (uint256 i = 0; i \u003C keys.length; i\u002B\u002B) {\r\n      uint160 key = uint160(keys[i]);\r\n\r\n      require(key != uint160(0), \u0022Cannot supply the null address as a key.\u0022);\r\n\r\n      require(_keys[key] == KeyType.None, \u0022Cannot supply duplicate keys.\u0022);\r\n\r\n      KeyType keyType = KeyType(keyTypes[i]);\r\n\r\n      _keys[key] = keyType;\r\n\r\n      bool isStandard = (keyType == KeyType.Standard || keyType == KeyType.Dual);\r\n      bool isAdmin = (keyType == KeyType.Admin || keyType == KeyType.Dual);\r\n\r\n      emit KeyModified(keys[i], isStandard, isAdmin);\r\n\r\n      if (isStandard) {\r\n        executorKeys\u002B\u002B;\r\n      }\r\n\r\n      if (isAdmin) {\r\n        adminKeys\u002B\u002B;\r\n      }\r\n    }\r\n\r\n    require(adminKeys \u003E 0, \u0022Must supply at least one admin key.\u0022);\r\n\r\n    require(executorKeys \u003E 0, \u0022Must supply at least one executor key.\u0022);\r\n\r\n    require(\r\n      adminThreshold \u003E= adminKeys,\r\n      \u0022Admin threshold cannot be less than the total supplied admin keys.\u0022\r\n    );\r\n\r\n    require(\r\n      executorThreshold \u003E= executorKeys,\r\n      \u0022Executor threshold cannot be less than the total supplied executor keys.\u0022\r\n    );\r\n\r\n    if (adminKeys \u003E 1 || executorKeys \u003E 1) {\r\n      _additionalKeyCounts = AdditionalKeyCount({\r\n        standard: executorKeys - 1,\r\n        admin: adminKeys - 1\r\n      });\r\n    }\r\n\r\n    if (adminThreshold \u003E 1 || executorThreshold \u003E 1) {\r\n      _additionalThresholds = AdditionalThreshold({\r\n        standard: executorThreshold - 1,\r\n        admin: adminThreshold - 1\r\n      });\r\n    }\r\n  }\r\n\r\n  // Admin or Dual key holders have authority to issue actions from the keyring.\r\n  function takeAction(\r\n    address payable to, uint256 value, bytes calldata data, bytes calldata\r\n  ) external returns (bool ok, bytes memory returnData) {\r\n    require(\r\n      _keys[uint160(msg.sender)] == KeyType.Admin ||\r\n      _keys[uint160(msg.sender)] == KeyType.Dual,\r\n      \u0022Only Admin or Dual key holders can call this function.\u0022\r\n    );\r\n\r\n    (ok, returnData) = to.call.value(value)(data);\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022adminThreshold\u0022,\u0022type\u0022:\u0022uint128\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022executorThreshold\u0022,\u0022type\u0022:\u0022uint128\u0022},{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022keys\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022uint8[]\u0022,\u0022name\u0022:\u0022keyTypes\u0022,\u0022type\u0022:\u0022uint8[]\u0022}],\u0022name\u0022:\u0022initialize\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022takeAction\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022ok\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022returnData\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022key\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022standard\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022admin\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022KeyModified\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"AdharmaKeyRingImplementation","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://202041646861726d614b657952696e67496d706c656d656e746174696f6e2020"}]