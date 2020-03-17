[{"SourceCode":"//                               __     __               __\r\n//    _________ ___  ____ ______/ /_   / /__ _   _____  / /\r\n//   / ___/ __ \u0060__ \\/ __ \u0060/ ___/ __/  / / _ \\ | / / _ \\/ / \r\n//  (__  ) / / / / / /_/ / /  / /_   / /  __/ |/ /  __/ /  \r\n// /____/_/ /_/ /_/\\__,_/_/   \\__/  /_/\\___/|___/\\___/_/   \r\n//\r\n//\r\n// Telegram: @smartlvl\r\n// hashtag: #smartlvl\r\n\r\n\r\npragma solidity ^0.5.11;\r\n\r\ncontract Smartlevel {\r\n\taddress public creator;\r\n\tuint public currentUserID;\r\n\r\n\tmapping(uint =\u003E uint) public levelPrice;\r\n\tmapping(address =\u003E User) public users;\r\n\tmapping(uint =\u003E address) public userAddresses;\r\n\r\n\tuint MAX_LEVEL = 10;\r\n\tuint REFERRALS_LIMIT = 3;\r\n\tuint LEVEL_DURATION = 15 days;\r\n\r\n\tstruct User {\r\n\t\tuint id;\r\n\t\tuint referrerID;\r\n\t\taddress[] referrals;\r\n\t\tmapping (uint =\u003E uint) levelExpiresAt;\r\n\t}\r\n\r\n\tevent RegisterUserEvent(address indexed user, address indexed referrer, uint time, uint id, uint expires);\r\n\tevent BuyLevelEvent(address indexed user, uint indexed level, uint time, uint expires);\r\n\tevent GetLevelProfitEvent(address indexed user, address indexed referral, uint indexed level, uint time);\r\n\tevent LostLevelProfitEvent(address indexed user, address indexed referral, uint indexed level, uint time);\r\n\r\n\tmodifier userNotRegistered() {\r\n\t\trequire(users[msg.sender].id == 0, \u0027User is already registered\u0027);\r\n\t\t_;\r\n\t}\r\n\r\n\tmodifier userRegistered() {\r\n\t\trequire(users[msg.sender].id != 0, \u0027User does not exist\u0027);\r\n\t\t_;\r\n\t}\r\n\r\n\tmodifier validReferrerID(uint _referrerID) {\r\n\t\trequire(_referrerID \u003E 0 \u0026\u0026 _referrerID \u003C= currentUserID, \u0027Invalid referrer ID\u0027);\r\n\t\t_;\r\n\t}\r\n\r\n\tmodifier validLevel(uint _level) {\r\n\t\trequire(_level \u003E 0 \u0026\u0026 _level \u003C= MAX_LEVEL, \u0027Invalid level\u0027);\r\n\t\t_;\r\n\t}\r\n\r\n\tmodifier validLevelAmount(uint _level) {\r\n\t\trequire(msg.value == levelPrice[_level], \u0027Invalid level amount\u0027);\r\n\t\t_;\r\n\t}\r\n\r\n\tconstructor() public {\r\n\t\tlevelPrice[1] = 0.03 ether;\r\n\t\tlevelPrice[2] = 0.09 ether;\r\n\t\tlevelPrice[3] = 0.15 ether;\r\n\t\tlevelPrice[4] = 0.3 ether;\r\n\t\tlevelPrice[5] = 0.35 ether;\r\n\t\tlevelPrice[6] = 0.6 ether;\r\n\t\tlevelPrice[7] = 1 ether;\r\n\t\tlevelPrice[8] = 2 ether;\r\n\t\tlevelPrice[9] = 5 ether;\r\n\t\tlevelPrice[10] = 10 ether;\r\n\r\n\t\tcurrentUserID\u002B\u002B;\r\n\r\n\t\tcreator = 0x91c59276d6f1360BEB35e7e5105FE6A0BD26df2c;\r\n\r\n\t\tusers[creator] = createNewUser(0);\r\n\t\tuserAddresses[currentUserID] = creator;\r\n\r\n\t\tfor(uint i = 1; i \u003C= MAX_LEVEL; i\u002B\u002B) {\r\n\t\t\tusers[creator].levelExpiresAt[i] = 1893456000;\r\n\t\t}\r\n\t}\r\n\r\n\tfunction() external payable {\r\n\t\tuint level;\r\n\r\n\t\tfor(uint i = 1; i \u003C= MAX_LEVEL; i\u002B\u002B) {\r\n\t\t\tif(msg.value == levelPrice[i]) {\r\n\t\t\t\tlevel = i;\r\n\t\t\t\tbreak;\r\n\t\t\t}\r\n\t\t}\r\n\r\n\t\trequire(level \u003E 0, \u0027Invalid amount has sent\u0027);\r\n\r\n\t\tif(users[msg.sender].id != 0) {\r\n\t\t\tbuyLevel(level);\r\n\t\t\treturn;\r\n\t\t}\r\n\r\n\t\tif(level != 1) {\r\n\t\t\trevert(\u0027Buy first level for 0.03 ETH\u0027);\r\n\t\t}\r\n\r\n\t\taddress referrer = bytesToAddress(msg.data);\r\n\t\tregisterUser(users[referrer].id);\r\n\t}\r\n\t\r\n\tfunction registerUser(uint _referrerID) public payable userNotRegistered() validReferrerID(_referrerID) validLevelAmount(1) {\r\n\t\tif(users[userAddresses[_referrerID]].referrals.length \u003E= REFERRALS_LIMIT) {\r\n\t\t\t_referrerID = users[findReferrer(userAddresses[_referrerID])].id;\r\n\t\t}\r\n\r\n\t\tcurrentUserID\u002B\u002B;\r\n\r\n\t\tusers[msg.sender] = createNewUser(_referrerID);\r\n\t\tuserAddresses[currentUserID] = msg.sender;\r\n\t\tusers[msg.sender].levelExpiresAt[1] = now \u002B LEVEL_DURATION;\r\n\r\n\t\tusers[userAddresses[_referrerID]].referrals.push(msg.sender);\r\n\r\n\t\ttransferLevelPayment(1, msg.sender);\r\n\t\temit RegisterUserEvent(msg.sender, userAddresses[_referrerID], now, currentUserID, users[msg.sender].levelExpiresAt[1]);\r\n\t}\r\n\r\n\tfunction buyLevel(uint _level) public payable userRegistered() validLevel(_level) validLevelAmount(_level) {\r\n\t\tfor(uint l = _level - 1; l \u003E 0; l--) {\r\n\t\t\trequire(getUserLevelExpiresAt(msg.sender, l) \u003E= now, \u0027Buy the previous level\u0027);\r\n\t\t}\r\n\r\n\t\tif(getUserLevelExpiresAt(msg.sender, _level) \u003C now) {\r\n\t\t\tusers[msg.sender].levelExpiresAt[_level] = now \u002B LEVEL_DURATION;\r\n\t\t} else {\r\n\t\t\tusers[msg.sender].levelExpiresAt[_level] \u002B= LEVEL_DURATION;\r\n\t\t}\r\n\r\n\t\ttransferLevelPayment(_level, msg.sender);\r\n\t\temit BuyLevelEvent(msg.sender, _level, now, users[msg.sender].levelExpiresAt[_level]);\r\n\t}\r\n\r\n\tfunction findReferrer(address _user) public view returns(address) {\r\n\t\tif(users[_user].referrals.length \u003C REFERRALS_LIMIT) {\r\n\t\t\treturn _user;\r\n\t\t}\r\n\r\n\t\taddress[1200] memory referrals;\r\n\t\treferrals[0] = users[_user].referrals[0];\r\n\t\treferrals[1] = users[_user].referrals[1];\r\n\t\treferrals[2] = users[_user].referrals[2];\r\n\r\n\t\taddress referrer;\r\n\r\n\t\tfor(uint i = 0; i \u003C 1200; i\u002B\u002B) {\r\n\t\t\tif(users[referrals[i]].referrals.length \u003C REFERRALS_LIMIT) {\r\n\t\t\t\treferrer = referrals[i];\r\n\t\t\t\tbreak;\r\n\t\t\t}\r\n\r\n\t\t\tif(i \u003E= 400) {\r\n\t\t\t\tcontinue;\r\n\t\t\t}\r\n\r\n\t\t\treferrals[(i \u002B 1) * 3] = users[referrals[i]].referrals[0];\r\n\t\t\treferrals[(i \u002B 1) * 3 \u002B 1] = users[referrals[i]].referrals[1];\r\n\t\t\treferrals[(i \u002B 1) * 3 \u002B 2] = users[referrals[i]].referrals[2];\r\n\t\t}\r\n\r\n\t\trequire(referrer != address(0), \u0027Referrer was not found\u0027);\r\n\r\n\t\treturn referrer;\r\n\t}\r\n\r\n\tfunction transferLevelPayment(uint _level, address _user) internal {\r\n\t\tuint height = _level % 2 == 0 ? 2 : 1;\r\n\t\taddress referrer = getUserUpline(_user, height);\r\n\r\n\t\tif(referrer == address(0)) {\r\n\t\t\treferrer = creator;\r\n\t\t}\r\n\r\n\t\tif(getUserLevelExpiresAt(referrer, _level) \u003C now) {\r\n\t\t\temit LostLevelProfitEvent(referrer, msg.sender, _level, now);\r\n\t\t\ttransferLevelPayment(_level, referrer);\r\n\t\t\treturn;\r\n\t\t}\r\n\r\n\t\tif(addressToPayable(referrer).send(msg.value)) {\r\n\t\t\temit GetLevelProfitEvent(referrer, msg.sender, _level, now);\r\n\t\t}\r\n\t}\r\n\r\n\r\n\tfunction getUserUpline(address _user, uint height) public view returns(address) {\r\n\t\tif(height \u003C= 0 || _user == address(0)) {\r\n\t\t\treturn _user;\r\n\t\t}\r\n\r\n\t\treturn this.getUserUpline(userAddresses[users[_user].referrerID], height - 1);\r\n\t}\r\n\r\n\tfunction getUserReferrals(address _user) public view returns(address[] memory) {\r\n\t\treturn users[_user].referrals;\r\n\t}\r\n\r\n\tfunction getUserLevelExpiresAt(address _user, uint _level) public view returns(uint) {\r\n\t\treturn users[_user].levelExpiresAt[_level];\r\n\t}\r\n\r\n\r\n\tfunction createNewUser(uint _referrerID) private view returns(User memory) {\r\n\t\treturn User({ id: currentUserID, referrerID: _referrerID, referrals: new address[](0) });\r\n\t}\r\n\r\n\tfunction bytesToAddress(bytes memory _addr) private pure returns(address addr) {\r\n\t\tassembly {\r\n\t\t\taddr := mload(add(_addr, 20))\r\n\t\t}\r\n\t}\r\n\r\n\tfunction addressToPayable(address _addr) private pure returns(address payable) {\r\n\t\treturn address(uint160(_addr));\r\n\t}\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022level\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022expires\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022BuyLevelEvent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022referral\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022level\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022GetLevelProfitEvent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022referral\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022level\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LostLevelProfitEvent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022referrer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022expires\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022RegisterUserEvent\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_level\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022buyLevel\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022creator\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022currentUserID\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022findReferrer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_level\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getUserLevelExpiresAt\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getUserReferrals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022height\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getUserUpline\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022levelPrice\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_referrerID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022registerUser\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022userAddresses\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022users\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022referrerID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"Smartlevel","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://785ddfd40bacab9bd1b08cbe21802854b6052f65563f9b4934472a8f2a05e93f"}]