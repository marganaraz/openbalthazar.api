[{"SourceCode":"pragma solidity 0.5.8;\r\n\r\ninterface DateTimeAPI {\r\n    function getYear(uint timestamp) external pure returns (uint16);\r\n\r\n    function getMonth(uint timestamp) external pure returns (uint8);\r\n\r\n    function getDay(uint timestamp) external pure returns (uint8);\r\n\r\n    function getHour(uint timestamp) external pure returns (uint8);\r\n\r\n    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) external pure returns (uint);\r\n}\r\n\r\ncontract Ownable {\r\n    address public owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n     * account.\r\n     */\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner, \u0022Called by unknown account\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function transferOwnership(address newOwner) onlyOwner public {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(owner, newOwner);\r\n        owner = newOwner;\r\n    }\r\n}\r\n\r\ncontract DateTime {\r\n    /*\r\n     *  Date and Time utilities for ethereum contracts\r\n     *\r\n     */\r\n    struct _DateTime {\r\n        uint16 year;\r\n        uint8 month;\r\n        uint8 day;\r\n        uint8 hour;\r\n        uint8 minute;\r\n        uint8 second;\r\n        uint8 weekday;\r\n    }\r\n\r\n    uint constant DAY_IN_SECONDS = 86400;\r\n    uint constant YEAR_IN_SECONDS = 31536000;\r\n    uint constant LEAP_YEAR_IN_SECONDS = 31622400;\r\n\r\n    uint constant HOUR_IN_SECONDS = 3600;\r\n    uint constant MINUTE_IN_SECONDS = 60;\r\n\r\n    uint16 constant ORIGIN_YEAR = 1970;\r\n\r\n    function isLeapYear(uint16 year) public pure returns (bool) {\r\n        if (year % 4 != 0) {\r\n            return false;\r\n        }\r\n        if (year % 100 != 0) {\r\n            return true;\r\n        }\r\n        if (year % 400 != 0) {\r\n            return false;\r\n        }\r\n        return true;\r\n    }\r\n\r\n    function leapYearsBefore(uint year) public pure returns (uint) {\r\n        year -= 1;\r\n        return year / 4 - year / 100 \u002B year / 400;\r\n    }\r\n\r\n    function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {\r\n        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {\r\n            return 31;\r\n        }\r\n        else if (month == 4 || month == 6 || month == 9 || month == 11) {\r\n            return 30;\r\n        }\r\n        else if (isLeapYear(year)) {\r\n            return 29;\r\n        }\r\n        else {\r\n            return 28;\r\n        }\r\n    }\r\n\r\n    function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory dt) {\r\n        uint secondsAccountedFor = 0;\r\n        uint buf;\r\n        uint8 i;\r\n\r\n        // Year\r\n        dt.year = getYear(timestamp);\r\n        buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);\r\n\r\n        secondsAccountedFor \u002B= LEAP_YEAR_IN_SECONDS * buf;\r\n        secondsAccountedFor \u002B= YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);\r\n\r\n        // Month\r\n        uint secondsInMonth;\r\n        for (i = 1; i \u003C= 12; i\u002B\u002B) {\r\n            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);\r\n            if (secondsInMonth \u002B secondsAccountedFor \u003E timestamp) {\r\n                dt.month = i;\r\n                break;\r\n            }\r\n            secondsAccountedFor \u002B= secondsInMonth;\r\n        }\r\n\r\n        // Day\r\n        for (i = 1; i \u003C= getDaysInMonth(dt.month, dt.year); i\u002B\u002B) {\r\n            if (DAY_IN_SECONDS \u002B secondsAccountedFor \u003E timestamp) {\r\n                dt.day = i;\r\n                break;\r\n            }\r\n            secondsAccountedFor \u002B= DAY_IN_SECONDS;\r\n        }\r\n\r\n        // Hour\r\n        dt.hour = getHour(timestamp);\r\n\r\n        // Minute\r\n        dt.minute = getMinute(timestamp);\r\n\r\n        // Second\r\n        dt.second = getSecond(timestamp);\r\n\r\n        // Day of week.\r\n        dt.weekday = getWeekday(timestamp);\r\n    }\r\n\r\n    function getYear(uint timestamp) public pure returns (uint16) {\r\n        uint secondsAccountedFor = 0;\r\n        uint16 year;\r\n        uint numLeapYears;\r\n\r\n        // Year\r\n        year = uint16(ORIGIN_YEAR \u002B timestamp / YEAR_IN_SECONDS);\r\n        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);\r\n\r\n        secondsAccountedFor \u002B= LEAP_YEAR_IN_SECONDS * numLeapYears;\r\n        secondsAccountedFor \u002B= YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);\r\n\r\n        while (secondsAccountedFor \u003E timestamp) {\r\n            if (isLeapYear(uint16(year - 1))) {\r\n                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;\r\n            }\r\n            else {\r\n                secondsAccountedFor -= YEAR_IN_SECONDS;\r\n            }\r\n            year -= 1;\r\n        }\r\n        return year;\r\n    }\r\n\r\n    function getMonth(uint timestamp) public pure returns (uint8) {\r\n        return parseTimestamp(timestamp).month;\r\n    }\r\n\r\n    function getDay(uint timestamp) public pure returns (uint8) {\r\n        return parseTimestamp(timestamp).day;\r\n    }\r\n\r\n    function getHour(uint timestamp) public pure returns (uint8) {\r\n        return uint8((timestamp / 60 / 60) % 24);\r\n    }\r\n\r\n    function getMinute(uint timestamp) public pure returns (uint8) {\r\n        return uint8((timestamp / 60) % 60);\r\n    }\r\n\r\n    function getSecond(uint timestamp) public pure returns (uint8) {\r\n        return uint8(timestamp % 60);\r\n    }\r\n\r\n    function getWeekday(uint timestamp) public pure returns (uint8) {\r\n        return uint8((timestamp / DAY_IN_SECONDS \u002B 4) % 7);\r\n    }\r\n\r\n    function toTimestamp(uint16 year, uint8 month, uint8 day) public pure returns (uint timestamp) {\r\n        return toTimestamp(year, month, day, 0, 0, 0);\r\n    }\r\n\r\n    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) public pure returns (uint timestamp) {\r\n        return toTimestamp(year, month, day, hour, 0, 0);\r\n    }\r\n\r\n    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public pure returns (uint timestamp) {\r\n        return toTimestamp(year, month, day, hour, minute, 0);\r\n    }\r\n\r\n    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public pure returns (uint timestamp) {\r\n        uint16 i;\r\n\r\n        // Year\r\n        for (i = ORIGIN_YEAR; i \u003C year; i\u002B\u002B) {\r\n            if (isLeapYear(i)) {\r\n                timestamp \u002B= LEAP_YEAR_IN_SECONDS;\r\n            }\r\n            else {\r\n                timestamp \u002B= YEAR_IN_SECONDS;\r\n            }\r\n        }\r\n\r\n        // Month\r\n        uint8[12] memory monthDayCounts;\r\n        monthDayCounts[0] = 31;\r\n        if (isLeapYear(year)) {\r\n            monthDayCounts[1] = 29;\r\n        }\r\n        else {\r\n            monthDayCounts[1] = 28;\r\n        }\r\n        monthDayCounts[2] = 31;\r\n        monthDayCounts[3] = 30;\r\n        monthDayCounts[4] = 31;\r\n        monthDayCounts[5] = 30;\r\n        monthDayCounts[6] = 31;\r\n        monthDayCounts[7] = 31;\r\n        monthDayCounts[8] = 30;\r\n        monthDayCounts[9] = 31;\r\n        monthDayCounts[10] = 30;\r\n        monthDayCounts[11] = 31;\r\n\r\n        for (i = 1; i \u003C month; i\u002B\u002B) {\r\n            timestamp \u002B= DAY_IN_SECONDS * monthDayCounts[i - 1];\r\n        }\r\n\r\n        // Day\r\n        timestamp \u002B= DAY_IN_SECONDS * (day - 1);\r\n\r\n        // Hour\r\n        timestamp \u002B= HOUR_IN_SECONDS * (hour);\r\n\r\n        // Minute\r\n        timestamp \u002B= MINUTE_IN_SECONDS * (minute);\r\n\r\n        // Second\r\n        timestamp \u002B= second;\r\n\r\n        return timestamp;\r\n    }\r\n}\r\n\r\ncontract EJackpot is Ownable {\r\n    event CaseOpened(\r\n        uint amount,\r\n        uint prize,\r\n        address indexed user,\r\n        uint indexed timestamp\r\n    );\r\n\r\n    struct ReferralStat {\r\n        uint profit;\r\n        uint count;\r\n    }\r\n\r\n    struct Probability {\r\n        uint from;\r\n        uint to;\r\n    }\r\n\r\n    uint public usersCount = 0;\r\n    uint public openedCases = 0;\r\n    uint public totalWins = 0;\r\n    Probability[1/*11*/] public probabilities;\r\n    mapping(uint =\u003E uint[11]) public betsPrizes;\r\n    mapping(uint =\u003E bool) public cases;\r\n    uint[1/*9*/] public casesArr = [\r\n    5 * 10 ** 16/*,\r\n    10 ** 17,\r\n    2 * 10 ** 17,\r\n    3 * 10 ** 17,\r\n    5 * 10 ** 17,\r\n    7 * 10 ** 17,\r\n    10 ** 18,\r\n    15 * 10 ** 17,\r\n    2 * 10 ** 18*/\r\n    ];\r\n    mapping(uint =\u003E uint) public caseWins;\r\n    mapping(uint =\u003E uint) public caseOpenings;\r\n    mapping(address =\u003E bool) private users;\r\n    mapping(address =\u003E uint) private userCasesCount;\r\n    mapping(address =\u003E address payable) private referrals;\r\n    mapping(address =\u003E mapping(address =\u003E bool)) private usedReferrals;\r\n    mapping(address =\u003E ReferralStat) public referralStats;\r\n    uint private constant multiplier = 1 ether / 10000;\r\n    DateTimeAPI private dateTimeAPI;\r\n\r\n    /**\r\n    * @dev The EJackpot constructor sets the default cases that are available for opening.\r\n    * @param _dateTimeAPI address of deployed DateTime contract\r\n    */\r\n    constructor(address _dateTimeAPI) public Ownable() {\r\n        dateTimeAPI = DateTimeAPI(_dateTimeAPI);\r\n        for (uint i = 0; i \u003C 1/*9*/; i\u002B\u002B) cases[casesArr[i]] = true;\r\n        probabilities[0] = Probability(1, 100/*6*/);\r\n//        probabilities[1] = Probability(7, 18);\r\n//        probabilities[2] = Probability(19, 30);\r\n//        probabilities[3] = Probability(31, 44);\r\n//        probabilities[4] = Probability(45, 58);\r\n//        probabilities[5] = Probability(59, 72);\r\n//        probabilities[6] = Probability(73, 83);\r\n//        probabilities[7] = Probability(84, 92);\r\n//        probabilities[8] = Probability(93, 97);\r\n//        probabilities[9] = Probability(98, 99);\r\n//        probabilities[10] = Probability(100, 100);\r\n\r\n        betsPrizes[5 * 10 ** 16] = [65, 100, 130, 170, 230, 333, 500, 666, 1350, 2000, 2500];\r\n//        betsPrizes[10 ** 17] = [130, 200, 265, 333, 450, 666, 1000, 1350, 2650, 4000, 5000];\r\n//        betsPrizes[2 * 10 ** 17] = [265, 400, 530, 666, 930, 1330, 2000, 2665, 5300, 8000, 10000];\r\n//        betsPrizes[3 * 10 ** 17] = [400, 600, 800, 1000, 1400, 2000, 3000, 4000, 8000, 12000, 15000];\r\n//        betsPrizes[5 * 10 ** 17] = [666, 1000, 1330, 1665, 2330, 3333, 5000, 6666, 13330, 20000, 25000];\r\n//        betsPrizes[7 * 10 ** 17] = [950, 1400, 1850, 2330, 3265, 4665, 7000, 9330, 18665, 28000, 35000];\r\n//        betsPrizes[10 ** 18] = [1330, 2000, 2665, 3333, 4666, 6666, 10000, 13330, 26660, 40000, 50000];\r\n//        betsPrizes[15 * 10 ** 17] = [2000, 3000, 4000, 5000, 7000, 10000, 15000, 20000, 40000, 60000, 75000];\r\n//        betsPrizes[2 * 10 ** 18] = [2665, 4000, 5330, 6666, 9350, 13330, 20000, 26665, 53330, 80000, 100000];\r\n    }\r\n\r\n    /**\r\n     * @dev Shows the average winning rate in% with a normal distribution. For example, 10,000 = 100% or 7621 == 76.21%\r\n     */\r\n    function showCoefs() external view returns (uint[1/*9*/] memory result){\r\n        uint d = 10000;\r\n\r\n        for (uint casesIndex = 0; casesIndex \u003C casesArr.length; casesIndex\u002B\u002B) {\r\n            uint sum = 0;\r\n            uint casesVal = casesArr[casesIndex];\r\n\r\n            for (uint i = 0; i \u003C probabilities.length; i\u002B\u002B) {\r\n                sum \u002B= multiplier * betsPrizes[casesVal][i] * (probabilities[i].to - probabilities[i].from \u002B 1);\r\n            }\r\n\r\n            result[casesIndex] = ((d * sum) / (casesVal * 100));\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the user to open case and win one of the available prizes.\r\n     */\r\n    function play(address payable referrer) external payable notContract(msg.sender, false) notContract(referrer, true) {\r\n        if (msg.sender == owner) return;\r\n        uint maxPrize = betsPrizes[msg.value][betsPrizes[msg.value].length - 1] * multiplier;\r\n        require(cases[msg.value] \u0026\u0026 address(this).balance \u003E= maxPrize, \u0022Contract balance is not enough\u0022);\r\n        openedCases\u002B\u002B;\r\n        userCasesCount[msg.sender]\u002B\u002B;\r\n        if (!users[msg.sender]) {\r\n            users[msg.sender] = true;\r\n            usersCount\u002B\u002B;\r\n        }\r\n        uint prize = determinePrize();\r\n        caseWins[msg.value] \u002B= prize;\r\n        caseOpenings[msg.value]\u002B\u002B;\r\n        totalWins \u002B= prize;\r\n        increaseDailyStat(prize);\r\n        msg.sender.transfer(prize);\r\n\r\n        if (referrer == address(0x0) \u0026\u0026 referrals[msg.sender] == address(0x0)) return;\r\n\r\n        int casinoProfit = int(msg.value) - int(prize);\r\n        if (referrer != address(0x0)) {\r\n            if (referrals[msg.sender] != address(0x0) \u0026\u0026 referrer != referrals[msg.sender]) referralStats[referrals[msg.sender]].count -= 1;\r\n            referrals[msg.sender] = referrer;\r\n        }\r\n        if (!usedReferrals[referrals[msg.sender]][msg.sender]) {\r\n            referralStats[referrals[msg.sender]].count\u002B\u002B;\r\n            usedReferrals[referrals[msg.sender]][msg.sender] = true;\r\n        }\r\n        if (casinoProfit \u003C= 0) return;\r\n        uint referrerProfit = uint(casinoProfit * 10 / 100);\r\n        referralStats[referrals[msg.sender]].profit \u002B= referrerProfit;\r\n        referrals[msg.sender].transfer(referrerProfit);\r\n    }\r\n\r\n    /**\r\n     * @dev Determines which prize will be given to user by lottery.\r\n     * @return uint Amount of wei won by the user.\r\n     */\r\n    function determinePrize() private returns (uint) {\r\n        uint8 chance = random();\r\n        uint[11] memory prizes = betsPrizes[msg.value];\r\n        uint prize = 0;\r\n        for (uint i = 0; i \u003C 1/*11*/; i\u002B\u002B) {\r\n            if (chance \u003E= probabilities[i].from \u0026\u0026 chance \u003C= probabilities[i].to) {\r\n                prize = prizes[i] * multiplier;\r\n                break;\r\n            }\r\n        }\r\n\r\n        return prize;\r\n    }\r\n\r\n    /**\r\n     * @dev Updates statistics for current date.\r\n     * @param prize Prize that was won by user.\r\n     */\r\n    function increaseDailyStat(uint prize) private {\r\n        uint16 year = dateTimeAPI.getYear(now);\r\n        uint8 month = dateTimeAPI.getMonth(now);\r\n        uint8 day = dateTimeAPI.getDay(now);\r\n        uint8 hour = dateTimeAPI.getHour(now);\r\n        uint timestamp = dateTimeAPI.toTimestamp(year, month, day, hour);\r\n\r\n        emit CaseOpened(msg.value, prize, msg.sender, timestamp);\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to withdraw certain amount of ether from the contract.\r\n     * @param amount Amount of wei that needs to be withdrawn.\r\n     */\r\n    function withdraw(uint amount) external onlyOwner {\r\n        require(address(this).balance \u003E= amount);\r\n        msg.sender.transfer(amount);\r\n    }\r\n\r\n    function random() private view returns (uint8) {\r\n        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, userCasesCount[msg.sender]))) % 100) \u002B 1;\r\n    }\r\n\r\n    modifier notContract(address addr, bool referrer) {\r\n        if (addr != address(0x0)) {\r\n            uint size;\r\n            assembly {size := extcodesize(addr)}\r\n            require(size \u003C= 0, \u0022Called by contract\u0022);\r\n            if (!referrer) require(tx.origin == addr, \u0022Called by contract\u0022);\r\n        }\r\n        _;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022showCoefs\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022result\u0022,\u0022type\u0022:\u0022uint256[1]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022referralStats\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022profit\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022count\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022caseWins\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022openedCases\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022usersCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalWins\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022betsPrizes\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022casesArr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022caseOpenings\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022referrer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022play\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022cases\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022probabilities\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_dateTimeAPI\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022prize\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022user\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022timestamp\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022CaseOpened\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"EJackpot","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000001fb8a16257d83931ebfd488881f00b89093427aa","Library":"","SwarmSource":"bzzr://91991d16ada6f505590459b34a57ff15693388a98790b88f33613134cab2e793"}]