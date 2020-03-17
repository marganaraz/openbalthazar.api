[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\n// File: contracts/interfaces/ERC20.sol\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ninterface ERC20 {\r\n  function decimals() external view returns (uint8);\r\n\r\n  function totalSupply() external view returns (uint256);\r\n\r\n  function balanceOf(address _who) external view returns (uint256);\r\n\r\n  function allowance(address _owner, address _spender) external view returns (uint256);\r\n\r\n  function transfer(address _to, uint256 _value) external returns (bool);\r\n\r\n  function approve(address _spender, uint256 _value) external returns (bool);\r\n\r\n  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);\r\n\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n  event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// File: contracts/interfaces/DBInterface.sol\r\n\r\n// Database interface\r\ninterface DBInterface {\r\n\r\n  function setContractManager(address _contractManager)\r\n  external;\r\n\r\n    // --------------------Set Functions------------------------\r\n\r\n    function setAddress(bytes32 _key, address _value)\r\n    external;\r\n\r\n    function setUint(bytes32 _key, uint _value)\r\n    external;\r\n\r\n    function setString(bytes32 _key, string _value)\r\n    external;\r\n\r\n    function setBytes(bytes32 _key, bytes _value)\r\n    external;\r\n\r\n    function setBytes32(bytes32 _key, bytes32 _value)\r\n    external;\r\n\r\n    function setBool(bytes32 _key, bool _value)\r\n    external;\r\n\r\n    function setInt(bytes32 _key, int _value)\r\n    external;\r\n\r\n\r\n     // -------------- Deletion Functions ------------------\r\n\r\n    function deleteAddress(bytes32 _key)\r\n    external;\r\n\r\n    function deleteUint(bytes32 _key)\r\n    external;\r\n\r\n    function deleteString(bytes32 _key)\r\n    external;\r\n\r\n    function deleteBytes(bytes32 _key)\r\n    external;\r\n\r\n    function deleteBytes32(bytes32 _key)\r\n    external;\r\n\r\n    function deleteBool(bytes32 _key)\r\n    external;\r\n\r\n    function deleteInt(bytes32 _key)\r\n    external;\r\n\r\n    // ----------------Variable Getters---------------------\r\n\r\n    function uintStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (uint);\r\n\r\n    function stringStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (string);\r\n\r\n    function addressStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (address);\r\n\r\n    function bytesStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (bytes);\r\n\r\n    function bytes32Storage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (bytes32);\r\n\r\n    function boolStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (bool);\r\n\r\n    function intStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (bool);\r\n}\r\n\r\n// File: contracts/database/Events.sol\r\n\r\ncontract Events {\r\n  DBInterface public database;\r\n\r\n  constructor(address _database) public{\r\n    database = DBInterface(_database);\r\n  }\r\n\r\n  function message(string _message)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogEvent(_message, keccak256(abi.encodePacked(_message)), tx.origin);\r\n  }\r\n\r\n  function transaction(string _message, address _from, address _to, uint _amount, address _token)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogTransaction(_message, keccak256(abi.encodePacked(_message)), _from, _to, _amount, _token, tx.origin);\r\n  }\r\n\r\n  function registration(string _message, address _account)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogAddress(_message, keccak256(abi.encodePacked(_message)), _account, tx.origin);\r\n  }\r\n\r\n  function contractChange(string _message, address _account, string _name)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogContractChange(_message, keccak256(abi.encodePacked(_message)), _account, _name, tx.origin);\r\n  }\r\n\r\n  function asset(string _message, string _uri, address _assetAddress, address _manager)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogAsset(_message, keccak256(abi.encodePacked(_message)), _uri, keccak256(abi.encodePacked(_uri)), _assetAddress, _manager, tx.origin);\r\n  }\r\n\r\n  function escrow(string _message, address _assetAddress, bytes32 _escrowID, address _manager, uint _amount)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogEscrow(_message, keccak256(abi.encodePacked(_message)), _assetAddress, _escrowID, _manager, _amount, tx.origin);\r\n  }\r\n\r\n  function order(string _message, bytes32 _orderID, uint _amount, uint _price)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogOrder(_message, keccak256(abi.encodePacked(_message)), _orderID, _amount, _price, tx.origin);\r\n  }\r\n\r\n  function exchange(string _message, bytes32 _orderID, address _assetAddress, address _account)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogExchange(_message, keccak256(abi.encodePacked(_message)), _orderID, _assetAddress, _account, tx.origin);\r\n  }\r\n\r\n  function operator(string _message, bytes32 _id, string _name, string _ipfs, address _account)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogOperator(_message, keccak256(abi.encodePacked(_message)), _id, _name, _ipfs, _account, tx.origin);\r\n  }\r\n\r\n  function consensus(string _message, bytes32 _executionID, bytes32 _votesID, uint _votes, uint _tokens, uint _quorum)\r\n  external\r\n  onlyApprovedContract {\r\n    emit LogConsensus(_message, keccak256(abi.encodePacked(_message)), _executionID, _votesID, _votes, _tokens, _quorum, tx.origin);\r\n  }\r\n\r\n  //Generalized events\r\n  event LogEvent(string message, bytes32 indexed messageID, address indexed origin);\r\n  event LogTransaction(string message, bytes32 indexed messageID, address indexed from, address indexed to, uint amount, address token, address origin); //amount and token will be empty on some events\r\n  event LogAddress(string message, bytes32 indexed messageID, address indexed account, address indexed origin);\r\n  event LogContractChange(string message, bytes32 indexed messageID, address indexed account, string name, address indexed origin);\r\n  event LogAsset(string message, bytes32 indexed messageID, string uri, bytes32 indexed assetID, address asset, address manager, address indexed origin);\r\n  event LogEscrow(string message, bytes32 indexed messageID, address asset, bytes32  escrowID, address indexed manager, uint amount, address indexed origin);\r\n  event LogOrder(string message, bytes32 indexed messageID, bytes32 indexed orderID, uint amount, uint price, address indexed origin);\r\n  event LogExchange(string message, bytes32 indexed messageID, bytes32 orderID, address indexed asset, address account, address indexed origin);\r\n  event LogOperator(string message, bytes32 indexed messageID, bytes32 id, string name, string ipfs, address indexed account, address indexed origin);\r\n  event LogConsensus(string message, bytes32 indexed messageID, bytes32 executionID, bytes32 votesID, uint votes, uint tokens, uint quorum, address indexed origin);\r\n\r\n\r\n  // --------------------------------------------------------------------------------------\r\n  // Caller must be registered as a contract through ContractManager.sol\r\n  // --------------------------------------------------------------------------------------\r\n  modifier onlyApprovedContract() {\r\n      require(database.boolStorage(keccak256(abi.encodePacked(\u0022contract\u0022, msg.sender))));\r\n      _;\r\n  }\r\n\r\n}\r\n\r\n// File: contracts/math/SafeMath.sol\r\n\r\n// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol\r\n\r\n// @title SafeMath: overflow/underflow checks\r\n// @notice Math operations with safety checks that throw on error\r\nlibrary SafeMath {\r\n\r\n  // @notice Multiplies two numbers, throws on overflow.\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  // @notice Integer division of two numbers, truncating the quotient.\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    // uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return a / b;\r\n  }\r\n\r\n  // @notice Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  // @notice Adds two numbers, throws on overflow.\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n\r\n  // @notice Returns fractional amount\r\n  function getFractionalAmount(uint256 _amount, uint256 _percentage)\r\n  internal\r\n  pure\r\n  returns (uint256) {\r\n    return div(mul(_amount, _percentage), 100);\r\n  }\r\n\r\n}\r\n\r\n// File: contracts/roles/AssetManagerFunds.sol\r\n\r\ninterface DToken {\r\n  function withdraw() external returns (bool);\r\n  function getAmountOwed(address _user) external view returns (uint);\r\n  function balanceOf(address _tokenHolder) external view returns (uint);\r\n  function transfer(address _to, uint _amount) external returns (bool success);\r\n  function getERC20() external  view returns (address);\r\n}\r\n\r\n// @title A dividend-token holding contract that locks tokens and retrieves dividends for assetManagers\r\n// @notice This contract receives newly minted tokens and retrieves Ether or ERC20 tokens received from the asset\r\n// @author Kyle Dewhurst \u0026 Peter Phillips, MyBit Foundation\r\ncontract AssetManagerFunds {\r\n  using SafeMath for uint256;\r\n\r\n  DBInterface public database;\r\n  Events public events;\r\n\r\n  uint256 private transactionNumber;\r\n\r\n  // @notice constructor: initializes database\r\n  constructor(address _database, address _events)\r\n  public {\r\n    database = DBInterface(_database);\r\n    events = Events(_events);\r\n  }\r\n\r\n  // @notice asset manager can withdraw his dividend fee from assets here\r\n  // @param : address _assetAddress = the address of this asset on the platform\r\n  function withdraw(address _assetAddress)\r\n  external\r\n  nonReentrant\r\n  returns (bool) {\r\n    require(_assetAddress != address(0));\r\n    require(msg.sender == database.addressStorage(keccak256(abi.encodePacked(\u0022asset.manager\u0022, _assetAddress))));\r\n    DToken token = DToken( _assetAddress);\r\n    uint amountOwed;\r\n    uint balanceBefore;\r\n    if (token.getERC20() == address(0)){\r\n      balanceBefore = address(this).balance;\r\n      amountOwed = token.getAmountOwed(address(this));\r\n      require(amountOwed \u003E 0);\r\n      uint balanceAfter = balanceBefore.add(amountOwed);\r\n      require(token.withdraw());\r\n      require(address(this).balance == balanceAfter);\r\n      msg.sender.transfer(amountOwed);\r\n    }\r\n    else {\r\n      amountOwed = token.getAmountOwed(address(this));\r\n      require(amountOwed \u003E 0);\r\n      DToken fundingToken = DToken(token.getERC20());\r\n      balanceBefore = fundingToken.balanceOf(address(this));\r\n      require(token.withdraw());\r\n      require(fundingToken.balanceOf(address(this)).sub(amountOwed) == balanceBefore);\r\n      fundingToken.transfer(msg.sender, amountOwed);\r\n    }\r\n    events.transaction(\u0027Asset manager income withdrawn\u0027, _assetAddress, msg.sender, amountOwed, token.getERC20());\r\n    return true;\r\n  }\r\n\r\n  function retrieveAssetManagerTokens(address[] _assetAddress)\r\n  external\r\n  nonReentrant\r\n  returns (bool) {\r\n    require(_assetAddress.length \u003C= 42);\r\n    uint[] memory payoutAmounts = new uint[](_assetAddress.length);\r\n    address[] memory tokenAddresses = new address[](_assetAddress.length);\r\n    uint8 numEntries;\r\n    for(uint8 i = 0; i \u003C _assetAddress.length; i\u002B\u002B){\r\n      require(msg.sender == database.addressStorage(keccak256(abi.encodePacked(\u0022asset.manager\u0022, _assetAddress[i]))) );\r\n      DToken token = DToken(_assetAddress[i]);\r\n      require(address(token) != address(0));\r\n      uint tokensOwed = token.getAmountOwed(address(this));\r\n      if(tokensOwed \u003E 0){\r\n        DToken fundingToken = DToken(token.getERC20());\r\n        uint balanceBefore = fundingToken.balanceOf(address(this));\r\n        uint8 tokenIndex = containsAddress(tokenAddresses, address(token));\r\n        if (tokenIndex \u003C _assetAddress.length) {  payoutAmounts[tokenIndex] = payoutAmounts[tokenIndex].add(tokensOwed); }\r\n        else {\r\n          tokenAddresses[numEntries] = address(fundingToken);\r\n          payoutAmounts[numEntries] = tokensOwed;\r\n          numEntries\u002B\u002B;\r\n        }\r\n        require(token.withdraw());\r\n        require(fundingToken.balanceOf(address(this)).sub(tokensOwed) == balanceBefore);\r\n      }\r\n    }\r\n\r\n    for(i = 0; i \u003C numEntries; i\u002B\u002B){\r\n      require(ERC20(tokenAddresses[i]).transfer(msg.sender, payoutAmounts[i]));\r\n    }\r\n    return true;\r\n  }\r\n\r\n\r\n  function retrieveAssetManagerETH(address[] _assetAddress)\r\n  external\r\n  nonReentrant\r\n  returns (bool) {\r\n    require(_assetAddress.length \u003C= 93);\r\n    uint weiOwed;\r\n    for(uint8 i = 0; i \u003C _assetAddress.length; i\u002B\u002B){\r\n      require(msg.sender == database.addressStorage(keccak256(abi.encodePacked(\u0022asset.manager\u0022, _assetAddress[i]))));\r\n      DToken token = DToken(_assetAddress[i]);\r\n      uint balanceBefore = address(this).balance;\r\n      uint amountOwed = token.getAmountOwed(address(this));\r\n      if(amountOwed \u003E 0){\r\n        uint balanceAfter = balanceBefore.add(amountOwed);\r\n        require(token.withdraw());\r\n        require(address(this).balance == balanceAfter);\r\n        weiOwed = weiOwed.add(amountOwed);\r\n      }\r\n    }\r\n    msg.sender.transfer(weiOwed);\r\n    return true;\r\n  }\r\n\r\n  function viewBalance(address _assetAddress, address _assetManager)\r\n  external\r\n  view\r\n  returns (uint){\r\n    require(_assetAddress != address(0), \u0027Empty address passed\u0027);\r\n    require(_assetManager == database.addressStorage(keccak256(abi.encodePacked(\u0022asset.manager\u0022, _assetAddress))), \u0027That user does not manage the asset\u0027);\r\n    DToken token = DToken( _assetAddress);\r\n    uint balance = token.balanceOf(address(this));\r\n    return balance;\r\n  }\r\n\r\n  function viewAmountOwed(address _assetAddress, address _assetManager)\r\n  external\r\n  view\r\n  returns (uint){\r\n    require(_assetAddress != address(0), \u0027Empty address passed\u0027);\r\n    require(_assetManager == database.addressStorage(keccak256(abi.encodePacked(\u0022asset.manager\u0022, _assetAddress))), \u0027That user does not manage the asset\u0027);\r\n    DToken token = DToken( _assetAddress);\r\n    uint amountOwed = token.getAmountOwed(address(this));\r\n    return amountOwed;\r\n  }\r\n\r\n  // @notice returns the index if the address is in the list, otherwise returns list length \u002B 1\r\n  function containsAddress(address[] _addressList, address _addr)\r\n  internal\r\n  pure\r\n  returns (uint8) {\r\n    for (uint8 i = 0; i \u003C _addressList.length; i\u002B\u002B){\r\n      if (_addressList[i] == _addr) return i;\r\n    }\r\n    return uint8(_addressList.length \u002B 1);\r\n  }\r\n\r\n  // @notice platform owners can destroy contract here\r\n  function destroy()\r\n  onlyOwner\r\n  external {\r\n    events.transaction(\u0027AssetManagerFunds destroyed\u0027, address(this), msg.sender, address(this).balance, address(0));\r\n    selfdestruct(msg.sender);\r\n  }\r\n\r\n  // @notice prevents calls from re-entering contract\r\n  modifier nonReentrant() {\r\n    transactionNumber \u002B= 1;\r\n    uint256 localCounter = transactionNumber;\r\n    _;\r\n    require(localCounter == transactionNumber);\r\n  }\r\n\r\n  // @notice reverts if caller is not the owner\r\n  modifier onlyOwner {\r\n    require(database.boolStorage(keccak256(abi.encodePacked(\u0022owner\u0022, msg.sender))) == true);\r\n    _;\r\n  }\r\n\r\n  function ()\r\n  payable\r\n  public {\r\n    emit EtherReceived(msg.sender, msg.value);\r\n  }\r\n\r\n  event EtherReceived(address sender, uint amount);\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_assetManager\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022viewAmountOwed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_assetManager\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022viewBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022retrieveAssetManagerETH\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022retrieveAssetManagerTokens\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022database\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022destroy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022events\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_database\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_events\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022EtherReceived\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"AssetManagerFunds","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000005fcebeb70b88e86dd880352684e775b0f4d57c71000000000000000000000000eb6533f29a54c2c18bb2ce2a100de717692a518f","Library":"","SwarmSource":"bzzr://1703e786d33850f1255952b3e936037d3de035f7937c90f3514a276fcede221c"}]