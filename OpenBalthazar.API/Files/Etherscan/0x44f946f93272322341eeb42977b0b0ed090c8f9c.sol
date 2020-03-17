[{"SourceCode":"{\u0022ERC20.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.0;\\n\\nimport \\\u0022./IERC20.sol\\\u0022;\\nimport \\\u0022./SafeMath.sol\\\u0022;\\n\\n/**\\n * @dev Implementation of the \u0060IERC20\u0060 interface.\\n *\\n * This implementation is agnostic to the way tokens are created. This means\\n * that a supply mechanism has to be added in a derived contract using \u0060_mint\u0060.\\n * For a generic mechanism see \u0060ERC20Mintable\u0060.\\n *\\n * *For a detailed writeup see our guide [How to implement supply\\n * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*\\n *\\n * We have followed general OpenZeppelin guidelines: functions revert instead\\n * of returning \u0060false\u0060 on failure. This behavior is nonetheless conventional\\n * and does not conflict with the expectations of ERC20 applications.\\n *\\n * Additionally, an \u0060Approval\u0060 event is emitted on calls to \u0060transferFrom\u0060.\\n * This allows applications to reconstruct the allowance for all accounts just\\n * by listening to said events. Other implementations of the EIP may not emit\\n * these events, as it isn\\u0027t required by the specification.\\n *\\n * Finally, the non-standard \u0060decreaseAllowance\u0060 and \u0060increaseAllowance\u0060\\n * functions have been added to mitigate the well-known issues around setting\\n * allowances. See \u0060IERC20.approve\u0060.\\n */\\ncontract ERC20 is IERC20 {\\n    using SafeMath for uint256;\\n\\n    mapping (address =\\u003e uint256) private _balances;\\n\\n    mapping (address =\\u003e mapping (address =\\u003e uint256)) private _allowances;\\n\\n    uint256 private _totalSupply;\\n\\n    /**\\n     * @dev See \u0060IERC20.totalSupply\u0060.\\n     */\\n    function totalSupply() public view returns (uint256) {\\n        return _totalSupply;\\n    }\\n\\n    /**\\n     * @dev See \u0060IERC20.balanceOf\u0060.\\n     */\\n    function balanceOf(address account) public view returns (uint256) {\\n        return _balances[account];\\n    }\\n\\n    /**\\n     * @dev See \u0060IERC20.transfer\u0060.\\n     *\\n     * Requirements:\\n     *\\n     * - \u0060recipient\u0060 cannot be the zero address.\\n     * - the caller must have a balance of at least \u0060amount\u0060.\\n     */\\n    function transfer(address recipient, uint256 amount) public returns (bool) {\\n        _transfer(msg.sender, recipient, amount);\\n        return true;\\n    }\\n\\n    /**\\n     * @dev See \u0060IERC20.allowance\u0060.\\n     */\\n    function allowance(address owner, address spender) public view returns (uint256) {\\n        return _allowances[owner][spender];\\n    }\\n\\n    /**\\n     * @dev See \u0060IERC20.approve\u0060.\\n     *\\n     * Requirements:\\n     *\\n     * - \u0060spender\u0060 cannot be the zero address.\\n     */\\n    function approve(address spender, uint256 value) public returns (bool) {\\n        _approve(msg.sender, spender, value);\\n        return true;\\n    }\\n\\n    /**\\n     * @dev See \u0060IERC20.transferFrom\u0060.\\n     *\\n     * Emits an \u0060Approval\u0060 event indicating the updated allowance. This is not\\n     * required by the EIP. See the note at the beginning of \u0060ERC20\u0060;\\n     *\\n     * Requirements:\\n     * - \u0060sender\u0060 and \u0060recipient\u0060 cannot be the zero address.\\n     * - \u0060sender\u0060 must have a balance of at least \u0060value\u0060.\\n     * - the caller must have allowance for \u0060sender\u0060\\u0027s tokens of at least\\n     * \u0060amount\u0060.\\n     */\\n    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {\\n        _transfer(sender, recipient, amount);\\n        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));\\n        return true;\\n    }\\n\\n    /**\\n     * @dev Atomically increases the allowance granted to \u0060spender\u0060 by the caller.\\n     *\\n     * This is an alternative to \u0060approve\u0060 that can be used as a mitigation for\\n     * problems described in \u0060IERC20.approve\u0060.\\n     *\\n     * Emits an \u0060Approval\u0060 event indicating the updated allowance.\\n     *\\n     * Requirements:\\n     *\\n     * - \u0060spender\u0060 cannot be the zero address.\\n     */\\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\\n        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));\\n        return true;\\n    }\\n\\n    /**\\n     * @dev Atomically decreases the allowance granted to \u0060spender\u0060 by the caller.\\n     *\\n     * This is an alternative to \u0060approve\u0060 that can be used as a mitigation for\\n     * problems described in \u0060IERC20.approve\u0060.\\n     *\\n     * Emits an \u0060Approval\u0060 event indicating the updated allowance.\\n     *\\n     * Requirements:\\n     *\\n     * - \u0060spender\u0060 cannot be the zero address.\\n     * - \u0060spender\u0060 must have allowance for the caller of at least\\n     * \u0060subtractedValue\u0060.\\n     */\\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\\n        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));\\n        return true;\\n    }\\n\\n    /**\\n     * @dev Moves tokens \u0060amount\u0060 from \u0060sender\u0060 to \u0060recipient\u0060.\\n     *\\n     * This is internal function is equivalent to \u0060transfer\u0060, and can be used to\\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\\n     *\\n     * Emits a \u0060Transfer\u0060 event.\\n     *\\n     * Requirements:\\n     *\\n     * - \u0060sender\u0060 cannot be the zero address.\\n     * - \u0060recipient\u0060 cannot be the zero address.\\n     * - \u0060sender\u0060 must have a balance of at least \u0060amount\u0060.\\n     */\\n    function _transfer(address sender, address recipient, uint256 amount) internal {\\n        require(sender != address(0), \\\u0022ERC20: transfer from the zero address\\\u0022);\\n        require(recipient != address(0), \\\u0022ERC20: transfer to the zero address\\\u0022);\\n\\n        _balances[sender] = _balances[sender].sub(amount);\\n        _balances[recipient] = _balances[recipient].add(amount);\\n        emit Transfer(sender, recipient, amount);\\n    }\\n\\n    /** @dev Creates \u0060amount\u0060 tokens and assigns them to \u0060account\u0060, increasing\\n     * the total supply.\\n     *\\n     * Emits a \u0060Transfer\u0060 event with \u0060from\u0060 set to the zero address.\\n     *\\n     * Requirements\\n     *\\n     * - \u0060to\u0060 cannot be the zero address.\\n     */\\n    function _mint(address account, uint256 amount) internal {\\n        require(account != address(0), \\\u0022ERC20: mint to the zero address\\\u0022);\\n\\n        _totalSupply = _totalSupply.add(amount);\\n        _balances[account] = _balances[account].add(amount);\\n        emit Transfer(address(0), account, amount);\\n    }\\n\\n     /**\\n     * @dev Destoys \u0060amount\u0060 tokens from \u0060account\u0060, reducing the\\n     * total supply.\\n     *\\n     * Emits a \u0060Transfer\u0060 event with \u0060to\u0060 set to the zero address.\\n     *\\n     * Requirements\\n     *\\n     * - \u0060account\u0060 cannot be the zero address.\\n     * - \u0060account\u0060 must have at least \u0060amount\u0060 tokens.\\n     */\\n    function _burn(address account, uint256 value) internal {\\n        require(account != address(0), \\\u0022ERC20: burn from the zero address\\\u0022);\\n\\n        _totalSupply = _totalSupply.sub(value);\\n        _balances[account] = _balances[account].sub(value);\\n        emit Transfer(account, address(0), value);\\n    }\\n\\n    /**\\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the \u0060owner\u0060s tokens.\\n     *\\n     * This is internal function is equivalent to \u0060approve\u0060, and can be used to\\n     * e.g. set automatic allowances for certain subsystems, etc.\\n     *\\n     * Emits an \u0060Approval\u0060 event.\\n     *\\n     * Requirements:\\n     *\\n     * - \u0060owner\u0060 cannot be the zero address.\\n     * - \u0060spender\u0060 cannot be the zero address.\\n     */\\n    function _approve(address owner, address spender, uint256 value) internal {\\n        require(owner != address(0), \\\u0022ERC20: approve from the zero address\\\u0022);\\n        require(spender != address(0), \\\u0022ERC20: approve to the zero address\\\u0022);\\n\\n        _allowances[owner][spender] = value;\\n        emit Approval(owner, spender, value);\\n    }\\n\\n    /**\\n     * @dev Destoys \u0060amount\u0060 tokens from \u0060account\u0060.\u0060amount\u0060 is then deducted\\n     * from the caller\\u0027s allowance.\\n     *\\n     * See \u0060_burn\u0060 and \u0060_approve\u0060.\\n     */\\n    function _burnFrom(address account, uint256 amount) internal {\\n        _burn(account, amount);\\n        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));\\n    }\\n}\\n\\n\u0022},\u0022ERC20Detailed.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.0;\\n\\nimport \\\u0022./IERC20.sol\\\u0022;\\n\\n/**\\n * @dev Optional functions from the ERC20 standard.\\n */\\ncontract ERC20Detailed is IERC20 {\\n    string private _name;\\n    string private _symbol;\\n    uint8 private _decimals;\\n\\n    /**\\n     * @dev Sets the values for \u0060name\u0060, \u0060symbol\u0060, and \u0060decimals\u0060. All three of\\n     * these values are immutable: they can only be set once during\\n     * construction.\\n     */\\n    constructor (string memory name, string memory symbol, uint8 decimals) public {\\n        _name = name;\\n        _symbol = symbol;\\n        _decimals = decimals;\\n    }\\n\\n    /**\\n     * @dev Returns the name of the token.\\n     */\\n    function name() public view returns (string memory) {\\n        return _name;\\n    }\\n\\n    /**\\n     * @dev Returns the symbol of the token, usually a shorter version of the\\n     * name.\\n     */\\n    function symbol() public view returns (string memory) {\\n        return _symbol;\\n    }\\n\\n    /**\\n     * @dev Returns the number of decimals used to get its user representation.\\n     * For example, if \u0060decimals\u0060 equals \u00602\u0060, a balance of \u0060505\u0060 tokens should\\n     * be displayed to a user as \u00605,05\u0060 (\u0060505 / 10 ** 2\u0060).\\n     *\\n     * Tokens usually opt for a value of 18, imitating the relationship between\\n     * Ether and Wei.\\n     *\\n     * \\u003e Note that this information is only used for _display_ purposes: it in\\n     * no way affects any of the arithmetic of the contract, including\\n     * \u0060IERC20.balanceOf\u0060 and \u0060IERC20.transfer\u0060.\\n     */\\n    function decimals() public view returns (uint8) {\\n        return _decimals;\\n    }\\n}\\n\\n\u0022},\u0022IERC20.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.0;\\n\\n/**\\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\\n * the optional functions; to access them see \u0060ERC20Detailed\u0060.\\n */\\ninterface IERC20 {\\n    /**\\n     * @dev Returns the amount of tokens in existence.\\n     */\\n    function totalSupply() external view returns (uint256);\\n\\n    /**\\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\\n     */\\n    function balanceOf(address account) external view returns (uint256);\\n\\n    /**\\n     * @dev Moves \u0060amount\u0060 tokens from the caller\\u0027s account to \u0060recipient\u0060.\\n     *\\n     * Returns a boolean value indicating whether the operation succeeded.\\n     *\\n     * Emits a \u0060Transfer\u0060 event.\\n     */\\n    function transfer(address recipient, uint256 amount) external returns (bool);\\n\\n    /**\\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\\n     * allowed to spend on behalf of \u0060owner\u0060 through \u0060transferFrom\u0060. This is\\n     * zero by default.\\n     *\\n     * This value changes when \u0060approve\u0060 or \u0060transferFrom\u0060 are called.\\n     */\\n    function allowance(address owner, address spender) external view returns (uint256);\\n\\n    /**\\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\\u0027s tokens.\\n     *\\n     * Returns a boolean value indicating whether the operation succeeded.\\n     *\\n     * \\u003e Beware that changing an allowance with this method brings the risk\\n     * that someone may use both the old and the new allowance by unfortunate\\n     * transaction ordering. One possible solution to mitigate this race\\n     * condition is to first reduce the spender\\u0027s allowance to 0 and set the\\n     * desired value afterwards:\\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\\n     *\\n     * Emits an \u0060Approval\u0060 event.\\n     */\\n    function approve(address spender, uint256 amount) external returns (bool);\\n\\n    /**\\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\\u0027s\\n     * allowance.\\n     *\\n     * Returns a boolean value indicating whether the operation succeeded.\\n     *\\n     * Emits a \u0060Transfer\u0060 event.\\n     */\\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\\n\\n    /**\\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\\n     * another (\u0060to\u0060).\\n     *\\n     * Note that \u0060value\u0060 may be zero.\\n     */\\n    event Transfer(address indexed from, address indexed to, uint256 value);\\n\\n    /**\\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\\n     * a call to \u0060approve\u0060. \u0060value\u0060 is the new allowance.\\n     */\\n    event Approval(address indexed owner, address indexed spender, uint256 value);\\n}\\n\\n\u0022},\u0022SafeMath.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.0;\\n\\n/**\\n * @dev Wrappers over Solidity\\u0027s arithmetic operations with added overflow\\n * checks.\\n *\\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\\n * in bugs, because programmers usually assume that an overflow raises an\\n * error, which is the standard behavior in high level programming languages.\\n * \u0060SafeMath\u0060 restores this intuition by reverting the transaction when an\\n * operation overflows.\\n *\\n * Using this library instead of the unchecked operations eliminates an entire\\n * class of bugs, so it\\u0027s recommended to use it always.\\n */\\nlibrary SafeMath {\\n    /**\\n     * @dev Returns the addition of two unsigned integers, reverting on\\n     * overflow.\\n     *\\n     * Counterpart to Solidity\\u0027s \u0060\u002B\u0060 operator.\\n     *\\n     * Requirements:\\n     * - Addition cannot overflow.\\n     */\\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\\n        uint256 c = a \u002B b;\\n        require(c \\u003e= a, \\\u0022SafeMath: addition overflow\\\u0022);\\n\\n        return c;\\n    }\\n\\n    /**\\n     * @dev Returns the subtraction of two unsigned integers, reverting on\\n     * overflow (when the result is negative).\\n     *\\n     * Counterpart to Solidity\\u0027s \u0060-\u0060 operator.\\n     *\\n     * Requirements:\\n     * - Subtraction cannot overflow.\\n     */\\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\\n        require(b \\u003c= a, \\\u0022SafeMath: subtraction overflow\\\u0022);\\n        uint256 c = a - b;\\n\\n        return c;\\n    }\\n\\n    /**\\n     * @dev Returns the multiplication of two unsigned integers, reverting on\\n     * overflow.\\n     *\\n     * Counterpart to Solidity\\u0027s \u0060*\u0060 operator.\\n     *\\n     * Requirements:\\n     * - Multiplication cannot overflow.\\n     */\\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\\n        // Gas optimization: this is cheaper than requiring \\u0027a\\u0027 not being zero, but the\\n        // benefit is lost if \\u0027b\\u0027 is also tested.\\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\\n        if (a == 0) {\\n            return 0;\\n        }\\n\\n        uint256 c = a * b;\\n        require(c / a == b, \\\u0022SafeMath: multiplication overflow\\\u0022);\\n\\n        return c;\\n    }\\n\\n    /**\\n     * @dev Returns the integer division of two unsigned integers. Reverts on\\n     * division by zero. The result is rounded towards zero.\\n     *\\n     * Counterpart to Solidity\\u0027s \u0060/\u0060 operator. Note: this function uses a\\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\\n     * uses an invalid opcode to revert (consuming all remaining gas).\\n     *\\n     * Requirements:\\n     * - The divisor cannot be zero.\\n     */\\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\\n        // Solidity only automatically asserts when dividing by 0\\n        require(b \\u003e 0, \\\u0022SafeMath: division by zero\\\u0022);\\n        uint256 c = a / b;\\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\\u0027t hold\\n\\n        return c;\\n    }\\n\\n    /**\\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\\n     * Reverts when dividing by zero.\\n     *\\n     * Counterpart to Solidity\\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\\n     * invalid opcode to revert (consuming all remaining gas).\\n     *\\n     * Requirements:\\n     * - The divisor cannot be zero.\\n     */\\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\\n        require(b != 0, \\\u0022SafeMath: modulo by zero\\\u0022);\\n        return a % b;\\n    }\\n}\\n\\n\u0022},\u0022ULMCERC20Token.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.0;\\n\\nimport \\\u0022./ERC20.sol\\\u0022;\\nimport \\\u0022./ERC20Detailed.sol\\\u0022;\\n\\n/**\\n\\n */\\ncontract ULMC is ERC20, ERC20Detailed {\\n\\n    /**\\n     * @dev Constructor that gives msg.sender all of existing tokens.\\n     */\\n    constructor () public ERC20Detailed(\\\u0022UltraLink Machine System Ecological Rights Token\\\u0022, \\\u0022ULMC\\\u0022, 18) {\\n        _mint(msg.sender, 10000000000 * (10 ** uint256(decimals())));\\n    }\\n}\u0022}}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"ULMC","CompilerVersion":"v0.5.0\u002Bcommit.1d4f565a","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://dc0da6e852713f3d5f53d6542ff3f2dc60cd0efb7307f33f39369bf3baa39cd9"}]