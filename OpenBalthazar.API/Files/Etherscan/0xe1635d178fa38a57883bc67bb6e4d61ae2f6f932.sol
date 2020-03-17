[{"SourceCode":"/**\r\n * CryptoWeek\r\n */\r\n\r\npragma solidity ^0.5.11;\r\n\r\ncontract CryptoWeek {\r\n  address public creator;\r\n  uint public currentUserID;\r\n\r\n  mapping (uint =\u003E uint) public levelPrice;\r\n  mapping (address =\u003E User) public users;\r\n  mapping (uint =\u003E address) public userAddresses;\r\n\r\n  uint MAX_LEVEL = 3;\r\n  uint REFERRALS_LIMIT = 2;\r\n  uint LEVEL_DURATION = 15 days;\r\n\r\n  struct User {\r\n    uint id;\r\n    uint referrerID;\r\n    address[] referrals;\r\n    mapping (uint =\u003E uint) levelExpiresAt;\r\n  }\r\n\r\n  event RegisterUserEvent(address indexed user, address indexed referrer, uint time);\r\n  event BuyLevelEvent(address indexed user, uint indexed level, uint time);\r\n  event GetLevelProfitEvent(address indexed user, address indexed referral, uint indexed level, uint time);\r\n  event LostLevelProfitEvent(address indexed user, address indexed referral, uint indexed level, uint time);\r\n\r\n  modifier userNotRegistered() {\r\n    require(users[msg.sender].id == 0, \u0027User is already registered\u0027);\r\n    _;\r\n  }\r\n\r\n  modifier userRegistered() {\r\n    require(users[msg.sender].id != 0, \u0027User does not exist\u0027);\r\n    _;\r\n  }\r\n\r\n  modifier validReferrerID(uint _referrerID) {\r\n    require(_referrerID \u003E 0 \u0026\u0026 _referrerID \u003C= currentUserID, \u0027Invalid referrer ID\u0027);\r\n    _;\r\n  }\r\n\r\n  modifier validLevel(uint _level) {\r\n    require(_level \u003E 0 \u0026\u0026 _level \u003C= MAX_LEVEL, \u0027Invalid level\u0027);\r\n    _;\r\n  }\r\n\r\n  modifier validLevelAmount(uint _level) {\r\n    require(msg.value == levelPrice[_level], \u0027Invalid level amount\u0027);\r\n    _;\r\n  }\r\n\r\n  constructor() public {\r\n    levelPrice[1] = 0.1 ether;\r\n    levelPrice[2] = 0.15 ether;\r\n    levelPrice[3] = 0.3 ether;\r\n\r\n    currentUserID\u002B\u002B;\r\n\r\n    creator = msg.sender;\r\n\r\n    users[creator] = createNewUser(0);\r\n    userAddresses[currentUserID] = creator;\r\n\r\n    for (uint i = 1; i \u003C= MAX_LEVEL; i\u002B\u002B) {\r\n      users[creator].levelExpiresAt[i] = 1 \u003C\u003C 37;\r\n    }\r\n  }\r\n\r\n  function () external payable {\r\n    uint level;\r\n\r\n    for (uint i = 1; i \u003C= MAX_LEVEL; i\u002B\u002B) {\r\n      if (msg.value == levelPrice[i]) {\r\n        level = i;\r\n        break;\r\n      }\r\n    }\r\n\r\n    require(level \u003E 0, \u0027Invalid amount has sent\u0027);\r\n\r\n    if (users[msg.sender].id != 0) {\r\n      buyLevel(level);\r\n      return;\r\n    }\r\n\r\n    if (level != 1) {\r\n      revert(\u0027Buy first level for 0.1 ETH\u0027);\r\n    }\r\n\r\n    address referrer = bytesToAddress(msg.data);\r\n    registerUser(users[referrer].id);\r\n  }\r\n\r\n  function registerUser(uint _referrerID) public payable userNotRegistered() validReferrerID(_referrerID) validLevelAmount(1) {\r\n    if (users[userAddresses[_referrerID]].referrals.length \u003E= REFERRALS_LIMIT) {\r\n      _referrerID = users[findReferrer(userAddresses[_referrerID])].id;\r\n    }\r\n\r\n    currentUserID\u002B\u002B;\r\n\r\n    users[msg.sender] = createNewUser(_referrerID);\r\n    userAddresses[currentUserID] = msg.sender;\r\n    users[msg.sender].levelExpiresAt[1] = now \u002B LEVEL_DURATION;\r\n\r\n    users[userAddresses[_referrerID]].referrals.push(msg.sender);\r\n\r\n    transferLevelPayment(1, msg.sender);\r\n    emit RegisterUserEvent(msg.sender, userAddresses[_referrerID], now);\r\n  }\r\n\r\n  function buyLevel(uint _level) public payable userRegistered() validLevel(_level) validLevelAmount(_level) {\r\n    for (uint l = _level - 1; l \u003E 0; l--) {\r\n      require(getUserLevelExpiresAt(msg.sender, l) \u003E= now, \u0027Buy the previous level\u0027);\r\n    }\r\n\r\n    if (getUserLevelExpiresAt(msg.sender, _level) == 0) {\r\n      users[msg.sender].levelExpiresAt[_level] = now \u002B LEVEL_DURATION;\r\n    } else {\r\n      users[msg.sender].levelExpiresAt[_level] \u002B= LEVEL_DURATION;\r\n    }\r\n\r\n    transferLevelPayment(_level, msg.sender);\r\n    emit BuyLevelEvent(msg.sender, _level, now);\r\n  }\r\n\r\n  function findReferrer(address _user) public view returns (address) {\r\n    if (users[_user].referrals.length \u003C REFERRALS_LIMIT) {\r\n      return _user;\r\n    }\r\n\r\n    address[1024] memory referrals;\r\n    referrals[0] = users[_user].referrals[0];\r\n    referrals[1] = users[_user].referrals[1];\r\n\r\n    address referrer;\r\n\r\n    for (uint i = 0; i \u003C 1024; i\u002B\u002B) {\r\n      if (users[referrals[i]].referrals.length \u003C REFERRALS_LIMIT) {\r\n        referrer = referrals[i];\r\n        break;\r\n      }\r\n\r\n      if (i \u003E= 512) {\r\n        continue;\r\n      }\r\n\r\n      referrals[(i\u002B1)*2] = users[referrals[i]].referrals[0];\r\n      referrals[(i\u002B1)*2\u002B1] = users[referrals[i]].referrals[1];\r\n    }\r\n\r\n    require(referrer != address(0), \u0027Referrer was not found\u0027);\r\n\r\n    return referrer;\r\n  }\r\n\r\n  function transferLevelPayment(uint _level, address _user) internal {\r\n    uint height = _level;\r\n    address referrer = getUserUpline(_user, height);\r\n\r\n    if (referrer == address(0)) {\r\n      referrer = creator;\r\n    }\r\n\r\n    if (getUserLevelExpiresAt(referrer, _level) \u003C now) {\r\n      emit LostLevelProfitEvent(referrer, msg.sender, _level, now);\r\n      transferLevelPayment(_level, referrer);\r\n      return;\r\n    }\r\n\r\n    if (addressToPayable(referrer).send(msg.value)) {\r\n      emit GetLevelProfitEvent(referrer, msg.sender, _level, now);\r\n    }\r\n  }\r\n\r\n\r\n  function getUserUpline(address _user, uint height) public view returns (address) {\r\n    if (height \u003C= 0 || _user == address(0)) {\r\n      return _user;\r\n    }\r\n\r\n    return this.getUserUpline(userAddresses[users[_user].referrerID], height - 1);\r\n  }\r\n\r\n  function getUserReferrals(address _user) public view returns (address[] memory) {\r\n    return users[_user].referrals;\r\n  }\r\n\r\n  function getUserLevelExpiresAt(address _user, uint _level) public view returns (uint) {\r\n    return users[_user].levelExpiresAt[_level];\r\n  }\r\n\r\n\r\n  function createNewUser(uint _referrerID) private view returns (User memory) {\r\n    return User({ id: currentUserID, referrerID: _referrerID, referrals: new address[](0) });\r\n  }\r\n\r\n  function bytesToAddress(bytes memory _addr) private pure returns (address addr) {\r\n    assembly {\r\n      addr := mload(add(_addr, 20))\r\n    }\r\n  }\r\n\r\n  function addressToPayable(address _addr) private pure returns (address payable) {\r\n    return address(uint160(_addr));\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022creator\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_referrerID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022registerUser\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022userAddresses\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_level\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getUserLevelExpiresAt\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getUserReferrals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022users\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022referrerID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022currentUserID\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022levelPrice\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022findReferrer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022height\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getUserUpline\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_level\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022buyLevel\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022referrer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022RegisterUserEvent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022level\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022BuyLevelEvent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022referral\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022level\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022GetLevelProfitEvent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022referral\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022level\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LostLevelProfitEvent\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"CryptoWeek","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://1ddf66d4e39d0d27307e8bc6b89439610f490075145f389bac586061bf1b7e58"}]