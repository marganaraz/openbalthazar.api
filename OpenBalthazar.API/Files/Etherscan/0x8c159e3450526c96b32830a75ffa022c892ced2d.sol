[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\ncontract ExpTokenProxy {\r\n    bytes32 private constant proxyOwner = keccak256(\u0022exptoken.proxy.owner\u0022);\r\n    bytes32 private constant proxyImplementation = keccak256(\u0022exptoken.proxy.implementation\u0022);\r\n    bytes32 private constant proxyVersion = keccak256(\u0022exptoken.proxy.version\u0022);\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    event UpdateContract(address indexed implAddress, uint256 version);\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022failure\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @return true if \u0060msg.sender\u0060 is the owner of the contract.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == getOwner();\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to relinquish control of the contract.\r\n     * @notice Renouncing to ownership will leave the contract without an owner.\r\n     * It will not be possible to call the functions with the \u0060onlyOwner\u0060\r\n     * modifier anymore.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(getOwner(), address(0));\r\n        address _address = address(0);\r\n        bytes32 position = proxyOwner;\r\n        assembly {\r\n            sstore(position, _address)\r\n        }\r\n    }\r\n\r\n    function getOwner() public view returns (address owner) {\r\n        bytes32 position = proxyOwner;\r\n        assembly {\r\n            owner := sload(position)\r\n        }\r\n    }\r\n\r\n    constructor() public {\r\n        bytes32 position = proxyOwner;\r\n        address owner = msg.sender;\r\n        assembly {\r\n            sstore(position, owner)\r\n        }\r\n        emit OwnershipTransferred(address(0), owner);\r\n    }\r\n\r\n    function setImplementation(address _address, uint256 _version) public onlyOwner {\r\n        bytes32 implPosition = proxyImplementation;\r\n        bytes32 versionPosition = proxyVersion;\r\n        assembly {\r\n            sstore(implPosition, _address)\r\n            sstore(versionPosition, _version)\r\n        }\r\n        emit UpdateContract(_address, _version);\r\n    }\r\n\r\n    function getImplementation() public view returns (address implementaion) {\r\n        bytes32 position = proxyImplementation;\r\n        assembly {\r\n            implementaion := sload(position)\r\n        }\r\n    }\r\n\r\n    function getVersion() public view returns (uint256 version) {\r\n        bytes32 position = proxyVersion;\r\n        assembly {\r\n            version := sload(position)\r\n        }\r\n    }\r\n\r\n    /**\r\n    * @dev Fallback function allowing to perform a delegatecall to the given implementation.\r\n    * This function will return whatever the implementation call returns\r\n    */\r\n    function () external payable {\r\n        address _impl = getImplementation();\r\n        require(_impl != address(0), \u0022failure\u0022);\r\n\r\n        assembly {\r\n            let ptr := mload(0x40)\r\n            calldatacopy(ptr, 0, calldatasize)\r\n            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)\r\n            let size := returndatasize\r\n            returndatacopy(ptr, 0, size)\r\n\r\n            switch result\r\n            case 0 { revert(ptr, size) }\r\n            default { return(ptr, size) }\r\n        }\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getVersion\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022version\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_version\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setImplementation\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getImplementation\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022implementaion\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022implAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022version\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022UpdateContract\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"ExpTokenProxy","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://8dfc1bb5db87f3332b8ae81e98ba1b7cb20f37604869823115476d44134633bd"}]