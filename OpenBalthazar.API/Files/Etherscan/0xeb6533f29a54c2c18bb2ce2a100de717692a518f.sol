[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\n// File: contracts/interfaces/DBInterface.sol\r\n\r\n// Database interface\r\ninterface DBInterface {\r\n\r\n  function setContractManager(address _contractManager)\r\n  external;\r\n\r\n    // --------------------Set Functions------------------------\r\n\r\n    function setAddress(bytes32 _key, address _value)\r\n    external;\r\n\r\n    function setUint(bytes32 _key, uint _value)\r\n    external;\r\n\r\n    function setString(bytes32 _key, string _value)\r\n    external;\r\n\r\n    function setBytes(bytes32 _key, bytes _value)\r\n    external;\r\n\r\n    function setBytes32(bytes32 _key, bytes32 _value)\r\n    external;\r\n\r\n    function setBool(bytes32 _key, bool _value)\r\n    external;\r\n\r\n    function setInt(bytes32 _key, int _value)\r\n    external;\r\n\r\n\r\n     // -------------- Deletion Functions ------------------\r\n\r\n    function deleteAddress(bytes32 _key)\r\n    external;\r\n\r\n    function deleteUint(bytes32 _key)\r\n    external;\r\n\r\n    function deleteString(bytes32 _key)\r\n    external;\r\n\r\n    function deleteBytes(bytes32 _key)\r\n    external;\r\n\r\n    function deleteBytes32(bytes32 _key)\r\n    external;\r\n\r\n    function deleteBool(bytes32 _key)\r\n    external;\r\n\r\n    function deleteInt(bytes32 _key)\r\n    external;\r\n\r\n    // ----------------Variable Getters---------------------\r\n\r\n    function uintStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (uint);\r\n\r\n    function stringStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (string);\r\n\r\n    function addressStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (address);\r\n\r\n    function bytesStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (bytes);\r\n\r\n    function bytes32Storage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (bytes32);\r\n\r\n    function boolStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (bool);\r\n\r\n    function intStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (bool);\r\n}\r\n\r\n// File: contracts/database/Events.sol\r\n\r\ncontract Events {\r\n  DBInterface public database;\r\n\r\n  constructor(address _database) public{\r\n    database = DBInterface(_database);\r\n  }\r\n\r\n  function message(string _message)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogEvent(_message, keccak256(abi.encodePacked(_message)), tx.origin);\r\n  }\r\n\r\n  function transaction(string _message, address _from, address _to, uint _amount, address _token)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogTransaction(_message, keccak256(abi.encodePacked(_message)), _from, _to, _amount, _token, tx.origin);\r\n  }\r\n\r\n  function registration(string _message, address _account)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogAddress(_message, keccak256(abi.encodePacked(_message)), _account, tx.origin);\r\n  }\r\n\r\n  function contractChange(string _message, address _account, string _name)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogContractChange(_message, keccak256(abi.encodePacked(_message)), _account, _name, tx.origin);\r\n  }\r\n\r\n  function asset(string _message, string _uri, address _assetAddress, address _manager)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogAsset(_message, keccak256(abi.encodePacked(_message)), _uri, keccak256(abi.encodePacked(_uri)), _assetAddress, _manager, tx.origin);\r\n  }\r\n\r\n  function escrow(string _message, address _assetAddress, bytes32 _escrowID, address _manager, uint _amount)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogEscrow(_message, keccak256(abi.encodePacked(_message)), _assetAddress, _escrowID, _manager, _amount, tx.origin);\r\n  }\r\n\r\n  function order(string _message, bytes32 _orderID, uint _amount, uint _price)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogOrder(_message, keccak256(abi.encodePacked(_message)), _orderID, _amount, _price, tx.origin);\r\n  }\r\n\r\n  function exchange(string _message, bytes32 _orderID, address _assetAddress, address _account)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogExchange(_message, keccak256(abi.encodePacked(_message)), _orderID, _assetAddress, _account, tx.origin);\r\n  }\r\n\r\n  function operator(string _message, bytes32 _id, string _name, string _ipfs, address _account)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogOperator(_message, keccak256(abi.encodePacked(_message)), _id, _name, _ipfs, _account, tx.origin);\r\n  }\r\n\r\n  function consensus(string _message, bytes32 _executionID, bytes32 _votesID, uint _votes, uint _tokens, uint _quorum)\r\n  external\r\n  onlyApprovedContract {\r\n    emit LogConsensus(_message, keccak256(abi.encodePacked(_message)), _executionID, _votesID, _votes, _tokens, _quorum, tx.origin);\r\n  }\r\n\r\n  //Generalized events\r\n  event LogEvent(string message, bytes32 indexed messageID, address indexed origin);\r\n  event LogTransaction(string message, bytes32 indexed messageID, address indexed from, address indexed to, uint amount, address token, address origin); //amount and token will be empty on some events\r\n  event LogAddress(string message, bytes32 indexed messageID, address indexed account, address indexed origin);\r\n  event LogContractChange(string message, bytes32 indexed messageID, address indexed account, string name, address indexed origin);\r\n  event LogAsset(string message, bytes32 indexed messageID, string uri, bytes32 indexed assetID, address asset, address manager, address indexed origin);\r\n  event LogEscrow(string message, bytes32 indexed messageID, address asset, bytes32  escrowID, address indexed manager, uint amount, address indexed origin);\r\n  event LogOrder(string message, bytes32 indexed messageID, bytes32 indexed orderID, uint amount, uint price, address indexed origin);\r\n  event LogExchange(string message, bytes32 indexed messageID, bytes32 orderID, address indexed asset, address account, address indexed origin);\r\n  event LogOperator(string message, bytes32 indexed messageID, bytes32 id, string name, string ipfs, address indexed account, address indexed origin);\r\n  event LogConsensus(string message, bytes32 indexed messageID, bytes32 executionID, bytes32 votesID, uint votes, uint tokens, uint quorum, address indexed origin);\r\n\r\n\r\n  // --------------------------------------------------------------------------------------\r\n  // Caller must be registered as a contract through ContractManager.sol\r\n  // --------------------------------------------------------------------------------------\r\n  modifier onlyApprovedContract() {\r\n      require(database.boolStorage(keccak256(abi.encodePacked(\u0022contract\u0022, msg.sender))));\r\n      _;\r\n  }\r\n\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_executionID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_votesID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_votes\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_tokens\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_quorum\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022consensus\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_message\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022message\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_escrowID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_manager\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022escrow\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transaction\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022database\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_uri\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_manager\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022asset\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_orderID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022order\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022registration\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_orderID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022exchange\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_ipfs\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022operator\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022contractChange\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_database\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022messageID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022origin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogEvent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022messageID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022origin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogTransaction\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022messageID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022origin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogAddress\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022messageID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022origin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogContractChange\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022messageID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022uri\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022assetID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022asset\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022manager\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022origin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogAsset\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022messageID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022asset\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022escrowID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022manager\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022origin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogEscrow\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022messageID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022orderID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022price\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022origin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogOrder\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022messageID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022orderID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022asset\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022origin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogExchange\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022messageID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ipfs\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022origin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogOperator\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022messageID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022executionID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022votesID\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022votes\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022quorum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022origin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogConsensus\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Events","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000005fcebeb70b88e86dd880352684e775b0f4d57c71","Library":"","SwarmSource":"bzzr://a5f0fb5e96c3c63c07c6399606c67162a50de7ee6311af49fc6875446c83da44"}]