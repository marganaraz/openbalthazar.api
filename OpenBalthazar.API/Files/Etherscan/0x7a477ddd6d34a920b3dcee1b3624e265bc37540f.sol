[{"SourceCode":"pragma solidity 0.4.24;\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n  address public owner;\r\n\r\n\r\n  event OwnershipRenounced(address indexed previousOwner);\r\n  event OwnershipTransferred(\r\n    address indexed previousOwner,\r\n    address indexed newOwner\r\n  );\r\n\r\n\r\n  /**\r\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n  constructor() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to relinquish control of the contract.\r\n   * @notice Renouncing to ownership will leave the contract without an owner.\r\n   * It will not be possible to call the functions with the \u0060onlyOwner\u0060\r\n   * modifier anymore.\r\n   */\r\n  function renounceOwnership() public onlyOwner {\r\n    emit OwnershipRenounced(owner);\r\n    owner = address(0);\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param _newOwner The address to transfer ownership to.\r\n   */\r\n  function transferOwnership(address _newOwner) public onlyOwner {\r\n    _transferOwnership(_newOwner);\r\n  }\r\n\r\n  /**\r\n   * @dev Transfers control of the contract to a newOwner.\r\n   * @param _newOwner The address to transfer ownership to.\r\n   */\r\n  function _transferOwnership(address _newOwner) internal {\r\n    require(_newOwner != address(0));\r\n    emit OwnershipTransferred(owner, _newOwner);\r\n    owner = _newOwner;\r\n  }\r\n}\r\n\r\n\r\ninterface AggregatorInterface {\r\n  function latestAnswer() external view returns (int256);\r\n  function latestTimestamp() external view returns (uint256);\r\n  function latestRound() external view returns (uint256);\r\n  function getAnswer(uint256 roundId) external view returns (int256);\r\n  function getTimestamp(uint256 roundId) external view returns (uint256);\r\n\r\n  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);\r\n  event NewRound(uint256 indexed roundId, address indexed startedBy);\r\n}\r\n\r\n/**\r\n * @title A trusted proxy for updating where current answers are read from\r\n * @notice This contract provides a consistent address for the\r\n * CurrentAnwerInterface but delegates where it reads from to the owner, who is\r\n * trusted to update it.\r\n */\r\ncontract AggregatorProxy is AggregatorInterface, Ownable {\r\n\r\n  AggregatorInterface public aggregator;\r\n\r\n  constructor(address _aggregator) public Ownable() {\r\n    setAggregator(_aggregator);\r\n  }\r\n\r\n  /**\r\n   * @notice Reads the current answer from aggregator delegated to.\r\n   */\r\n  function latestAnswer()\r\n    external\r\n    view\r\n    returns (int256)\r\n  {\r\n    return aggregator.latestAnswer();\r\n  }\r\n\r\n  /**\r\n   * @notice Reads the last updated height from aggregator delegated to.\r\n   */\r\n  function latestTimestamp()\r\n    external\r\n    view\r\n    returns (uint256)\r\n  {\r\n    return aggregator.latestTimestamp();\r\n  }\r\n\r\n  /**\r\n   * @notice get past rounds answers\r\n   * @param _roundId the answer number to retrieve the answer for\r\n   */\r\n  function getAnswer(uint256 _roundId)\r\n    external\r\n    view\r\n    returns (int256)\r\n  {\r\n    return aggregator.getAnswer(_roundId);\r\n  }\r\n\r\n  /**\r\n   * @notice get block timestamp when an answer was last updated\r\n   * @param _roundId the answer number to retrieve the updated timestamp for\r\n   */\r\n  function getTimestamp(uint256 _roundId)\r\n    external\r\n    view\r\n    returns (uint256)\r\n  {\r\n    return aggregator.getTimestamp(_roundId);\r\n  }\r\n\r\n  /**\r\n   * @notice get the latest completed round where the answer was updated\r\n   */\r\n  function latestRound()\r\n    external\r\n    view\r\n    returns (uint256)\r\n  {\r\n    return aggregator.latestRound();\r\n  }\r\n\r\n  /**\r\n   * @notice Allows the owner to update the aggregator address.\r\n   * @param _aggregator The new address for the aggregator contract\r\n   */\r\n  function setAggregator(address _aggregator)\r\n    public\r\n    onlyOwner()\r\n  {\r\n    aggregator = AggregatorInterface(_aggregator);\r\n  }\r\n\r\n  /**\r\n   * @notice Allows the owner to destroy the contract if it is not intended to\r\n   * be used any longer.\r\n   */\r\n  function destroy()\r\n    external\r\n    onlyOwner()\r\n  {\r\n    selfdestruct(owner);\r\n  }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022aggregator\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022latestAnswer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022int256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022latestRound\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022latestTimestamp\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022destroy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_roundId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getAnswer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022int256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_roundId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getTimestamp\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_aggregator\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setAggregator\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_aggregator\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipRenounced\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022current\u0022,\u0022type\u0022:\u0022int256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022roundId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022timestamp\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022AnswerUpdated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022roundId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022startedBy\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022NewRound\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"AggregatorProxy","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000b8b513d9cf440c1b6f5c7142120d611c94fc220c","Library":"","SwarmSource":"bzzr://434f367d441001d1222ec36bf2560dd40cb0df45e72acc722c8be59c48eef44b"}]