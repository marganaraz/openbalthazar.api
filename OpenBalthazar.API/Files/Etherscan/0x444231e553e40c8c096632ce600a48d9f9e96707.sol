[{"SourceCode":"/**\r\n * Dfw project\r\n *\r\n * Website: https://dfw.vc\r\n * Email: admin@dfw.vc\r\n */\r\n\r\npragma solidity ^0.5.10;\r\n\r\ncontract DFW {\r\n  mapping (uint =\u003E uint) public stagePrice;\r\n\r\n  address public owner;\r\n\r\n  uint public currentUserID;\r\n\r\n  mapping (address =\u003E User) public users;\r\n  mapping (uint =\u003E address) public userAddresses;\r\n\r\n  uint REFERRALS_LIMIT = 3;\r\n  uint STAGE_DURATION = 365 days;\r\n\r\n  struct User {\r\n    uint id;\r\n    uint referrerID;\r\n    address[] referrals;\r\n    mapping (uint =\u003E uint) stageEndTime;\r\n  }\r\n\r\n  event RegisterUserEvent(address indexed user, address indexed referrer, uint time);\r\n  event BuyStageEvent(address indexed user, uint indexed stage, uint time);\r\n  event GetStageProfitEvent(address indexed user, address indexed referral, uint indexed stage, uint time);\r\n  event LostStageProfitEvent(address indexed user, address indexed referral, uint indexed stage, uint time);\r\n\r\n  modifier userNotRegistered() {\r\n    require(users[msg.sender].id == 0, \u0027User is already registered\u0027);\r\n    _;\r\n  }\r\n\r\n  modifier userRegistered() {\r\n    require(users[msg.sender].id != 0, \u0027User does not exist\u0027);\r\n    _;\r\n  }\r\n\r\n  modifier validReferrerID(uint _referrerID) {\r\n    require(_referrerID \u003E 0 \u0026\u0026 _referrerID \u003C= currentUserID, \u0027Invalid referrer ID\u0027);\r\n    _;\r\n  }\r\n\r\n  modifier validStage(uint _stage) {\r\n    require(_stage \u003E 0 \u0026\u0026 _stage \u003C= 8, \u0027Invalid stage\u0027);\r\n    _;\r\n  }\r\n\r\n  modifier validStageAmount(uint _stage) {\r\n    require(msg.value == stagePrice[_stage], \u0027Invalid stage amount\u0027);\r\n    _;\r\n  }\r\n\r\n  constructor() public {\r\n    stagePrice[1] = 0.05 ether;\r\n    stagePrice[2] = 0.15 ether;\r\n    stagePrice[3] = 0.45 ether;\r\n    stagePrice[4] = 1.35 ether;\r\n    stagePrice[5] = 4.05 ether;\r\n    stagePrice[6] = 12.15 ether;\r\n    stagePrice[7] = 36.45 ether;\r\n    stagePrice[8] = 109.35 ether;\r\n\r\n    currentUserID\u002B\u002B;\r\n\r\n    owner = msg.sender;\r\n\r\n    users[owner] = createNewUser(0);\r\n    userAddresses[currentUserID] = owner;\r\n\r\n    for (uint i = 1; i \u003C= 8; i\u002B\u002B) {\r\n      users[owner].stageEndTime[i] = 1 \u003C\u003C 37;\r\n    }\r\n  }\r\n\r\n  function () external payable {\r\n    uint stage;\r\n\r\n    for (uint i = 1; i \u003C= 8; i\u002B\u002B) {\r\n      if (msg.value == stagePrice[i]) {\r\n        stage = i;\r\n        break;\r\n      }\r\n    }\r\n\r\n    require(stage \u003E 0, \u0027Invalid amount has sent\u0027);\r\n\r\n    if (users[msg.sender].id != 0) {\r\n      buyStage(stage);\r\n      return;\r\n    }\r\n\r\n    if (stage != 1) {\r\n      revert(\u0027Buy first stage for 0.05 ETH\u0027);\r\n    }\r\n\r\n    address referrer = bytesToAddress(msg.data);\r\n    registerUser(users[referrer].id);\r\n  }\r\n\r\n  function registerUser(uint _referrerID) public payable userNotRegistered() validReferrerID(_referrerID) validStageAmount(1) {\r\n    if (users[userAddresses[_referrerID]].referrals.length \u003E= REFERRALS_LIMIT) {\r\n      _referrerID = users[findReferrer(userAddresses[_referrerID])].id;\r\n    }\r\n\r\n    currentUserID\u002B\u002B;\r\n\r\n    users[msg.sender] = createNewUser(_referrerID);\r\n    userAddresses[currentUserID] = msg.sender;\r\n    users[msg.sender].stageEndTime[1] = now \u002B STAGE_DURATION;\r\n\r\n    users[userAddresses[_referrerID]].referrals.push(msg.sender);\r\n\r\n    transferStagePayment(1, msg.sender);\r\n    emit RegisterUserEvent(msg.sender, userAddresses[_referrerID], now);\r\n  }\r\n\r\n  function buyStage(uint _stage) public payable userRegistered() validStage(_stage) validStageAmount(_stage) {\r\n    for (uint s = _stage - 1; s \u003E 0; s--) {\r\n      require(getUserStageEndTime(msg.sender, s) \u003E= now, \u0027Buy the previous stage\u0027);\r\n    }\r\n\r\n    if (getUserStageEndTime(msg.sender, _stage) == 0) {\r\n      users[msg.sender].stageEndTime[_stage] = now \u002B STAGE_DURATION;\r\n    } else {\r\n      users[msg.sender].stageEndTime[_stage] \u002B= STAGE_DURATION;\r\n    }\r\n\r\n    transferStagePayment(_stage, msg.sender);\r\n    emit BuyStageEvent(msg.sender, _stage, now);\r\n  }\r\n\r\n  function findReferrer(address _user) public view returns (address) {\r\n    if (users[_user].referrals.length \u003C REFERRALS_LIMIT) {\r\n      return _user;\r\n    }\r\n\r\n    address[363] memory referrals;\r\n    referrals[0] = users[_user].referrals[0];\r\n    referrals[1] = users[_user].referrals[1];\r\n    referrals[2] = users[_user].referrals[2];\r\n\r\n    address referrer;\r\n\r\n    for (uint i = 0; i \u003C 363; i\u002B\u002B) {\r\n      if (users[referrals[i]].referrals.length \u003C REFERRALS_LIMIT) {\r\n        referrer = referrals[i];\r\n        break;\r\n      }\r\n\r\n      if (i \u003E= 120) {\r\n        continue;\r\n      }\r\n\r\n      referrals[(i\u002B1)*3] = users[referrals[i]].referrals[0];\r\n      referrals[(i\u002B1)*3\u002B1] = users[referrals[i]].referrals[1];\r\n      referrals[(i\u002B1)*3\u002B2] = users[referrals[i]].referrals[2];\r\n    }\r\n\r\n    require(referrer != address(0), \u0027Referrer was not found\u0027);\r\n\r\n    return referrer;\r\n  }\r\n\r\n  function transferStagePayment(uint _stage, address _user) internal {\r\n    uint height;\r\n    if (_stage == 1 || _stage == 5) {\r\n      height = 1;\r\n    } else if (_stage == 2 || _stage == 6) {\r\n      height = 2;\r\n    } else if (_stage == 3 || _stage == 7) {\r\n      height = 3;\r\n    } else if (_stage == 4 || _stage == 8) {\r\n      height = 4;\r\n    }\r\n\r\n    address referrer = getUserUpline(_user, height);\r\n\r\n    if (referrer == address(0)) {\r\n      referrer = owner;\r\n    }\r\n\r\n    if (getUserStageEndTime(referrer, _stage) \u003C now) {\r\n      emit LostStageProfitEvent(referrer, msg.sender, _stage, now);\r\n      transferStagePayment(_stage, referrer);\r\n      return;\r\n    }\r\n\r\n    if (addressToPayable(referrer).send(msg.value)) {\r\n      emit GetStageProfitEvent(referrer, msg.sender, _stage, now);\r\n    }\r\n  }\r\n\r\n\r\n  function getUserUpline(address _user, uint height) public view returns (address) {\r\n    if (height \u003C= 0 || _user == address(0)) {\r\n      return _user;\r\n    } else {\r\n      return this.getUserUpline(userAddresses[users[_user].referrerID], height - 1);\r\n    }\r\n  }\r\n\r\n  function getUserReferrals(address _user) public view returns (address[] memory) {\r\n    return users[_user].referrals;\r\n  }\r\n\r\n  function getUserStageEndTime(address _user, uint _stage) public view returns (uint) {\r\n    return users[_user].stageEndTime[_stage];\r\n  }\r\n\r\n\r\n  function createNewUser(uint _referrerID) private view returns (User memory) {\r\n    return User({ id: currentUserID, referrerID: _referrerID, referrals: new address[](0) });\r\n  }\r\n\r\n  function bytesToAddress(bytes memory _addr) private pure returns (address addr) {\r\n    assembly {\r\n      addr := mload(add(_addr, 20))\r\n    }\r\n  }\r\n\r\n  function addressToPayable(address _addr) private pure returns (address payable) {\r\n    return address(uint160(_addr));\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_stage\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getUserStageEndTime\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_referrerID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022registerUser\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022userAddresses\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getUserReferrals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022users\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022referrerID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022currentUserID\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022stagePrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022findReferrer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_stage\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022buyStage\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022height\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getUserUpline\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022referrer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022RegisterUserEvent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022stage\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022BuyStageEvent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022referral\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022stage\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022GetStageProfitEvent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022referral\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022stage\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LostStageProfitEvent\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"DFW","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://64ec29311d23a585c78f41bd279783490fe3624627848db688fb218dab85ff12"}]