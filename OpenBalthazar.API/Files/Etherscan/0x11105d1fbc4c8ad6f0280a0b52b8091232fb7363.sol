[{"SourceCode":"/*! blagada.sol | (c) 2019 Develop by BelovITLab LLC (smartcontract.ru), author @stupidlovejoy | License: MIT */\r\n\r\npragma solidity 0.5.13;\r\n\r\ncontract Fund {\r\n    mapping(address =\u003E uint16) public percentages;\r\n    mapping(address =\u003E uint256) public withdraws;\r\n\r\n    uint256 replenishment;\r\n    \r\n    constructor() public {\r\n        percentages[0x1e10282a6B7B17c731A9858ae5c86a87D61E4900] = 1875;  // 18.75%\r\n        percentages[0x59592072569070A4FE7031F1851c86C7e30BFF03] = 1875;  // 18.75%\r\n        percentages[0x16Dc9c884e833ad686e3e034734F66677fF789d5] = 1875;  // 18.75%\r\n        percentages[0xE8f4BE5808d428f62858aF0C33632100b3DEa7a7] = 1875;  // 18.75%\r\n\r\n        percentages[0x56955CF0778F5DD5a2E79Ff9e51b208dF11Ef380] = 1000;  // \u041A\u043E\u0448\u0435\u043B\u0435\u043A B 10%\r\n        percentages[0x75f44Ab0FDf7bBEdaDa482689c9847f06A4Be444] = 500;   // \u041A\u043E\u0448\u0435\u043B\u0435\u043A \u041A 5%\r\n\r\n        percentages[0x4581B2fCB5A2DA7da54dD44D9ff310F16F1b2c15] = 100;   // 1% \r\n        percentages[0x15cAeBd9909c1d766255145091531Fb1cC4bB78F] = 100;   // 1% \r\n        percentages[0xBFc2d6ED4F5Bbed2A086511d8c31BFD248C7Cb6b] = 100;   // 1% \r\n        percentages[0x4325E5605eCcC2dB662e4cA2BA5fBE8F13B4CB52] = 100;   // 1% \r\n        percentages[0x3BaE1345fD48De81559f37448a6d6Ad1cA8d6906] = 100;   // 1% \r\n        percentages[0x999d246b3F01f41E500007c21f1B3Ac14324A44F] = 100;   // 1% \r\n        percentages[0x2500628b6523E3F4F7BBdD92D9cF7F4A91f8e331] = 100;   // 1% \r\n        percentages[0xFCFF774f6945C7541e585bfd3244359F7b27ff30] = 100;   // 1% \r\n        percentages[0xD683d5835DFa541b192eDdB14b5516cDeBc97445] = 100;   // 1% \r\n        percentages[0xdb741F30840aE7a3A17Fe5f5773559A0DB3C26a6] = 100;   // 1% \r\n        \r\n    }\r\n\r\n    function() external payable {\r\n        replenishment \u002B= msg.value;\r\n    }\r\n\r\n    function withdraw() external {\r\n        require(percentages[msg.sender] \u003E 0, \u0022You are not a member\u0022);\r\n\r\n        uint256 value = replenishment * percentages[msg.sender] / 10000;\r\n\r\n        require(value \u003E 0 \u0026\u0026 value \u003E withdraws[msg.sender], \u0022No funds to withdraw\u0022);\r\n\r\n        value -= withdraws[msg.sender];\r\n\r\n        withdraws[msg.sender] \u002B= value;\r\n\r\n        address(msg.sender).transfer(value);\r\n    }\r\n\r\n\r\n    function balanceOf(address addr) public view returns(uint) {\r\n        uint256 value = percentages[addr] \u003E 0 ? replenishment * percentages[addr] / 10000 : 0;\r\n\r\n        return value \u003E withdraws[addr] ? value - withdraws[addr] : 0;\r\n    }\r\n\r\n    function changeWallet(address wallet) external {\r\n        require(percentages[msg.sender] \u003E 0, \u0022You are not a member\u0022);\r\n        require(wallet != address(0), \u0022Zero address\u0022);\r\n\r\n        percentages[wallet] = percentages[msg.sender];\r\n        withdraws[wallet] = withdraws[msg.sender];\r\n        percentages[msg.sender] = 0;\r\n        withdraws[msg.sender] = 0;\r\n    }\r\n}\r\n\r\ncontract Blagada {\r\n    struct Level {\r\n        uint96 min_price;\r\n        uint96 max_price;\r\n    }\r\n\r\n    struct User {\r\n        address payable upline;\r\n        address payable[] referrals;\r\n        uint8 level;\r\n        uint64 expires;\r\n        uint256 fwithdraw;\r\n    }\r\n    \r\n    uint32 LEVEL_LIFE_TIME = 180 days;\r\n\r\n    address payable public root_user;\r\n    address payable public blago;\r\n    address payable public walletK;\r\n    address payable public owner;\r\n\r\n    Level[] public levels;\r\n    uint8[] public payouts;\r\n    mapping(address =\u003E User) public users;\r\n    address[] public vips;\r\n\r\n    event Registration(address indexed user, address indexed upline, uint64 time);\r\n    event LevelPurchase(address indexed user, uint8 indexed level, uint64 time, uint64 expires, uint256 amount);\r\n    event ReceivingProfit(address indexed user, address indexed referral, uint8 indexed level, uint64 time, uint256 amount);\r\n    event LostProfit(address indexed user, address indexed referral, uint8 indexed level, uint64 time, uint256 amount);\r\n    event Blago(address indexed from, uint64 time, uint256 amount);\r\n    event Withdraw(address indexed user, uint64 time, uint256 amount);\r\n\r\n    modifier onlyOwner() {\r\n        require(owner == msg.sender, \u0022Ownable: caller is not owner\u0022);\r\n        _;\r\n    }\r\n\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n        root_user = address(new Fund());\r\n        blago = address(0x56955CF0778F5DD5a2E79Ff9e51b208dF11Ef380);        // \u041A\u043E\u0448\u0435\u043B\u0435\u043A B 10%\r\n        walletK = address(0x75f44Ab0FDf7bBEdaDa482689c9847f06A4Be444);      // \u041A\u043E\u0448\u0435\u043B\u0435\u043A \u041A 5%\r\n\r\n        levels.push(Level({min_price: 0.299 ether, max_price: 1 ether}));\r\n        levels.push(Level({min_price: 1 ether, max_price: 5 ether}));\r\n        levels.push(Level({min_price: 5 ether, max_price: 10 ether}));\r\n        levels.push(Level({min_price: 10 ether, max_price: 15 ether}));\r\n        levels.push(Level({min_price: 15 ether, max_price: 25 ether}));\r\n        levels.push(Level({min_price: 25 ether, max_price: 1000 ether}));\r\n\r\n        payouts.push(30);\r\n        payouts.push(25);\r\n        payouts.push(12);\r\n        payouts.push(5);\r\n        payouts.push(5);\r\n        payouts.push(3);\r\n        payouts.push(2);\r\n        payouts.push(1);\r\n        payouts.push(1);\r\n        payouts.push(1);\r\n        \r\n        users[root_user].level = uint8(levels.length - 1);\r\n        users[root_user].expires = 183267472027;\r\n\r\n        emit Registration(root_user, address(0), uint64(block.timestamp));\r\n        emit LevelPurchase(root_user, users[root_user].level, uint64(block.timestamp), users[root_user].expires, 0);\r\n\r\n        address[] memory list = new address[](46);\r\n        list[0] = 0xde600c21494c15D4CDBfCa5Bf689ee534342EcfA;\r\n        list[1] = 0x8E6cbF3fA5D12e010898DC6E68e784ac1e58E80F;\r\n        list[2] = 0x1e9d8D511a5D2d0c6aF6DF6Da462E3894Bb32325;\r\n        list[3] = 0xB41B73a83DBdfD24A35E31c19b4fb0CE0252aa27;\r\n        list[4] = 0xA1B8cA867A26401AE07126a47126EE3C7080e251;\r\n        list[5] = 0x8BaDE5100669AF635703832b62C996009560bD18;\r\n        list[6] = 0x772e032AeecCf7aab3683a5df8dc3B9002d29D51;\r\n        list[7] = 0x7692214250d03438e9843b13C0effa1F85394025;\r\n        list[8] = 0x0F147484a079b4426921a16bc70FB4C7Bd754dc4;\r\n        list[9] = 0xc6170ac0cEC6E22e250AfbDDE291df64F94626C0;\r\n\r\n        list[10] = 0xDdd96C742fb846a10E9Ca0c50b123Dbbbb1D70B0;\r\n        list[11] = 0x8b4b7F5CB3165e6f32e091304aD2aD43E870826e;\r\n        list[12] = 0x63d2B1Ca8e2F949A59216Ba6C55f41545392a918;\r\n        list[13] = 0xe14d67d018230410f237b5489Cac50451c8841ab;\r\n        list[14] = 0x54EE5d0A4DC8CDE0f51eb2ba9b861519D37B380C;\r\n        list[15] = 0x83594907F7677cA96b568CA2bD7ee04A219B4FC2;\r\n        list[16] = 0x1Ca922172299685798011Fc5941822FEcfFB8485;\r\n        list[17] = 0xBFb52505Cb8F51412ef897320b2D0199fFab2151;\r\n        list[18] = 0xde10a0378A8A2d7A64fA6D62feF99B6fcf17C0A3;\r\n        list[19] = 0x717c6447d865E617951A2Bc9B08C5ea804f2a8aE;\r\n        list[20] = 0x615E643772570fEC30664b17EE8DF9bbb0e79E1C;\r\n        list[21] = 0x394ec39117b7aA48D70186C3F5edB1f8c09084C7;\r\n        list[22] = 0xCDf9799c49ACacCac3B0b9e14BB64798301B8996;\r\n        list[23] = 0x7873E6ca3bA7C098Ce85a37831348514CCd511dF;\r\n        list[24] = 0xF00435beA2220Ad496eb63853F6E97B52a9d9b2C;\r\n        list[25] = 0x40c84308bAd2504998Be9C04CD023576DF171053;\r\n        list[26] = 0x3e8e59a3763f26Ec53CdcEb6B1824a66F404E1C6;\r\n        list[27] = 0x13c4F19a3D055DA02107723AE8c9Ca19e2dE102B;\r\n        list[28] = 0xf4DE137266f9670b91654cFFcef61C2C27A5B9ae;\r\n        list[29] = 0x99A994646c69e4b0636F32b878b6a78067F478fe;\r\n\r\n        list[30] = 0x1e10282a6B7B17c731A9858ae5c86a87D61E4900;   // 18.75%\r\n        list[31] = 0x59592072569070A4FE7031F1851c86C7e30BFF03;   // 18.75%\r\n        list[32] = 0x16Dc9c884e833ad686e3e034734F66677fF789d5;   // 18.75%\r\n        list[33] = 0xE8f4BE5808d428f62858aF0C33632100b3DEa7a7;   // 18.75%\r\n\r\n        list[34] = 0x4581B2fCB5A2DA7da54dD44D9ff310F16F1b2c15;   // 1% \r\n        list[35] = 0x15cAeBd9909c1d766255145091531Fb1cC4bB78F;   // 1% \r\n        list[36] = 0xBFc2d6ED4F5Bbed2A086511d8c31BFD248C7Cb6b;   // 1% \r\n        list[37] = 0x4325E5605eCcC2dB662e4cA2BA5fBE8F13B4CB52;   // 1% \r\n        list[38] = 0x3BaE1345fD48De81559f37448a6d6Ad1cA8d6906;   // 1% \r\n        list[39] = 0x999d246b3F01f41E500007c21f1B3Ac14324A44F;   // 1% \r\n        list[40] = 0x2500628b6523E3F4F7BBdD92D9cF7F4A91f8e331;   // 1% \r\n        list[41] = 0xFCFF774f6945C7541e585bfd3244359F7b27ff30;   // 1% \r\n        list[42] = 0xD683d5835DFa541b192eDdB14b5516cDeBc97445;   // 1% \r\n        list[43] = 0xdb741F30840aE7a3A17Fe5f5773559A0DB3C26a6;   // 1% \r\n\r\n        list[44] = 0x56955CF0778F5DD5a2E79Ff9e51b208dF11Ef380;   // \u041A\u043E\u0448\u0435\u043B\u0435\u043A B 10%\r\n        list[45] = 0x75f44Ab0FDf7bBEdaDa482689c9847f06A4Be444;   // \u041A\u043E\u0448\u0435\u043B\u0435\u043A \u041A 5%\r\n\r\n        for(uint8 i = 0; i \u003C list.length; i\u002B\u002B) {\r\n            users[list[i]].level = i \u003E 43 ? 0 : uint8(levels.length - 1);\r\n            users[list[i]].expires = 183267472027;\r\n\r\n            if(i \u003C 44)vips.push(list[i]);\r\n\r\n            emit Registration(list[i], root_user, uint64(block.timestamp));\r\n            emit LevelPurchase(list[i], users[list[i]].level, uint64(block.timestamp), users[list[i]].expires, 0);\r\n        }\r\n\r\n    }\r\n\r\n    function payout(address payable user, uint256 value, uint8 level) private {\r\n        address payable member = users[user].upline;\r\n        uint256 balance = value;\r\n        uint256 bvalue = 0;\r\n\r\n        blago.transfer(value * 10 / 100);\r\n        walletK.transfer(value * 4 / 100);\r\n\r\n        balance -= balance * 14 / 100;\r\n\r\n        for(uint8 i = 0; i \u003C payouts.length; i\u002B\u002B) {\r\n            if(member == address(0) || member == root_user) break;\r\n            \r\n            uint256 amount = value * payouts[i] / 100;\r\n\r\n            if(i \u003E 5 \u0026\u0026 users[member].level \u003C i - 5) {\r\n                amount /= 2;\r\n                bvalue \u002B= amount;\r\n            }\r\n\r\n            if(users[member].expires \u003E= block.timestamp \u0026\u0026 users[member].level \u003E= level) {\r\n                if(member.send(amount)) {\r\n                    balance -= amount;\r\n\r\n                    emit ReceivingProfit(member, user, level, uint64(block.timestamp), amount);\r\n                }\r\n            }\r\n            else {\r\n                bvalue \u002B= amount;\r\n\r\n                emit LostProfit(member, user, level, uint64(block.timestamp), amount);\r\n            }\r\n\r\n            member = users[member].upline;\r\n        }\r\n\r\n        if(bvalue \u003E 0) {\r\n            blago.transfer(bvalue);\r\n            balance -= bvalue;\r\n\r\n            emit Blago(user, uint64(block.timestamp), bvalue);\r\n        }\r\n\r\n        if(vips.length \u003E 0) {\r\n            uint256 vpay = value / 100;\r\n            uint256 vpay_pm = vpay / vips.length;\r\n            balance -= vpay;\r\n\r\n            for(uint256 i = 0; i \u003C vips.length; i\u002B\u002B) {\r\n                users[vips[i]].fwithdraw \u002B= vpay_pm;\r\n            }\r\n        }\r\n\r\n        (bool success,) = address(root_user).call.value(balance).gas(180000)(\u0022\u0022);\r\n        require(success, \u0022Error send root money\u0022);\r\n\r\n        emit ReceivingProfit(root_user, user, level, uint64(block.timestamp), balance);\r\n    }\r\n\r\n    function setLevel(uint8 index, uint96 min_price, uint96 max_price) external onlyOwner {\r\n        levels[index] = Level({min_price: min_price, max_price: max_price});\r\n    }\r\n\r\n    function() external payable {\r\n        User storage user = users[msg.sender];\r\n        \r\n        if(user.upline == address(0)) {\r\n            user.upline = bytesToAddress(msg.data);\r\n\r\n            if(users[user.upline].upline == address(0)) {\r\n                user.upline = root_user;\r\n            }\r\n\r\n            users[user.upline].referrals.push(msg.sender);\r\n\r\n            emit Registration(msg.sender, user.upline, uint64(block.timestamp));\r\n        }\r\n\r\n        uint8 level = this.getLevelByPrice(msg.value);\r\n\r\n        require(user.expires == 0 || (user.expires \u003E= block.timestamp \u0026\u0026 level \u003E user.level) || (user.expires \u003C block.timestamp \u0026\u0026 level \u003E= user.level), \u0022Invalid level\u0022);\r\n        \r\n        if(user.level \u003C 5 \u0026\u0026 level == 5) {\r\n            vips.push(msg.sender);\r\n        }\r\n\r\n        user.level = level;\r\n\r\n        user.expires = uint64(block.timestamp \u002B LEVEL_LIFE_TIME);\r\n\r\n        emit LevelPurchase(msg.sender, level, uint64(block.timestamp), user.expires, msg.value);\r\n\r\n        payout(msg.sender, msg.value, level);\r\n    }\r\n\r\n\r\n    function withdraw() external {\r\n        require(users[msg.sender].fwithdraw \u003E 0, \u0022Your balance is empty\u0022);\r\n        require(users[msg.sender].expires \u003E block.timestamp, \u0022Pay level\u0022);\r\n\r\n        address(msg.sender).transfer(users[msg.sender].fwithdraw);\r\n\r\n        emit Withdraw(msg.sender, uint64(block.timestamp), users[msg.sender].fwithdraw);\r\n\r\n        users[msg.sender].fwithdraw = 0;\r\n    }\r\n\r\n    function getLevelByPrice(uint value) external view returns(uint8) {\r\n        require(value \u003E= levels[0].min_price \u0026\u0026 value \u003C= levels[levels.length - 1].max_price, \u0022Amount not in the range\u0022);\r\n\r\n        for(uint8 i = 0; i \u003C levels.length; i\u002B\u002B) {\r\n            if(value \u003E levels[i].min_price \u0026\u0026 value \u003C= levels[i].max_price) {\r\n                return i;\r\n            }\r\n        }\r\n    }\r\n\r\n    function getUserReferrals(address user) external view returns(address payable[] memory) {\r\n        return users[user].referrals;\r\n    }\r\n\r\n    function bytesToAddress(bytes memory data) private pure returns(address payable addr) {\r\n        assembly {\r\n            addr := mload(add(data, 20))\r\n        }\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint64\u0022,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Blago\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022level\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint64\u0022,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint64\u0022,\u0022name\u0022:\u0022expires\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LevelPurchase\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022referral\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022level\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint64\u0022,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LostProfit\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022referral\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022level\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint64\u0022,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ReceivingProfit\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022upline\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint64\u0022,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint64\u0022}],\u0022name\u0022:\u0022Registration\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint64\u0022,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Withdraw\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022blago\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getLevelByPrice\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getUserReferrals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable[]\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022levels\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint96\u0022,\u0022name\u0022:\u0022min_price\u0022,\u0022type\u0022:\u0022uint96\u0022},{\u0022internalType\u0022:\u0022uint96\u0022,\u0022name\u0022:\u0022max_price\u0022,\u0022type\u0022:\u0022uint96\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022payouts\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022root_user\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022index\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022uint96\u0022,\u0022name\u0022:\u0022min_price\u0022,\u0022type\u0022:\u0022uint96\u0022},{\u0022internalType\u0022:\u0022uint96\u0022,\u0022name\u0022:\u0022max_price\u0022,\u0022type\u0022:\u0022uint96\u0022}],\u0022name\u0022:\u0022setLevel\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022users\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022upline\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022level\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022uint64\u0022,\u0022name\u0022:\u0022expires\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022fwithdraw\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022vips\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022walletK\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"Blagada","CompilerVersion":"v0.5.13\u002Bcommit.5b0b510c","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://bab63243c7e1679cac0c4d28de0f2d0c28520c0416dc1a850b71bea3060c4f12"}]