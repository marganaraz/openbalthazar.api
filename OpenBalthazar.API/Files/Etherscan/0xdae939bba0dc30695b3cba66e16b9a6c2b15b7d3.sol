[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\n// File: contracts/interfaces/DBInterface.sol\r\n\r\n// Database interface\r\ninterface DBInterface {\r\n\r\n  function setContractManager(address _contractManager)\r\n  external;\r\n\r\n    // --------------------Set Functions------------------------\r\n\r\n    function setAddress(bytes32 _key, address _value)\r\n    external;\r\n\r\n    function setUint(bytes32 _key, uint _value)\r\n    external;\r\n\r\n    function setString(bytes32 _key, string _value)\r\n    external;\r\n\r\n    function setBytes(bytes32 _key, bytes _value)\r\n    external;\r\n\r\n    function setBytes32(bytes32 _key, bytes32 _value)\r\n    external;\r\n\r\n    function setBool(bytes32 _key, bool _value)\r\n    external;\r\n\r\n    function setInt(bytes32 _key, int _value)\r\n    external;\r\n\r\n\r\n     // -------------- Deletion Functions ------------------\r\n\r\n    function deleteAddress(bytes32 _key)\r\n    external;\r\n\r\n    function deleteUint(bytes32 _key)\r\n    external;\r\n\r\n    function deleteString(bytes32 _key)\r\n    external;\r\n\r\n    function deleteBytes(bytes32 _key)\r\n    external;\r\n\r\n    function deleteBytes32(bytes32 _key)\r\n    external;\r\n\r\n    function deleteBool(bytes32 _key)\r\n    external;\r\n\r\n    function deleteInt(bytes32 _key)\r\n    external;\r\n\r\n    // ----------------Variable Getters---------------------\r\n\r\n    function uintStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (uint);\r\n\r\n    function stringStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (string);\r\n\r\n    function addressStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (address);\r\n\r\n    function bytesStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (bytes);\r\n\r\n    function bytes32Storage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (bytes32);\r\n\r\n    function boolStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (bool);\r\n\r\n    function intStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (bool);\r\n}\r\n\r\n// File: contracts/database/Events.sol\r\n\r\ncontract Events {\r\n  DBInterface public database;\r\n\r\n  constructor(address _database) public{\r\n    database = DBInterface(_database);\r\n  }\r\n\r\n  function message(string _message)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogEvent(_message, keccak256(abi.encodePacked(_message)), tx.origin);\r\n  }\r\n\r\n  function transaction(string _message, address _from, address _to, uint _amount, address _token)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogTransaction(_message, keccak256(abi.encodePacked(_message)), _from, _to, _amount, _token, tx.origin);\r\n  }\r\n\r\n  function registration(string _message, address _account)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogAddress(_message, keccak256(abi.encodePacked(_message)), _account, tx.origin);\r\n  }\r\n\r\n  function contractChange(string _message, address _account, string _name)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogContractChange(_message, keccak256(abi.encodePacked(_message)), _account, _name, tx.origin);\r\n  }\r\n\r\n  function asset(string _message, string _uri, address _assetAddress, address _manager)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogAsset(_message, keccak256(abi.encodePacked(_message)), _uri, keccak256(abi.encodePacked(_uri)), _assetAddress, _manager, tx.origin);\r\n  }\r\n\r\n  function escrow(string _message, address _assetAddress, bytes32 _escrowID, address _manager, uint _amount)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogEscrow(_message, keccak256(abi.encodePacked(_message)), _assetAddress, _escrowID, _manager, _amount, tx.origin);\r\n  }\r\n\r\n  function order(string _message, bytes32 _orderID, uint _amount, uint _price)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogOrder(_message, keccak256(abi.encodePacked(_message)), _orderID, _amount, _price, tx.origin);\r\n  }\r\n\r\n  function exchange(string _message, bytes32 _orderID, address _assetAddress, address _account)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogExchange(_message, keccak256(abi.encodePacked(_message)), _orderID, _assetAddress, _account, tx.origin);\r\n  }\r\n\r\n  function operator(string _message, bytes32 _id, string _name, string _ipfs, address _account)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogOperator(_message, keccak256(abi.encodePacked(_message)), _id, _name, _ipfs, _account, tx.origin);\r\n  }\r\n\r\n  function consensus(string _message, bytes32 _executionID, bytes32 _votesID, uint _votes, uint _tokens, uint _quorum)\r\n  external\r\n  onlyApprovedContract {\r\n    emit LogConsensus(_message, keccak256(abi.encodePacked(_message)), _executionID, _votesID, _votes, _tokens, _quorum, tx.origin);\r\n  }\r\n\r\n  //Generalized events\r\n  event LogEvent(string message, bytes32 indexed messageID, address indexed origin);\r\n  event LogTransaction(string message, bytes32 indexed messageID, address indexed from, address indexed to, uint amount, address token, address origin); //amount and token will be empty on some events\r\n  event LogAddress(string message, bytes32 indexed messageID, address indexed account, address indexed origin);\r\n  event LogContractChange(string message, bytes32 indexed messageID, address indexed account, string name, address indexed origin);\r\n  event LogAsset(string message, bytes32 indexed messageID, string uri, bytes32 indexed assetID, address asset, address manager, address indexed origin);\r\n  event LogEscrow(string message, bytes32 indexed messageID, address asset, bytes32  escrowID, address indexed manager, uint amount, address indexed origin);\r\n  event LogOrder(string message, bytes32 indexed messageID, bytes32 indexed orderID, uint amount, uint price, address indexed origin);\r\n  event LogExchange(string message, bytes32 indexed messageID, bytes32 orderID, address indexed asset, address account, address indexed origin);\r\n  event LogOperator(string message, bytes32 indexed messageID, bytes32 id, string name, string ipfs, address indexed account, address indexed origin);\r\n  event LogConsensus(string message, bytes32 indexed messageID, bytes32 executionID, bytes32 votesID, uint votes, uint tokens, uint quorum, address indexed origin);\r\n\r\n\r\n  // --------------------------------------------------------------------------------------\r\n  // Caller must be registered as a contract through ContractManager.sol\r\n  // --------------------------------------------------------------------------------------\r\n  modifier onlyApprovedContract() {\r\n      require(database.boolStorage(keccak256(abi.encodePacked(\u0022contract\u0022, msg.sender))));\r\n      _;\r\n  }\r\n\r\n}\r\n\r\n// File: contracts/database/ContractManager.sol\r\n\r\n// @title A contract manager that determines which contracts have write access to platform database\r\n// @notice This contract determines which contracts are allowed to make changes to the database contract.\r\n// @author Kyle Dewhurst, MyBit Foundation\r\ncontract ContractManager{\r\n  DBInterface public database;\r\n  Events public events;\r\n\r\n  // @notice constructor: initializes database\r\n  // @param: the address for the database contract used by this platform\r\n  constructor(address _database, address _events)\r\n  public {\r\n    database = DBInterface(_database);\r\n    events = Events(_events);\r\n  }\r\n\r\n  // @notice This function adds new contracts to the platform. Giving them write access to Database.sol\r\n  // @Param: The name of the contract\r\n  // @Param: The address of the new contract\r\n  function addContract(string _name, address _contractAddress)\r\n  external\r\n  isTrue(_contractAddress != address(0))\r\n  isTrue(bytes(_name).length != uint(0))\r\n  anyOwner\r\n  returns (bool) {\r\n    require(!database.boolStorage(keccak256(abi.encodePacked(\u0022contract\u0022, _contractAddress))));\r\n    require(database.addressStorage(keccak256(abi.encodePacked(\u0022contract\u0022, _name))) == address(0));\r\n    database.setAddress(keccak256(abi.encodePacked(\u0022contract\u0022, _name)), _contractAddress);\r\n    database.setBool(keccak256(abi.encodePacked(\u0022contract\u0022, _contractAddress)), true);\r\n    bytes32 currentState = database.bytes32Storage(keccak256(abi.encodePacked(\u0022currentState\u0022)));      //Update currentState\r\n    bytes32 newState = keccak256(abi.encodePacked(currentState, _contractAddress));\r\n    database.setBytes32(keccak256(abi.encodePacked(\u0022currentState\u0022)), newState);\r\n    events.contractChange(\u0022Contract added\u0022, _contractAddress, _name);\r\n    return true;\r\n  }\r\n\r\n  // @notice Owner can remove an existing contract on the platform.\r\n  // @Param: The name of the contract\r\n  // @Param: The owner who authorized this function to be called\r\n  function removeContract(string _name)\r\n  external\r\n  contractExists(database.addressStorage(keccak256(abi.encodePacked(\u0022contract\u0022, _name))))\r\n  isUpgradeable\r\n  anyOwner {\r\n    address contractToDelete = database.addressStorage(keccak256(abi.encodePacked(\u0022contract\u0022, _name)));\r\n    database.deleteBool(keccak256(abi.encodePacked(\u0022contract\u0022, contractToDelete)));\r\n    database.deleteAddress(keccak256(abi.encodePacked(\u0022contract\u0022, _name)));\r\n    events.contractChange(\u0022Contract removed\u0022, contractToDelete, _name);\r\n  }\r\n\r\n  // @notice Owner can update an existing contract on the platform, giving it write access to Database\r\n  // @Param: The name of the contract (First Letter Capitalized)\r\n  // @Param: The address of the new contract\r\n  function updateContract(string _name, address _newContractAddress)\r\n  external\r\n  isTrue(_newContractAddress != 0)\r\n  contractExists(database.addressStorage(keccak256(abi.encodePacked(\u0022contract\u0022, _name))))\r\n  isUpgradeable\r\n  anyOwner {\r\n    address oldAddress = database.addressStorage(keccak256(abi.encodePacked(\u0022contract\u0022, _name)));\r\n    database.setAddress(keccak256(abi.encodePacked(\u0022contract\u0022, _name)), _newContractAddress);\r\n    database.setBool(keccak256(abi.encodePacked(\u0022contract\u0022, _newContractAddress)), true);\r\n    database.deleteBool(keccak256(abi.encodePacked(\u0022contract\u0022, oldAddress)));\r\n    bytes32 currentState = database.bytes32Storage(keccak256(abi.encodePacked(\u0022currentState\u0022)));      //Update currentState\r\n    bytes32 newState = keccak256(abi.encodePacked(currentState, _newContractAddress));\r\n    database.setBytes32(keccak256(abi.encodePacked(\u0022currentState\u0022)), newState);\r\n    events.contractChange(\u0022Contract updated (old)\u0022, oldAddress, _name);\r\n    events.contractChange(\u0022Contract updated (new)\u0022, _newContractAddress, _name);\r\n  }\r\n\r\n  // @notice user can decide to accept or deny the current and future state of the platform contracts\r\n  // @notice if user accepts future upgrades they will automatically be able to interact with upgraded contracts\r\n  // @param (bool) _acceptCurrentState: does the user agree to use the current contracts in the platform\r\n  // @param (bool) _ignoreStateChanges: does the user agree to use the platform despite contract changes\r\n  function setContractStatePreferences(bool _acceptCurrentState, bool _ignoreStateChanges)\r\n  external\r\n  returns (bool) {\r\n    bytes32 currentState = database.bytes32Storage(keccak256(abi.encodePacked(\u0022currentState\u0022)));\r\n    database.setBool(keccak256(abi.encodePacked(currentState, msg.sender)), _acceptCurrentState);\r\n    database.setBool(keccak256(abi.encodePacked(\u0022ignoreStateChanges\u0022, msg.sender)), _ignoreStateChanges);\r\n    emit LogContractStatePreferenceChanged(msg.sender, _acceptCurrentState, _ignoreStateChanges);\r\n    return true;\r\n  }\r\n\r\n\r\n  // ------------------------------------------------------------------------------------------------\r\n  //                                                Modifiers\r\n  // ------------------------------------------------------------------------------------------------\r\n\r\n  modifier isUpgradeable {\r\n    require(database.boolStorage(keccak256(abi.encodePacked(\u0022upgradeable\u0022))), \u0022Not upgradeable\u0022);\r\n    _;\r\n  }\r\n\r\n  // @notice Verify that sender is an owner\r\n  modifier anyOwner {\r\n    require(database.boolStorage(keccak256(abi.encodePacked(\u0022owner\u0022, msg.sender))), \u0022Not owner\u0022);\r\n    _;\r\n  }\r\n\r\n  modifier contractExists(address _contract) {\r\n    require(database.boolStorage(keccak256(abi.encodePacked(\u0022contract\u0022, _contract))), \u0022Contract does not exist\u0022);\r\n    _;\r\n  }\r\n\r\n  modifier isTrue(bool _conditional) {\r\n    require(_conditional, \u0022Not true\u0022);\r\n    _;\r\n  }\r\n\r\n\r\n\r\n  // ------------------------------------------------------------------------------------------------\r\n  //                                    Events\r\n  // ------------------------------------------------------------------------------------------------\r\n  event LogContractAdded(address _contractAddress, string _name, uint _blockNumber);\r\n  event LogContractRemoved(address contractToDelete, string _name, uint _blockNumber);\r\n  event LogContractUpdated(address oldAddress, string _name, uint _blockNumber);\r\n  event LogNewContractLocation(address _contractAddress, string _name, uint _blockNumber);\r\n  event LogContractStatePreferenceChanged(address indexed _user, bool _currentStateAcceptance, bool _ignoreStateChanges);\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_newContractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022updateContract\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022database\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022removeContract\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_acceptCurrentState\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022_ignoreStateChanges\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setContractStatePreferences\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022events\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_contractAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addContract\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_database\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_events\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_contractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_blockNumber\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogContractAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022contractToDelete\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_blockNumber\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogContractRemoved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022oldAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_blockNumber\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogContractUpdated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_contractAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_blockNumber\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogNewContractLocation\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_currentStateAcceptance\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_ignoreStateChanges\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022LogContractStatePreferenceChanged\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"ContractManager","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000005fcebeb70b88e86dd880352684e775b0f4d57c71000000000000000000000000eb6533f29a54c2c18bb2ce2a100de717692a518f","Library":"","SwarmSource":"bzzr://ff77ce391f461d696cdd08eef581a35fe74f74d221a8e3689f7f14f8f518bd42"}]