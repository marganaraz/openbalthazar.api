[{"SourceCode":"// File: contracts\\UtilitiesStorage.sol\r\n\r\npragma solidity ^0.4.21;\r\n\r\ncontract UtilitiesStorage {\r\n\r\n\tuint public constant ROLE_BIDDER = 1;\r\n\tuint public constant ROLE_ADVERTISER = 2;\r\n\tuint public constant ROLE_PUBLISHER = 3;\r\n\tuint public constant ROLE_VOTER = 4;\r\n\r\n\taddress public CONTRACT_MEMBERS;\r\n\taddress public CONTRACT_TOKEN;\r\n\r\n\tmapping (address =\u003E mapping (address =\u003E uint256)) deposits;\r\n}\r\n\r\n// File: node_modules\\openzeppelin-solidity\\contracts\\ownership\\Ownable.sol\r\n\r\npragma solidity ^0.4.24;\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n  address private _owner;\r\n\r\n  event OwnershipTransferred(\r\n    address indexed previousOwner,\r\n    address indexed newOwner\r\n  );\r\n\r\n  /**\r\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n  constructor() internal {\r\n    _owner = msg.sender;\r\n    emit OwnershipTransferred(address(0), _owner);\r\n  }\r\n\r\n  /**\r\n   * @return the address of the owner.\r\n   */\r\n  function owner() public view returns(address) {\r\n    return _owner;\r\n  }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(isOwner());\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @return true if \u0060msg.sender\u0060 is the owner of the contract.\r\n   */\r\n  function isOwner() public view returns(bool) {\r\n    return msg.sender == _owner;\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to relinquish control of the contract.\r\n   * @notice Renouncing to ownership will leave the contract without an owner.\r\n   * It will not be possible to call the functions with the \u0060onlyOwner\u0060\r\n   * modifier anymore.\r\n   */\r\n  function renounceOwnership() public onlyOwner {\r\n    emit OwnershipTransferred(_owner, address(0));\r\n    _owner = address(0);\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param newOwner The address to transfer ownership to.\r\n   */\r\n  function transferOwnership(address newOwner) public onlyOwner {\r\n    _transferOwnership(newOwner);\r\n  }\r\n\r\n  /**\r\n   * @dev Transfers control of the contract to a newOwner.\r\n   * @param newOwner The address to transfer ownership to.\r\n   */\r\n  function _transferOwnership(address newOwner) internal {\r\n    require(newOwner != address(0));\r\n    emit OwnershipTransferred(_owner, newOwner);\r\n    _owner = newOwner;\r\n  }\r\n}\r\n\r\n// File: contracts\\UtilitiesRegistry.sol\r\n\r\npragma solidity ^0.4.21;\r\n\r\n\r\n\r\ncontract UtilitiesRegistry is UtilitiesStorage, Ownable {\r\n\r\n\taddress private CONTRACT_ADDRESS;\r\n\r\n\tfunction setContractAddress(address newContractAddress) public onlyOwner {\r\n\t\tCONTRACT_ADDRESS = newContractAddress;\r\n\t}\r\n\r\n\tfunction () payable public {\r\n\t\taddress target = CONTRACT_ADDRESS;\r\n\t\tassembly {\r\n\t\t\t// Copy the data sent to the memory address starting free mem position\r\n\t\t\tlet ptr := mload(0x40)\r\n\t\t\tcalldatacopy(ptr, 0, calldatasize)\r\n\t\t\t// Proxy the call to the contract address with the provided gas and data\r\n\t\t\tlet result := delegatecall(gas, target, ptr, calldatasize, 0, 0)\r\n\t\t\t// Copy the data returned by the proxied call to memory\r\n\t\t\tlet size := returndatasize\r\n\t\t\treturndatacopy(ptr, 0, size)\r\n\t\t\t// Check what the result is, return and revert accordingly\r\n\t\t\tswitch result\r\n\t\t\tcase 0 { revert(ptr, size) }\r\n\t\t\tcase 1 { return(ptr, size) }\r\n\t\t}\r\n\t}\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ROLE_ADVERTISER\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022CONTRACT_MEMBERS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ROLE_BIDDER\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newContractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setContractAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ROLE_VOTER\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ROLE_PUBLISHER\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022CONTRACT_TOKEN\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"UtilitiesRegistry","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://3ce4e37d488a3f3fe8dff8a9d4e8c3aa0669af4e2b1e8be052b86910ebf06af1"}]