[{"SourceCode":"pragma solidity 0.5.11; // optimization runs: 200, evm version: petersburg\r\n\r\n\r\ninterface DharmaKeyRingImplementationV0Interface {\r\n  event KeyModified(address indexed key, bool standard, bool admin);\r\n\r\n  enum KeyType {\r\n    None,\r\n    Standard,\r\n    Admin,\r\n    Dual\r\n  }\r\n\r\n  enum AdminActionType {\r\n    AddStandardKey,\r\n    RemoveStandardKey,\r\n    SetStandardThreshold,\r\n    AddAdminKey,\r\n    RemoveAdminKey,\r\n    SetAdminThreshold,\r\n    AddDualKey,\r\n    RemoveDualKey,\r\n    SetDualThreshold\r\n  }\r\n\r\n  struct AdditionalKeyCount {\r\n    uint128 standard;\r\n    uint128 admin;\r\n  }\r\n\r\n  function takeAdminAction(\r\n    AdminActionType adminActionType, uint160 argument, bytes calldata signatures\r\n  ) external;\r\n\r\n  function getAdminActionID(\r\n    AdminActionType adminActionType, uint160 argument, uint256 nonce\r\n  ) external view returns (bytes32 adminActionID);\r\n\r\n  function getNextAdminActionID(\r\n    AdminActionType adminActionType, uint160 argument\r\n  ) external view returns (bytes32 adminActionID);\r\n\r\n  function getKeyCount() external view returns (\r\n    uint256 standardKeyCount, uint256 adminKeyCount\r\n  );\r\n\r\n  function getKeyType(\r\n    address key\r\n  ) external view returns (bool standard, bool admin);\r\n\r\n  function getNonce() external returns (uint256 nonce);\r\n\r\n  function getVersion() external pure returns (uint256 version);\r\n}\r\n\r\n\r\ninterface ERC1271 {\r\n  /**\r\n   * @dev Should return whether the signature provided is valid for the provided data\r\n   * @param data Arbitrary length data signed on the behalf of address(this)\r\n   * @param signature Signature byte array associated with data\r\n   *\r\n   * MUST return the bytes4 magic value 0x20c13b0b when function passes.\r\n   * MUST NOT modify state (using STATICCALL for solc \u003C 0.5, view modifier for solc \u003E 0.5)\r\n   * MUST allow external calls\r\n   */ \r\n  function isValidSignature(\r\n    bytes calldata data, \r\n    bytes calldata signature\r\n  ) external view returns (bytes4 magicValue);\r\n}\r\n\r\n\r\nlibrary ECDSA {\r\n  function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {\r\n    if (signature.length != 65) {\r\n      return (address(0));\r\n    }\r\n\r\n    bytes32 r;\r\n    bytes32 s;\r\n    uint8 v;\r\n\r\n    assembly {\r\n      r := mload(add(signature, 0x20))\r\n      s := mload(add(signature, 0x40))\r\n      v := byte(0, mload(add(signature, 0x60)))\r\n    }\r\n\r\n    if (uint256(s) \u003E 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {\r\n      return address(0);\r\n    }\r\n\r\n    if (v != 27 \u0026\u0026 v != 28) {\r\n      return address(0);\r\n    }\r\n\r\n    return ecrecover(hash, v, r, s);\r\n  }\r\n\r\n  function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {\r\n    return keccak256(abi.encodePacked(\u0022\\x19Ethereum Signed Message:\\n32\u0022, hash));\r\n  }\r\n}\r\n\r\n\r\n/**\r\n * @title DharmaKeyRingImplementationV0\r\n * @author 0age\r\n * @notice The Dharma Key Ring is a smart contract that implements ERC-1271 and\r\n * can be used in place of an externally-owned account for the user signing key\r\n * on the Dharma Smart Wallet to support multiple user signing keys. For this V0\r\n * implementation, new Dual keys (standard \u002B admin) can be added, but cannot be\r\n * removed, and the action threshold is fixed at one. Upgrades are managed by an\r\n * upgrade beacon, similar to the one utilized by the Dharma Smart Wallet. Note\r\n * that this implementation only implements the minimum feature set required to\r\n * support multiple user signing keys on the current Dharma Smart Wallet, and\r\n * that it will likely be replaced with a new, more full-featured implementation\r\n * relatively soon.\r\n */\r\ncontract DharmaKeyRingImplementationV0 is\r\n  DharmaKeyRingImplementationV0Interface,\r\n  ERC1271 {\r\n  using ECDSA for bytes32;\r\n  // WARNING: DO NOT REMOVE OR REORDER STORAGE WHEN WRITING NEW IMPLEMENTATIONS!\r\n\r\n  // Track all keys as an address (as uint160) =\u003E key type mapping in slot zero.\r\n  mapping (uint160 =\u003E KeyType) private _keys;\r\n\r\n  // Track the nonce in slot 1 so that actions cannot be replayed. Note that\r\n  // proper nonce management must be managed by the implementing contract when\r\n  // using \u0060isValidSignature\u0060, as it is a static method and cannot change state.\r\n  uint256 private _nonce;\r\n\r\n  // Track the total number of standard and admin keys in storage slot 2.\r\n  AdditionalKeyCount private _additionalKeyCounts;\r\n\r\n  // Track the required threshold standard and admin actions in storage slot 3.\r\n  // AdditionalThreshold private _additionalThresholds;\r\n\r\n  // END STORAGE DECLARATIONS - DO NOT REMOVE OR REORDER STORAGE ABOVE HERE!\r\n\r\n  // The key ring version will be used when constructing valid signatures.\r\n  uint256 internal constant _DHARMA_KEY_RING_VERSION = 0;\r\n\r\n  // ERC-1271 must return this magic value when \u0060isValidSignature\u0060 is called.\r\n  bytes4 internal constant _ERC_1271_MAGIC_VALUE = bytes4(0x20c13b0b);\r\n\r\n  /**\r\n   * @notice In initializer, set up an initial user signing key. For V0, the\r\n   * adminThreshold and executorThreshold arguments must both be equal to 1 and\r\n   * exactly one key with a key type of 3 (Dual key) must be supplied. Note that\r\n   * this initializer is only callable while the key ring instance is still in\r\n   * the contract creation phase.\r\n   * @param adminThreshold uint128 Must be equal to 1 in V0.\r\n   * @param executorThreshold uint128 Must be equal to 1 in V0.\r\n   * @param keys address[] The initial user signing key for the key ring. Must\r\n   * have exactly one non-null key in V0.\r\n   * @param keyTypes uint8[] Must be equal to [3].\r\n   */\r\n  function initialize(\r\n    uint128 adminThreshold,\r\n    uint128 executorThreshold,\r\n    address[] calldata keys,\r\n    uint8[] calldata keyTypes // must all be 3 (Dual) for V0\r\n  ) external {\r\n    // Ensure that this function is only callable during contract construction.\r\n    assembly { if extcodesize(address) { revert(0, 0) } }\r\n\r\n    // V0 only allows setting a singly Dual key with thresholds both set to 1.\r\n    require(keys.length == 1, \u0022Must supply exactly one key in V0.\u0022);\r\n\r\n    require(keys[0] != address(0), \u0022Cannot supply the null address as a key.\u0022);\r\n\r\n    require(\r\n      keyTypes.length == 1 \u0026\u0026 keyTypes[0] == uint8(3),\r\n      \u0022Must supply exactly one Dual keyType (3) in V0.\u0022\r\n    );\r\n\r\n    require(adminThreshold == 1, \u0022Admin threshold must be exactly one in V0.\u0022);\r\n\r\n    require(\r\n      executorThreshold == 1, \u0022Executor threshold must be exactly one in V0.\u0022\r\n    );\r\n\r\n    // Set the key and emit a corresponding event.\r\n    _keys[uint160(keys[0])] = KeyType.Dual;\r\n    emit KeyModified(keys[0], true, true);\r\n\r\n    // Note: skip additional key counts \u002B thresholds setup in V0 (only one key).\r\n  }\r\n\r\n  /**\r\n   * @notice Supply a signature from one of the existing keys on the keyring in\r\n   * order to add a new key. \r\n   * @param adminActionType uint8 Must be equal to 6 in V0.\r\n   * @param argument uint160 The signing address to add to the key ring.\r\n   * @param signatures bytes A signature from an existing key on the key ring.\r\n   */\r\n  function takeAdminAction(\r\n    AdminActionType adminActionType, uint160 argument, bytes calldata signatures\r\n  ) external {\r\n    // Only Admin Action Type 6 (AddDualKey) is supported in V0.\r\n    require(\r\n      adminActionType == AdminActionType.AddDualKey,\r\n      \u0022Only adding new Dual key types (admin action type 6) is supported in V0.\u0022\r\n    );\r\n\r\n    require(argument != uint160(0), \u0022Cannot supply the null address as a key.\u0022);\r\n\r\n    require(_keys[argument] == KeyType.None, \u0022Key already exists.\u0022);\r\n\r\n    // Verify signature against an admin action hash derived from the argument.\r\n    _verifySignature(_getAdminActionHash(argument, _nonce), signatures);\r\n\r\n    // Increment the key count for both standard and admin keys.\r\n    _additionalKeyCounts.standard\u002B\u002B;\r\n    _additionalKeyCounts.admin\u002B\u002B;\r\n\r\n    // Set the key and emit a corresponding event.\r\n    _keys[argument] = KeyType.Dual;\r\n    emit KeyModified(address(argument), true, true);\r\n\r\n    // Increment the nonce.\r\n    _nonce\u002B\u002B;\r\n  }\r\n\r\n  /**\r\n   * @notice View function that implements ERC-1271 and validates a signature\r\n   * against one of the keys on the keyring based on the supplied data. The data\r\n   * must be ABI encoded as (bytes32, uint8, bytes) - in V0, only the first\r\n   * bytes32 parameter is used to validate the supplied signature.\r\n   * @param data bytes The data used to validate the signature.\r\n   * @param signature bytes A signature from an existing key on the key ring.\r\n   * @return The 4-byte magic value to signify a valid signature in ERC-1271, if\r\n   * the signature is valid.\r\n   */\r\n  function isValidSignature(\r\n    bytes calldata data, bytes calldata signature\r\n  ) external view returns (bytes4 magicValue) {\r\n    (bytes32 hash, , ) = abi.decode(data, (bytes32, uint8, bytes));\r\n\r\n    _verifySignature(hash, signature);\r\n\r\n    magicValue = _ERC_1271_MAGIC_VALUE;\r\n  }\r\n\r\n  /**\r\n   * @notice View function that returns the message hash that must be signed in\r\n   * order to add a new key to the key ring based on the supplied parameters.\r\n   * @param adminActionType uint8 Unused in V0, as only action type 6 is valid.\r\n   * @param argument uint160 The signing address to add to the key ring.\r\n   * @param nonce uint256 The nonce to use when deriving the message hash.\r\n   * @return The message hash to sign.\r\n   */\r\n  function getAdminActionID(\r\n    AdminActionType adminActionType, uint160 argument, uint256 nonce\r\n  ) external view returns (bytes32 adminActionID) {\r\n    adminActionType;\r\n    adminActionID = _getAdminActionHash(argument, nonce);\r\n  }\r\n\r\n  /**\r\n   * @notice View function that returns the message hash that must be signed in\r\n   * order to add a new key to the key ring based on the supplied parameters and\r\n   * using the current nonce of the key ring.\r\n   * @param adminActionType uint8 Unused in V0, as only action type 6 is valid.\r\n   * @param argument uint160 The signing address to add to the key ring.\r\n   * @return The message hash to sign.\r\n   */\r\n  function getNextAdminActionID(\r\n    AdminActionType adminActionType, uint160 argument\r\n  ) external view returns (bytes32 adminActionID) {\r\n    adminActionType;\r\n    adminActionID = _getAdminActionHash(argument, _nonce);\r\n  }\r\n\r\n  /**\r\n   * @notice Pure function for getting the current Dharma Key Ring version.\r\n   * @return The current Dharma Key Ring version.\r\n   */\r\n  function getVersion() external pure returns (uint256 version) {\r\n    version = _DHARMA_KEY_RING_VERSION;\r\n  }\r\n\r\n  /**\r\n   * @notice View function for getting the current number of both standard and\r\n   * admin keys that are set on the Dharma Key Ring. For V0, these should be the\r\n   * same value as one another.\r\n   * @return The number of standard and admin keys set on the Dharma Key Ring.\r\n   */\r\n  function getKeyCount() external view returns (\r\n    uint256 standardKeyCount, uint256 adminKeyCount\r\n  ) {\r\n    AdditionalKeyCount memory additionalKeyCount = _additionalKeyCounts;\r\n    standardKeyCount = uint256(additionalKeyCount.standard) \u002B 1;\r\n    adminKeyCount = uint256(additionalKeyCount.admin) \u002B 1;\r\n  }\r\n\r\n  /**\r\n   * @notice View function for getting standard and admin key status of a given\r\n   * address. For V0, these should both be true, or both be false (i.e. the key\r\n   * is not set).\r\n   * @param key address An account to check for key type information.\r\n   * @return Booleans for standard and admin key status for the given address.\r\n   */\r\n  function getKeyType(\r\n    address key\r\n  ) external view returns (bool standard, bool admin) {\r\n    KeyType keyType = _keys[uint160(key)];\r\n    standard = (keyType == KeyType.Standard || keyType == KeyType.Dual);\r\n    admin = (keyType == KeyType.Admin || keyType == KeyType.Dual);\r\n  }\r\n\r\n  /**\r\n   * @notice View function for getting the current nonce of the Dharma Key Ring.\r\n   * @return The current nonce set on the Dharma Key Ring.\r\n   */\r\n  function getNonce() external returns (uint256 nonce) {\r\n    nonce = _nonce;\r\n  }\r\n\r\n  /**\r\n   * @notice Internal view function for deriving the message hash that must be\r\n   * signed in order to add a new key to the key ring based on given parameters.\r\n   * Note that V0 does not include a prefix when constructing the message hash.\r\n   * @return The message hash to sign.\r\n   */\r\n  function _getAdminActionHash(\r\n    uint160 argument, uint256 nonce\r\n  ) internal view returns (bytes32 hash) {\r\n    hash = keccak256(\r\n      abi.encodePacked(\r\n        address(this), _DHARMA_KEY_RING_VERSION, nonce, argument\r\n      )\r\n    );\r\n  }\r\n\r\n  /**\r\n   * @notice Internal view function for verifying a signature and a message hash\r\n   * against the mapping of keys currently stored on the key ring. For V0, all\r\n   * stored keys are the Dual key type, and only a single signature is provided\r\n   * for verification at once since the threshold is fixed at one signature.\r\n   */\r\n  function _verifySignature(\r\n    bytes32 hash, bytes memory signature\r\n  ) internal view {   \r\n    require(\r\n      _keys[uint160(hash.recover(signature))] == KeyType.Dual,\r\n      \u0022Supplied signature does not have a signer with the required key type.\u0022\r\n    );\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getVersion\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022version\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022signature\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022isValidSignature\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes4\u0022,\u0022name\u0022:\u0022magicValue\u0022,\u0022type\u0022:\u0022bytes4\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022enum DharmaKeyRingImplementationV0Interface.AdminActionType\u0022,\u0022name\u0022:\u0022adminActionType\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022uint160\u0022,\u0022name\u0022:\u0022argument\u0022,\u0022type\u0022:\u0022uint160\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022signatures\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022takeAdminAction\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022adminThreshold\u0022,\u0022type\u0022:\u0022uint128\u0022},{\u0022internalType\u0022:\u0022uint128\u0022,\u0022name\u0022:\u0022executorThreshold\u0022,\u0022type\u0022:\u0022uint128\u0022},{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022keys\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022uint8[]\u0022,\u0022name\u0022:\u0022keyTypes\u0022,\u0022type\u0022:\u0022uint8[]\u0022}],\u0022name\u0022:\u0022initialize\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022key\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getKeyType\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022standard\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022admin\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022enum DharmaKeyRingImplementationV0Interface.AdminActionType\u0022,\u0022name\u0022:\u0022adminActionType\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022uint160\u0022,\u0022name\u0022:\u0022argument\u0022,\u0022type\u0022:\u0022uint160\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getAdminActionID\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022adminActionID\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getNonce\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022enum DharmaKeyRingImplementationV0Interface.AdminActionType\u0022,\u0022name\u0022:\u0022adminActionType\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022uint160\u0022,\u0022name\u0022:\u0022argument\u0022,\u0022type\u0022:\u0022uint160\u0022}],\u0022name\u0022:\u0022getNextAdminActionID\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022adminActionID\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getKeyCount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022standardKeyCount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022adminKeyCount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022key\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022standard\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022admin\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022KeyModified\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"DharmaKeyRingImplementationV0","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://20446861726d614b657952696e67496d706c656d656e746174696f6e56302020"}]