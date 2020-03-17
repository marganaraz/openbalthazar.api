[{"SourceCode":"pragma solidity ^0.4.24;\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n  address public owner;\r\n \r\n\r\n  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n\r\n  /**\r\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n  constructor () public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param newOwner The address to transfer ownership to.\r\n   */\r\n  function transferOwnership(address newOwner) onlyOwner public {\r\n    require(newOwner != address(0));\r\n    emit OwnershipTransferred(owner, newOwner);\r\n    owner = newOwner;\r\n  }\r\n}\r\n\r\ninterface token { function transfer(address, uint) external; }\r\n\r\ncontract DistributeTokens is Ownable{\r\n  \r\n  token tokenReward;\r\n  address public addressOfTokenUsedAsReward;\r\n  function setTokenReward(address _addr) public onlyOwner {\r\n    tokenReward = token(_addr);\r\n    addressOfTokenUsedAsReward = _addr;\r\n  }\r\n\r\n  function distributeVariable(address[] _addrs, uint[] _bals) public onlyOwner{\r\n    for(uint i = 0; i \u003C _addrs.length; \u002B\u002Bi){\r\n      tokenReward.transfer(_addrs[i],_bals[i]);\r\n    }\r\n  }\r\n  \r\n  function distributeEth(address[] _addrs, uint[] _bals) public onlyOwner {\r\n    for(uint i = 0; i \u003C _addrs.length; \u002B\u002Bi) {\r\n        _addrs[i].transfer(_bals[i]);\r\n    }\r\n  }\r\n\r\n  function distributeFixed(address[] _addrs, uint _amoutToEach) public onlyOwner{\r\n    for(uint i = 0; i \u003C _addrs.length; \u002B\u002Bi){\r\n      tokenReward.transfer(_addrs[i],_amoutToEach);\r\n    }\r\n  }\r\n  \r\n\r\n  \r\n  // accept ETH\r\n  function () payable public {}\r\n\r\n  function withdrawTokens(uint _amount) public onlyOwner {\r\n    tokenReward.transfer(owner,_amount);\r\n  }\r\n\r\n  function withdrawEth(uint _value) public onlyOwner {\r\n    owner.transfer(_value);\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setTokenReward\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addrs\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_bals\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022distributeEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022addressOfTokenUsedAsReward\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addrs\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_bals\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022distributeVariable\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addrs\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_amoutToEach\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022distributeFixed\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"DistributeTokens","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://8051fbcc3ba7d32b1faf231d21a51d189e5b16607980a924486e27b59e7e55d0"}]