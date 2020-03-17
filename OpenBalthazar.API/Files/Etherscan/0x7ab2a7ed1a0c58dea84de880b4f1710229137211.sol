[{"SourceCode":"// File: @openzeppelin/contracts/token/ERC20/IERC20.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\r\n * the optional functions; to access them see {ERC20Detailed}.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from the caller\u0027s account to \u0060recipient\u0060.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\r\n     * allowed to spend on behalf of \u0060owner\u0060 through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\r\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\r\n     * another (\u0060to\u0060).\r\n     *\r\n     * Note that \u0060value\u0060 may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\r\n     * a call to {approve}. \u0060value\u0060 is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// File: @openzeppelin/contracts/math/SafeMath.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * \u0060SafeMath\u0060 restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060\u002B\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060*\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n// File: @openzeppelin/contracts/math/Math.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Standard math utilities missing in the Solidity language.\r\n */\r\nlibrary Math {\r\n    /**\r\n     * @dev Returns the largest of two numbers.\r\n     */\r\n    function max(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a \u003E= b ? a : b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the smallest of two numbers.\r\n     */\r\n    function min(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a \u003C b ? a : b;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the average of two numbers. The result is rounded towards\r\n     * zero.\r\n     */\r\n    function average(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // (a \u002B b) / 2 can overflow, so we distribute\r\n        return (a / 2) \u002B (b / 2) \u002B ((a % 2 \u002B b % 2) / 2);\r\n    }\r\n}\r\n\r\n// File: @openzeppelin/contracts/GSN/Context.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/*\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with GSN meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\ncontract Context {\r\n    // Empty internal constructor, to prevent people from mistakenly deploying\r\n    // an instance of this contract, which should be used via inheritance.\r\n    constructor () internal { }\r\n    // solhint-disable-previous-line no-empty-blocks\r\n\r\n    function _msgSender() internal view returns (address payable) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}\r\n\r\n// File: @openzeppelin/contracts/utils/Address.sol\r\n\r\npragma solidity ^0.5.5;\r\n\r\n/**\r\n * @dev Collection of functions related to the address type\r\n */\r\nlibrary Address {\r\n    /**\r\n     * @dev Returns true if \u0060account\u0060 is a contract.\r\n     *\r\n     * This test is non-exhaustive, and there may be false-negatives: during the\r\n     * execution of a contract\u0027s constructor, its address will be reported as\r\n     * not containing a contract.\r\n     *\r\n     * IMPORTANT: It is unsafe to assume that an address for which this\r\n     * function returns false is an externally-owned account (EOA) and not a\r\n     * contract.\r\n     */\r\n    function isContract(address account) internal view returns (bool) {\r\n        // This method relies in extcodesize, which returns 0 for contracts in\r\n        // construction, since the code is only stored at the end of the\r\n        // constructor execution.\r\n\r\n        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts\r\n        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned\r\n        // for accounts without code, i.e. \u0060keccak256(\u0027\u0027)\u0060\r\n        bytes32 codehash;\r\n        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;\r\n        // solhint-disable-next-line no-inline-assembly\r\n        assembly { codehash := extcodehash(account) }\r\n        return (codehash != 0x0 \u0026\u0026 codehash != accountHash);\r\n    }\r\n\r\n    /**\r\n     * @dev Converts an \u0060address\u0060 into \u0060address payable\u0060. Note that this is\r\n     * simply a type cast: the actual underlying value is not changed.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function toPayable(address account) internal pure returns (address payable) {\r\n        return address(uint160(account));\r\n    }\r\n\r\n    /**\r\n     * @dev Replacement for Solidity\u0027s \u0060transfer\u0060: sends \u0060amount\u0060 wei to\r\n     * \u0060recipient\u0060, forwarding all available gas and reverting on errors.\r\n     *\r\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\r\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\r\n     * imposed by \u0060transfer\u0060, making them unable to receive funds via\r\n     * \u0060transfer\u0060. {sendValue} removes this limitation.\r\n     *\r\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\r\n     *\r\n     * IMPORTANT: because control is transferred to \u0060recipient\u0060, care must be\r\n     * taken to not create reentrancy vulnerabilities. Consider using\r\n     * {ReentrancyGuard} or the\r\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function sendValue(address payable recipient, uint256 amount) internal {\r\n        require(address(this).balance \u003E= amount, \u0022Address: insufficient balance\u0022);\r\n\r\n        // solhint-disable-next-line avoid-call-value\r\n        (bool success, ) = recipient.call.value(amount)(\u0022\u0022);\r\n        require(success, \u0022Address: unable to send value, recipient may have reverted\u0022);\r\n    }\r\n}\r\n\r\n// File: @openzeppelin/contracts/ownership/Ownable.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * \u0060onlyOwner\u0060, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\ncontract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () internal {\r\n        _owner = _msgSender();\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the caller is the current owner.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return _msgSender() == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * \u0060onlyOwner\u0060 functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\n// File: contracts/IdleMcdBridge.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\ninterface IIdleV1 {\r\n    // _amount is the amount of idleSAI that one wants to burn\r\n    function redeemIdleToken(uint256 _amount) external returns (uint256 tokensRedeemed);\r\n    function balanceOf(address _account) external view returns (uint256);\r\n    function bestToken() external view returns(address);\r\n    function iToken() external view returns(address);\r\n    function cToken() external view returns(address);\r\n    function token() external view returns(address);\r\n    function tokenPrice() external view returns (uint256);\r\n}\r\n\r\n// File: contracts/interfaces/IIToken.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\ninterface IIToken {\r\n    function mint(\r\n        address _receiver,\r\n        uint256 _depositAmount)\r\n        external\r\n        returns (uint256 _mintAmount);\r\n\r\n    function burn(\r\n        address receiver,\r\n        uint256 burnAmount)\r\n        external\r\n        returns (uint256 loanAmountPaid);\r\n    function loanTokenAddress() external view returns (address);\r\n    function tokenPrice() external view returns (uint256);\r\n}\r\n\r\n// File: contracts/libraries/Utils.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\n\r\n\r\n// Should not forget to linkx\r\nlibrary Utils {\r\n    using Math for uint256;\r\n\r\n    function balanceOrAmount(IERC20 _token, uint256 _amount) internal view returns(uint256) {\r\n        if(address(_token) == address(0)) {\r\n            return address(this).balance;\r\n        }\r\n        return _token.balanceOf(address(this)).min(_amount);\r\n        // return 1 ether;\r\n    }\r\n}\r\n\r\n// File: contracts/partials/PartialIdleV1.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\nlibrary PartialIdleV1 {\r\n    using SafeMath for uint256;\r\n\r\n    function burn(address _idleTokenAddress, uint256 _amount) internal {\r\n        IIdleV1 idleToken = IIdleV1(_idleTokenAddress);\r\n        uint256 idleTokenAmount = Utils.balanceOrAmount(IERC20(_idleTokenAddress), _amount);\r\n        uint256 expectedAmount = idleTokenAmount.mul(idleToken.tokenPrice()).div(10**18);\r\n        idleToken.redeemIdleToken(idleTokenAmount);\r\n        require(IERC20(idleToken.token()).balanceOf(address(this)) \u003E= (expectedAmount - 1), \u0022PartialIdleV1.burn: IDLE_MONEY_MARKET_NOT_LIQUID\u0022);\r\n    }\r\n\r\n    function getUnderlying(address _idleTokenAddress) internal returns(address) {\r\n        return IIdleV1(_idleTokenAddress).token();\r\n    }\r\n }\r\n\r\n// File: contracts/interfaces/IIdleV2.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\ninterface IIdleV2 {\r\n  // one should approve the contract as spender for DAI before calling this method\r\n  // _amount is the amount of SAI/DAI that one wants to lend\r\n  // _clientProtocolAmounts can be an empty array for the migration\r\n  function mintIdleToken(uint256 _amount, uint256[] calldata _clientProtocolAmounts) external returns (uint256 mintedTokens);\r\n  function token() external view returns(address);\r\n}\r\n\r\n// File: contracts/partials/PartialIdleV2.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\n\r\n\r\n\r\n\r\n\r\nlibrary PartialIdleV2 {\r\n\r\n    function mint(address _idleTokenAddress, uint256 _amount, uint256[] memory _clientProtocolAmounts) internal {\r\n        IIdleV2 idleToken = IIdleV2(_idleTokenAddress);\r\n        IERC20 token = IERC20(idleToken.token());\r\n        uint256 amount = Utils.balanceOrAmount(token, _amount);\r\n        token.approve(_idleTokenAddress, amount);\r\n        idleToken.mintIdleToken(amount, _clientProtocolAmounts);\r\n        require(IERC20(_idleTokenAddress).transfer(msg.sender, IERC20(_idleTokenAddress).balanceOf(address(this))), \u0027Err transfering\u0027);\r\n    }\r\n\r\n    function getUnderlying(address _idleTokenAddress) internal returns(address) {\r\n        return IIdleV2(_idleTokenAddress).token();\r\n    }\r\n }\r\n\r\n// File: contracts/interfaces/IScdMcdMigration.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\ninterface IScdMcdMigration {\r\n    function swapSaiToDai(uint256 _amount) external;\r\n    function swapDaiToSai(uint256 _amount) external;\r\n}\r\n\r\n// File: contracts/Registry.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\n\r\ncontract Registry is Ownable {\r\n    mapping(bytes32 =\u003E address) internal contracts;\r\n\r\n    function lookup(bytes32 _hashedName) external view returns(address) {\r\n        return contracts[_hashedName];\r\n    }\r\n\r\n    function lookup(string memory _name) public view returns(address){\r\n        return contracts[keccak256(abi.encodePacked(_name))];\r\n    }\r\n\r\n    function setContract(string memory _name, address _contractAddress) public {\r\n        setContract(keccak256(abi.encodePacked(_name)), _contractAddress);\r\n    }\r\n\r\n    function setContract(bytes32 _hashedName, address _contractAddress) public onlyOwner {\r\n        contracts[_hashedName] = _contractAddress;\r\n    }\r\n}\r\n\r\n// File: contracts/libraries/RL.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\n\r\nlibrary RL {\r\n    // Mainnet\r\n    Registry constant internal registry = Registry(0xDc7eB6c5d66e4816E5CC69a70AA22f4584167333);\r\n    // Kovan\r\n    /* Registry constant internal registry = Registry(0xECbA2158241a05B833F61F8BB56F690A63fBFF77); */\r\n\r\n    // keccakc256(abi.encodePacked(\u0022sai\u0022));\r\n    bytes32 public constant _sai = 0x121766960ca66154cf52cc7f62663f2342706e7901d35f1d93fb4a7c321fa14a;\r\n    bytes32 public constant _dai = 0x9f08c71555a1be56230b2e2579fafe4777867e0a1b947f01073e934471de15c1;\r\n    bytes32 public constant _daiMigrationContract = 0x42d07b69ad62387b020b27e811fc060bc382308c513cb96f08ea805c77a04f9b;\r\n\r\n    bytes32 public constant _cache = 0x422c51ed3da5a7658c50a3684c705b5f1e3d2d1673c5e16aaf93ea6271bb54cf;\r\n    bytes32 public constant _gateKeeper = 0xcfa0d7a8bc1be8e2b981746eace0929cdd2721f615b63382540820f02696577b;\r\n    bytes32 public constant _treasury = 0xcbd818ad4dd6f1ff9338c2bb62480241424dd9a65f9f3284101a01cd099ad8ac;\r\n\r\n    bytes32 public constant _kyber = 0x758760f431d5bf0c2e6f8c11dbc38ddba93c5ba4e9b5425f4730333b3ecaf21b;\r\n    bytes32 public constant _synthetix = 0x52da455363ee608ccf172b43cb25e66cd1734a315508cf1dae3e995e8106011a;\r\n    bytes32 public constant _synthetixDepot = 0xcfead29a36d4ab9b4a23124bdd16cdd5acfdf5334caa9b0df48b01a0b6d68b20;\r\n\r\n\r\n    function lookup(bytes32 _hashedName) internal view returns(address) {\r\n        return registry.lookup(_hashedName);\r\n    }\r\n\r\n    function dai() internal pure returns(bytes32) {\r\n        return _dai;\r\n    }\r\n    function sai() internal pure returns(bytes32) {\r\n        return _sai;\r\n    }\r\n    function daiMigrationContract() internal pure returns(bytes32) {\r\n        return _daiMigrationContract;\r\n    }\r\n    function cache() internal pure returns(bytes32) {\r\n        return _cache;\r\n    }\r\n    function gateKeeper() internal pure returns(bytes32) {\r\n        return _gateKeeper;\r\n    }\r\n    function treasury() internal pure returns(bytes32) {\r\n        return _treasury;\r\n    }\r\n\r\n    function kyber() internal pure returns(bytes32) {\r\n        return _kyber;\r\n    }\r\n    function synthetix() internal pure returns(bytes32) {\r\n        return _synthetix;\r\n    }\r\n    function synthetixDepot() internal pure returns(bytes32) {\r\n        return _synthetixDepot;\r\n    }\r\n}\r\n\r\n// File: contracts/partials/PartialMcdMigration.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\n\r\n\r\n\r\n\r\nlibrary PartialMcdMigration {\r\n\r\n    function swapSaiToDai(uint256 _amount) internal {\r\n        IERC20 sai = IERC20(RL.lookup(RL.sai()));\r\n        IScdMcdMigration daiMigrationContract = IScdMcdMigration(RL.lookup(RL.daiMigrationContract()));\r\n        uint256 amount = Utils.balanceOrAmount(sai, _amount);\r\n        sai.approve(address(daiMigrationContract), amount);\r\n        daiMigrationContract.swapSaiToDai(amount);\r\n    }\r\n\r\n    function swapDaiToSai(uint256 _amount) internal {\r\n        IERC20 dai = IERC20(RL.lookup(RL.dai()));\r\n        IScdMcdMigration daiMigrationContract = IScdMcdMigration(RL.lookup(RL.daiMigrationContract()));\r\n        uint256 amount = Utils.balanceOrAmount(dai, _amount);\r\n        dai.approve(address(daiMigrationContract), amount);\r\n        daiMigrationContract.swapDaiToSai(amount);\r\n    }\r\n}\r\n\r\n// File: contracts/partials/PartialPull.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\n\r\n\r\nlibrary PartialPull {\r\n    using Math for uint256;\r\n\r\n    function pull(IERC20 _token, uint256 _amount) internal {\r\n        if(address(_token) == address(0)) {\r\n            require(msg.value == _amount, \u0022PartialPull.pull: MSG_VALUE_INCORRECT\u0022);\r\n        }\r\n        // uint256 amount = Utils.balanceOrAmount(_token, _amount);\r\n        // Either pull the balance, allowance or _amount, whichever is the smallest number\r\n        uint256 amount = _token.balanceOf(msg.sender).min(_amount).min(_token.allowance(msg.sender, address(this)));\r\n        require(_token.transferFrom(msg.sender, address(this), amount), \u0022PartialPull.pull: TRANSFER_FAILED\u0022);\r\n    }\r\n}\r\n\r\n// File: contracts/partials/PartialPush.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\n\r\n\r\n\r\n\r\nlibrary PartialPush {\r\n    using Math for uint256;\r\n    using Address for address;\r\n\r\n    function push(IERC20 _token, address _receiver, uint256 _amount) internal {\r\n        uint256 amount = Utils.balanceOrAmount(_token, _amount);\r\n        if(address(_token) == address(0)) {\r\n            _receiver.toPayable().transfer(amount);\r\n        }\r\n        _token.transfer(_receiver, amount);\r\n    }\r\n}\r\n\r\n// File: contracts/TokenSaver.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\n\r\n\r\ncontract TokenSaver is Ownable {\r\n\r\n    function saveEther() external onlyOwner {\r\n        msg.sender.transfer(address(this).balance);\r\n    }\r\n\r\n    function saveTokens(address _token) external onlyOwner {\r\n        IERC20 token = IERC20(_token);\r\n        // Some tokens do not allow a balance to drop to zero so we leave 1 wei to be safe\r\n        token.transfer(msg.sender, token.balanceOf(address(this)) - 1);\r\n    }\r\n\r\n}\r\n\r\n// File: contracts/static-recipes/IdleMcdBridge.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\ncontract IdleMcdBridge is TokenSaver {\r\n\r\n    uint256 constant MAX = uint256(-1);\r\n\r\n    address public SAI;\r\n    address public DAI;\r\n\r\n    constructor(address _SAI, address _DAI) public {\r\n        SAI = _SAI;\r\n        DAI = _DAI;\r\n    }\r\n\r\n    function bridgeIdleV1ToIdleV2(address _V1, address _V2, uint256 _amount, uint256[] calldata _clientProtocolAmounts) external {\r\n        PartialPull.pull(IERC20(_V1), _amount);\r\n        PartialIdleV1.burn(_V1, _amount);\r\n\r\n        address underlyingV1 = PartialIdleV1.getUnderlying(_V1);\r\n        address underlyingV2 = PartialIdleV2.getUnderlying(_V2);\r\n\r\n        if(underlyingV1 == SAI \u0026\u0026 underlyingV2 == DAI) {\r\n            // Migrate SAI TO DAI\r\n            PartialMcdMigration.swapSaiToDai(MAX);\r\n\r\n        } else if(underlyingV1 == DAI \u0026\u0026 underlyingV2 == SAI) {\r\n            // Migrate DAI TO SAI\r\n            PartialMcdMigration.swapDaiToSai(MAX);\r\n        }\r\n        // Else idle tokens have same underlying asset so do nothing\r\n\r\n        // Mint v2 Tokens\r\n        PartialIdleV2.mint(_V2, MAX, _clientProtocolAmounts);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_V1\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_V2\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_clientProtocolAmounts\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022bridgeIdleV1ToIdleV2\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022SAI\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022saveEther\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022saveTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DAI\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_SAI\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_DAI\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"IdleMcdBridge","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"00000000000000000000000089d24a6b4ccb1b6faa2625fe562bdd9a232603590000000000000000000000006b175474e89094c44da98b954eedeac495271d0f","Library":"","SwarmSource":"bzzr://3dbcf3f12ba5dd9aa968a5416f83eebfe2d9afabd26404c9307bff9785d27a73"}]