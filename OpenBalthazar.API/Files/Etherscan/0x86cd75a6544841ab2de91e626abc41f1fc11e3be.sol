[{"SourceCode":"// File: openzeppelin-solidity\\contracts\\ownership\\Ownable.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * \u0060onlyOwner\u0060, which can be aplied to your functions to restrict their use to\r\n * the owner.\r\n */\r\ncontract Ownable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the caller is the current owner.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * \u0060onlyOwner\u0060 functions anymore. Can only be called by the current owner.\r\n     *\r\n     * \u003E Note: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\n// File: node_modules\\openzeppelin-solidity\\contracts\\token\\ERC20\\IERC20.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\r\n * the optional functions; to access them see \u0060ERC20Detailed\u0060.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from the caller\u0027s account to \u0060recipient\u0060.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\r\n     * allowed to spend on behalf of \u0060owner\u0060 through \u0060transferFrom\u0060. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when \u0060approve\u0060 or \u0060transferFrom\u0060 are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * \u003E Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an \u0060Approval\u0060 event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\r\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\r\n     * another (\u0060to\u0060).\r\n     *\r\n     * Note that \u0060value\u0060 may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\r\n     * a call to \u0060approve\u0060. \u0060value\u0060 is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// File: node_modules\\openzeppelin-solidity\\contracts\\math\\SafeMath.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * \u0060SafeMath\u0060 restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060\u002B\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a, \u0022SafeMath: subtraction overflow\u0022);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060*\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, \u0022SafeMath: division by zero\u0022);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0, \u0022SafeMath: modulo by zero\u0022);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n// File: node_modules\\openzeppelin-solidity\\contracts\\token\\ERC20\\ERC20.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\n\r\n/**\r\n * @dev Implementation of the \u0060IERC20\u0060 interface.\r\n *\r\n * This implementation is agnostic to the way tokens are created. This means\r\n * that a supply mechanism has to be added in a derived contract using \u0060_mint\u0060.\r\n * For a generic mechanism see \u0060ERC20Mintable\u0060.\r\n *\r\n * *For a detailed writeup see our guide [How to implement supply\r\n * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*\r\n *\r\n * We have followed general OpenZeppelin guidelines: functions revert instead\r\n * of returning \u0060false\u0060 on failure. This behavior is nonetheless conventional\r\n * and does not conflict with the expectations of ERC20 applications.\r\n *\r\n * Additionally, an \u0060Approval\u0060 event is emitted on calls to \u0060transferFrom\u0060.\r\n * This allows applications to reconstruct the allowance for all accounts just\r\n * by listening to said events. Other implementations of the EIP may not emit\r\n * these events, as it isn\u0027t required by the specification.\r\n *\r\n * Finally, the non-standard \u0060decreaseAllowance\u0060 and \u0060increaseAllowance\u0060\r\n * functions have been added to mitigate the well-known issues around setting\r\n * allowances. See \u0060IERC20.approve\u0060.\r\n */\r\ncontract ERC20 is IERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    mapping (address =\u003E uint256) private _balances;\r\n\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) private _allowances;\r\n\r\n    uint256 private _totalSupply;\r\n\r\n    /**\r\n     * @dev See \u0060IERC20.totalSupply\u0060.\r\n     */\r\n    function totalSupply() public view returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    /**\r\n     * @dev See \u0060IERC20.balanceOf\u0060.\r\n     */\r\n    function balanceOf(address account) public view returns (uint256) {\r\n        return _balances[account];\r\n    }\r\n\r\n    /**\r\n     * @dev See \u0060IERC20.transfer\u0060.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060recipient\u0060 cannot be the zero address.\r\n     * - the caller must have a balance of at least \u0060amount\u0060.\r\n     */\r\n    function transfer(address recipient, uint256 amount) public returns (bool) {\r\n        _transfer(msg.sender, recipient, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See \u0060IERC20.allowance\u0060.\r\n     */\r\n    function allowance(address owner, address spender) public view returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    /**\r\n     * @dev See \u0060IERC20.approve\u0060.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060spender\u0060 cannot be the zero address.\r\n     */\r\n    function approve(address spender, uint256 value) public returns (bool) {\r\n        _approve(msg.sender, spender, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See \u0060IERC20.transferFrom\u0060.\r\n     *\r\n     * Emits an \u0060Approval\u0060 event indicating the updated allowance. This is not\r\n     * required by the EIP. See the note at the beginning of \u0060ERC20\u0060;\r\n     *\r\n     * Requirements:\r\n     * - \u0060sender\u0060 and \u0060recipient\u0060 cannot be the zero address.\r\n     * - \u0060sender\u0060 must have a balance of at least \u0060value\u0060.\r\n     * - the caller must have allowance for \u0060sender\u0060\u0027s tokens of at least\r\n     * \u0060amount\u0060.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {\r\n        _transfer(sender, recipient, amount);\r\n        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically increases the allowance granted to \u0060spender\u0060 by the caller.\r\n     *\r\n     * This is an alternative to \u0060approve\u0060 that can be used as a mitigation for\r\n     * problems described in \u0060IERC20.approve\u0060.\r\n     *\r\n     * Emits an \u0060Approval\u0060 event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060spender\u0060 cannot be the zero address.\r\n     */\r\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\r\n        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically decreases the allowance granted to \u0060spender\u0060 by the caller.\r\n     *\r\n     * This is an alternative to \u0060approve\u0060 that can be used as a mitigation for\r\n     * problems described in \u0060IERC20.approve\u0060.\r\n     *\r\n     * Emits an \u0060Approval\u0060 event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060spender\u0060 cannot be the zero address.\r\n     * - \u0060spender\u0060 must have allowance for the caller of at least\r\n     * \u0060subtractedValue\u0060.\r\n     */\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\r\n        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Moves tokens \u0060amount\u0060 from \u0060sender\u0060 to \u0060recipient\u0060.\r\n     *\r\n     * This is internal function is equivalent to \u0060transfer\u0060, and can be used to\r\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060sender\u0060 cannot be the zero address.\r\n     * - \u0060recipient\u0060 cannot be the zero address.\r\n     * - \u0060sender\u0060 must have a balance of at least \u0060amount\u0060.\r\n     */\r\n    function _transfer(address sender, address recipient, uint256 amount) internal {\r\n        require(sender != address(0), \u0022ERC20: transfer from the zero address\u0022);\r\n        require(recipient != address(0), \u0022ERC20: transfer to the zero address\u0022);\r\n\r\n        _balances[sender] = _balances[sender].sub(amount);\r\n        _balances[recipient] = _balances[recipient].add(amount);\r\n        emit Transfer(sender, recipient, amount);\r\n    }\r\n\r\n    /** @dev Creates \u0060amount\u0060 tokens and assigns them to \u0060account\u0060, increasing\r\n     * the total supply.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event with \u0060from\u0060 set to the zero address.\r\n     *\r\n     * Requirements\r\n     *\r\n     * - \u0060to\u0060 cannot be the zero address.\r\n     */\r\n    function _mint(address account, uint256 amount) internal {\r\n        require(account != address(0), \u0022ERC20: mint to the zero address\u0022);\r\n\r\n        _totalSupply = _totalSupply.add(amount);\r\n        _balances[account] = _balances[account].add(amount);\r\n        emit Transfer(address(0), account, amount);\r\n    }\r\n\r\n     /**\r\n     * @dev Destoys \u0060amount\u0060 tokens from \u0060account\u0060, reducing the\r\n     * total supply.\r\n     *\r\n     * Emits a \u0060Transfer\u0060 event with \u0060to\u0060 set to the zero address.\r\n     *\r\n     * Requirements\r\n     *\r\n     * - \u0060account\u0060 cannot be the zero address.\r\n     * - \u0060account\u0060 must have at least \u0060amount\u0060 tokens.\r\n     */\r\n    function _burn(address account, uint256 value) internal {\r\n        require(account != address(0), \u0022ERC20: burn from the zero address\u0022);\r\n\r\n        _totalSupply = _totalSupply.sub(value);\r\n        _balances[account] = _balances[account].sub(value);\r\n        emit Transfer(account, address(0), value);\r\n    }\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the \u0060owner\u0060s tokens.\r\n     *\r\n     * This is internal function is equivalent to \u0060approve\u0060, and can be used to\r\n     * e.g. set automatic allowances for certain subsystems, etc.\r\n     *\r\n     * Emits an \u0060Approval\u0060 event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060owner\u0060 cannot be the zero address.\r\n     * - \u0060spender\u0060 cannot be the zero address.\r\n     */\r\n    function _approve(address owner, address spender, uint256 value) internal {\r\n        require(owner != address(0), \u0022ERC20: approve from the zero address\u0022);\r\n        require(spender != address(0), \u0022ERC20: approve to the zero address\u0022);\r\n\r\n        _allowances[owner][spender] = value;\r\n        emit Approval(owner, spender, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Destoys \u0060amount\u0060 tokens from \u0060account\u0060.\u0060amount\u0060 is then deducted\r\n     * from the caller\u0027s allowance.\r\n     *\r\n     * See \u0060_burn\u0060 and \u0060_approve\u0060.\r\n     */\r\n    function _burnFrom(address account, uint256 amount) internal {\r\n        _burn(account, amount);\r\n        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));\r\n    }\r\n}\r\n\r\n// File: node_modules\\openzeppelin-solidity\\contracts\\access\\Roles.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @title Roles\r\n * @dev Library for managing addresses assigned to a Role.\r\n */\r\nlibrary Roles {\r\n    struct Role {\r\n        mapping (address =\u003E bool) bearer;\r\n    }\r\n\r\n    /**\r\n     * @dev Give an account access to this role.\r\n     */\r\n    function add(Role storage role, address account) internal {\r\n        require(!has(role, account), \u0022Roles: account already has role\u0022);\r\n        role.bearer[account] = true;\r\n    }\r\n\r\n    /**\r\n     * @dev Remove an account\u0027s access to this role.\r\n     */\r\n    function remove(Role storage role, address account) internal {\r\n        require(has(role, account), \u0022Roles: account does not have role\u0022);\r\n        role.bearer[account] = false;\r\n    }\r\n\r\n    /**\r\n     * @dev Check if an account has this role.\r\n     * @return bool\r\n     */\r\n    function has(Role storage role, address account) internal view returns (bool) {\r\n        require(account != address(0), \u0022Roles: account is the zero address\u0022);\r\n        return role.bearer[account];\r\n    }\r\n}\r\n\r\n// File: node_modules\\openzeppelin-solidity\\contracts\\access\\roles\\MinterRole.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\ncontract MinterRole {\r\n    using Roles for Roles.Role;\r\n\r\n    event MinterAdded(address indexed account);\r\n    event MinterRemoved(address indexed account);\r\n\r\n    Roles.Role private _minters;\r\n\r\n    constructor () internal {\r\n        _addMinter(msg.sender);\r\n    }\r\n\r\n    modifier onlyMinter() {\r\n        require(isMinter(msg.sender), \u0022MinterRole: caller does not have the Minter role\u0022);\r\n        _;\r\n    }\r\n\r\n    function isMinter(address account) public view returns (bool) {\r\n        return _minters.has(account);\r\n    }\r\n\r\n    function addMinter(address account) public onlyMinter {\r\n        _addMinter(account);\r\n    }\r\n\r\n    function renounceMinter() public {\r\n        _removeMinter(msg.sender);\r\n    }\r\n\r\n    function _addMinter(address account) internal {\r\n        _minters.add(account);\r\n        emit MinterAdded(account);\r\n    }\r\n\r\n    function _removeMinter(address account) internal {\r\n        _minters.remove(account);\r\n        emit MinterRemoved(account);\r\n    }\r\n}\r\n\r\n// File: openzeppelin-solidity\\contracts\\token\\ERC20\\ERC20Mintable.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\n\r\n/**\r\n * @dev Extension of \u0060ERC20\u0060 that adds a set of accounts with the \u0060MinterRole\u0060,\r\n * which have permission to mint (create) new tokens as they see fit.\r\n *\r\n * At construction, the deployer of the contract is the only minter.\r\n */\r\ncontract ERC20Mintable is ERC20, MinterRole {\r\n    /**\r\n     * @dev See \u0060ERC20._mint\u0060.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - the caller must have the \u0060MinterRole\u0060.\r\n     */\r\n    function mint(address account, uint256 amount) public onlyMinter returns (bool) {\r\n        _mint(account, amount);\r\n        return true;\r\n    }\r\n}\r\n\r\n// File: contracts\\token\\TokenRecipient.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\n/**\r\n* @dev Interface to use the receiveApproval method\r\n**/\r\ninterface TokenRecipient {\r\n\r\n    /**\r\n    * @notice Receives a notification of approval of the transfer\r\n    * @param _from Sender of approval\r\n    * @param _value  The amount of tokens to be spent\r\n    * @param _tokenContract Address of the token contract\r\n    * @param _extraData Extra data\r\n    **/\r\n    function receiveApproval(address _from, uint256 _value, address _tokenContract, bytes calldata _extraData) external returns (bool);\r\n\r\n}\r\n\r\n// File: contracts\\token\\FuchsiaToken.sol\r\n\r\npragma solidity 0.5.11;\r\n\r\n\r\n\r\n\r\ncontract FuchsiaToken is Ownable, ERC20Mintable {\r\n  string public name = \u0022Fuchsia\u0022;\r\n  string public symbol = \u0022XF\u0022;\r\n  uint8 public decimals = 18;\r\n  uint256 private initialSupply = 888 * 1000 * 1000 * 1000;\r\n\r\n  constructor() public {\r\n    _mint(owner(), initialSupply * (10 ** uint256(decimals)));\r\n  }\r\n\r\n  /**\r\n  * @notice Approves and then calls the receiving contract\r\n  *\r\n  * @dev call the receiveApproval function on the contract you want to be notified.\r\n  * receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)\r\n  **/\r\n  function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success)\r\n  {\r\n    require(approve(_spender, _value));\r\n    require(TokenRecipient(_spender).receiveApproval(msg.sender, _value, address(this), _extraData));\r\n    return true;\r\n  }\r\n\r\n  /**\r\n  * @notice Drop tokens to list of accounts\r\n  * @param _addresses Accounts which will get tokens\r\n  * @param _amounts Token amounts\r\n  */\r\n  function batchTransfer(address[] calldata _addresses, uint256[] calldata _amounts) external returns (bool) {\r\n    require(_addresses.length == _amounts.length);\r\n\r\n    for (uint256 index = 0; index \u003C _addresses.length; index\u002B\u002B) {\r\n      require(transfer(_addresses[index], _amounts[index]));\r\n    }\r\n\r\n    return true;\r\n  }\r\n\r\n  /**\r\n  * @notice Drop tokens to list of accounts\r\n  * @param _from Account from which will get tokens\r\n  * @param _to Accounts to which will get tokens\r\n  * @param _amounts Token amounts\r\n  */\r\n  function batchTransferFrom(address _from, address[] calldata _to, uint256[] calldata _amounts) external returns (bool) {\r\n    require(_to.length == _amounts.length);\r\n\r\n    for (uint256 index = 0; index \u003C _to.length; index\u002B\u002B) {\r\n      require(transferFrom(_from, _to[index], _amounts[index]));\r\n    }\r\n\r\n    return true;\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseAllowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseAllowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"ERC20","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://36de4ccd7f56123c25442c0549f5a2ed693cc6e5434fa33a7f02a252d315afc0"}]