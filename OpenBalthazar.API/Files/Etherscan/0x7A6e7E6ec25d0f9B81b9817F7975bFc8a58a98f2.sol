[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\ncontract Ownable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n     * account.\r\n     */\r\n    constructor () internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @return the address of the owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner());\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @return true if \u0060msg.sender\u0060 is the owner of the contract.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to relinquish control of the contract.\r\n     * @notice Renouncing to ownership will leave the contract without an owner.\r\n     * It will not be possible to call the functions with the \u0060onlyOwner\u0060\r\n     * modifier anymore.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\nlibrary SafeMath {\r\n    /**\r\n    * @dev Multiplies two numbers, reverts on overflow.\r\n    */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022Mul failed\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.\r\n    */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, \u0022Div failed\u0022);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n    */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a, \u0022Sub failed\u0022);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Adds two numbers, reverts on overflow.\r\n    */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022Add failed\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),\r\n    * reverts when dividing by zero.\r\n    */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0, \u0022Math failed\u0022);\r\n        return a % b;\r\n    }\r\n}\r\nlibrary SafeMath64 {\r\n    /**\r\n    * @dev Multiplies two numbers, reverts on overflow.\r\n    */\r\n    function mul(uint64 a, uint64 b) internal pure returns (uint64) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint64 c = a * b;\r\n        require(c / a == b, \u0022Mul failed\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.\r\n    */\r\n    function div(uint64 a, uint64 b) internal pure returns (uint64) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, \u0022Div failed\u0022);\r\n        uint64 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n    */\r\n    function sub(uint64 a, uint64 b) internal pure returns (uint64) {\r\n        require(b \u003C= a, \u0022Sub failed\u0022);\r\n        uint64 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Adds two numbers, reverts on overflow.\r\n    */\r\n    function add(uint64 a, uint64 b) internal pure returns (uint64) {\r\n        uint64 c = a \u002B b;\r\n        require(c \u003E= a, \u0022Add failed\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),\r\n    * reverts when dividing by zero.\r\n    */\r\n    function mod(uint64 a, uint64 b) internal pure returns (uint64) {\r\n        require(b != 0, \u0022mod failed\u0022);\r\n        return a % b;\r\n    }\r\n}\r\ninterface IERC20 {\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    function balanceOf(address who) external view returns (uint256);\r\n\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    function transfer(address to, uint256 value) external returns (bool);\r\n\r\n    function approve(address spender, uint256 value) external returns (bool);\r\n\r\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\nlibrary SafeERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    function safeTransfer(IERC20 token, address to, uint256 value) internal {\r\n        require(token.transfer(to, value), \u0022Transfer failed\u0022);\r\n    }\r\n\r\n    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {\r\n        require(token.transferFrom(from, to, value));\r\n    }\r\n\r\n    function safeApprove(IERC20 token, address spender, uint256 value) internal {\r\n        // safeApprove should only be called when setting an initial allowance,\r\n        // or when resetting it to zero. To increase and decrease it, use\r\n        // \u0027safeIncreaseAllowance\u0027 and \u0027safeDecreaseAllowance\u0027\r\n        require((value == 0) || (token.allowance(msg.sender, spender) == 0));\r\n        require(token.approve(spender, value));\r\n    }\r\n\r\n    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {\r\n        uint256 newAllowance = token.allowance(address(this), spender).add(value);\r\n        require(token.approve(spender, newAllowance));\r\n    }\r\n\r\n    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {\r\n        uint256 newAllowance = token.allowance(address(this), spender).sub(value);\r\n        require(token.approve(spender, newAllowance));\r\n    }\r\n}\r\ncontract TokenVesting is Ownable {\r\n    using SafeMath for uint256;\r\n    using SafeMath64 for uint64;\r\n    using SafeERC20 for IERC20;\r\n\r\n    uint64 constant internal SECONDS_PER_MONTH = 2628000;\r\n\r\n    event TokensReleased(uint256 amount);\r\n    event TokenVestingRevoked(uint256 amount);\r\n\r\n    // beneficiary of tokens after they are released\r\n    address private _beneficiary;\r\n    // token being vested\r\n    IERC20 private _token;\r\n\r\n    uint64 private _cliff;\r\n    uint64 private _start;\r\n    uint64 private _vestingDuration;\r\n\r\n    bool private _revocable;\r\n    bool private _revoked;\r\n\r\n    uint256 private _released;\r\n\r\n    uint64[] private _monthTimestamps;\r\n    uint256 private _tokensPerMonth;\r\n    // struct MonthlyVestAmounts {\r\n    //     uint timestamp;\r\n    //     uint amount;\r\n    // }\r\n\r\n    // MonthlyVestAmounts[] private _vestings;\r\n\r\n    /**\r\n     * @dev Creates a vesting contract that vests its balance of the ERC20 token declared to the\r\n     * beneficiary, gradually in a linear fashion until start \u002B duration. By then all\r\n     * of the balance will have vested.\r\n     * @param beneficiary address of the beneficiary to whom vested tokens are transferred\r\n     * @param token address of the token of the tokens being vested\r\n     * @param cliffDuration duration in seconds of the cliff in which tokens will begin to vest\r\n     * @param start the time (as Unix time) at which point vesting starts\r\n     * @param vestingDuration duration in seconds of the total period in which the tokens will vest\r\n     * @param revocable whether the vesting is revocable or not\r\n     */\r\n    constructor (address beneficiary, IERC20 token, uint64 start, uint64 cliffDuration, uint64 vestingDuration, bool revocable, uint256 totalTokens) public {\r\n        require(beneficiary != address(0));\r\n        require(token != address(0));\r\n        require(cliffDuration \u003C vestingDuration);\r\n        require(start \u003E 0);\r\n        require(vestingDuration \u003E 0);\r\n        require(start.add(vestingDuration) \u003E block.timestamp);\r\n        _beneficiary = beneficiary;\r\n        _token = token;\r\n        _revocable = revocable;\r\n        _vestingDuration = vestingDuration;\r\n        _cliff = start.add(cliffDuration);\r\n        _start = start;\r\n\r\n        uint64 totalReleasingTime = vestingDuration.sub(cliffDuration);\r\n        require(totalReleasingTime.mod(SECONDS_PER_MONTH) == 0);\r\n        uint64 releasingMonths = totalReleasingTime.div(SECONDS_PER_MONTH);\r\n        require(totalTokens.mod(releasingMonths) == 0);\r\n        _tokensPerMonth = totalTokens.div(releasingMonths);\r\n    \r\n        for (uint64 month = 0; month \u003C releasingMonths; month\u002B\u002B) {\r\n            uint64 monthTimestamp = uint64(start.add(cliffDuration).add(month.mul(SECONDS_PER_MONTH)).add(SECONDS_PER_MONTH));\r\n            _monthTimestamps.push(monthTimestamp);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @return the beneficiary of the tokens.\r\n     */\r\n    function beneficiary() public view returns (address) {\r\n        return _beneficiary;\r\n    }\r\n    /**\r\n     * @return the address of the token vested.\r\n     */\r\n    function token() public view returns (address) {\r\n        return _token;\r\n    }\r\n    /**\r\n     * @return the cliff time of the token vesting.\r\n     */\r\n    function cliff() public view returns (uint256) {\r\n        return _cliff;\r\n    }\r\n    /**\r\n     * @return the start time of the token vesting.\r\n     */\r\n    function start() public view returns (uint256) {\r\n        return _start;\r\n    }\r\n    /**\r\n     * @return the duration of the token vesting.\r\n     */\r\n    function vestingDuration() public view returns (uint256) {\r\n        return _vestingDuration;\r\n    }\r\n    /**\r\n     * @return the amount of months to vest.\r\n     */\r\n    function monthsToVest() public view returns (uint256) {\r\n        return _monthTimestamps.length;\r\n    }\r\n    /**\r\n     * @return the amount of tokens vested.\r\n     */\r\n    function amountVested() public view returns (uint256) {\r\n        uint256 vested = 0;\r\n\r\n        for (uint256 month = 0; month \u003C _monthTimestamps.length; month\u002B\u002B) {\r\n            uint256 monthlyVestTimestamp = _monthTimestamps[month];\r\n            if (monthlyVestTimestamp \u003E 0 \u0026\u0026 block.timestamp \u003E= monthlyVestTimestamp) {\r\n                vested = vested.add(_tokensPerMonth);\r\n            }\r\n        }\r\n\r\n        return vested;\r\n    }\r\n    /**\r\n     * @return true if the vesting is revocable.\r\n     */\r\n    function revocable() public view returns (bool) {\r\n        return _revocable;\r\n    }\r\n    /**\r\n     * @return the amount of the token released.\r\n     */\r\n    function released() public view returns (uint256) {\r\n        return _released;\r\n    }\r\n    /**\r\n     * @return true if the token is revoked.\r\n     */\r\n    function revoked() public view returns (bool) {\r\n        return _revoked;\r\n    }\r\n\r\n    /**\r\n     * @notice Transfers vested tokens to beneficiary.\r\n     */\r\n    function release() public {\r\n        require(block.timestamp \u003E _cliff, \u0022Cliff hasnt started yet.\u0022);\r\n        uint256 amountToSend = 0;\r\n\r\n        for (uint256 month = 0; month \u003C _monthTimestamps.length; month\u002B\u002B) {\r\n            uint256 monthlyVestTimestamp = _monthTimestamps[month];\r\n            if (monthlyVestTimestamp \u003E 0) {\r\n                if (block.timestamp \u003E= monthlyVestTimestamp) {\r\n                    _monthTimestamps[month] = 0;\r\n                    amountToSend = amountToSend.add(_tokensPerMonth);\r\n                } else {\r\n                    break;\r\n                }\r\n            }\r\n        }\r\n\r\n        require(amountToSend \u003E 0, \u0022No tokens to release\u0022);\r\n\r\n        _released \u002B= amountToSend;\r\n        _token.safeTransfer(_beneficiary, amountToSend);\r\n        emit TokensReleased(amountToSend);\r\n    }\r\n\r\n    /**\r\n     * @notice Allows the owner to revoke the vesting. Tokens already vested\r\n     * remain in the contract, the rest are returned to the owner.\r\n     */\r\n    function revoke() public onlyOwner {\r\n        require(_revocable, \u0022This vest cannot be revoked\u0022);\r\n        require(!_revoked, \u0022This vest has already been revoked\u0022);\r\n\r\n        _revoked = true;\r\n        uint256 amountToSend = 0;\r\n        for (uint256 month = 0; month \u003C _monthTimestamps.length; month\u002B\u002B) {\r\n            uint256 monthlyVestTimestamp = _monthTimestamps[month];\r\n            if (block.timestamp \u003C= monthlyVestTimestamp) {\r\n                _monthTimestamps[month] = 0;\r\n                amountToSend = amountToSend.add(_tokensPerMonth);\r\n            }\r\n        }\r\n\r\n        require(amountToSend \u003E 0, \u0022No tokens to revoke\u0022);\r\n\r\n        _token.safeTransfer(owner(), amountToSend);\r\n        emit TokenVestingRevoked(amountToSend);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022cliff\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022vestingDuration\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022beneficiary\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022revoked\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022release\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022revocable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022released\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022revoke\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022start\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022amountVested\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022token\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022monthsToVest\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022start\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022cliffDuration\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022vestingDuration\u0022,\u0022type\u0022:\u0022uint64\u0022},{\u0022name\u0022:\u0022revocable\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022totalTokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022TokensReleased\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022TokenVestingRevoked\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"TokenVesting","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000d9342482d740a2fdcef388fd23f60b09210c8c490000000000000000000000006b4e0684806fe53902469b6286024db9c6271f53000000000000000000000000000000000000000000000000000000005d4ef2ca0000000000000000000000000000000000000000000000000000000001b919e00000000000000000000000000000000000000000000000000000000001e13380000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000d3c21bcecceda1000000","Library":"","SwarmSource":"bzzr://19b9aab36a41487e489df51ea2d426db38c40e59e6a6890dc8a03742b4c452eb"}]