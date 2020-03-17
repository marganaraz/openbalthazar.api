[{"SourceCode":"/*\r\n\r\n $$$$$$\\  $$$$$$\\  \r\n \\_$$  _|$$  __$$\\ \r\n   $$ |  $$ /  $$ |\r\n   $$ |  $$ |  $$ |\r\n   $$ |  $$ |  $$ |\r\n   $$ |  $$ |  $$ |\r\n $$$$$$\\  $$$$$$  |\r\n \\______| \\______/ \r\n\r\n*/\r\n\r\npragma solidity ^0.5.10;\r\n\r\nlibrary Util {\r\n    struct User {\r\n        bool isExist;\r\n        uint256 id;\r\n        uint256 origRefID;\r\n        uint256 referrerID;\r\n        address[] referral;\r\n        uint256[] expiring;\r\n    }\r\n}\r\n\r\ncontract I0Crypto {\r\n    /////////////////////\r\n    // Events\r\n    /////////////////////\r\n    event registered(address indexed user, address indexed referrer);\r\n    event levelBought(address indexed user, uint256 level);\r\n    event receivedEther(address indexed user, address indexed referral, uint256 level);\r\n    event lostEther(address indexed user, address indexed referral, uint256 level);\r\n\r\n    /////////////////////\r\n    // Storage variables\r\n    /////////////////////\r\n    address public wallet;\r\n\r\n    uint256 constant MAX_REFERRERS = 2;\r\n    uint256 LEVEL_PERIOD = 365 days;\r\n\r\n    /////////////////////\r\n    // User structure and mappings\r\n    /////////////////////\r\n\r\n    mapping(address =\u003E Util.User) public users;\r\n    mapping(uint256 =\u003E address) public userList;\r\n    uint256 public userIDCounter = 0;\r\n\r\n    /////////////////////\r\n    // Code\r\n    /////////////////////\r\n    constructor() public {\r\n        wallet = 0x4118305883c1aA672420C140D7f251D34f86C55e;\r\n\r\n        Util.User memory user;\r\n        userIDCounter\u002B\u002B;\r\n\r\n        user = Util.User({\r\n            isExist : true,\r\n            id : userIDCounter,\r\n            origRefID: 0,\r\n            referrerID : 0,\r\n            referral : new address[](0),\r\n            expiring : new uint256[](9)\r\n            });\r\n\r\n        user.expiring[1] = 101010101010;\r\n        user.expiring[2] = 101010101010;\r\n        user.expiring[3] = 101010101010;\r\n        user.expiring[4] = 101010101010;\r\n        user.expiring[5] = 101010101010;\r\n        user.expiring[6] = 101010101010;\r\n        user.expiring[7] = 101010101010;\r\n        user.expiring[8] = 101010101010;\r\n\r\n        userList[userIDCounter] = wallet;\r\n        users[wallet] = user;\r\n    }\r\n\r\n    function() external payable {\r\n        uint256 level = getLevel(msg.value);\r\n\r\n        if (users[msg.sender].isExist) {\r\n            buy(level);\r\n        } else if (level == 1) {\r\n            uint256 referrerID = 0;\r\n            address referrer = bytesToAddress(msg.data);\r\n\r\n            if (users[referrer].isExist) {\r\n                referrerID = users[referrer].id;\r\n            } else {\r\n                revert(\u002701 wrong referrer\u0027);\r\n            }\r\n\r\n            register(referrerID);\r\n        } else {\r\n            revert(\u002202 buy level 1 for 0.1 ETH\u0022);\r\n        }\r\n    }\r\n\r\n    function register(uint256 referrerID) public payable {\r\n        require(!users[msg.sender].isExist, \u002703 user exist\u0027);\r\n        require(referrerID \u003E 0 \u0026\u0026 referrerID \u003C= userIDCounter, \u00270x04 wrong referrer ID\u0027);\r\n        require(getLevel(msg.value) == 1, \u002705 wrong value\u0027);\r\n\r\n        uint origRefID = referrerID;\r\n\t\tif (referrerID != 1) {\r\n        if (users[userList[referrerID]].referral.length \u003E= MAX_REFERRERS)\r\n        {\r\n            referrerID = users[findReferrer(userList[referrerID])].id;\r\n        }\r\n\t\t}\r\n\r\n        Util.User memory user;\r\n        userIDCounter\u002B\u002B;\r\n\r\n        user = Util.User({\r\n            isExist : true,\r\n            id : userIDCounter,\r\n            origRefID : origRefID,\r\n            referrerID : referrerID,\r\n            referral : new address[](0),\r\n            expiring : new uint256[](9)\r\n            });\r\n\r\n        user.expiring[1] = now \u002B LEVEL_PERIOD;\r\n        user.expiring[2] = 0;\r\n        user.expiring[3] = 0;\r\n        user.expiring[4] = 0;\r\n        user.expiring[5] = 0;\r\n        user.expiring[6] = 0;\r\n        user.expiring[7] = 0;\r\n        user.expiring[8] = 0;\r\n\r\n        userList[userIDCounter] = msg.sender;\r\n        users[msg.sender] = user;\r\n\r\n        users[userList[referrerID]].referral.push(msg.sender);\r\n\r\n        payForLevel(msg.sender, 1);\r\n\r\n        emit registered(msg.sender, userList[referrerID]);\r\n    }\r\n\r\n    function buy(uint256 level) public payable {\r\n        require(users[msg.sender].isExist, \u002706 user not exist\u0027);\r\n\r\n        require(level \u003E 0 \u0026\u0026 level \u003C= 8, \u002707 wrong level\u0027);\r\n\r\n        require(getLevel(msg.value) == level, \u002708 wrong value\u0027);\r\n\r\n        for (uint256 l = level - 1; l \u003E 0; l--) {\r\n             require(users[msg.sender].expiring[l] \u003E= now, \u002709 buy level\u0027);\r\n        }\r\n\r\n        if (users[msg.sender].expiring[level] == 0) {\r\n            users[msg.sender].expiring[level] = now \u002B LEVEL_PERIOD;\r\n        } else {\r\n            users[msg.sender].expiring[level] \u002B= LEVEL_PERIOD;\r\n        }\r\n\r\n        payForLevel(msg.sender, level);\r\n        emit levelBought(msg.sender, level);\r\n    }\r\n\r\n    function payForLevel(address user, uint256 level) internal {\r\n        address referrer;\r\n        uint256 above = level \u003E 4 ? level - 4 : level;\r\n        if (1 \u003C level \u0026\u0026 level \u003C 4) {\r\n            checkCanBuy(user, level);\r\n        }\r\n        if (above == 1) {\r\n            referrer = userList[users[user].referrerID];\r\n        } else if (above == 2) {\r\n            referrer = userList[users[user].referrerID];\r\n            referrer = userList[users[referrer].referrerID];\r\n        } else if (above == 3) {\r\n            referrer = userList[users[user].referrerID];\r\n            referrer = userList[users[referrer].referrerID];\r\n            referrer = userList[users[referrer].referrerID];\r\n        } else if (above == 4) {\r\n            referrer = userList[users[user].referrerID];\r\n            referrer = userList[users[referrer].referrerID];\r\n            referrer = userList[users[referrer].referrerID];\r\n            referrer = userList[users[referrer].referrerID];\r\n        }\r\n\r\n        if (!users[referrer].isExist) {\r\n            referrer = userList[1];\r\n        }\r\n\r\n        if (users[referrer].expiring[level] \u003E= now) {\r\n            bool result;\r\n            result = address(uint160(referrer)).send(msg.value);\r\n            emit receivedEther(referrer, msg.sender, level);\r\n        } else {\r\n            emit lostEther(referrer, msg.sender, level);\r\n            payForLevel(referrer, level);\r\n        }\r\n    }\r\n\r\n    function checkCanBuy(address user, uint256 level) private view {\r\n        if (level == 1) return;\r\n        address[] memory referral = users[user].referral;\r\n        require(referral.length == MAX_REFERRERS, \u002710 not enough referrals\u0027);\r\n\r\n        if (level == 2) return;\r\n        checkCanBuy(referral[0], level - 1);\r\n        checkCanBuy(referral[1], level - 1);\r\n    }\r\n\r\n    function findReferrer(address user) public view returns (address) {\r\n        address[] memory referral = users[user].referral;\r\n        if (referral.length \u003C MAX_REFERRERS) {\r\n            return user;\r\n        }\r\n\r\n        address[] memory referrals = new address[](1024);\r\n        referrals[0] = referral[0];\r\n        referrals[1] = referral[1];\r\n\r\n        address freeReferrer;\r\n        bool hasFreeReferrer = false;\r\n\r\n        for (uint256 i = 0; i \u003C 1024; i\u002B\u002B) {\r\n            referral = users[referrals[i]].referral;\r\n            if (referral.length == MAX_REFERRERS) {\r\n                if (i \u003C 512) {\r\n                    uint256 pos = (i \u002B 1) * 2;\r\n                    referrals[pos] = referral[0];\r\n                    referrals[pos \u002B 1] = referral[1];\r\n                }\r\n            } else {\r\n                hasFreeReferrer = true;\r\n                freeReferrer = referrals[i];\r\n                break;\r\n            }\r\n        }\r\n        require(hasFreeReferrer, \u002711 no free referrer\u0027);\r\n        return freeReferrer;\r\n    }\r\n\r\n    function getLevel(uint256 price) public pure returns (uint8) {\r\n        if (price == 0.1 ether) {\r\n            return 1;\r\n        } else if (price == 0.15 ether) {\r\n            return 2;\r\n        } else if (price == 0.35 ether) {\r\n            return 3;\r\n        } else if (price == 2 ether) {\r\n            return 4;\r\n        } else if (price == 5 ether) {\r\n            return 5;\r\n        } else if (price == 9 ether) {\r\n            return 6;\r\n        } else if (price == 35 ether) {\r\n            return 7;\r\n        } else if (price == 100 ether) {\r\n            return 8;\r\n        } else {\r\n            revert(\u002712 wrong value\u0027);\r\n        }\r\n    }\r\n\r\n    function viewReferral(address user) public view returns (address[] memory) {\r\n        return users[user].referral;\r\n    }\r\n\r\n    function viewLevelExpired(address user, uint256 level) public view returns (uint256) {\r\n        return users[user].expiring[level];\r\n    }\r\n\r\n    function bytesToAddress(bytes memory bys) private pure returns (address addr) {\r\n        assembly {\r\n            addr := mload(add(bys, 20))\r\n        }\r\n    }\r\n}\r\n\r\n/*\r\n300392160310180992\r\n*/","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022level\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022viewLevelExpired\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022wallet\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getLevel\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022userList\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022users\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022isExist\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022origRefID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022referrerID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022userIDCounter\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022findReferrer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022viewReferral\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022level\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022buy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022referrerID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022register\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022referrer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022registered\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022level\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022levelBought\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022referral\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022level\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022receivedEther\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022referral\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022level\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022lostEther\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"I0Crypto","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://bc1c229a0341b4fed36087d7edb72d16361c9d9d21543e2c4efc933f2ed4642f"}]