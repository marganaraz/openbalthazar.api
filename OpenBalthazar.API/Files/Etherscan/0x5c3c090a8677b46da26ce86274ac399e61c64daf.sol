[{"SourceCode":"pragma solidity 0.4.24;\r\n\r\n/**\r\n * @title Proxy\r\n * @dev Gives the possibility to delegate any call to a foreign implementation.\r\n */\r\ncontract Proxy {\r\n  /**\r\n  * @dev Tells the address of the implementation where every call will be delegated.\r\n  * @return address of the implementation to which it will be delegated\r\n  */\r\n  function implementation() public view returns (address);\r\n  \r\n  /**\r\n  * @dev Tells the version of the current implementation\r\n  * @return version of the current implementation\r\n  */\r\n  function version() public view returns (string);\r\n\r\n  /**\r\n  * @dev Fallback function allowing to perform a delegatecall to the given implementation.\r\n  * This function will return whatever the implementation call returns\r\n  */\r\n  function () payable public {\r\n    address _impl = implementation();\r\n    require(_impl != address(0));\r\n\r\n    assembly {\r\n      let ptr := mload(0x40)\r\n      calldatacopy(ptr, 0, calldatasize)\r\n      let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)\r\n      let size := returndatasize\r\n      returndatacopy(ptr, 0, size)\r\n\r\n      switch result\r\n      case 0 { revert(ptr, size) }\r\n      default { return(ptr, size) }\r\n    }\r\n  }\r\n}\r\n\r\npragma solidity 0.4.24;\r\n\r\n/**\r\n * @title UpgradeabilityProxy\r\n * @dev This contract represents a proxy where the implementation address to which it will delegate can be upgraded\r\n */\r\ncontract UpgradeabilityProxy is Proxy {\r\n  /**\r\n   * @dev This event will be emitted every time the implementation gets upgraded\r\n   * @param implementation representing the address of the upgraded implementation\r\n   */\r\n  event Upgraded(address indexed implementation, string version);\r\n\r\n  // Storage position of the address of the current implementation\r\n  bytes32 private constant implementationPosition = keccak256(\u0022bulksender.app.proxy.implementation\u0022);\r\n  \r\n   //Version name of the current implementation\r\n  string internal _version;\r\n\r\n  /**\r\n   * @dev Constructor function\r\n   */\r\n  constructor() public {}\r\n  \r\n  \r\n  /**\r\n    * @dev Tells the version name of the current implementation\r\n    * @return string representing the name of the current version\r\n    */\r\n    function version() public view returns (string) {\r\n        return _version;\r\n    }\r\n\r\n  /**\r\n   * @dev Tells the address of the current implementation\r\n   * @return address of the current implementation\r\n   */\r\n  function implementation() public view returns (address impl) {\r\n    bytes32 position = implementationPosition;\r\n    assembly {\r\n      impl := sload(position)\r\n    }\r\n  }\r\n\r\n  /**\r\n   * @dev Sets the address of the current implementation\r\n   * @param _newImplementation address representing the new implementation to be set\r\n   */\r\n  function _setImplementation(address _newImplementation) internal {\r\n    bytes32 position = implementationPosition;\r\n    assembly {\r\n      sstore(position, _newImplementation)\r\n    }\r\n  }\r\n\r\n  /**\r\n   * @dev Upgrades the implementation address\r\n   * @param _newImplementation representing the address of the new implementation to be set\r\n   */\r\n  function _upgradeTo(address _newImplementation, string _newVersion) internal {\r\n    address currentImplementation = implementation();\r\n    require(currentImplementation != _newImplementation);\r\n    _setImplementation(_newImplementation);\r\n    _version = _newVersion;\r\n    emit Upgraded( _newImplementation, _newVersion);\r\n  }\r\n}\r\n\r\n\r\npragma solidity 0.4.24;\r\n/**\r\n * @title BulksenderProxy\r\n * @dev This contract combines an upgradeability proxy with basic authorization control functionalities\r\n */\r\ncontract BulksenderProxy is UpgradeabilityProxy {\r\n  /**\r\n  * @dev Event to show ownership has been transferred\r\n  * @param previousOwner representing the address of the previous owner\r\n  * @param newOwner representing the address of the new owner\r\n  */\r\n  event ProxyOwnershipTransferred(address previousOwner, address newOwner);\r\n\r\n  // Storage position of the owner of the contract\r\n  bytes32 private constant proxyOwnerPosition = keccak256(\u0022bulksender.app.proxy.owner\u0022);\r\n\r\n  /**\r\n  * @dev the constructor sets the original owner of the contract to the sender account.\r\n  */\r\n  constructor(address _implementation, string _version) public {\r\n    _setUpgradeabilityOwner(msg.sender);\r\n    _upgradeTo(_implementation, _version);\r\n  }\r\n\r\n  /**\r\n  * @dev Throws if called by any account other than the owner.\r\n  */\r\n  modifier onlyProxyOwner() {\r\n    require(msg.sender == proxyOwner());\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Tells the address of the owner\r\n   * @return the address of the owner\r\n   */\r\n  function proxyOwner() public view returns (address owner) {\r\n    bytes32 position = proxyOwnerPosition;\r\n    assembly {\r\n      owner := sload(position)\r\n    }\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param _newOwner The address to transfer ownership to.\r\n   */\r\n  function transferProxyOwnership(address _newOwner) public onlyProxyOwner {\r\n    require(_newOwner != address(0));\r\n    _setUpgradeabilityOwner(_newOwner);\r\n    emit ProxyOwnershipTransferred(proxyOwner(), _newOwner);\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the proxy owner to upgrade the current version of the proxy.\r\n   * @param _implementation representing the address of the new implementation to be set.\r\n   */\r\n  function upgradeTo(address _implementation, string _newVersion) public onlyProxyOwner {\r\n    _upgradeTo(_implementation, _newVersion);\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the proxy owner to upgrade the current version of the proxy and call the new implementation\r\n   * to initialize whatever is needed through a low level call.\r\n   * @param _implementation representing the address of the new implementation to be set.\r\n   * @param _data represents the msg.data to bet sent in the low level call. This parameter may include the function\r\n   * signature of the implementation to be called with the needed payload\r\n   */\r\n  function upgradeToAndCall(address _implementation, string _newVersion, bytes _data) payable public onlyProxyOwner {\r\n    _upgradeTo(_implementation, _newVersion);\r\n    require(address(this).call.value(msg.value)(_data));\r\n  }\r\n\r\n  /*\r\n   * @dev Sets the address of the owner\r\n   */\r\n  function _setUpgradeabilityOwner(address _newProxyOwner) internal {\r\n    bytes32 position = proxyOwnerPosition;\r\n    assembly {\r\n      sstore(position, _newProxyOwner)\r\n    }\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022proxyOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_implementation\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_newVersion\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022upgradeTo\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022version\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022implementation\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022impl\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_implementation\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_newVersion\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022upgradeToAndCall\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferProxyOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_implementation\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_version\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022ProxyOwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022implementation\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022version\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022Upgraded\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"BulksenderProxy","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000108cf041aab8a65cdd0a78c1dc703b0dbb0a7659000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000037761790000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://cbecfef302270db700604906f023d6fee2ae523ac48f654562f5a404945f9631"}]