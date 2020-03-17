[{"SourceCode":"pragma solidity 0.5.11; // optimization disabled, evm version: petersburg\r\n\r\n\r\n/**\r\n * @title DharmaUpgradeMultisig\r\n * @author 0age (derived from Christian Lundkvist\u0027s Simple Multisig)\r\n * @notice This contract is a multisig that will control upgrades to the Dharma\r\n * Smart Wallet and the Dharma Key Ring via the Dharma Upgrade Beacon Controller\r\n * Manager. it is based on Christian Lundkvist\u0027s Simple Multisig (found at\r\n * https://github.com/christianlundkvist/simple-multisig). The address of the\r\n * Dharma Upgrade Beacon Controller Manager is hard-coded as the only allowable\r\n * call destination, and any changes in ownership or signature threshold will\r\n * require deploying a new multisig and transferring ownership of the upgrade\r\n * beacon controller manager.\r\n */\r\ncontract DharmaUpgradeMultisig {\r\n  // The nonce is the only mutable state, and is incremented on every call.\r\n  uint256 private _nonce;\r\n\r\n  // Maintain a mapping and a convenience array of owners.\r\n  mapping(address =\u003E bool) private _isOwner;\r\n  address[] private _owners;\r\n\r\n  // This multisig can only call the Upgrade Beacon Controller Manager contract.\r\n  address private constant _DESTINATION = address(\r\n    0x0000000000415B1381260aE0F9f78d8207452815\r\n  );\r\n\r\n  // The threshold is an exact number of valid signatures that must be supplied.\r\n  uint256 private constant _THRESHOLD = 3;\r\n\r\n  // Note: Owners must be strictly increasing in order to prevent duplicates.\r\n  constructor(address[] memory owners) public {\r\n    require(owners.length \u003C= 10, \u0022Cannot have more than 10 owners.\u0022);\r\n    require(_THRESHOLD \u003C= owners.length, \u0022Threshold cannot exceed total owners.\u0022);\r\n\r\n    address lastAddress = address(0);\r\n    for (uint256 i = 0; i \u003C owners.length; i\u002B\u002B) {\r\n      require(\r\n        owners[i] \u003E lastAddress, \u0022Owner addresses must be strictly increasing.\u0022\r\n      );\r\n      _isOwner[owners[i]] = true;\r\n      lastAddress = owners[i];\r\n    }\r\n    _owners = owners;\r\n  }\r\n\r\n  function getNextHash(\r\n    bytes calldata data,\r\n    address executor,\r\n    uint256 gasLimit\r\n  ) external view returns (bytes32 hash) {\r\n    hash = _getHash(data, executor, gasLimit, _nonce);\r\n  }\r\n\r\n  function getHash(\r\n    bytes calldata data,\r\n    address executor,\r\n    uint256 gasLimit,\r\n    uint256 nonce\r\n  ) external view returns (bytes32 hash) {\r\n    hash = _getHash(data, executor, gasLimit, nonce);\r\n  }\r\n\r\n  function getNonce() external view returns (uint256 nonce) {\r\n    nonce = _nonce;\r\n  }\r\n\r\n  function getOwners() external view returns (address[] memory owners) {\r\n    owners = _owners;\r\n  }\r\n\r\n  function isOwner(address account) external view returns (bool owner) {\r\n    owner = _isOwner[account];\r\n  }\r\n\r\n  function getThreshold() external pure returns (uint256 threshold) {\r\n    threshold = _THRESHOLD;\r\n  }\r\n\r\n  function getDestination() external pure returns (address destination) {\r\n    destination = _DESTINATION;\r\n  }\r\n\r\n  // Note: addresses recovered from signatures must be strictly increasing.\r\n  function execute(\r\n    bytes calldata data,\r\n    address executor,\r\n    uint256 gasLimit,\r\n    bytes calldata signatures\r\n  ) external returns (bool success, bytes memory returnData) {\r\n    require(\r\n      executor == msg.sender || executor == address(0),\r\n      \u0022Must call from the executor account if one is specified.\u0022\r\n    );\r\n\r\n    // Derive the message hash and wrap in the eth signed messsage hash.\r\n    bytes32 hash = _toEthSignedMessageHash(\r\n      _getHash(data, executor, gasLimit, _nonce)\r\n    );\r\n\r\n    // Recover each signer from the provided signatures.\r\n    address[] memory signers = _recoverGroup(hash, signatures);\r\n\r\n    require(signers.length == _THRESHOLD, \u0022Total signers must equal threshold.\u0022);\r\n\r\n    // Verify that each signatory is an owner and is strictly increasing.\r\n    address lastAddress = address(0); // cannot have address(0) as an owner\r\n    for (uint256 i = 0; i \u003C signers.length; i\u002B\u002B) {\r\n      require(\r\n        _isOwner[signers[i]], \u0022Signature does not correspond to an owner.\u0022\r\n      );\r\n      require(\r\n        signers[i] \u003E lastAddress, \u0022Signer addresses must be strictly increasing.\u0022\r\n      );\r\n      lastAddress = signers[i];\r\n    }\r\n\r\n    // Increment the nonce and execute the transaction.\r\n    _nonce\u002B\u002B;\r\n    (success, returnData) = _DESTINATION.call.gas(gasLimit)(data);\r\n  }\r\n\r\n  function _getHash(\r\n    bytes memory data,\r\n    address executor,\r\n    uint256 gasLimit,\r\n    uint256 nonce\r\n  ) internal view returns (bytes32 hash) {\r\n    // Note: this is the data used to create a personal signed message hash.\r\n    hash = keccak256(\r\n      abi.encodePacked(address(this), nonce, executor, gasLimit, data)\r\n    );\r\n  }\r\n\r\n  /**\r\n   * @dev Returns each address that signed a hashed message (\u0060hash\u0060) from a\r\n   * collection of \u0060signatures\u0060.\r\n   *\r\n   * The \u0060ecrecover\u0060 EVM opcode allows for malleable (non-unique) signatures:\r\n   * this function rejects them by requiring the \u0060s\u0060 value to be in the lower\r\n   * half order, and the \u0060v\u0060 value to be either 27 or 28.\r\n   *\r\n   * NOTE: This call _does not revert_ if a signature is invalid, or if the\r\n   * signer is otherwise unable to be retrieved. In those scenarios, the zero\r\n   * address is returned for that signature.\r\n   *\r\n   * IMPORTANT: \u0060hash\u0060 _must_ be the result of a hash operation for the\r\n   * verification to be secure: it is possible to craft signatures that recover\r\n   * to arbitrary addresses for non-hashed data.\r\n   */\r\n  function _recoverGroup(\r\n    bytes32 hash,\r\n    bytes memory signatures\r\n  ) internal pure returns (address[] memory signers) {\r\n    // Ensure that the signatures length is a multiple of 65.\r\n    if (signatures.length % 65 != 0) {\r\n      return new address[](0);\r\n    }\r\n\r\n    // Create an appropriately-sized array of addresses for each signer.\r\n    signers = new address[](signatures.length / 65);\r\n\r\n    // Get each signature location and divide into r, s and v variables.\r\n    bytes32 signatureLocation;\r\n    bytes32 r;\r\n    bytes32 s;\r\n    uint8 v;\r\n\r\n    for (uint256 i = 0; i \u003C signers.length; i\u002B\u002B) {\r\n      assembly {\r\n        signatureLocation := add(signatures, mul(i, 65))\r\n        r := mload(add(signatureLocation, 32))\r\n        s := mload(add(signatureLocation, 64))\r\n        v := byte(0, mload(add(signatureLocation, 96)))\r\n      }\r\n\r\n      // EIP-2 still allows signature malleability for ecrecover(). Remove\r\n      // this possibility and make the signature unique.\r\n      if (uint256(s) \u003E 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {\r\n        continue;\r\n      }\r\n\r\n      if (v != 27 \u0026\u0026 v != 28) {\r\n        continue;\r\n      }\r\n\r\n      // If signature is valid \u0026 not malleable, add signer address.\r\n      signers[i] = ecrecover(hash, v, r, s);\r\n    }\r\n  }\r\n\r\n  function _toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {\r\n    return keccak256(abi.encodePacked(\u0022\\x19Ethereum Signed Message:\\n32\u0022, hash));\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022executor\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022gasLimit\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getHash\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022hash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getDestination\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022destination\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022executor\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022gasLimit\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getNextHash\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022hash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getOwners\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022owners\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getNonce\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getThreshold\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022threshold\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022executor\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022gasLimit\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022signatures\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022execute\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022returnData\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022owners\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"DharmaUpgradeMultisig","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000500000000000000000000000097659dab3885339dca94a1ffa319cfb2f1b18d8c000000000000000000000000a7e36e02a59c5ddd85c1a30177091db9790a2b29000000000000000000000000c1fb35ed6440c5a99ec6372a20541f92812a4b30000000000000000000000000e1ee55f4c4959bd680aa397c29bf3e957f744044000000000000000000000000f70f7983f765f72c05f725f506d3f1197704e128","Library":"","SwarmSource":"bzzr://08e5c4a1804fe9bac45c9a515a8b3994eed51bcd252fba9ab1b03d93e8d9ca92"}]