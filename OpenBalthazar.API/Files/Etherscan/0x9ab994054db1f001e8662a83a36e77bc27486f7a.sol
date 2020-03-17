[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\n// File: contracts/math/SafeMath.sol\r\n\r\n// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol\r\n\r\n// @title SafeMath: overflow/underflow checks\r\n// @notice Math operations with safety checks that throw on error\r\nlibrary SafeMath {\r\n\r\n  // @notice Multiplies two numbers, throws on overflow.\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  // @notice Integer division of two numbers, truncating the quotient.\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    // uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return a / b;\r\n  }\r\n\r\n  // @notice Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  // @notice Adds two numbers, throws on overflow.\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n\r\n  // @notice Returns fractional amount\r\n  function getFractionalAmount(uint256 _amount, uint256 _percentage)\r\n  internal\r\n  pure\r\n  returns (uint256) {\r\n    return div(mul(_amount, _percentage), 100);\r\n  }\r\n\r\n}\r\n\r\n// File: contracts/interfaces/DBInterface.sol\r\n\r\n// Database interface\r\ninterface DBInterface {\r\n\r\n  function setContractManager(address _contractManager)\r\n  external;\r\n\r\n    // --------------------Set Functions------------------------\r\n\r\n    function setAddress(bytes32 _key, address _value)\r\n    external;\r\n\r\n    function setUint(bytes32 _key, uint _value)\r\n    external;\r\n\r\n    function setString(bytes32 _key, string _value)\r\n    external;\r\n\r\n    function setBytes(bytes32 _key, bytes _value)\r\n    external;\r\n\r\n    function setBytes32(bytes32 _key, bytes32 _value)\r\n    external;\r\n\r\n    function setBool(bytes32 _key, bool _value)\r\n    external;\r\n\r\n    function setInt(bytes32 _key, int _value)\r\n    external;\r\n\r\n\r\n     // -------------- Deletion Functions ------------------\r\n\r\n    function deleteAddress(bytes32 _key)\r\n    external;\r\n\r\n    function deleteUint(bytes32 _key)\r\n    external;\r\n\r\n    function deleteString(bytes32 _key)\r\n    external;\r\n\r\n    function deleteBytes(bytes32 _key)\r\n    external;\r\n\r\n    function deleteBytes32(bytes32 _key)\r\n    external;\r\n\r\n    function deleteBool(bytes32 _key)\r\n    external;\r\n\r\n    function deleteInt(bytes32 _key)\r\n    external;\r\n\r\n    // ----------------Variable Getters---------------------\r\n\r\n    function uintStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (uint);\r\n\r\n    function stringStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (string);\r\n\r\n    function addressStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (address);\r\n\r\n    function bytesStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (bytes);\r\n\r\n    function bytes32Storage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (bytes32);\r\n\r\n    function boolStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (bool);\r\n\r\n    function intStorage(bytes32 _key)\r\n    external\r\n    view\r\n    returns (bool);\r\n}\r\n\r\n// File: contracts/database/Events.sol\r\n\r\ncontract Events {\r\n  DBInterface public database;\r\n\r\n  constructor(address _database) public{\r\n    database = DBInterface(_database);\r\n  }\r\n\r\n  function message(string _message)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogEvent(_message, keccak256(abi.encodePacked(_message)), tx.origin);\r\n  }\r\n\r\n  function transaction(string _message, address _from, address _to, uint _amount, address _token)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogTransaction(_message, keccak256(abi.encodePacked(_message)), _from, _to, _amount, _token, tx.origin);\r\n  }\r\n\r\n  function registration(string _message, address _account)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogAddress(_message, keccak256(abi.encodePacked(_message)), _account, tx.origin);\r\n  }\r\n\r\n  function contractChange(string _message, address _account, string _name)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogContractChange(_message, keccak256(abi.encodePacked(_message)), _account, _name, tx.origin);\r\n  }\r\n\r\n  function asset(string _message, string _uri, address _assetAddress, address _manager)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogAsset(_message, keccak256(abi.encodePacked(_message)), _uri, keccak256(abi.encodePacked(_uri)), _assetAddress, _manager, tx.origin);\r\n  }\r\n\r\n  function escrow(string _message, address _assetAddress, bytes32 _escrowID, address _manager, uint _amount)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogEscrow(_message, keccak256(abi.encodePacked(_message)), _assetAddress, _escrowID, _manager, _amount, tx.origin);\r\n  }\r\n\r\n  function order(string _message, bytes32 _orderID, uint _amount, uint _price)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogOrder(_message, keccak256(abi.encodePacked(_message)), _orderID, _amount, _price, tx.origin);\r\n  }\r\n\r\n  function exchange(string _message, bytes32 _orderID, address _assetAddress, address _account)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogExchange(_message, keccak256(abi.encodePacked(_message)), _orderID, _assetAddress, _account, tx.origin);\r\n  }\r\n\r\n  function operator(string _message, bytes32 _id, string _name, string _ipfs, address _account)\r\n  external\r\n  onlyApprovedContract {\r\n      emit LogOperator(_message, keccak256(abi.encodePacked(_message)), _id, _name, _ipfs, _account, tx.origin);\r\n  }\r\n\r\n  function consensus(string _message, bytes32 _executionID, bytes32 _votesID, uint _votes, uint _tokens, uint _quorum)\r\n  external\r\n  onlyApprovedContract {\r\n    emit LogConsensus(_message, keccak256(abi.encodePacked(_message)), _executionID, _votesID, _votes, _tokens, _quorum, tx.origin);\r\n  }\r\n\r\n  //Generalized events\r\n  event LogEvent(string message, bytes32 indexed messageID, address indexed origin);\r\n  event LogTransaction(string message, bytes32 indexed messageID, address indexed from, address indexed to, uint amount, address token, address origin); //amount and token will be empty on some events\r\n  event LogAddress(string message, bytes32 indexed messageID, address indexed account, address indexed origin);\r\n  event LogContractChange(string message, bytes32 indexed messageID, address indexed account, string name, address indexed origin);\r\n  event LogAsset(string message, bytes32 indexed messageID, string uri, bytes32 indexed assetID, address asset, address manager, address indexed origin);\r\n  event LogEscrow(string message, bytes32 indexed messageID, address asset, bytes32  escrowID, address indexed manager, uint amount, address indexed origin);\r\n  event LogOrder(string message, bytes32 indexed messageID, bytes32 indexed orderID, uint amount, uint price, address indexed origin);\r\n  event LogExchange(string message, bytes32 indexed messageID, bytes32 orderID, address indexed asset, address account, address indexed origin);\r\n  event LogOperator(string message, bytes32 indexed messageID, bytes32 id, string name, string ipfs, address indexed account, address indexed origin);\r\n  event LogConsensus(string message, bytes32 indexed messageID, bytes32 executionID, bytes32 votesID, uint votes, uint tokens, uint quorum, address indexed origin);\r\n\r\n\r\n  // --------------------------------------------------------------------------------------\r\n  // Caller must be registered as a contract through ContractManager.sol\r\n  // --------------------------------------------------------------------------------------\r\n  modifier onlyApprovedContract() {\r\n      require(database.boolStorage(keccak256(abi.encodePacked(\u0022contract\u0022, msg.sender))));\r\n      _;\r\n  }\r\n\r\n}\r\n\r\n// File: contracts/interfaces/EscrowReserveInterface.sol\r\n\r\ninterface EscrowReserveInterface {\r\n  function issueERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool);\r\n  function requestERC20(address _payer, uint256 _amount, address _tokenAddress) external returns (bool);\r\n  function approveERC20(address _receiver, uint256 _amount, address _tokenAddress) external returns (bool);\r\n  function burnERC20(uint256 _amount, address _tokenAddress) external returns (bool);\r\n}\r\n\r\n// File: contracts/roles/AssetManagerEscrow.sol\r\n\r\ninterface AssetManagerEscrow_ERC20 {\r\n    function transfer(address _to, uint256 _value) external returns (bool);\r\n    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);\r\n    function burn(uint _amount) external returns (bool);\r\n    function burnFrom(address _user, uint _amount) external returns (bool);\r\n    function balanceOf(address _user) external view returns (uint);\r\n  }\r\n\r\n  interface AssetManagerEscrow_DivToken {\r\n    function totalSupply() external view returns (uint);\r\n    function assetIncome() external view returns (uint);\r\n    function balanceOf(address _user) external view returns (uint);\r\n  }\r\n\r\n  // @title A contract to hold escrow as collateral against assets\r\n  // @author Kyle Dewhurst, MyBit Foundation\r\n  // @notice AssetManager can lock his escrow in this contract and retrieve it if asset funding fails or successfully returns ROI\r\n  contract AssetManagerEscrow {\r\n\r\n    using SafeMath for uint256;\r\n\r\n    DBInterface public database;\r\n    Events public events;\r\n    EscrowReserveInterface private reserve;\r\n\r\n    //uint public consensus = 66;\r\n\r\n    // @notice constructor: initializes database\r\n    // @param: the address for the database contract used by this platform\r\n    constructor(address _database, address _events)\r\n    public {\r\n      database = DBInterface(_database);\r\n      events = Events(_events);\r\n      reserve = EscrowReserveInterface(database.addressStorage(keccak256(abi.encodePacked(\u0022contract\u0022, \u0022EscrowReserve\u0022))));\r\n    }\r\n\r\n    // @dev anybody can make the assetManager escrow if he leaves this contract with approval to transfer\r\n    function lockEscrow(address _assetAddress, address _assetManager, uint _amount)\r\n    public\r\n    returns (bool) {\r\n      require(lockEscrowInternal(_assetManager, _assetAddress, _amount));\r\n      return true;\r\n    }\r\n\r\n    // @notice assetManager can unlock his escrow here once funding fails or asset returns sufficient ROI\r\n    // @dev asset must have fundingDeadline = 0 or have ROI \u003E 25%\r\n    // @dev returns escrow according to ROI. 25% ROI returns 25% of escrow, 50% ROI returns 50% of escrow etc...\r\n    function unlockEscrow(address _assetAddress)\r\n    public\r\n    returns (bool) {\r\n      bytes32 assetManagerEscrowID = keccak256(abi.encodePacked(_assetAddress, msg.sender));\r\n      require(database.uintStorage(keccak256(abi.encodePacked(\u0022asset.escrow\u0022, assetManagerEscrowID))) != 0, \u0027Asset escrow is zero\u0027);\r\n      //require(database.uintStorage(keccak256(abi.encodePacked(\u0022crowdsale.deadline\u0022, _assetAddress))) \u003C now, \u0027Before crowdsale deadline\u0027);\r\n      address platformToken = database.addressStorage(keccak256(abi.encodePacked(\u0022platform.token\u0022)));\r\n      uint totalEscrow = database.uintStorage(keccak256(abi.encodePacked(\u0022asset.escrow\u0022, assetManagerEscrowID)));\r\n      uint escrowRedeemed = database.uintStorage(keccak256(abi.encodePacked(\u0022asset.escrowRedeemed\u0022, assetManagerEscrowID)));\r\n      uint unlockAmount = totalEscrow.sub(escrowRedeemed);\r\n      if(!database.boolStorage(keccak256(abi.encodePacked(\u0022crowdsale.finalized\u0022, _assetAddress)))){\r\n        require(database.uintStorage(keccak256(abi.encodePacked(\u0022crowdsale.deadline\u0022, _assetAddress))) \u003C now);\r\n        //Crowdsale failed, return escrow\r\n        emit NotFinalized();\r\n        //If we\u0027re past deadline but crowdsale did NOT finalize, release all escrow\r\n        require(removeAssetManager(_assetAddress));\r\n        require(removeEscrowData(assetManagerEscrowID));\r\n        require(reserve.issueERC20(msg.sender, unlockAmount, platformToken));\r\n        return true;\r\n      } else {\r\n        //Crowdsale finalized. Only pay back based on ROI\r\n        AssetManagerEscrow_DivToken token = AssetManagerEscrow_DivToken(_assetAddress);\r\n        uint roiPercent = token.assetIncome().mul(100).div(token.totalSupply());   // Scaled up by 10^2  (approaches 100 as asset income increases)\r\n        uint roiCheckpoints = roiPercent.div(25);       // How many quarterly increments have been reached?\r\n        emit ROICheckpoint(roiCheckpoints);\r\n        require(roiCheckpoints \u003E 0);\r\n        if(roiCheckpoints \u003C= 4){\r\n          // Can\u0027t unlock escrow past 100% ROI\r\n          //  multiply the number of quarterly increments by a quarter of the escrow and subtract the escrow already redeemed.\r\n          uint quarterEscrow = totalEscrow.div(4);\r\n          unlockAmount = roiCheckpoints.mul(quarterEscrow).sub(escrowRedeemed);\r\n        }\r\n        require(unlockAmount \u003E 0);\r\n        database.setUint(keccak256(abi.encodePacked(\u0022asset.escrowRedeemed\u0022, assetManagerEscrowID)), escrowRedeemed.add(unlockAmount));\r\n        require(reserve.issueERC20(msg.sender, unlockAmount, platformToken));\r\n        return true;\r\n      }\r\n    }\r\n\r\n\r\n    // @notice investors can vote to call this function for the new assetManager to then call\r\n    // @dev new assetManager must approve this contract to transfer in and lock _ amount of platform tokens\r\n    function changeAssetManager(address _assetAddress, address _newAssetManager, uint256 _amount, bool _withhold)\r\n    external\r\n    returns (bool) {\r\n      require(_newAssetManager != address(0));\r\n      require(msg.sender == database.addressStorage(keccak256(abi.encodePacked(\u0022asset.dao.admin\u0022, _assetAddress))), \u0022Only the asset DAO adminstrator contract may change the asset manager\u0022);\r\n      address currentAssetManager = database.addressStorage(keccak256(abi.encodePacked(\u0022asset.manager\u0022, _assetAddress)));\r\n      require(currentAssetManager != _newAssetManager, \u0022New asset manager is the same\u0022);\r\n      //Remove current asset manager\r\n      require(removeAssetManager(_assetAddress), \u0027Asset manager not removed\u0027);\r\n      database.setAddress(keccak256(abi.encodePacked(\u0022asset.manager\u0022, _assetAddress)), _newAssetManager);\r\n      if(!_withhold){\r\n        processEscrow(_assetAddress, currentAssetManager);\r\n      }\r\n      require(lockEscrowInternal(_newAssetManager, _assetAddress, _amount), \u0027Failed to lock escrow\u0027);\r\n      return true;\r\n    }\r\n\r\n    function returnEscrow(address _assetAddress, address _oldAssetManager)\r\n    external\r\n    {\r\n      require(database.addressStorage(keccak256(abi.encodePacked(\u0022asset.manager\u0022, _assetAddress))) == msg.sender);\r\n      processEscrow(_assetAddress, _oldAssetManager);\r\n    }\r\n\r\n    function voteToBurn(address _assetAddress)\r\n    external\r\n    returns (bool) {\r\n      require(msg.sender == database.addressStorage(keccak256(abi.encodePacked(\u0022asset.dao.admin\u0022, _assetAddress))), \u0022Only the asset DAO adminstrator contract may change the asset manager\u0022);\r\n      bytes32 assetManagerEscrowID = keccak256(abi.encodePacked(_assetAddress, database.addressStorage(keccak256(abi.encodePacked(\u0022asset.manager\u0022, _assetAddress)))));\r\n      uint escrowRedeemed = database.uintStorage(keccak256(abi.encodePacked(\u0022asset.escrowRedeemed\u0022, assetManagerEscrowID)));\r\n      uint escrowAmount = database.uintStorage(keccak256(abi.encodePacked(\u0022asset.escrow\u0022, assetManagerEscrowID)));\r\n      require(reserve.burnERC20(escrowAmount.sub(escrowRedeemed), database.addressStorage(keccak256(abi.encodePacked(\u0022platform.token\u0022))))); // burn manager tokens\r\n      database.setUint(keccak256(abi.encodePacked(\u0022asset.escrowRedeemed\u0022, assetManagerEscrowID)), escrowAmount );  // mark burned _assetAddresss as redeemed\r\n      return true;\r\n    }\r\n\r\n    /*\r\n    //Burn platform tokens to unilaterally burn asset manager\u0027s escrow\r\n    function mutualBurn(address _assetAddress, uint _amountToBurn)\r\n    external\r\n    returns (bool) {\r\n      require(AssetManagerEscrow_DivToken(_assetAddress).balanceOf(msg.sender) \u003E 0, \u0027Must be an asset holder\u0027);\r\n      bytes32 assetManagerEscrowID = keccak256(abi.encodePacked(_assetAddress, database.addressStorage(keccak256(abi.encodePacked(\u0022asset.manager\u0022, _assetAddress)))));\r\n      uint escrowRedeemed = database.uintStorage(keccak256(abi.encodePacked(\u0022asset.escrowRedeemed\u0022, assetManagerEscrowID)));\r\n      uint unlockAmount = database.uintStorage(keccak256(abi.encodePacked(\u0022asset.escrow\u0022, assetManagerEscrowID))).sub(escrowRedeemed);\r\n      require(unlockAmount \u003E= _amountToBurn, \u0022asset manager has no escrow left\u0022);\r\n      uint256 selfBurnAmount = _amountToBurn.getFractionalAmount(database.uintStorage(keccak256(abi.encodePacked(\u0022platform.burnRate\u0022))));\r\n      AssetManagerEscrow_ERC20 platformToken = AssetManagerEscrow_ERC20(database.addressStorage(keccak256(abi.encodePacked(\u0022platform.token\u0022))));\r\n      require(platformToken.balanceOf(msg.sender) \u003E= selfBurnAmount);\r\n      require(platformToken.burnFrom(msg.sender, selfBurnAmount));  // burn investor tokens\r\n      require(reserve.burnERC20(_amountToBurn, address(platformToken))); // burn manager tokens\r\n      database.setUint(keccak256(abi.encodePacked(\u0022asset.escrowRedeemed\u0022, assetManagerEscrowID)), escrowRedeemed.add(_amountToBurn));  // mark burned _assetAddresss as redeemed\r\n      events.escrow(\u0027Escrow mutually burned\u0027, _assetAddress, assetManagerEscrowID, msg.sender, _amountToBurn);\r\n      return true;\r\n    }\r\n    */\r\n\r\n    // @notice platform owners can destroy contract here\r\n    function destroy()\r\n    onlyOwner\r\n    external {\r\n      events.transaction(\u0027AssetManagerEscrow destroyed\u0027, address(this), msg.sender, address(this).balance, address(0));\r\n      selfdestruct(msg.sender);\r\n    }\r\n\r\n    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n    //                                            Internal/ Private Functions\r\n    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n\r\n    function processEscrow(address _assetAddress, address _oldAssetManager)\r\n    private\r\n    {\r\n      bytes32 oldAssetManagerEscrowID = keccak256(abi.encodePacked(_assetAddress, _oldAssetManager));\r\n      uint oldEscrowRemaining = database.uintStorage(keccak256(abi.encodePacked(\u0022asset.escrow\u0022, oldAssetManagerEscrowID))).sub(database.uintStorage(keccak256(abi.encodePacked(\u0022asset.escrowRedeemed\u0022, oldAssetManagerEscrowID))));\r\n      require(removeEscrowData(oldAssetManagerEscrowID), \u0027Remove escrow data failed\u0027);\r\n      if(oldEscrowRemaining \u003E 0){\r\n        require(reserve.issueERC20(_oldAssetManager, oldEscrowRemaining, database.addressStorage(keccak256(abi.encodePacked(\u0022platform.token\u0022)))), \u0027Funds not returned\u0027);\r\n      }\r\n    }\r\n\r\n    function removeAssetManager(address _assetAddress)\r\n    private\r\n    returns (bool) {\r\n        database.deleteAddress(keccak256(abi.encodePacked(\u0022asset.manager\u0022, _assetAddress)));\r\n        return true;\r\n    }\r\n\r\n    function removeEscrowData(bytes32 _assetManagerEscrowID)\r\n    private\r\n    returns (bool) {\r\n        database.deleteUint(keccak256(abi.encodePacked(\u0022asset.escrow\u0022, _assetManagerEscrowID)));\r\n        database.deleteUint(keccak256(abi.encodePacked(\u0022asset.escrowRedeemed\u0022, _assetManagerEscrowID)));\r\n        return true;\r\n    }\r\n\r\n    function lockEscrowInternal(address _assetManager, address _assetAddress, uint _amount)\r\n    private\r\n    returns (bool) {\r\n      require(_assetManager == database.addressStorage(keccak256(abi.encodePacked(\u0022asset.manager\u0022, _assetAddress))));\r\n      bytes32 assetManagerEscrowID = keccak256(abi.encodePacked(_assetAddress, _assetManager));\r\n      require(database.uintStorage(keccak256(abi.encodePacked(\u0022asset.escrow\u0022, assetManagerEscrowID))) == 0, \u0027Asset escrow already set\u0027);\r\n      AssetManagerEscrow_ERC20 platformToken = AssetManagerEscrow_ERC20(database.addressStorage(keccak256(abi.encodePacked(\u0022platform.token\u0022))));\r\n      require(platformToken.transferFrom(_assetManager, address(reserve), _amount));\r\n      database.setUint(keccak256(abi.encodePacked(\u0022asset.escrow\u0022, assetManagerEscrowID)), _amount);\r\n      events.escrow(\u0027Escrow locked\u0027, _assetAddress, assetManagerEscrowID, _assetManager, _amount);\r\n      return true;\r\n    }\r\n\r\n  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n  //                                            Modifiers\r\n  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////\r\n\r\n    // @notice reverts if caller is not the owner\r\n    modifier onlyOwner {\r\n      require(database.boolStorage(keccak256(abi.encodePacked(\u0022owner\u0022, msg.sender))) == true);\r\n      _;\r\n    }\r\n\r\n    event NotFinalized();\r\n    event ROICheckpoint(uint checkpoint);\r\n    /*\r\n    event LogConsensus(bytes32 votesID, uint votes, uint _assetAddresss, bytes32 executionID, uint quorum);\r\n    event LogEscrowBurned(bytes32 indexed _assetAddress, address indexed _assetManager, uint _amountBurnt);\r\n    event LogEscrowLocked(bytes32 indexed _assetAddress, bytes32 indexed _assetManagerEscrowID, address indexed _assetManager, uint _amount);\r\n    */\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_assetManager\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022lockEscrow\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_newAssetManager\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_withhold\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022changeAssetManager\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022voteToBurn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022database\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022destroy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022events\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022unlockEscrow\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_assetAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_oldAssetManager\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022returnEscrow\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_database\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_events\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022NotFinalized\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022checkpoint\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ROICheckpoint\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"AssetManagerEscrow","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000005fcebeb70b88e86dd880352684e775b0f4d57c71000000000000000000000000eb6533f29a54c2c18bb2ce2a100de717692a518f","Library":"","SwarmSource":"bzzr://05509c6c0cf6835640e7710dd23766d394134be33f2a3978f91654c80dbd878e"}]