[{"SourceCode":"pragma solidity 0.5.13;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * \u0060SafeMath\u0060 restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060\u002B\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060*\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\r\n * the optional functions; to access them see {ERC20Detailed}.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from the caller\u0027s account to \u0060recipient\u0060.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\r\n     * allowed to spend on behalf of \u0060owner\u0060 through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\r\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\r\n     * another (\u0060to\u0060).\r\n     *\r\n     * Note that \u0060value\u0060 may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\r\n     * a call to {approve}. \u0060value\u0060 is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// Beta program for ERC20 token swap deals. Use at own risk!\r\ncontract tokenSwap {\r\n    using SafeMath for uint256;\r\n    \r\n    event Swapped(address indexed caller, address indexed counterparty, string indexed details);\r\n    \r\n    function Swap( \r\n    \tuint256 partyAswap,\r\n    \tIERC20 partyAtkn,\r\n    \taddress partyB,\r\n    \tuint256 partyBswap,\r\n    \tIERC20 partyBtkn,\r\n        string memory details) public {\r\n        \r\n        partyAtkn.transferFrom(msg.sender, partyB, partyAswap);\r\n        partyBtkn.transferFrom(partyB, msg.sender, partyBswap);\r\n        \t \r\n        emit Swapped(msg.sender, partyB, details); \r\n    }\r\n}","ABI":"[{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022caller\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022counterparty\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022details\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022Swapped\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022partyAswap\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022partyAtkn\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022partyB\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022partyBswap\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022partyBtkn\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022details\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022Swap\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"tokenSwap","CompilerVersion":"v0.5.13\u002Bcommit.5b0b510c","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://c1c5d1bf31f30d723efec34ec0b5659c8734eeb7ca26e3f748477ea5f3b70e89"}]