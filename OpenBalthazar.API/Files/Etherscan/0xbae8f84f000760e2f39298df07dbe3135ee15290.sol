[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\n/*\r\n *\tutils.sol\r\n */\r\n \r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\r\n * the optional functions; to access them see {ERC20Detailed}.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from the caller\u0027s account to \u0060recipient\u0060.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\r\n     * allowed to spend on behalf of \u0060owner\u0060 through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\r\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\r\n     * another (\u0060to\u0060).\r\n     *\r\n     * Note that \u0060value\u0060 may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\r\n     * a call to {approve}. \u0060value\u0060 is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n \r\ncontract Owned {\r\n    constructor() public { owner = msg.sender; }\r\n    address payable owner;\r\n\r\n    // This contract only defines a modifier but does not use\r\n    // it: it will be used in derived contracts.\r\n    // The function body is inserted where the special symbol\r\n    // \u0060_;\u0060 in the definition of a modifier appears.\r\n    // This means that if the owner calls this function, the\r\n    // function is executed and otherwise, an exception is\r\n    // thrown.\r\n    modifier onlyOwner {\r\n        require(\r\n            msg.sender == owner,\r\n            \u0022Only owner can call this function.\u0022\r\n        );\r\n        _;\r\n    }\r\n}\r\n\r\n/*\r\n *\tHEX.sol\r\n */\r\n \r\ninterface HEX{\r\n\t\r\n\t// These are the needed calls from the original HEX contract\r\n\t\r\n    struct XfLobbyEntryStore {\r\n        uint96 rawAmount;\r\n        address referrerAddr;\r\n    }\r\n\t\r\n    struct XfLobbyQueueStore {\r\n        uint40 headIndex;\r\n        uint40 tailIndex;\r\n        mapping(uint256 =\u003E XfLobbyEntryStore) entries;\r\n    }\r\n\t\r\n\tfunction xfLobbyMembers(uint256 i, address _XfLobbyQueueStore) external view returns(uint40 headIndex, uint40 tailIndex);\r\n\tfunction xfLobbyEnter(address referrerAddr) external payable;\r\n\tfunction currentDay() external view returns (uint256);\r\n\tfunction xfLobbyExit(uint256 enterDay, uint256 count) external;\r\n\t\r\n\t\r\n\t// Following code is standard IERC20 interface:\r\n\t// Since I don\u0027t think you can inherit interfaces internaly yet\r\n\t\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from the caller\u0027s account to \u0060recipient\u0060.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\r\n     * allowed to spend on behalf of \u0060owner\u0060 through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\r\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\r\n     * another (\u0060to\u0060).\r\n     *\r\n     * Note that \u0060value\u0060 may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\r\n     * a call to {approve}. \u0060value\u0060 is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n/*\r\n *\tERC20Distributor.sol\r\n */\r\n \r\ninterface ERC20Distributor{\r\n    function distributeTokens() external;\r\n}\r\n\r\n/*\r\n *\tHEXAutomator.sol\r\n */\r\n\r\ncontract HEXAutomator is Owned{\r\n\tHEX public HEXcontract = HEX(0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39);\r\n\tERC20Distributor public Distributor;\r\n\t\r\n\tuint256[] public openLobbyDays;\r\n\t\r\n\tbool public autoDistribution = true;\r\n\tuint256 public distributionWeekday = 5; \r\n\tuint256 public distributionCycle = 1;\r\n\tuint256 public distributionCycleCounter = 0;\r\n\t\t\r\n\tconstructor(ERC20Distributor _distAddr) public {\r\n        Distributor = ERC20Distributor(_distAddr);\r\n    }\r\n\t\r\n\tfunction () payable external{\r\n\t\trequire(msg.value \u003E 0);\r\n\t\t\r\n\t\t// Enter current open HEX Lobby with contracts address as referral\r\n\t\tHEXcontract.xfLobbyEnter.value(msg.value)(address(this));\r\n\t\topenLobbyDays.push(hexCurrentDay());\r\n\t\t\r\n\t\t// Exits all past still open lobby entries\r\n\t\tselfLobbyExitAll();\r\n\t\t\r\n\t\t// Sends the received HEX to the Distributor\r\n\t\twithdrawHEXToDistributor();\r\n\t\t\r\n\t\t// check if distribution conditions are set \u0026 do it if so\r\n\t\tcheckAutoDistribution();\r\n\t}\r\n\t\r\n\t// returns current day of hex contract\r\n\tfunction hexCurrentDay() public view \r\n\t\treturns(uint256 currentDay){\r\n\t\treturn HEXcontract.currentDay();\r\n\t}\r\n\t\r\n\t// Exits all still open lobby entries of this contract\r\n\tfunction selfLobbyExitAll() public {\r\n\t\tfor(uint i = 0; i \u003C openLobbyDays.length; i\u002B\u002B)\r\n\t\t{\r\n\t\t\tif(openLobbyDays[i] \u003C hexCurrentDay()){\r\n\t\t\t\tif(selfLobbyExit(openLobbyDays[i], 0)){\r\n\t\t\t\t\tif(i \u003C openLobbyDays.length - 1){\r\n\t\t\t\t\t\topenLobbyDays[i] = openLobbyDays[openLobbyDays.length - 1];\r\n\t\t\t\t\t}\r\n\t\t\t\t\tdelete openLobbyDays[openLobbyDays.length - 1];\r\n\t\t\t\t\topenLobbyDays.length--;\r\n\t\t\t\t}\r\n\t\t\t}\r\n\t\t}\r\n\t}\r\n\t\r\n\t// Exits the smart contracts address of given enterDays HEX Lobby\r\n\t// _count can be 0 for default all, it\u0027s forwarded to HEX xfLobbyExit contract\r\n\tfunction selfLobbyExit(uint256 _enterDay, uint256 _count) public returns(bool){\r\n\t\trequire(_enterDay \u003C hexCurrentDay());\r\n\t\t\r\n\t\t(uint40 HEX_headIndex, uint40 HEX_tailIndex) = \r\n\t\t\tHEXcontract.xfLobbyMembers(_enterDay, address(this));\r\n\t\t\t\r\n\t\tif(HEX_tailIndex \u003E 0 \u0026\u0026 HEX_headIndex \u003C HEX_tailIndex){\r\n\t\t\tHEXcontract.xfLobbyExit(_enterDay, _count);\r\n\t\t\tdistributionCycleCounter\u002B\u002B;\r\n\t\t\treturn true;\r\n\t\t} else {\r\n\t\t\treturn false;\r\n\t\t}\r\n\t}\r\n\t\r\n\t// transfers all on this contracts sitting HEX to the Distributor\r\n\tfunction withdrawHEXToDistributor() public {\r\n\t\tuint256 HEX_balance = HEXcontract.balanceOf(address(this));\r\n\t\tif(HEX_balance \u003E 0){\r\n\t\t\tHEXcontract.transfer(address(Distributor), HEX_balance);\r\n\t\t}\r\n\t}\r\n\t\r\n\t// if autoDistribution is true, check conditions (weekday \u0026 cycles)\r\n\t// for autoDistribution and perform if valid\r\n\tfunction checkAutoDistribution() private {\r\n\t\tif(autoDistribution){\r\n\t\t\tif((distributionWeekday != 0 \u0026\u0026 (hexCurrentDay() \u002B 7 - distributionWeekday) % 7 == 0) || \r\n\t\t\t\t(distributionCycle != 0 \u0026\u0026 distributionCycleCounter \u003E= distributionCycle)){\r\n\t\t\t\tif(HEXcontract.balanceOf(address(Distributor)) \u003E 0){\r\n\t\t\t\t\tdistributionCycleCounter = 0;\r\n\t\t\t\t\tDistributor.distributeTokens();\r\n\t\t\t\t}\r\n\t\t\t}\r\n\t\t}\r\n\t}\r\n\t\r\n\t// owner can change Distributor\r\n\tfunction changeDistributor(ERC20Distributor _distAddr) public onlyOwner{\r\n        Distributor = ERC20Distributor(_distAddr);\r\n\t}\r\n\t\r\n\t// owner can switch auto distribution on/off\r\n\tfunction switchAutoDistribution() public onlyOwner{\r\n\t\tif(autoDistribution){\r\n\t\t\tautoDistribution = false;\r\n\t\t} else {\r\n\t\t\tautoDistribution = true;\r\n\t\t}\r\n\t}\r\n\t\r\n\t// @param _weekday: 0 = sunday, 1 = monday, ... , 6 = saturday | -1 to disable\r\n\t// Note: autoDistribution need to be true for auto distribution to work\r\n\tfunction changeDistributionWeekday(int256 _weekday) public onlyOwner{\r\n\t\trequire(_weekday \u003E= -1, \u0022_weekday must be between -1 to 6\u0022);\r\n\t\trequire(_weekday \u003C= 6, \u0022_weekday must be between -1 to 6\u0022);\r\n\t\tif(_weekday \u003E= 0){\r\n\t\t\tdistributionWeekday = 5 \u002B uint256(_weekday);\r\n\t\t\t// 5 \u002B ... syncs 0-6 notation to sunday - saturday,\r\n\t\t\t// due to hex contract starting with 0 on a tuesday\r\n\t\t} else {\r\n\t\t\tdistributionWeekday = 0;\r\n\t\t}\r\n\t}\r\n\t\r\n\t// @param _cycle: number of lobbys, the contract shall participated \u0026 exited in\r\n\t// \t\t\t\t  before it auto distributes accumulated HEX | 0 to disable\r\n\tfunction changeDistributionCycle(uint256 _cycle) public onlyOwner{\r\n\t\trequire(_cycle \u003C 350, \u0022Can\u0027t go higher than 350 cycles/days\u0022);\r\n\t\tdistributionCycle = _cycle;\r\n\t}\r\n\t\t\r\n\t// allows the creator to withdraw any ERC20 Token,\r\n\t// which might land here\r\n\tfunction withdrawERC20(IERC20 _token) public onlyOwner {\r\n\t\trequire(_token.balanceOf(address(this)) \u003E 0, \u0022no balance\u0022);\r\n\t\trequire(address(_token) != address(HEXcontract), \u0022can\u0027t withdraw HEX, must use distributor\u0022);\r\n\t\t_token.transfer(owner, _token.balanceOf(address(this)));\r\n\t}\r\n\r\n\t// destroys contract \r\n\t// !! Attention !!\r\n\t// Be sure the contract hasn\u0027t any more open lobbys nor any funds on it\r\n\tfunction kill(bool _die) public onlyOwner {\r\n\t\trequire(_die, \u0022If you are sure, send me true for _die\u0022);\r\n\t\tselfdestruct(owner);\r\n\t}\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract ERC20Distributor\u0022,\u0022name\u0022:\u0022_distAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Distributor\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract ERC20Distributor\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022HEXcontract\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract HEX\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022autoDistribution\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_cycle\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022changeDistributionCycle\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022int256\u0022,\u0022name\u0022:\u0022_weekday\u0022,\u0022type\u0022:\u0022int256\u0022}],\u0022name\u0022:\u0022changeDistributionWeekday\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract ERC20Distributor\u0022,\u0022name\u0022:\u0022_distAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeDistributor\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022distributionCycle\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022distributionCycleCounter\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022distributionWeekday\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022hexCurrentDay\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022currentDay\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_die\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022kill\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022openLobbyDays\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_enterDay\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_count\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022selfLobbyExit\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022selfLobbyExitAll\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022switchAutoDistribution\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022withdrawERC20\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdrawHEXToDistributor\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"HEXAutomator","CompilerVersion":"v0.5.13\u002Bcommit.5b0b510c","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000706c1b83cce2292f5dce762e33d05c4d708c5bd0","Library":"","SwarmSource":"bzzr://e9e05dfe27b69232a58fcd535193c5629b884d2b4755354348534c5c3b2ae613"}]