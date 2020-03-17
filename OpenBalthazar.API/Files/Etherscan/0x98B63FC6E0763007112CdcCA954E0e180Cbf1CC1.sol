[{"SourceCode":"pragma solidity ^0.4.26;\r\n\r\n/*\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with GSN meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\ncontract Context {\r\n    // Empty internal constructor, to prevent people from mistakenly deploying\r\n    // an instance of this contract, which should be used via inheritance.\r\n    constructor() internal {}\r\n    // solhint-disable-previous-line no-empty-blocks\r\n\r\n    function _msgSender() internal view returns (address) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view returns (bytes memory) {\r\n        this;\r\n        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * \u0060onlyOwner\u0060, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\ncontract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () internal {\r\n        _owner = _msgSender();\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the caller is the current owner.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return _msgSender() == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * \u0060onlyOwner\u0060 functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\n/**\r\n * @title Roles\r\n * @dev Library for managing addresses assigned to a Role.\r\n */\r\nlibrary Roles {\r\n    struct Role {\r\n        mapping(address =\u003E bool) bearer;\r\n    }\r\n\r\n    /**\r\n     * @dev Give an account access to this role.\r\n     */\r\n    function add(Role storage role, address account) internal {\r\n        require(!has(role, account), \u0022Roles: account already has role\u0022);\r\n        role.bearer[account] = true;\r\n    }\r\n\r\n    /**\r\n     * @dev Remove an account\u0027s access to this role.\r\n     */\r\n    function remove(Role storage role, address account) internal {\r\n        require(has(role, account), \u0022Roles: account does not have role\u0022);\r\n        role.bearer[account] = false;\r\n    }\r\n\r\n    /**\r\n     * @dev Check if an account has this role.\r\n     * @return bool\r\n     */\r\n    function has(Role storage role, address account) internal view returns (bool) {\r\n        require(account != address(0), \u0022Roles: account is the zero address\u0022);\r\n        return role.bearer[account];\r\n    }\r\n}\r\n\r\n/**\r\n * @title WhitelistAdminRole\r\n * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.\r\n */\r\ncontract WhitelistAdminRole is Context, Ownable {\r\n    using Roles for Roles.Role;\r\n\r\n    event WhitelistAdminAdded(address indexed account);\r\n    event WhitelistAdminRemoved(address indexed account);\r\n\r\n    Roles.Role private _whitelistAdmins;\r\n\r\n    constructor () internal {\r\n        _addWhitelistAdmin(_msgSender());\r\n    }\r\n\r\n    modifier onlyWhitelistAdmin() {\r\n        require(isWhitelistAdmin(_msgSender()) || isOwner(), \u0022WhitelistAdminRole: caller does not have the WhitelistAdmin role\u0022);\r\n        _;\r\n    }\r\n\r\n    function isWhitelistAdmin(address account) public view returns (bool) {\r\n        return _whitelistAdmins.has(account);\r\n    }\r\n\r\n    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {\r\n        _addWhitelistAdmin(account);\r\n    }\r\n\r\n    function removeWhitelistAdmin(address account) public onlyOwner {\r\n        _whitelistAdmins.remove(account);\r\n        emit WhitelistAdminRemoved(account);\r\n    }\r\n\r\n    function renounceWhitelistAdmin() public {\r\n        _removeWhitelistAdmin(_msgSender());\r\n    }\r\n\r\n    function _addWhitelistAdmin(address account) internal {\r\n        _whitelistAdmins.add(account);\r\n        emit WhitelistAdminAdded(account);\r\n    }\r\n\r\n    function _removeWhitelistAdmin(address account) internal {\r\n        _whitelistAdmins.remove(account);\r\n        emit WhitelistAdminRemoved(account);\r\n    }\r\n}\r\n\r\ncontract TTBTC is WhitelistAdminRole {\r\n\r\n    using SafeMath for *;\r\n\r\n    string constant private name = \u0022TTBTC Game Official\u0022;\r\n\r\n    uint startTime = 9;\r\n    uint endTime = 12;\r\n\r\n    uint investMin = 10 ** 17 wei;\r\n    uint investMax = 10 ether;\r\n    uint winnerProfitMax = 25 ether;\r\n\r\n    address  private devAddr = address(0xEBd465Cd6B0d415887B6B035ADfF0237EFb413b9);\r\n\r\n    uint devBalance = 0;\r\n    uint userBalance = 0;\r\n\r\n    struct UserGlobal {\r\n        uint id;\r\n        address userAddress;\r\n        string referrer;\r\n        string inviteCode;\r\n        uint level;\r\n        uint lv2Friends;\r\n        uint lv3Friends;\r\n    }\r\n\r\n    struct User {\r\n        uint id;\r\n        address userAddress;\r\n        uint level;\r\n        string referrer;\r\n        string inviteCode;\r\n        uint balance;\r\n        uint allInvestMoney;\r\n        uint allInvestCount;\r\n        uint allGuessBonus;\r\n        uint allInviteBonus;\r\n    }\r\n\r\n    struct Invest {\r\n        address userAddress;\r\n        uint investAmount;\r\n        uint intent;\r\n        uint investTime;\r\n    }\r\n\r\n    struct InvestPool {\r\n        uint investCount;\r\n        mapping(uint =\u003E Invest) invests;\r\n        mapping(address =\u003E Invest[]) userInvests;\r\n        uint riseInvests;\r\n        uint fallInvests;\r\n        uint beginBtcPrice;\r\n        uint endBtcPrice;\r\n        bool isRise;\r\n    }\r\n\r\n    mapping(uint =\u003E InvestPool) rInvests;\r\n\r\n    uint rid = 0;\r\n\r\n    uint investCount = 0;\r\n\r\n    uint investMoney = 0;\r\n\r\n    uint uid = 0;\r\n\r\n    mapping(uint =\u003E address) public indexMapping;\r\n    mapping(string =\u003E UserGlobal) inviteCodeMapping;\r\n    mapping(address =\u003E User) addressMapping;\r\n\r\n    modifier isHuman() {\r\n        address addr = msg.sender;\r\n        uint codeLength;\r\n\r\n        assembly {codeLength := extcodesize(addr)}\r\n        require(codeLength == 0, \u0022sorry humans only\u0022);\r\n        require(tx.origin == msg.sender, \u0022sorry, human only\u0022);\r\n        _;\r\n    }\r\n\r\n    event LogInvestIn(uint indexed r, address indexed who, uint amount, uint time, uint intent);\r\n    event LogWinnerProfit(uint indexed r, address indexed who, uint amount, uint intent, uint time);\r\n    event LogInviteProfit(uint indexed r, address indexed from, uint fromLv, address indexed who, uint profit, uint time);\r\n    event LogWithdrawProfit(address indexed who, uint amount, uint time);\r\n    event LogRoundEnd(uint r, uint time);\r\n    event LogSystemParamChange(uint paramType, uint time);\r\n\r\n    constructor () public {\r\n    }\r\n\r\n    function() external payable {\r\n    }\r\n\r\n    function investIn(string memory inviteCode, string memory referrer, uint intent) public isHuman() payable {\r\n        require(validInvestTime(), \u0022invest is not allowd now\u0022);\r\n        require(validInvestAmount(msg.value), \u0022invalid invest value\u0022);\r\n        require(intent == 0 || intent == 1, \u0022invalid intent\u0022);\r\n\r\n        User storage user = addressMapping[msg.sender];\r\n        if (user.id == 0) {\r\n            require(!compareStr(inviteCode, \u0022\u0022), \u0022empty invite code\u0022);\r\n            require(!isUsed(inviteCode), \u0022invite code is used\u0022);\r\n            uint userLevel = 1;\r\n            UserGlobal storage parent = inviteCodeMapping[referrer];\r\n            if (parent.id != 0) {\r\n                if (parent.level == 1) {\r\n                    userLevel = 2;\r\n                    parent.lv2Friends\u002B\u002B;\r\n                } else if (parent.level == 2) {\r\n                    userLevel = 3;\r\n                    parent.lv3Friends\u002B\u002B;\r\n                    UserGlobal storage topParent = inviteCodeMapping[parent.referrer];\r\n                    topParent.lv3Friends\u002B\u002B;\r\n                }\r\n            } else {\r\n                referrer = \u0022\u0022;\r\n            }\r\n            registerUser(msg.sender, inviteCode, referrer, userLevel);\r\n            user = addressMapping[msg.sender];\r\n        }\r\n\r\n        user.allInvestCount\u002B\u002B;\r\n        user.allInvestMoney \u002B= msg.value;\r\n\r\n        Invest memory invest = Invest(msg.sender, msg.value, intent, now);\r\n        InvestPool storage investPool = rInvests[rid];\r\n        investPool.investCount\u002B\u002B;\r\n        investPool.invests[investPool.investCount] = invest;\r\n        if (intent == 1) {\r\n            investPool.riseInvests \u002B= msg.value;\r\n        } else {\r\n            investPool.fallInvests \u002B= msg.value;\r\n        }\r\n        Invest[] storage investList = investPool.userInvests[msg.sender];\r\n        investList.push(invest);\r\n\r\n        investCount\u002B\u002B;\r\n        investMoney \u002B= msg.value;\r\n        emit LogInvestIn(rid, msg.sender, msg.value, invest.investTime, intent);\r\n    }\r\n\r\n    function reInvestIn(uint amount, uint intent) public isHuman() payable {\r\n        require(amount \u003E 0, \u0022invalid invest value\u0022);\r\n        require(validInvestTime(), \u0022invest is not allowd now\u0022);\r\n        require(intent == 0 || intent == 1, \u0022invalid intent\u0022);\r\n\r\n        User storage user = addressMapping[msg.sender];\r\n        require(user.balance \u003E= amount, \u0022balance insufficient\u0022);\r\n        uint allInvest = amount \u002B msg.value;\r\n        require(validInvestAmount(allInvest), \u0022invalid invest value\u0022);\r\n\r\n        user.balance -= amount;\r\n        user.allInvestCount\u002B\u002B;\r\n        user.allInvestMoney \u002B= allInvest;\r\n\r\n        Invest memory invest = Invest(msg.sender, allInvest, intent, now);\r\n        InvestPool storage investPool = rInvests[rid];\r\n        investPool.investCount\u002B\u002B;\r\n        investPool.invests[investPool.investCount] = invest;\r\n        if (intent == 1) {\r\n            investPool.riseInvests \u002B= allInvest;\r\n        } else {\r\n            investPool.fallInvests \u002B= allInvest;\r\n        }\r\n        Invest[] storage investList = investPool.userInvests[msg.sender];\r\n        investList.push(invest);\r\n\r\n        investCount\u002B\u002B;\r\n        investMoney \u002B= allInvest;\r\n        userBalance -= amount;\r\n        emit LogInvestIn(rid, msg.sender, allInvest, invest.investTime, intent);\r\n\r\n    }\r\n\r\n    function roundEnd(uint closePrice, uint openPrice, uint currentDate) external onlyWhitelistAdmin {\r\n        InvestPool storage investPool = rInvests[rid];\r\n        investPool.endBtcPrice = closePrice;\r\n        investPool.isRise = investPool.endBtcPrice \u003E= investPool.beginBtcPrice;\r\n        if (investPool.investCount \u003E 0) {\r\n            uint winnerInvest = investPool.isRise ? investPool.riseInvests : investPool.fallInvests;\r\n            uint allProfit = investPool.isRise ? investPool.fallInvests : investPool.riseInvests;\r\n            uint userAllProfit = allProfit.div(10).mul(9);\r\n            uint devProfit = allProfit.sub(userAllProfit);\r\n            uint divided = 0;\r\n\r\n            for (uint i = 1; i \u003C= investPool.investCount; i\u002B\u002B) {\r\n                Invest storage invest = investPool.invests[i];\r\n                uint userProfit = 0;\r\n                if (investPool.isRise \u0026\u0026 invest.intent == 1 || !investPool.isRise \u0026\u0026 invest.intent == 0) {\r\n                    uint profitSc = invest.investAmount.mul(1000000).div(winnerInvest);\r\n                    userProfit = profitSc.mul(userAllProfit).div(1000000);\r\n                    userProfit \u003E winnerProfitMax ? winnerProfitMax : userProfit;\r\n                }\r\n\r\n                if (userProfit \u003E 0) {\r\n                    divided \u002B= userProfit;\r\n                    uint divideProfit = divideProfitInternal(invest.userAddress, invest.investAmount, userProfit, invest.intent, invest.investTime);\r\n                    devProfit -= divideProfit;\r\n                }\r\n            }\r\n            devBalance = devBalance.add(devProfit).add(userAllProfit.sub(divided));\r\n        }\r\n\r\n        emit LogRoundEnd(rid, now);\r\n\r\n        rid = currentDate;\r\n        InvestPool storage ip = rInvests[rid];\r\n        ip.beginBtcPrice = openPrice;\r\n    }\r\n\r\n    function divideProfitInternal(address userAddress, uint investAmount, uint userProfit, uint intent, uint investTime) internal returns (uint) {\r\n        User storage userInfo = addressMapping[userAddress];\r\n        userInfo.allGuessBonus \u002B= userProfit;\r\n        userInfo.balance = userInfo.balance.add(investAmount).add(userProfit);\r\n        userBalance = userBalance.add(investAmount).add(userProfit);\r\n        emit LogWinnerProfit(rid, userInfo.userAddress, userProfit, intent, investTime);\r\n\r\n        uint divideProfit = parentProfit(userInfo, userProfit);\r\n        return divideProfit;\r\n    }\r\n\r\n    function parentProfit(User memory userInfo, uint userProfit) internal returns (uint) {\r\n        uint divideProfit = 0;\r\n        if (userInfo.level == 3) {\r\n            User storage lv2User = addressMapping[inviteCodeMapping[userInfo.referrer].userAddress];\r\n            if (lv2User.id != 0) {\r\n                uint lv2Profit = userProfit.mul(10).div(9).mul(2).div(100);\r\n                lv2User.allInviteBonus = lv2User.allInviteBonus.add(lv2Profit);\r\n                lv2User.balance = lv2User.balance.add(lv2Profit);\r\n                divideProfit \u002B= lv2Profit;\r\n                userBalance \u002B= lv2Profit;\r\n                emit LogInviteProfit(rid, userInfo.userAddress, userInfo.level, lv2User.userAddress, lv2Profit, now);\r\n                User storage lv1User = addressMapping[inviteCodeMapping[lv2User.referrer].userAddress];\r\n                if (lv1User.id != 0) {\r\n                    uint lv1Profit = userProfit.mul(10).div(9).mul(1).div(100);\r\n                    lv1User.allInviteBonus = lv1User.allInviteBonus.add(lv1Profit);\r\n                    lv1User.balance = lv1User.balance.add(lv1Profit);\r\n                    divideProfit \u002B= lv1Profit;\r\n                    userBalance \u002B= lv1Profit;\r\n                    emit LogInviteProfit(rid, userInfo.userAddress, userInfo.level, lv1User.userAddress, lv1Profit, now);\r\n                }\r\n            }\r\n        } else if (userInfo.level == 2) {\r\n            lv1User = addressMapping[inviteCodeMapping[userInfo.referrer].userAddress];\r\n            if (lv1User.id != 0) {\r\n                lv1Profit = userProfit.mul(10).div(9).mul(3).div(100);\r\n                lv1User.allInviteBonus = lv1User.allInviteBonus.add(lv1Profit);\r\n                lv1User.balance = lv1User.balance.add(lv1Profit);\r\n                divideProfit \u002B= lv1Profit;\r\n                userBalance \u002B= lv1Profit;\r\n                emit LogInviteProfit(rid, userInfo.userAddress, userInfo.level, lv1User.userAddress, lv1Profit, now);\r\n            }\r\n        }\r\n        return divideProfit;\r\n    }\r\n\r\n    function withdraw(uint amount)\r\n    public\r\n    isHuman() {\r\n        User storage user = addressMapping[msg.sender];\r\n        require(amount \u003E 0 \u0026\u0026 user.balance \u003E= amount, \u0022withdraw amount error\u0022);\r\n        sendMoneyToUser(msg.sender, amount);\r\n        user.balance -= amount;\r\n        userBalance -= amount;\r\n        emit LogWithdrawProfit(msg.sender, amount, now);\r\n    }\r\n\r\n    function devWithdraw(uint amount) external onlyWhitelistAdmin {\r\n        require(devBalance \u003E= amount, \u0022invalid withdraw amount\u0022);\r\n        sendMoneyToUser(devAddr, amount);\r\n        devBalance -= amount;\r\n        emit LogWithdrawProfit(devAddr, amount, now);\r\n    }\r\n\r\n    function sendMoneyToUser(address userAddress, uint money) private {\r\n        userAddress.transfer(money);\r\n    }\r\n\r\n    function registerUserInfo(address user, string inviteCode, string referrer) external onlyOwner {\r\n        registerUser(user, inviteCode, referrer, 1);\r\n    }\r\n\r\n    function isUsed(string memory code) public view returns (bool) {\r\n        UserGlobal storage user = inviteCodeMapping[code];\r\n        return user.id != 0;\r\n    }\r\n\r\n    function getGameInfo() public isHuman() view returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint) {\r\n        InvestPool storage investPool = rInvests[rid];\r\n        return (\r\n        rid,\r\n        investPool.investCount,\r\n        investPool.riseInvests,\r\n        investPool.fallInvests,\r\n        investPool.beginBtcPrice,\r\n        userBalance,\r\n        devBalance,\r\n        address(this).balance,\r\n        startTime,\r\n        endTime,\r\n        investMin,\r\n        investMax\r\n        );\r\n    }\r\n\r\n    function getGameInfoByRid(uint r) public isHuman() view returns (uint, uint, uint, uint, uint, uint, bool) {\r\n        InvestPool storage investPool = rInvests[r];\r\n        return (\r\n        rid,\r\n        investPool.investCount,\r\n        investPool.riseInvests,\r\n        investPool.fallInvests,\r\n        investPool.beginBtcPrice,\r\n        investPool.endBtcPrice,\r\n        investPool.isRise\r\n        );\r\n    }\r\n\r\n    function getUserInfo(address userAddr) public isHuman() view returns (uint [8] memory ct, string memory inviteCode, string memory referrer) {\r\n        User memory userInfo = addressMapping[userAddr];\r\n        UserGlobal memory userGlobal = inviteCodeMapping[userInfo.inviteCode];\r\n        ct[0] = userGlobal.level;\r\n        ct[1] = userGlobal.lv2Friends;\r\n        ct[2] = userGlobal.lv3Friends;\r\n        ct[3] = 0;\r\n        ct[4] = 0;\r\n        ct[5] = userInfo.balance;\r\n        ct[6] = userInfo.allGuessBonus;\r\n        ct[7] = userInfo.allInviteBonus;\r\n\r\n        InvestPool storage ip = rInvests[rid];\r\n        Invest[] storage invests = ip.userInvests[userInfo.userAddress];\r\n        for (uint i = 0; i \u003C invests.length; i\u002B\u002B) {\r\n            Invest storage invest = invests[i];\r\n            if (invest.intent == 1) {\r\n                ct[3] \u002B= invest.investAmount;\r\n            } else {\r\n                ct[4] \u002B= invest.investAmount;\r\n            }\r\n        }\r\n        inviteCode = userInfo.inviteCode;\r\n        referrer = userInfo.referrer;\r\n        return (\r\n        ct,\r\n        inviteCode,\r\n        referrer\r\n        );\r\n    }\r\n\r\n    function registerUser(address user, string memory inviteCode, string memory referrer, uint userLevel) private {\r\n        UserGlobal storage userGlobal = inviteCodeMapping[inviteCode];\r\n        uid\u002B\u002B;\r\n        userGlobal.id = uid;\r\n        userGlobal.userAddress = user;\r\n        userGlobal.inviteCode = inviteCode;\r\n        userGlobal.referrer = referrer;\r\n        userGlobal.level = userLevel;\r\n\r\n        indexMapping[uid] = user;\r\n        User storage userInfo = addressMapping[user];\r\n        userInfo.id = uid;\r\n        userInfo.userAddress = user;\r\n        userInfo.inviteCode = inviteCode;\r\n        userInfo.referrer = referrer;\r\n        userInfo.level = userLevel;\r\n    }\r\n\r\n    function setInvestMin(uint m) external onlyWhitelistAdmin {\r\n        require(m \u003E 0, \u0022param error\u0022);\r\n        investMin = m;\r\n        emit LogSystemParamChange(3, now);\r\n    }\r\n\r\n    function setInvestMax(uint m) external onlyWhitelistAdmin {\r\n        require(m \u003E 0, \u0022param error\u0022);\r\n        investMax = m;\r\n        emit LogSystemParamChange(4, now);\r\n    }\r\n\r\n    function getHour() internal view returns (uint) {\r\n        return now % 86400 / 3600 \u002B 8;\r\n    }\r\n\r\n    function getSecond() internal view returns (uint) {\r\n        return now % 3600 / 60;\r\n    }\r\n\r\n    function validInvestTime() internal view returns (bool) {\r\n        uint hour = getHour();\r\n        if (hour \u003E= startTime \u0026\u0026 hour \u003C endTime) {\r\n            return true;\r\n        }\r\n        return false;\r\n    }\r\n\r\n    function validInvestAmount(uint amount) internal view returns (bool) {\r\n        return amount \u003E= investMin \u0026\u0026 amount \u003C= investMax;\r\n    }\r\n\r\n    function compareStr(string memory _str, string memory str) public pure returns (bool) {\r\n        if (keccak256(abi.encodePacked(_str)) == keccak256(abi.encodePacked(str))) {\r\n            return true;\r\n        }\r\n        return false;\r\n    }\r\n}\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that revert on error\r\n */\r\nlibrary SafeMath {\r\n\r\n    /**\r\n    * @dev Multiplies two numbers, reverts on overflow.\r\n    */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022mul overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.\r\n    */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003E 0, \u0022div zero\u0022);\r\n        // Solidity only automatically asserts when dividing by 0\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n    */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a, \u0022lower sub bigger\u0022);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Adds two numbers, reverts on overflow.\r\n    */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022overflow\u0022);\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),\r\n    * reverts when dividing by zero.\r\n    */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0, \u0022mod zero\u0022);\r\n        return a % b;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getGameInfo\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022inviteCode\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022referrer\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022intent\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022investIn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022intent\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022reInvestIn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022m\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setInvestMin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022m\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setInvestMax\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceWhitelistAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022code\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022isUsed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022userAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getUserInfo\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022ct\u0022,\u0022type\u0022:\u0022uint256[8]\u0022},{\u0022name\u0022:\u0022inviteCode\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022referrer\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeWhitelistAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addWhitelistAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_str\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022str\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022compareStr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022inviteCode\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022referrer\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022registerUserInfo\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022indexMapping\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isWhitelistAdmin\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022devWithdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022r\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getGameInfoByRid\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022closePrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022openPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022currentDate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022roundEnd\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022r\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022intent\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogInvestIn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022r\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022intent\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogWinnerProfit\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022r\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022fromLv\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022profit\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogInviteProfit\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022who\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogWithdrawProfit\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022r\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogRoundEnd\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022paramType\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogSystemParamChange\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WhitelistAdminAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WhitelistAdminRemoved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"TTBTC","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://ac319e27858a49ba86e4285037e5c9c106e95c3ce17b9002c7dc019365278b7b"}]