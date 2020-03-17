[{"SourceCode":"// File: openzeppelin-solidity/contracts/ownership/Ownable.sol\r\n\r\npragma solidity ^0.4.24;\r\n\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n  address public owner;\r\n\r\n\r\n  event OwnershipRenounced(address indexed previousOwner);\r\n  event OwnershipTransferred(\r\n    address indexed previousOwner,\r\n    address indexed newOwner\r\n  );\r\n\r\n\r\n  /**\r\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n  constructor() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to relinquish control of the contract.\r\n   * @notice Renouncing to ownership will leave the contract without an owner.\r\n   * It will not be possible to call the functions with the \u0060onlyOwner\u0060\r\n   * modifier anymore.\r\n   */\r\n  function renounceOwnership() public onlyOwner {\r\n    emit OwnershipRenounced(owner);\r\n    owner = address(0);\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param _newOwner The address to transfer ownership to.\r\n   */\r\n  function transferOwnership(address _newOwner) public onlyOwner {\r\n    _transferOwnership(_newOwner);\r\n  }\r\n\r\n  /**\r\n   * @dev Transfers control of the contract to a newOwner.\r\n   * @param _newOwner The address to transfer ownership to.\r\n   */\r\n  function _transferOwnership(address _newOwner) internal {\r\n    require(_newOwner != address(0));\r\n    emit OwnershipTransferred(owner, _newOwner);\r\n    owner = _newOwner;\r\n  }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/math/SafeMath.sol\r\n\r\npragma solidity ^0.4.24;\r\n\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n\r\n  /**\r\n  * @dev Multiplies two numbers, throws on overflow.\r\n  */\r\n  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {\r\n    // Gas optimization: this is cheaper than asserting \u0027a\u0027 not being zero, but the\r\n    // benefit is lost if \u0027b\u0027 is also tested.\r\n    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n    if (_a == 0) {\r\n      return 0;\r\n    }\r\n\r\n    c = _a * _b;\r\n    assert(c / _a == _b);\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Integer division of two numbers, truncating the quotient.\r\n  */\r\n  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n    // assert(_b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    // uint256 c = _a / _b;\r\n    // assert(_a == _b * c \u002B _a % _b); // There is no case in which this doesn\u0027t hold\r\n    return _a / _b;\r\n  }\r\n\r\n  /**\r\n  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n  */\r\n  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n    assert(_b \u003C= _a);\r\n    return _a - _b;\r\n  }\r\n\r\n  /**\r\n  * @dev Adds two numbers, throws on overflow.\r\n  */\r\n  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {\r\n    c = _a \u002B _b;\r\n    assert(c \u003E= _a);\r\n    return c;\r\n  }\r\n}\r\n\r\n// File: contracts/interfaces/ChainlinkRequestInterface.sol\r\n\r\npragma solidity 0.4.24;\r\n\r\ninterface ChainlinkRequestInterface {\r\n  function oracleRequest(\r\n    address sender,\r\n    uint256 payment,\r\n    bytes32 id,\r\n    address callbackAddress,\r\n    bytes4 callbackFunctionId,\r\n    uint256 nonce,\r\n    uint256 version,\r\n    bytes data\r\n  ) external;\r\n\r\n  function cancelOracleRequest(\r\n    bytes32 requestId,\r\n    uint256 payment,\r\n    bytes4 callbackFunctionId,\r\n    uint256 expiration\r\n  ) external;\r\n}\r\n\r\n// File: contracts/interfaces/OracleInterface.sol\r\n\r\npragma solidity 0.4.24;\r\n\r\ninterface OracleInterface {\r\n  function fulfillOracleRequest(\r\n    bytes32 requestId,\r\n    uint256 payment,\r\n    address callbackAddress,\r\n    bytes4 callbackFunctionId,\r\n    uint256 expiration,\r\n    bytes32 data\r\n  ) external returns (bool);\r\n  function getAuthorizationStatus(address node) external view returns (bool);\r\n  function setFulfillmentPermission(address node, bool allowed) external;\r\n  function withdraw(address recipient, uint256 amount) external;\r\n  function withdrawable() external view returns (uint256);\r\n}\r\n\r\n// File: contracts/interfaces/LinkTokenInterface.sol\r\n\r\npragma solidity 0.4.24;\r\n\r\ninterface LinkTokenInterface {\r\n  function allowance(address owner, address spender) external returns (bool success);\r\n  function approve(address spender, uint256 value) external returns (bool success);\r\n  function balanceOf(address owner) external returns (uint256 balance);\r\n  function decimals() external returns (uint8 decimalPlaces);\r\n  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);\r\n  function increaseApproval(address spender, uint256 subtractedValue) external;\r\n  function name() external returns (string tokenName);\r\n  function symbol() external returns (string tokenSymbol);\r\n  function totalSupply() external returns (uint256 totalTokensIssued);\r\n  function transfer(address to, uint256 value) external returns (bool success);\r\n  function transferAndCall(address to, uint256 value, bytes data) external returns (bool success);\r\n  function transferFrom(address from, address to, uint256 value) external returns (bool success);\r\n}\r\n\r\n// File: contracts/Oracle.sol\r\n\r\npragma solidity 0.4.24;\r\n\r\n\r\n\r\n\r\n\r\n\r\n/**\r\n * @title The Chainlink Oracle contract\r\n * @notice Node operators can deploy this contract to fulfill requests sent to them\r\n */\r\ncontract Oracle is ChainlinkRequestInterface, OracleInterface, Ownable {\r\n  using SafeMath for uint256;\r\n\r\n  uint256 constant public EXPIRY_TIME = 5 minutes;\r\n  uint256 constant private MINIMUM_CONSUMER_GAS_LIMIT = 400000;\r\n  // We initialize fields to 1 instead of 0 so that the first invocation\r\n  // does not cost more gas.\r\n  uint256 constant private ONE_FOR_CONSISTENT_GAS_COST = 1;\r\n  uint256 constant private SELECTOR_LENGTH = 4;\r\n  uint256 constant private EXPECTED_REQUEST_WORDS = 2;\r\n  // solium-disable-next-line zeppelin/no-arithmetic-operations\r\n  uint256 constant private MINIMUM_REQUEST_LENGTH = SELECTOR_LENGTH \u002B (32 * EXPECTED_REQUEST_WORDS);\r\n\r\n  LinkTokenInterface internal LinkToken;\r\n  mapping(bytes32 =\u003E bytes32) private commitments;\r\n  mapping(address =\u003E bool) private authorizedNodes;\r\n  uint256 private withdrawableTokens = ONE_FOR_CONSISTENT_GAS_COST;\r\n\r\n  event OracleRequest(\r\n    bytes32 indexed specId,\r\n    address requester,\r\n    bytes32 requestId,\r\n    uint256 payment,\r\n    address callbackAddr,\r\n    bytes4 callbackFunctionId,\r\n    uint256 cancelExpiration,\r\n    uint256 dataVersion,\r\n    bytes data\r\n  );\r\n\r\n  event CancelOracleRequest(\r\n    bytes32 indexed requestId\r\n  );\r\n\r\n  /**\r\n   * @notice Deploy with the address of the LINK token\r\n   * @dev Sets the LinkToken address for the imported LinkTokenInterface\r\n   * @param _link The address of the LINK token\r\n   */\r\n  constructor(address _link) Ownable() public {\r\n    LinkToken = LinkTokenInterface(_link);\r\n  }\r\n\r\n  /**\r\n   * @notice Called when LINK is sent to the contract via \u0060transferAndCall\u0060\r\n   * @dev The data payload\u0027s first 2 words will be overwritten by the \u0060_sender\u0060 and \u0060_amount\u0060\r\n   * values to ensure correctness. Calls oracleRequest.\r\n   * @param _sender Address of the sender\r\n   * @param _amount Amount of LINK sent (specified in wei)\r\n   * @param _data Payload of the transaction\r\n   */\r\n  function onTokenTransfer(\r\n    address _sender,\r\n    uint256 _amount,\r\n    bytes _data\r\n  )\r\n    public\r\n    onlyLINK\r\n    validRequestLength(_data)\r\n    permittedFunctionsForLINK(_data)\r\n  {\r\n    assembly {\r\n      // solium-disable-next-line security/no-low-level-calls\r\n      mstore(add(_data, 36), _sender) // ensure correct sender is passed\r\n      // solium-disable-next-line security/no-low-level-calls\r\n      mstore(add(_data, 68), _amount)    // ensure correct amount is passed\r\n    }\r\n    // solium-disable-next-line security/no-low-level-calls\r\n    require(address(this).delegatecall(_data), \u0022Unable to create request\u0022); // calls oracleRequest\r\n  }\r\n\r\n  /**\r\n   * @notice Creates the Chainlink request\r\n   * @dev Stores the hash of the params as the on-chain commitment for the request.\r\n   * Emits OracleRequest event for the Chainlink node to detect.\r\n   * @param _sender The sender of the request\r\n   * @param _payment The amount of payment given (specified in wei)\r\n   * @param _specId The Job Specification ID\r\n   * @param _callbackAddress The callback address for the response\r\n   * @param _callbackFunctionId The callback function ID for the response\r\n   * @param _nonce The nonce sent by the requester\r\n   * @param _dataVersion The specified data version\r\n   * @param _data The CBOR payload of the request\r\n   */\r\n  function oracleRequest(\r\n    address _sender,\r\n    uint256 _payment,\r\n    bytes32 _specId,\r\n    address _callbackAddress,\r\n    bytes4 _callbackFunctionId,\r\n    uint256 _nonce,\r\n    uint256 _dataVersion,\r\n    bytes _data\r\n  )\r\n    external\r\n    onlyLINK\r\n    checkCallbackAddress(_callbackAddress)\r\n  {\r\n    bytes32 requestId = keccak256(abi.encodePacked(_sender, _nonce));\r\n    require(commitments[requestId] == 0, \u0022Must use a unique ID\u0022);\r\n    uint256 expiration = now.add(EXPIRY_TIME);\r\n\r\n    commitments[requestId] = keccak256(\r\n      abi.encodePacked(\r\n        _payment,\r\n        _callbackAddress,\r\n        _callbackFunctionId,\r\n        expiration\r\n      )\r\n    );\r\n\r\n    emit OracleRequest(\r\n      _specId,\r\n      _sender,\r\n      requestId,\r\n      _payment,\r\n      _callbackAddress,\r\n      _callbackFunctionId,\r\n      expiration,\r\n      _dataVersion,\r\n      _data);\r\n  }\r\n\r\n  /**\r\n   * @notice Called by the Chainlink node to fulfill requests\r\n   * @dev Given params must hash back to the commitment stored from \u0060oracleRequest\u0060.\r\n   * Will call the callback address\u0027 callback function without bubbling up error\r\n   * checking in a \u0060require\u0060 so that the node can get paid.\r\n   * @param _requestId The fulfillment request ID that must match the requester\u0027s\r\n   * @param _payment The payment amount that will be released for the oracle (specified in wei)\r\n   * @param _callbackAddress The callback address to call for fulfillment\r\n   * @param _callbackFunctionId The callback function ID to use for fulfillment\r\n   * @param _expiration The expiration that the node should respond by before the requester can cancel\r\n   * @param _data The data to return to the consuming contract\r\n   * @return Status if the external call was successful\r\n   */\r\n  function fulfillOracleRequest(\r\n    bytes32 _requestId,\r\n    uint256 _payment,\r\n    address _callbackAddress,\r\n    bytes4 _callbackFunctionId,\r\n    uint256 _expiration,\r\n    bytes32 _data\r\n  )\r\n    external\r\n    onlyAuthorizedNode\r\n    isValidRequest(_requestId)\r\n    returns (bool)\r\n  {\r\n    bytes32 paramsHash = keccak256(\r\n      abi.encodePacked(\r\n        _payment,\r\n        _callbackAddress,\r\n        _callbackFunctionId,\r\n        _expiration\r\n      )\r\n    );\r\n    require(commitments[_requestId] == paramsHash, \u0022Params do not match request ID\u0022);\r\n    withdrawableTokens = withdrawableTokens.add(_payment);\r\n    delete commitments[_requestId];\r\n    require(gasleft() \u003E= MINIMUM_CONSUMER_GAS_LIMIT, \u0022Must provide consumer enough gas\u0022);\r\n    // All updates to the oracle\u0027s fulfillment should come before calling the\r\n    // callback(addr\u002BfunctionId) as it is untrusted.\r\n    // See: https://solidity.readthedocs.io/en/develop/security-considerations.html#use-the-checks-effects-interactions-pattern\r\n    return _callbackAddress.call(_callbackFunctionId, _requestId, _data); // solium-disable-line security/no-low-level-calls\r\n  }\r\n\r\n  /**\r\n   * @notice Use this to check if a node is authorized for fulfilling requests\r\n   * @param _node The address of the Chainlink node\r\n   * @return The authorization status of the node\r\n   */\r\n  function getAuthorizationStatus(address _node) external view returns (bool) {\r\n    return authorizedNodes[_node];\r\n  }\r\n\r\n  /**\r\n   * @notice Sets the fulfillment permission for a given node. Use \u0060true\u0060 to allow, \u0060false\u0060 to disallow.\r\n   * @param _node The address of the Chainlink node\r\n   * @param _allowed Bool value to determine if the node can fulfill requests\r\n   */\r\n  function setFulfillmentPermission(address _node, bool _allowed) external onlyOwner {\r\n    authorizedNodes[_node] = _allowed;\r\n  }\r\n\r\n  /**\r\n   * @notice Allows the node operator to withdraw earned LINK to a given address\r\n   * @dev The owner of the contract can be another wallet and does not have to be a Chainlink node\r\n   * @param _recipient The address to send the LINK token to\r\n   * @param _amount The amount to send (specified in wei)\r\n   */\r\n  function withdraw(address _recipient, uint256 _amount)\r\n    external\r\n    onlyOwner\r\n    hasAvailableFunds(_amount)\r\n  {\r\n    withdrawableTokens = withdrawableTokens.sub(_amount);\r\n    assert(LinkToken.transfer(_recipient, _amount));\r\n  }\r\n\r\n  /**\r\n   * @notice Displays the amount of LINK that is available for the node operator to withdraw\r\n   * @dev We use \u0060ONE_FOR_CONSISTENT_GAS_COST\u0060 in place of 0 in storage\r\n   * @return The amount of withdrawable LINK on the contract\r\n   */\r\n  function withdrawable() external view onlyOwner returns (uint256) {\r\n    return withdrawableTokens.sub(ONE_FOR_CONSISTENT_GAS_COST);\r\n  }\r\n\r\n  /**\r\n   * @notice Allows requesters to cancel requests sent to this oracle contract. Will transfer the LINK\r\n   * sent for the request back to the requester\u0027s address.\r\n   * @dev Given params must hash to a commitment stored on the contract in order for the request to be valid\r\n   * Emits CancelOracleRequest event.\r\n   * @param _requestId The request ID\r\n   * @param _payment The amount of payment given (specified in wei)\r\n   * @param _callbackFunc The requester\u0027s specified callback address\r\n   * @param _expiration The time of the expiration for the request\r\n   */\r\n  function cancelOracleRequest(\r\n    bytes32 _requestId,\r\n    uint256 _payment,\r\n    bytes4 _callbackFunc,\r\n    uint256 _expiration\r\n  ) external {\r\n    bytes32 paramsHash = keccak256(\r\n      abi.encodePacked(\r\n        _payment,\r\n        msg.sender,\r\n        _callbackFunc,\r\n        _expiration)\r\n    );\r\n    require(paramsHash == commitments[_requestId], \u0022Params do not match request ID\u0022);\r\n    require(_expiration \u003C= now, \u0022Request is not expired\u0022);\r\n\r\n    delete commitments[_requestId];\r\n    emit CancelOracleRequest(_requestId);\r\n\r\n    assert(LinkToken.transfer(msg.sender, _payment));\r\n  }\r\n\r\n  // MODIFIERS\r\n\r\n  /**\r\n   * @dev Reverts if amount requested is greater than withdrawable balance\r\n   * @param _amount The given amount to compare to \u0060withdrawableTokens\u0060\r\n   */\r\n  modifier hasAvailableFunds(uint256 _amount) {\r\n    require(withdrawableTokens \u003E= _amount.add(ONE_FOR_CONSISTENT_GAS_COST), \u0022Amount requested is greater than withdrawable balance\u0022);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Reverts if request ID does not exist\r\n   * @param _requestId The given request ID to check in stored \u0060commitments\u0060\r\n   */\r\n  modifier isValidRequest(bytes32 _requestId) {\r\n    require(commitments[_requestId] != 0, \u0022Must have a valid requestId\u0022);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Reverts if \u0060msg.sender\u0060 is not authorized to fulfill requests\r\n   */\r\n  modifier onlyAuthorizedNode() {\r\n    require(authorizedNodes[msg.sender] || msg.sender == owner, \u0022Not an authorized node to fulfill requests\u0022);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Reverts if not sent from the LINK token\r\n   */\r\n  modifier onlyLINK() {\r\n    require(msg.sender == address(LinkToken), \u0022Must use LINK token\u0022);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Reverts if the given data does not begin with the \u0060oracleRequest\u0060 function selector\r\n   * @param _data The data payload of the request\r\n   */\r\n  modifier permittedFunctionsForLINK(bytes _data) {\r\n    bytes4 funcSelector;\r\n    assembly {\r\n      // solium-disable-next-line security/no-low-level-calls\r\n      funcSelector := mload(add(_data, 32))\r\n    }\r\n    require(funcSelector == this.oracleRequest.selector, \u0022Must use whitelisted functions\u0022);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Reverts if the callback address is the LINK token\r\n   * @param _to The callback address\r\n   */\r\n  modifier checkCallbackAddress(address _to) {\r\n    require(_to != address(LinkToken), \u0022Cannot callback to LINK\u0022);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Reverts if the given payload is less than needed to create a request\r\n   * @param _data The request payload\r\n   */\r\n  modifier validRequestLength(bytes _data) {\r\n    require(_data.length \u003E= MINIMUM_REQUEST_LENGTH, \u0022Invalid request length\u0022);\r\n    _;\r\n  }\r\n\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_payment\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_specId\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_callbackAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_callbackFunctionId\u0022,\u0022type\u0022:\u0022bytes4\u0022},{\u0022name\u0022:\u0022_nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_dataVersion\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022oracleRequest\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_requestId\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_payment\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_callbackAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_callbackFunctionId\u0022,\u0022type\u0022:\u0022bytes4\u0022},{\u0022name\u0022:\u0022_expiration\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022fulfillOracleRequest\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022EXPIRY_TIME\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdrawable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_requestId\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_payment\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_callbackFunc\u0022,\u0022type\u0022:\u0022bytes4\u0022},{\u0022name\u0022:\u0022_expiration\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022cancelOracleRequest\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_node\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_allowed\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setFulfillmentPermission\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022onTokenTransfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_node\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getAuthorizationStatus\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_link\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022specId\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022requester\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022requestId\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022payment\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022callbackAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022callbackFunctionId\u0022,\u0022type\u0022:\u0022bytes4\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022cancelExpiration\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022dataVersion\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022OracleRequest\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022requestId\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022CancelOracleRequest\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipRenounced\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Oracle","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000514910771af9ca656af840dff83e8264ecf986ca","Library":"","SwarmSource":"bzzr://d6cb0dbefba4769f938063152bd0acaeb0dee2c021aef4e43acef6ac22c5ea2b"}]