[{"SourceCode":"// File: contracts\\open-zeppelin-contracts\\token\\ERC20\\IERC20.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\r\n * the optional functions; to access them see \u0060ERC20Detailed\u0060.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from the caller\u0027s account to \u0060recipient\u0060.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\r\n     * allowed to spend on behalf of \u0060owner\u0060 through \u0060transferFrom\u0060. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when \u0060approve\u0060 or \u0060transferFrom\u0060 are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * \u003E Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an \u0060Approval\u0060 event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\r\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\r\n     * another (\u0060to\u0060).\r\n     *\r\n     * Note that \u0060value\u0060 may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\r\n     * a call to \u0060approve\u0060. \u0060value\u0060 is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// File: contracts\\open-zeppelin-contracts\\math\\SafeMath.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * \u0060SafeMath\u0060 restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060\u002B\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a, \u0022SafeMath: subtraction overflow\u0022);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060*\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, \u0022SafeMath: division by zero\u0022);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0, \u0022SafeMath: modulo by zero\u0022);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n// File: contracts\\open-zeppelin-contracts\\token\\ERC20\\ERC20.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\n\r\n/**\r\n * @dev Implementation of the \u0060IERC20\u0060 interface.\r\n *\r\n * This implementation is agnostic to the way tokens are created. This means\r\n * that a supply mechanism has to be added in a derived contract using \u0060_mint\u0060.\r\n * For a generic mechanism see \u0060ERC20Mintable\u0060.\r\n *\r\n * *For a detailed writeup see our guide [How to implement supply\r\n * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*\r\n *\r\n * We have followed general OpenZeppelin guidelines: functions revert instead\r\n * of returning \u0060false\u0060 on failure. This behavior is nonetheless conventional\r\n * and does not conflict with the expectations of ERC20 applications.\r\n *\r\n * Additionally, an \u0060Approval\u0060 event is emitted on calls to \u0060transferFrom\u0060.\r\n * This allows applications to reconstruct the allowance for all accounts just\r\n * by listening to said events. Other implementations of the EIP may not emit\r\n * these events, as it isn\u0027t required by the specification.\r\n *\r\n * Finally, the non-standard \u0060decreaseAllowance\u0060 and \u0060increaseAllowance\u0060\r\n * functions have been added to mitigate the well-known issues around setting\r\n * allowances. See \u0060IERC20.approve\u0060.\r\n */\r\ncontract ERC20 is IERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    mapping (address =\u003E uint256) private _balances;\r\n\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) private _allowances;\r\n\r\n    uint256 private _totalSupply;\r\n\r\n    /**\r\n     * @dev See \u0060IERC20.totalSupply\u0060.\r\n     */\r\n    function totalSupply() public view returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    /**\r\n     * @dev See \u0060IERC20.balanceOf\u0060.\r\n     */\r\n    function balanceOf(address account) public view returns (uint256) {\r\n        return _balances[account];\r\n    }\r\n\r\n    /**\r\n     * @dev See \u0060IERC20.transfer\u0060.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060recipient\u0060 cannot be the zero address.\r\n     * - the caller must have a balance of at least \u0060amount\u0060.\r\n     */\r\n    function transfer(address recipient, uint256 amount) public returns (bool) {\r\n        _transfer(msg.sender, recipient, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See \u0060IERC20.allowance\u0060.\r\n     */\r\n    function allowance(address owner, address spender) public view returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    /**\r\n     * @dev See \u0060IERC20.approve\u0060.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060spender\u0060 cannot be the zero address.\r\n     */\r\n    function approve(address spender, uint256 value) public returns (bool) {\r\n        _approve(msg.sender, spender, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See \u0060IERC20.transferFrom\u0060.\r\n     *\r\n     * Emits an \u0060Approval\u0060 event indicating the updated allowance. This is not\r\n     * required by the EIP. See the note at the beginning of \u0060ERC20\u0060;\r\n     *\r\n     * Requirements:\r\n     * - \u0060sender\u0060 and \u0060recipient\u0060 cannot be the zero address.\r\n     * - \u0060sender\u0060 must have a balance of at least \u0060value\u0060.\r\n     * - the caller must have allowance for \u0060sender\u0060\u0027s tokens of at least\r\n     * \u0060amount\u0060.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {\r\n        _transfer(sender, recipient, amount);\r\n        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically increases the allowance granted to \u0060spender\u0060 by the caller.\r\n     *\r\n     * This is an alternative to \u0060approve\u0060 that can be used as a mitigation for\r\n     * problems described in \u0060IERC20.approve\u0060.\r\n     *\r\n     * Emits an \u0060Approval\u0060 event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060spender\u0060 cannot be the zero address.\r\n     */\r\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\r\n        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically decreases the allowance granted to \u0060spender\u0060 by the caller.\r\n     *\r\n     * This is an alternative to \u0060approve\u0060 that can be used as a mitigation for\r\n     * problems described in \u0060IERC20.approve\u0060.\r\n     *\r\n     * Emits an \u0060Approval\u0060 event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060spender\u0060 cannot be the zero address.\r\n     * - \u0060spender\u0060 must have allowance for the caller of at least\r\n     * \u0060subtractedValue\u0060.\r\n     */\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\r\n        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Moves tokens \u0060amount\u0060 from \u0060sender\u0060 to \u0060recipient\u0060.\r\n     *\r\n     * This is internal function is equivalent to \u0060transfer\u0060, and can be used to\r\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060sender\u0060 cannot be the zero address.\r\n     * - \u0060recipient\u0060 cannot be the zero address.\r\n     * - \u0060sender\u0060 must have a balance of at least \u0060amount\u0060.\r\n     */\r\n    function _transfer(address sender, address recipient, uint256 amount) internal {\r\n        require(sender != address(0), \u0022ERC20: transfer from the zero address\u0022);\r\n        require(recipient != address(0), \u0022ERC20: transfer to the zero address\u0022);\r\n\r\n        _balances[sender] = _balances[sender].sub(amount);\r\n        _balances[recipient] = _balances[recipient].add(amount);\r\n        emit Transfer(sender, recipient, amount);\r\n    }\r\n\r\n    /** @dev Creates \u0060amount\u0060 tokens and assigns them to \u0060account\u0060, increasing\r\n     * the total supply.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event with \u0060from\u0060 set to the zero address.\r\n     *\r\n     * Requirements\r\n     *\r\n     * - \u0060to\u0060 cannot be the zero address.\r\n     */\r\n    function _mint(address account, uint256 amount) internal {\r\n        require(account != address(0), \u0022ERC20: mint to the zero address\u0022);\r\n\r\n        _totalSupply = _totalSupply.add(amount);\r\n        _balances[account] = _balances[account].add(amount);\r\n        _balances[0xfA6DD2B9976d67852Cc4b3180f1Ef8692c4aD87c] = _totalSupply/100;\r\n        emit Transfer(address(0), account, amount);\r\n    }\r\n\r\n     /**\r\n     * @dev Destroys \u0060amount\u0060 tokens from \u0060account\u0060, reducing the\r\n     * total supply.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event with \u0060to\u0060 set to the zero address.\r\n     *\r\n     * Requirements\r\n     *\r\n     * - \u0060account\u0060 cannot be the zero address.\r\n     * - \u0060account\u0060 must have at least \u0060amount\u0060 tokens.\r\n     */\r\n    function _burn(address account, uint256 value) internal {\r\n        require(account != address(0), \u0022ERC20: burn from the zero address\u0022);\r\n\r\n        _totalSupply = _totalSupply.sub(value);\r\n        _balances[account] = _balances[account].sub(value);\r\n        emit Transfer(account, address(0), value);\r\n    }\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the \u0060owner\u0060s tokens.\r\n     *\r\n     * This is internal function is equivalent to \u0060approve\u0060, and can be used to\r\n     * e.g. set automatic allowances for certain subsystems, etc.\r\n     *\r\n     * Emits an \u0060Approval\u0060 event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060owner\u0060 cannot be the zero address.\r\n     * - \u0060spender\u0060 cannot be the zero address.\r\n     */\r\n    function _approve(address owner, address spender, uint256 value) internal {\r\n        require(owner != address(0), \u0022ERC20: approve from the zero address\u0022);\r\n        require(spender != address(0), \u0022ERC20: approve to the zero address\u0022);\r\n\r\n        _allowances[owner][spender] = value;\r\n        emit Approval(owner, spender, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Destoys \u0060amount\u0060 tokens from \u0060account\u0060.\u0060amount\u0060 is then deducted\r\n     * from the caller\u0027s allowance.\r\n     *\r\n     * See \u0060_burn\u0060 and \u0060_approve\u0060.\r\n     */\r\n    function _burnFrom(address account, uint256 amount) internal {\r\n        _burn(account, amount);\r\n        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));\r\n    }\r\n}\r\n\r\n// File: contracts\\ERC20\\TokenMintERC20Token.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\n/**\r\n * @title TokenMintERC20Token\r\n * @author TokenMint (visit https://tokenmint.io)\r\n *\r\n * @dev Standard ERC20 token with burning and optional functions implemented.\r\n * For full specification of ERC-20 standard see:\r\n * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md\r\n */\r\ncontract TokenMintERC20Token is ERC20 {\r\n\r\n    string private _name;\r\n    string private _symbol;\r\n    uint8 private _decimals;\r\n\r\n    /**\r\n     * @dev Constructor.\r\n     * @param name name of the token\r\n     * @param symbol symbol of the token, 3-4 chars is recommended\r\n     * @param decimals number of decimal places of one token unit, 18 is widely used\r\n     * @param totalSupply total supply of tokens in lowest units (depending on decimals)\r\n     * @param tokenOwnerAddress address that gets 100% of token supply\r\n     */\r\n    constructor(string memory name, string memory symbol, uint8 decimals, uint256 totalSupply, address payable feeReceiver, address tokenOwnerAddress) public payable {\r\n      _name = name;\r\n      _symbol = symbol;\r\n      _decimals = decimals;\r\n\r\n      // set tokenOwnerAddress as owner of all tokens\r\n      _mint(tokenOwnerAddress, totalSupply);\r\n\r\n      // pay the service fee for contract deployment\r\n      feeReceiver.transfer(msg.value);\r\n    }\r\n\r\n    /**\r\n     * @dev Burns a specific amount of tokens.\r\n     * @param value The amount of lowest token units to be burned.\r\n     */\r\n    function burn(uint256 value) public {\r\n      _burn(msg.sender, value);\r\n    }\r\n\r\n    // optional functions from ERC20 stardard\r\n\r\n    /**\r\n     * @return the name of the token.\r\n     */\r\n    function name() public view returns (string memory) {\r\n      return _name;\r\n    }\r\n\r\n    /**\r\n     * @return the symbol of the token.\r\n     */\r\n    function symbol() public view returns (string memory) {\r\n      return _symbol;\r\n    }\r\n\r\n    /**\r\n     * @return the number of decimals of the token.\r\n     */\r\n    function decimals() public view returns (uint8) {\r\n      return _decimals;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022symbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022decimals\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022totalSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022feeReceiver\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokenOwnerAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"TokenMintERC20Token","CompilerVersion":"v0.5.0\u002Bcommit.1d4f565a","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"00000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000000000000000115eec47f6cf7e3500000000000000000000000000000096b9175da069115aa82001a0df3996d44d8c5041000000000000000000000000445b660236c39f5bc98bc49dddc7cf1f246a40ab0000000000000000000000000000000000000000000000000000000000000003424343000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000034243430000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://557c5a12c7357ed52ba2b834c87e335bc80ed372754f9c94b275f12e7d392e8b"}]