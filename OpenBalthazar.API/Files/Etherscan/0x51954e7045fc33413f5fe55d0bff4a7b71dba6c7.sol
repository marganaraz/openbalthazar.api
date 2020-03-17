[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\n/*\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with GSN meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\ncontract Context {\r\n    // Empty internal constructor, to prevent people from mistakenly deploying\r\n    // an instance of this contract, which should be used via inheritance.\r\n    constructor () internal { }\r\n    // solhint-disable-previous-line no-empty-blocks\r\n\r\n    function _msgSender() internal view returns (address payable) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * \u0060SafeMath\u0060 restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060\u002B\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060*\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP. Does not include\r\n * the optional functions; to access them see {ERC20Detailed}.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from the caller\u0027s account to \u0060recipient\u0060.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\r\n     * allowed to spend on behalf of \u0060owner\u0060 through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\r\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\r\n     * another (\u0060to\u0060).\r\n     *\r\n     * Note that \u0060value\u0060 may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\r\n     * a call to {approve}. \u0060value\u0060 is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n/**\r\n * @dev Implementation of the {IERC20} interface.\r\n *\r\n * This implementation is agnostic to the way tokens are created. This means\r\n * that a supply mechanism has to be added in a derived contract using {_mint}.\r\n * For a generic mechanism see {ERC20Mintable}.\r\n *\r\n * TIP: For a detailed writeup see our guide\r\n * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How\r\n * to implement supply mechanisms].\r\n *\r\n * We have followed general OpenZeppelin guidelines: functions revert instead\r\n * of returning \u0060false\u0060 on failure. This behavior is nonetheless conventional\r\n * and does not conflict with the expectations of ERC20 applications.\r\n *\r\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\r\n * This allows applications to reconstruct the allowance for all accounts just\r\n * by listening to said events. Other implementations of the EIP may not emit\r\n * these events, as it isn\u0027t required by the specification.\r\n *\r\n * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}\r\n * functions have been added to mitigate the well-known issues around setting\r\n * allowances. See {IERC20-approve}.\r\n */\r\ncontract ERC20 is Context, IERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    mapping (address =\u003E uint256) private _balances;\r\n\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) private _allowances;\r\n\r\n    uint256 private _totalSupply;\r\n\r\n    /**\r\n     * @dev See {IERC20-totalSupply}.\r\n     */\r\n    function totalSupply() public view returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-balanceOf}.\r\n     */\r\n    function balanceOf(address account) public view returns (uint256) {\r\n        return _balances[account];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transfer}.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060recipient\u0060 cannot be the zero address.\r\n     * - the caller must have a balance of at least \u0060amount\u0060.\r\n     */\r\n    function transfer(address recipient, uint256 amount) public returns (bool) {\r\n        _transfer(_msgSender(), recipient, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-allowance}.\r\n     */\r\n    function allowance(address owner, address spender) public view returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-approve}.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060spender\u0060 cannot be the zero address.\r\n     */\r\n    function approve(address spender, uint256 amount) public returns (bool) {\r\n        _approve(_msgSender(), spender, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transferFrom}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance. This is not\r\n     * required by the EIP. See the note at the beginning of {ERC20};\r\n     *\r\n     * Requirements:\r\n     * - \u0060sender\u0060 and \u0060recipient\u0060 cannot be the zero address.\r\n     * - \u0060sender\u0060 must have a balance of at least \u0060amount\u0060.\r\n     * - the caller must have allowance for \u0060sender\u0060\u0027s tokens of at least\r\n     * \u0060amount\u0060.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {\r\n        _transfer(sender, recipient, amount);\r\n        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, \u0022ERC20: transfer amount exceeds allowance\u0022));\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically increases the allowance granted to \u0060spender\u0060 by the caller.\r\n     *\r\n     * This is an alternative to {approve} that can be used as a mitigation for\r\n     * problems described in {IERC20-approve}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060spender\u0060 cannot be the zero address.\r\n     */\r\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\r\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically decreases the allowance granted to \u0060spender\u0060 by the caller.\r\n     *\r\n     * This is an alternative to {approve} that can be used as a mitigation for\r\n     * problems described in {IERC20-approve}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060spender\u0060 cannot be the zero address.\r\n     * - \u0060spender\u0060 must have allowance for the caller of at least\r\n     * \u0060subtractedValue\u0060.\r\n     */\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\r\n        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, \u0022ERC20: decreased allowance below zero\u0022));\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Moves tokens \u0060amount\u0060 from \u0060sender\u0060 to \u0060recipient\u0060.\r\n     *\r\n     * This is internal function is equivalent to {transfer}, and can be used to\r\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060sender\u0060 cannot be the zero address.\r\n     * - \u0060recipient\u0060 cannot be the zero address.\r\n     * - \u0060sender\u0060 must have a balance of at least \u0060amount\u0060.\r\n     */\r\n    function _transfer(address sender, address recipient, uint256 amount) internal {\r\n        require(sender != address(0), \u0022ERC20: transfer from the zero address\u0022);\r\n        require(recipient != address(0), \u0022ERC20: transfer to the zero address\u0022);\r\n\r\n        _balances[sender] = _balances[sender].sub(amount, \u0022ERC20: transfer amount exceeds balance\u0022);\r\n        _balances[recipient] = _balances[recipient].add(amount);\r\n        emit Transfer(sender, recipient, amount);\r\n    }\r\n\r\n    /** @dev Creates \u0060amount\u0060 tokens and assigns them to \u0060account\u0060, increasing\r\n     * the total supply.\r\n     *\r\n     * Emits a {Transfer} event with \u0060from\u0060 set to the zero address.\r\n     *\r\n     * Requirements\r\n     *\r\n     * - \u0060to\u0060 cannot be the zero address.\r\n     */\r\n    function _mint(address account, uint256 amount) internal {\r\n        require(account != address(0), \u0022ERC20: mint to the zero address\u0022);\r\n\r\n        _totalSupply = _totalSupply.add(amount);\r\n        _balances[account] = _balances[account].add(amount);\r\n        emit Transfer(address(0), account, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Destroys \u0060amount\u0060 tokens from \u0060account\u0060, reducing the\r\n     * total supply.\r\n     *\r\n     * Emits a {Transfer} event with \u0060to\u0060 set to the zero address.\r\n     *\r\n     * Requirements\r\n     *\r\n     * - \u0060account\u0060 cannot be the zero address.\r\n     * - \u0060account\u0060 must have at least \u0060amount\u0060 tokens.\r\n     */\r\n    function _burn(address account, uint256 amount) internal {\r\n        require(account != address(0), \u0022ERC20: burn from the zero address\u0022);\r\n\r\n        _balances[account] = _balances[account].sub(amount, \u0022ERC20: burn amount exceeds balance\u0022);\r\n        _totalSupply = _totalSupply.sub(amount);\r\n        emit Transfer(account, address(0), amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the \u0060owner\u0060s tokens.\r\n     *\r\n     * This is internal function is equivalent to \u0060approve\u0060, and can be used to\r\n     * e.g. set automatic allowances for certain subsystems, etc.\r\n     *\r\n     * Emits an {Approval} event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - \u0060owner\u0060 cannot be the zero address.\r\n     * - \u0060spender\u0060 cannot be the zero address.\r\n     */\r\n    function _approve(address owner, address spender, uint256 amount) internal {\r\n        require(owner != address(0), \u0022ERC20: approve from the zero address\u0022);\r\n        require(spender != address(0), \u0022ERC20: approve to the zero address\u0022);\r\n\r\n        _allowances[owner][spender] = amount;\r\n        emit Approval(owner, spender, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Destroys \u0060amount\u0060 tokens from \u0060account\u0060.\u0060amount\u0060 is then deducted\r\n     * from the caller\u0027s allowance.\r\n     *\r\n     * See {_burn} and {_approve}.\r\n     */\r\n    function _burnFrom(address account, uint256 amount) internal {\r\n        _burn(account, amount);\r\n        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, \u0022ERC20: burn amount exceeds allowance\u0022));\r\n    }\r\n}\r\n\r\n/**\r\n * @dev Extension of {ERC20} that allows token holders to destroy both their own\r\n * tokens and those that they have an allowance for, in a way that can be\r\n * recognized off-chain (via event analysis).\r\n */\r\ncontract ERC20Burnable is Context, ERC20 {\r\n    /**\r\n     * @dev Destroys \u0060amount\u0060 tokens from the caller.\r\n     *\r\n     * See {ERC20-_burn}.\r\n     */\r\n    function burn(uint256 amount) public {\r\n        _burn(_msgSender(), amount);\r\n    }\r\n\r\n    /**\r\n     * @dev See {ERC20-_burnFrom}.\r\n     */\r\n    function burnFrom(address account, uint256 amount) public {\r\n        _burnFrom(account, amount);\r\n    }\r\n}\r\n\r\ncontract offerToken is ERC20Burnable {\r\n    string public name; // name for offerToken registration\r\n    string public symbol; // symbol for offerToken registration\r\n    string public offer; // stored offerToken terms / e.g., IPFS hash\r\n    uint256 public rate; // mint rate amount of offerToken to ether (\u039E) / e.g., \u002710\u0027 = 1 ETH mints 10 offerToken\r\n    uint256 public min; // minimum amount of OfferToken required to redeem offer / e.g., \u00271\u0027 offerToken to burn and redeem stored offer\r\n    uint256 public decimals; // default \u002718\u0027 decimals to mirror ether-wei factoring in offerToken\r\n    address payable public offeror; // public address storing terms for offerToken redemption  \r\n    bool public closed; // public status of offer closure / default = \u0022false\u0022 / adjustable by offeror\r\n    \r\n    uint256 public RR; // counter for offerToken redemption requests\r\n    \r\n    mapping (uint256 =\u003E requests) public redemptions; \r\n    \r\n    struct requests { // RR: redemption requests stored on burn of offerToken at registered rate\r\n        address requester; \r\n        string details; \r\n        string response; \r\n        string review;\r\n        uint256 rNumber; \r\n        uint256 timeStamp;  \r\n        bool responded;\r\n    }\r\n    \r\n    constructor(\r\n        string memory _name, \r\n        string memory _symbol, \r\n        string memory _offer, \r\n        uint256 _init, \r\n        uint256 _rate,\r\n        uint256 _min,\r\n        uint8 _decimals, \r\n        address payable _offeror) public {\r\n        name = _name;\r\n        symbol = _symbol;\r\n        offer = _offer;\r\n        rate = _rate;\r\n        min = _min;\r\n        decimals = _decimals;\r\n        offeror = _offeror;\r\n        \r\n        _mint(offeror, _init); // mint offeror designated initial amount of offerToken \r\n    }\r\n    \r\n    modifier onlyOfferor {\r\n    \trequire(msg.sender == offeror, \u0022offerToken: onlyOfferor - not offeror\u0022);\r\n   \t_;\r\n    }\r\n    \r\n    function adjustOfferRate(uint256 newRate) public onlyOfferor { // offeror can adjust rate between ether (\u039E) and offerToken\r\n        rate = newRate;\r\n    }\r\n    \r\n    function updateOfferStatus(bool offerClosed) public onlyOfferor { // offeror can open and close offer\r\n        closed = offerClosed;\r\n    }\r\n    \r\n    function buyOfferToken() public payable { // public can swap ether (\u039E) for offerToken at registered rate\r\n        require(closed == false); // offer must be open to buy redemption units\r\n        \r\n        _mint(msg.sender, msg.value.mul(rate)); // mints offerToken in exchange for ether (\u039E) msg.value at offer rate\r\n        offeror.transfer(msg.value); // forwards ether (\u039E) to offeror \r\n    }\r\n    \r\n    function redeemOfferToken(string memory details) public {\r\n        _burn(_msgSender(), min); // redeem Offertoken at minimum burn rate \r\n        \r\n        uint256 rNumber = RR.add(1); \r\n        \r\n        RR = RR.add(1); // counts new entry to redemption counter \r\n        \r\n        redemptions[rNumber] = requests( \r\n            msg.sender,\r\n            details,\r\n            \u0022PENDING\u0022,\r\n            \u0022RESERVED\u0022,\r\n            rNumber,\r\n            now,\r\n            false);\r\n    }\r\n    \r\n    function writeRedemptionResponse(uint256 rNumber, string memory response) public onlyOfferor {\r\n        requests storage rr = redemptions[rNumber]; // retrieve RR data\r\n        \r\n        redemptions[rNumber] = requests( \r\n            rr.requester,\r\n            rr.details,\r\n            response,\r\n            rr.review,\r\n            rNumber,\r\n            rr.timeStamp,\r\n            true);\r\n    }\r\n    \r\n    function writeRedemptionReview(uint256 rNumber, string memory review) public {\r\n        requests storage rr = redemptions[rNumber]; // retrieve RR data\r\n        \r\n        require(msg.sender == rr.requester); // only requester can store review of redemption responses\r\n        require(rr.responded == true); // offeror response must be provided prior to review\r\n\r\n        redemptions[rNumber] = requests( \r\n            rr.requester,\r\n            rr.details,\r\n            rr.response,\r\n            review,\r\n            rNumber,\r\n            rr.timeStamp,\r\n            true);\r\n   }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022rate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022closed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022offeror\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022details\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022redeemOfferToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnFrom\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022buyOfferToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022rNumber\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022review\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022writeRedemptionReview\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022rNumber\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022response\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022writeRedemptionResponse\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022RR\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022redemptions\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022requester\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022details\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022response\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022review\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022rNumber\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022timeStamp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022responded\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022offer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newRate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022adjustOfferRate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022offerClosed\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022updateOfferStatus\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022min\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_offer\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_init\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_rate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_min\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_decimals\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022_offeror\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"offerToken","CompilerVersion":"v0.5.9\u002Bcommit.e560f70d","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"0000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000001800000000000000000000000000000000000000000000000008ac7230489e80000000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000008ac7230489e8000000000000000000000000000000000000000000000000000000000000000000120000000000000000000000001c0aa8ccd568d90d61659f060d1bfb1e6f855a20000000000000000000000000000000000000000000000000000000000000000f4f6666657220666f7220476f6f6473000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000054f4646455200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000674f666665726f72207368616c6c2064656c69766572204172746973616e204c7574657320313a3120696e2065786368616e676520666f72204f4646455220546f6b656e20746f20636f6e746163742064657461696c6564206f6e206275726e207265717565737400000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://02c3d18c09bd1e6f1d39ae8cbc2ce5667204f54b165ea241c0d88e4ecd00a51a"}]