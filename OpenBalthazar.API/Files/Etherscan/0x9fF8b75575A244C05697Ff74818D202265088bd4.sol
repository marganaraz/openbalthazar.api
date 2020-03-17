[{"SourceCode":"// File: @openzeppelin/contracts/token/ERC20/IERC20.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\r\n * the optional functions; to access them see {ERC20Detailed}.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from the caller\u0027s account to \u0060recipient\u0060.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\r\n     * allowed to spend on behalf of \u0060owner\u0060 through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\r\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\r\n     * another (\u0060to\u0060).\r\n     *\r\n     * Note that \u0060value\u0060 may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\r\n     * a call to {approve}. \u0060value\u0060 is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// File: @openzeppelin/contracts/math/SafeMath.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * \u0060SafeMath\u0060 restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060\u002B\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060*\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n// File: @openzeppelin/contracts/utils/Address.sol\r\n\r\npragma solidity ^0.5.5;\r\n\r\n/**\r\n * @dev Collection of functions related to the address type\r\n */\r\nlibrary Address {\r\n    /**\r\n     * @dev Returns true if \u0060account\u0060 is a contract.\r\n     *\r\n     * This test is non-exhaustive, and there may be false-negatives: during the\r\n     * execution of a contract\u0027s constructor, its address will be reported as\r\n     * not containing a contract.\r\n     *\r\n     * IMPORTANT: It is unsafe to assume that an address for which this\r\n     * function returns false is an externally-owned account (EOA) and not a\r\n     * contract.\r\n     */\r\n    function isContract(address account) internal view returns (bool) {\r\n        // This method relies in extcodesize, which returns 0 for contracts in\r\n        // construction, since the code is only stored at the end of the\r\n        // constructor execution.\r\n\r\n        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts\r\n        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned\r\n        // for accounts without code, i.e. \u0060keccak256(\u0027\u0027)\u0060\r\n        bytes32 codehash;\r\n        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;\r\n        // solhint-disable-next-line no-inline-assembly\r\n        assembly { codehash := extcodehash(account) }\r\n        return (codehash != 0x0 \u0026\u0026 codehash != accountHash);\r\n    }\r\n\r\n    /**\r\n     * @dev Converts an \u0060address\u0060 into \u0060address payable\u0060. Note that this is\r\n     * simply a type cast: the actual underlying value is not changed.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function toPayable(address account) internal pure returns (address payable) {\r\n        return address(uint160(account));\r\n    }\r\n\r\n    /**\r\n     * @dev Replacement for Solidity\u0027s \u0060transfer\u0060: sends \u0060amount\u0060 wei to\r\n     * \u0060recipient\u0060, forwarding all available gas and reverting on errors.\r\n     *\r\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\r\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\r\n     * imposed by \u0060transfer\u0060, making them unable to receive funds via\r\n     * \u0060transfer\u0060. {sendValue} removes this limitation.\r\n     *\r\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\r\n     *\r\n     * IMPORTANT: because control is transferred to \u0060recipient\u0060, care must be\r\n     * taken to not create reentrancy vulnerabilities. Consider using\r\n     * {ReentrancyGuard} or the\r\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function sendValue(address payable recipient, uint256 amount) internal {\r\n        require(address(this).balance \u003E= amount, \u0022Address: insufficient balance\u0022);\r\n\r\n        // solhint-disable-next-line avoid-call-value\r\n        (bool success, ) = recipient.call.value(amount)(\u0022\u0022);\r\n        require(success, \u0022Address: unable to send value, recipient may have reverted\u0022);\r\n    }\r\n}\r\n\r\n// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\n\r\n\r\n/**\r\n * @title SafeERC20\r\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\r\n * contract returns false). Tokens that return no value (and instead revert or\r\n * throw on failure) are also supported, non-reverting calls are assumed to be\r\n * successful.\r\n * To use this library you can add a \u0060using SafeERC20 for ERC20;\u0060 statement to your contract,\r\n * which allows you to call the safe operations as \u0060token.safeTransfer(...)\u0060, etc.\r\n */\r\nlibrary SafeERC20 {\r\n    using SafeMath for uint256;\r\n    using Address for address;\r\n\r\n    function safeTransfer(IERC20 token, address to, uint256 value) internal {\r\n        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\r\n    }\r\n\r\n    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {\r\n        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\r\n    }\r\n\r\n    function safeApprove(IERC20 token, address spender, uint256 value) internal {\r\n        // safeApprove should only be called when setting an initial allowance,\r\n        // or when resetting it to zero. To increase and decrease it, use\r\n        // \u0027safeIncreaseAllowance\u0027 and \u0027safeDecreaseAllowance\u0027\r\n        // solhint-disable-next-line max-line-length\r\n        require((value == 0) || (token.allowance(address(this), spender) == 0),\r\n            \u0022SafeERC20: approve from non-zero to non-zero allowance\u0022\r\n        );\r\n        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\r\n    }\r\n\r\n    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {\r\n        uint256 newAllowance = token.allowance(address(this), spender).add(value);\r\n        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\r\n    }\r\n\r\n    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {\r\n        uint256 newAllowance = token.allowance(address(this), spender).sub(value, \u0022SafeERC20: decreased allowance below zero\u0022);\r\n        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\r\n    }\r\n\r\n    /**\r\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\r\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\r\n     * @param token The token targeted by the call.\r\n     * @param data The call data (encoded using abi.encode or one of its variants).\r\n     */\r\n    function callOptionalReturn(IERC20 token, bytes memory data) private {\r\n        // We need to perform a low level call here, to bypass Solidity\u0027s return data size checking mechanism, since\r\n        // we\u0027re implementing it ourselves.\r\n\r\n        // A Solidity high level call has three parts:\r\n        //  1. The target address is checked to verify it contains contract code\r\n        //  2. The call itself is made, and success asserted\r\n        //  3. The return value is decoded, which in turn checks the size of the returned data.\r\n        // solhint-disable-next-line max-line-length\r\n        require(address(token).isContract(), \u0022SafeERC20: call to non-contract\u0022);\r\n\r\n        // solhint-disable-next-line avoid-low-level-calls\r\n        (bool success, bytes memory returndata) = address(token).call(data);\r\n        require(success, \u0022SafeERC20: low-level call failed\u0022);\r\n\r\n        if (returndata.length \u003E 0) { // Return data is optional\r\n            // solhint-disable-next-line max-line-length\r\n            require(abi.decode(returndata, (bool)), \u0022SafeERC20: ERC20 operation did not succeed\u0022);\r\n        }\r\n    }\r\n}\r\n\r\n// File: @openzeppelin/contracts/GSN/Context.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/*\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with GSN meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\ncontract Context {\r\n    // Empty internal constructor, to prevent people from mistakenly deploying\r\n    // an instance of this contract, which should be used via inheritance.\r\n    constructor () internal { }\r\n    // solhint-disable-previous-line no-empty-blocks\r\n\r\n    function _msgSender() internal view returns (address payable) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}\r\n\r\n// File: @openzeppelin/contracts/ownership/Ownable.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * \u0060onlyOwner\u0060, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\ncontract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () internal {\r\n        _owner = _msgSender();\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the caller is the current owner.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return _msgSender() == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * \u0060onlyOwner\u0060 functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\n// File: contracts/interfaces/iERC20Fulcrum.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\ninterface iERC20Fulcrum {\r\n  function mint(\r\n    address receiver,\r\n    uint256 depositAmount)\r\n    external\r\n    returns (uint256 mintAmount);\r\n\r\n  function burn(\r\n    address receiver,\r\n    uint256 burnAmount)\r\n    external\r\n    returns (uint256 loanAmountPaid);\r\n\r\n  function tokenPrice()\r\n    external\r\n    view\r\n    returns (uint256 price);\r\n\r\n  function supplyInterestRate()\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function rateMultiplier()\r\n    external\r\n    view\r\n    returns (uint256);\r\n  function baseRate()\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function borrowInterestRate()\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function avgBorrowInterestRate()\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function protocolInterestRate()\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function spreadMultiplier()\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function totalAssetBorrow()\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function totalAssetSupply()\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function nextSupplyInterestRate(uint256)\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function nextBorrowInterestRate(uint256)\r\n    external\r\n    view\r\n    returns (uint256);\r\n  function nextLoanInterestRate(uint256)\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function claimLoanToken()\r\n    external\r\n    returns (uint256 claimedAmount);\r\n\r\n  function dsr()\r\n    external\r\n    view\r\n    returns (uint256);\r\n\r\n  function chaiPrice()\r\n    external\r\n    view\r\n    returns (uint256);\r\n}\r\n\r\n// File: contracts/interfaces/ILendingProtocol.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\ninterface ILendingProtocol {\r\n  function mint() external returns (uint256);\r\n  function redeem(address account) external returns (uint256);\r\n  function nextSupplyRate(uint256 amount) external view returns (uint256);\r\n  function nextSupplyRateWithParams(uint256[] calldata params) external view returns (uint256);\r\n  function getAPR() external view returns (uint256);\r\n  function getPriceInToken() external view returns (uint256);\r\n  function token() external view returns (address);\r\n  function underlying() external view returns (address);\r\n}\r\n\r\n// File: contracts/wrappers/IdleFulcrum.sol\r\n\r\n/**\r\n * @title: Fulcrum wrapper\r\n * @summary: Used for interacting with Fulcrum. Has\r\n *           a common interface with all other protocol wrappers.\r\n *           This contract holds assets only during a tx, after tx it should be empty\r\n * @author: William Bergamo, idle.finance\r\n */\r\npragma solidity 0.5.11;\r\n\r\n\r\n\r\n\r\n\r\n\r\ncontract IdleFulcrum is ILendingProtocol, Ownable {\r\n  using SafeERC20 for IERC20;\r\n  using SafeMath for uint256;\r\n\r\n  // protocol token (iToken) address\r\n  address public token;\r\n  // underlying token (eg DAI) address\r\n  address public underlying;\r\n  address public idleToken;\r\n  /**\r\n   * @param _token : iToken address\r\n   * @param _underlying : underlying token (eg DAI) address\r\n   */\r\n  constructor(address _token, address _underlying) public {\r\n    require(_token != address(0) \u0026\u0026 _underlying != address(0), \u0027COMP: some addr is 0\u0027);\r\n\r\n    token = _token;\r\n    underlying = _underlying;\r\n  }\r\n\r\n  /**\r\n   * Throws if called by any account other than IdleToken contract.\r\n   */\r\n  modifier onlyIdle() {\r\n    require(msg.sender == idleToken, \u0022Ownable: caller is not IdleToken contract\u0022);\r\n    _;\r\n  }\r\n\r\n  // onlyOwner\r\n  /**\r\n   * sets idleToken address\r\n   * NOTE: can be called only once. It\u0027s not on the constructor because we are deploying this contract\r\n   *       after the IdleToken contract\r\n   * @param _idleToken : idleToken address\r\n   */\r\n  function setIdleToken(address _idleToken)\r\n    external onlyOwner {\r\n      require(idleToken == address(0), \u0022idleToken addr already set\u0022);\r\n      require(_idleToken != address(0), \u0022_idleToken addr is 0\u0022);\r\n      idleToken = _idleToken;\r\n  }\r\n  // end onlyOwner\r\n\r\n  /**\r\n   * Gets next supply rate from Fulcrum, given an \u0060_amount\u0060 supplied\r\n   *\r\n   * @param _amount : new underlying amount supplied (eg DAI)\r\n   * @return nextRate : yearly net rate\r\n   */\r\n  function nextSupplyRate(uint256 _amount)\r\n    external view\r\n    returns (uint256) {\r\n      return iERC20Fulcrum(token).nextSupplyInterestRate(_amount);\r\n  }\r\n\r\n  /**\r\n   * Calculate next supply rate from Fulcrum, given an \u0060_amount\u0060 supplied (last array param)\r\n   * and all other params supplied. See \u0060info_fulcrum.md\u0060 for more info\r\n   * on calculations.\r\n   *\r\n   * @param params : array with all params needed for calculation (see below)\r\n   * @return : yearly net rate\r\n   */\r\n  function nextSupplyRateWithParams(uint256[] calldata params)\r\n    external view\r\n    returns (uint256) {\r\n      /*\r\n        uint256 a1 = params[0]; // protocolInterestRate;\r\n        uint256 b1 = params[1]; // totalAssetBorrow;\r\n        uint256 s1 = params[2]; // totalAssetSupply;\r\n        uint256 x1 = params[3]; // _amount;\r\n      */\r\n\r\n      // q = (a1 * b1 / (s1 \u002B x1))\r\n      return params[0].mul(params[1]).div(params[2].add(params[3]));\r\n  }\r\n\r\n  /**\r\n   * @return current price of iToken in underlying\r\n   */\r\n  function getPriceInToken()\r\n    external view\r\n    returns (uint256) {\r\n      return iERC20Fulcrum(token).tokenPrice();\r\n  }\r\n\r\n  /**\r\n   * @return apr : current yearly net rate\r\n   */\r\n  function getAPR()\r\n    external view\r\n    returns (uint256) {\r\n      return iERC20Fulcrum(token).nextSupplyInterestRate(0);\r\n  }\r\n\r\n  /**\r\n   * Gets all underlying tokens in this contract and mints iTokens\r\n   * tokens are then transferred to msg.sender\r\n   * NOTE: underlying tokens needs to be sended here before calling this\r\n   *\r\n   * @return iTokens minted\r\n   */\r\n  function mint()\r\n    external onlyIdle\r\n    returns (uint256 iTokens) {\r\n      uint256 balance = IERC20(underlying).balanceOf(address(this));\r\n      if (balance == 0) {\r\n        return iTokens;\r\n      }\r\n      // approve the transfer to iToken contract\r\n      IERC20(underlying).safeIncreaseAllowance(token, balance);\r\n      // mint the iTokens and transfer to msg.sender\r\n      iTokens = iERC20Fulcrum(token).mint(msg.sender, balance);\r\n  }\r\n\r\n  /**\r\n   * Gets all iTokens in this contract and redeems underlying tokens.\r\n   * underlying tokens are then transferred to \u0060_account\u0060\r\n   * NOTE: iTokens needs to be sended here before calling this\r\n   *\r\n   * @return underlying tokens redeemd\r\n   */\r\n  function redeem(address _account)\r\n    external onlyIdle\r\n    returns (uint256 tokens) {\r\n      uint256 balance = IERC20(token).balanceOf(address(this));\r\n      uint256 expectedAmount = balance.mul(iERC20Fulcrum(token).tokenPrice()).div(10**18);\r\n\r\n      tokens = iERC20Fulcrum(token).burn(_account, balance);\r\n      require(tokens \u003E= expectedAmount, \u0022Not enough liquidity on Fulcrum\u0022);\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getPriceInToken\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022iTokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022idleToken\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022underlying\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022params\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022nextSupplyRateWithParams\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022redeem\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_idleToken\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setIdleToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAPR\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022nextSupplyRate\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022token\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_underlying\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"IdleFulcrum","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"00000000000000000000000014094949152eddbfcd073717200da82fed8dc96000000000000000000000000089d24a6b4ccb1b6faa2625fe562bdd9a23260359","Library":"","SwarmSource":"bzzr://f826e91ba0a237ac31f19a44ddb2595b20daea194e160ac19074cb918f3bf9da"}]