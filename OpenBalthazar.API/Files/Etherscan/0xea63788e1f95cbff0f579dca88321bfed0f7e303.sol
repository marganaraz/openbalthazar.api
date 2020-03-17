[{"SourceCode":"pragma solidity ^0.5.16;\r\n\r\ncontract Proxy {\r\n  function implementation() public view returns (address);\r\n\r\n  function () payable external {\r\n    address impl = implementation();\r\n    require(impl != address(0), \u0022impl != address(0)\u0022);\r\n\r\n    assembly {\r\n      let ptr := mload(0x40)\r\n      calldatacopy(ptr, 0, calldatasize)\r\n      let result := delegatecall(gas, impl, ptr, calldatasize, 0, 0)\r\n      let size := returndatasize\r\n      returndatacopy(ptr, 0, size)\r\n\r\n      switch result\r\n      case 0 { revert(ptr, size) }\r\n      default { return(ptr, size) }\r\n    }\r\n  }\r\n}\r\nlibrary RW {\r\n    function read(bytes32 _position) internal view returns (address addr) {\r\n        assembly {\r\n            addr := sload(_position)\r\n        }\r\n    }\r\n    function write(bytes32 _position, address _addr) internal {\r\n        assembly {\r\n            sstore(_position, _addr)\r\n        }\r\n    }\r\n}\r\n\r\ncontract OwnedProxy is Proxy {\r\n    using RW for bytes32;\r\n\r\n    bytes32 private constant implementationPosition = keccak256(\u0022org.tl.proxy.implementation\u0022);\r\n    function implementation() public view returns (address impl) {\r\n        impl = implementationPosition.read();\r\n    }\r\n    \r\n    bytes32 private constant proxyOwnerPosition = keccak256(\u0022org.tl.proxy.owner\u0022);\r\n    function proxyOwner() public view returns (address owner) {\r\n        owner = proxyOwnerPosition.read();\r\n    }\r\n\r\n    bytes32 private constant proxyNewOwnerPosition = keccak256(\u0022org.tl.proxy.newOwner\u0022);\r\n    function proxyNewOwner() public view returns (address newOwner) {\r\n        newOwner = proxyNewOwnerPosition.read();\r\n    }\r\n\r\n    constructor() public {\r\n        proxyOwnerPosition.write(msg.sender);\r\n    }\r\n\r\n    modifier onlyProxyOwner() {\r\n        require(msg.sender == proxyOwner(), \u0022msg.sender == proxyOwner()\u0022);\r\n        _;\r\n    }\r\n\r\n    function transferProxyOwnership(address _newOwner) public onlyProxyOwner {\r\n        require(_newOwner != address(0), \u0022_newOwner != address(0)\u0022);\r\n        proxyNewOwnerPosition.write(_newOwner);\r\n    }\r\n  \r\n    event ProxyOwnershipTransferred(address previousOwner, address newOwner);\r\n    function acceptProxyOwnership() public {\r\n    \trequire(msg.sender == proxyNewOwner(), \u0022msg.sender == proxyNewOwner()\u0022);\r\n        emit ProxyOwnershipTransferred(proxyOwner(), proxyNewOwner());\r\n        proxyOwnerPosition.write(proxyNewOwner());\r\n        proxyNewOwnerPosition.write(address(0));\r\n    }\r\n\r\n    event Upgraded(address indexed implementation);\r\n    function upgradeTo(address _newImpl) public onlyProxyOwner {\r\n        implementationPosition.write(_newImpl);\r\n        emit Upgraded(_newImpl);\r\n    }\r\n\r\n    function upgradeToAndCall(address _newImpl, bytes memory _data) payable public onlyProxyOwner {\r\n        upgradeTo(_newImpl);\r\n        (bool txOk, ) = address(this).call.value(msg.value)(_data);\r\n        require(txOk, \u0022txOk\u0022);\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022ProxyOwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022implementation\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Upgraded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptProxyOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022implementation\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022impl\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022proxyNewOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022proxyOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferProxyOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newImpl\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022upgradeTo\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newImpl\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022upgradeToAndCall\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"OwnedProxy","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://625277d016e1275090948db5689c7fea5c5686f8e4f07ebe013fa14e84a5aa5c"}]