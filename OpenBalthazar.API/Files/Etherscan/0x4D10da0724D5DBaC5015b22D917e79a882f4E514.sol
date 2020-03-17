[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\n// File: contracts/interfaces/CrowdsaleReserveInterface.sol\r\n\r\ninterface CrowdsaleReserveInterface {\r\n  function issueETH(address _receiver, uint256 _amount) external returns (bool);\r\n  function receiveETH(address _payer) external payable returns (bool);\r\n  function refundETHAsset(address _asset, uint256 _amount) external returns (bool);\r\n  function issueERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool);\r\n  function requestERC20(address _payer, uint256 _amount, address _tokenAddress) external returns (bool);\r\n  function approveERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool);\r\n  function refundERC20Asset(address _asset, uint256 _amount, address _tokenAddress) external returns (bool);\r\n}\r\n\r\n// File: contracts/interfaces/ERC20.sol\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ninterface ERC20 {\r\n  function decimals() external view returns (uint8);\r\n\r\n  function totalSupply() external view returns (uint256);\r\n\r\n  function balanceOf(address _who) external view returns (uint256);\r\n\r\n  function allowance(address _owner, address _spender) external view returns (uint256);\r\n\r\n  function transfer(address _to, uint256 _value) external returns (bool);\r\n\r\n  function approve(address _spender, uint256 _value) external returns (bool);\r\n\r\n  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);\r\n\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n  event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// File: contracts/interfaces/DividendInterface.sol\r\n\r\ninterface DividendInterface{\r\n  function issueDividends(uint _amount) external payable returns (bool);\r\n\r\n  // @dev Total number of tokens in existence\r\n  function totalSupply() external view returns (uint256);\r\n\r\n  function getERC20() external view returns (address);\r\n}\r\n\r\n// File: contracts/database/CrowdsaleReserve.sol\r\n\r\ninterface Events {\r\n  function transaction(string _message, address _from, address _to, uint _amount, address _token)  external;\r\n}\r\ninterface DB {\r\n  function addressStorage(bytes32 _key) external view returns (address);\r\n  function uintStorage(bytes32 _key) external view returns (uint);\r\n  function setUint(bytes32 _key, uint _value) external;\r\n  function deleteUint(bytes32 _key) external;\r\n  function setBool(bytes32 _key, bool _value) external;\r\n  function boolStorage(bytes32 _key) external view returns (bool);\r\n}\r\n\r\ncontract CrowdsaleReserve is CrowdsaleReserveInterface{\r\n  DB private database;\r\n  Events private events;\r\n\r\n  constructor(address _database, address _events) public {\r\n    database = DB(_database);\r\n    events = Events(_events);\r\n  }\r\n  function issueETH(address _receiver, uint256 _amount) external returns (bool){\r\n    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked(\u0022contract\u0022, \u0022CrowdsaleETH\u0022))), \u0027Contract not authorized\u0027);\r\n    require(address(this).balance \u003E= _amount, \u0027Not enough funds\u0027);\r\n    _receiver.transfer(_amount);\r\n    events.transaction(\u0022Ether withdrawn from crowdsale reserve\u0022, address(this), _receiver, _amount, address(0));\r\n    return true;\r\n  }\r\n  function receiveETH(address _payer) external payable returns (bool){\r\n    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked(\u0022contract\u0022, \u0022CrowdsaleETH\u0022))), \u0027Contract not authorized\u0027);\r\n    events.transaction(\u0022Ether received by crowdsale reserve\u0022, address(this), _payer, msg.value, address(0));\r\n    return true;\r\n  }\r\n  function refundETHAsset(address _asset, uint256 _amount) external returns (bool){\r\n    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked(\u0022contract\u0022, \u0022CrowdsaleETH\u0022))), \u0027Contract not authorized\u0027);\r\n    require(DividendInterface(_asset).issueDividends.value(_amount)(_amount), \u0027Dividend issuance failed\u0027);\r\n    events.transaction(\u0022Asset issued refund by crowdsale reserve\u0022, _asset, address(this), _amount, address(0));\r\n    return true;\r\n  }\r\n  function issueERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool){\r\n    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked(\u0022contract\u0022, \u0022CrowdsaleERC20\u0022))), \u0027Contract not authorized\u0027);\r\n    ERC20 erc20 = ERC20(_tokenAddress);\r\n    require(erc20.balanceOf(this) \u003E= _amount, \u0027Not enough funds\u0027);\r\n    require(erc20.transfer(_receiver, _amount), \u0027Transfer failed\u0027);\r\n    events.transaction(\u0022ERC20 withdrawn from crowdsale reserve\u0022, address(this), _receiver, _amount, _tokenAddress);\r\n    return true;\r\n  }\r\n  function requestERC20(address _payer, uint256 _amount, address _tokenAddress) external returns (bool){\r\n    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked(\u0022contract\u0022, \u0022CrowdsaleERC20\u0022))), \u0027Contract not authorized\u0027);\r\n    require(ERC20(_tokenAddress).transferFrom(_payer, address(this), _amount), \u0027Transfer failed\u0027);\r\n    events.transaction(\u0022ERC20 received by crowdsale reserve\u0022, _payer, address(this), _amount, _tokenAddress);\r\n  }\r\n  function approveERC20(address _receiver, uint256 _amount, address _tokenAddress) public returns (bool){\r\n    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked(\u0022contract\u0022, \u0022CrowdsaleERC20\u0022))), \u0027Contract not authorized\u0027);\r\n    ERC20(_tokenAddress).approve(_receiver, _amount); //always returns true\r\n    events.transaction(\u0022ERC20 approval given by crowdsale reserve\u0022, address(this), _receiver, _amount, _tokenAddress);\r\n    return true;\r\n  }\r\n  function refundERC20Asset(address _asset, uint256 _amount, address _tokenAddress) external returns (bool){\r\n    approveERC20(_asset, _amount, _tokenAddress);\r\n    require(DividendInterface(_asset).issueDividends(_amount), \u0027Dividend issuance failed\u0027);\r\n    events.transaction(\u0022Asset issued refund by crowdsale reserve\u0022, _asset, address(this), _amount, _tokenAddress);\r\n    return true;\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022issueERC20\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_payer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022requestERC20\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022issueETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_asset\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022refundETHAsset\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_payer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022receiveETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_receiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022approveERC20\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_asset\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022refundERC20Asset\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_database\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_events\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"CrowdsaleReserve","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000005fcebeb70b88e86dd880352684e775b0f4d57c71000000000000000000000000eb6533f29a54c2c18bb2ce2a100de717692a518f","Library":"","SwarmSource":"bzzr://d43660c69cfb064144d02cd4928d570fa0ab94b0774ed71215f822a0cabfaf89"}]