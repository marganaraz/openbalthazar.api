[{"SourceCode":"pragma solidity 0.5.0;\r\n\r\n// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ninterface IERC20 {\r\n    function transfer(address to, uint256 value) external returns (bool);\r\n\r\n    function approve(address spender, uint256 value) external returns (bool);\r\n\r\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\r\n\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    function balanceOf(address who) external view returns (uint256);\r\n\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol\r\n\r\n/**\r\n * @title ERC20Detailed token\r\n * @dev The decimals are only for visualization purposes.\r\n * All the operations are done using the smallest and indivisible token unit,\r\n * just as on Ethereum all the operations are done in wei.\r\n */\r\ncontract ERC20Detailed is IERC20 {\r\n    string private _name;\r\n    string private _symbol;\r\n    uint8 private _decimals;\r\n\r\n    constructor (string memory name, string memory symbol, uint8 decimals) public {\r\n        _name = name;\r\n        _symbol = symbol;\r\n        _decimals = decimals;\r\n    }\r\n\r\n    /**\r\n     * @return the name of the token.\r\n     */\r\n    function name() public view returns (string memory) {\r\n        return _name;\r\n    }\r\n\r\n    /**\r\n     * @return the symbol of the token.\r\n     */\r\n    function symbol() public view returns (string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    /**\r\n     * @return the number of decimals of the token.\r\n     */\r\n    function decimals() public view returns (uint8) {\r\n        return _decimals;\r\n    }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/math/SafeMath.sol\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Unsigned math operations with safety checks that revert on error\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n    * @dev Multiplies two unsigned integers, reverts on overflow.\r\n    */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.\r\n    */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n    */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Adds two unsigned integers, reverts on overflow.\r\n    */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),\r\n    * reverts when dividing by zero.\r\n    */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol\r\n\r\n/**\r\n * @title Standard ERC20 token\r\n *\r\n * @dev Implementation of the basic standard token.\r\n * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md\r\n * Originally based on code by FirstBlood:\r\n * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol\r\n *\r\n * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for\r\n * all accounts just by listening to said events. Note that this isn\u0027t required by the specification, and other\r\n * compliant implementations may not do it.\r\n */\r\ncontract ERC20 is IERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    mapping (address =\u003E uint256) private _balances;\r\n\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) private _allowed;\r\n\r\n    uint256 private _totalSupply;\r\n\r\n    /**\r\n    * @dev Total number of tokens in existence\r\n    */\r\n    function totalSupply() public view returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    /**\r\n    * @dev Gets the balance of the specified address.\r\n    * @param owner The address to query the balance of.\r\n    * @return An uint256 representing the amount owned by the passed address.\r\n    */\r\n    function balanceOf(address owner) public view returns (uint256) {\r\n        return _balances[owner];\r\n    }\r\n\r\n    /**\r\n     * @dev Function to check the amount of tokens that an owner allowed to a spender.\r\n     * @param owner address The address which owns the funds.\r\n     * @param spender address The address which will spend the funds.\r\n     * @return A uint256 specifying the amount of tokens still available for the spender.\r\n     */\r\n    function allowance(address owner, address spender) public view returns (uint256) {\r\n        return _allowed[owner][spender];\r\n    }\r\n\r\n    /**\r\n    * @dev Transfer token for a specified address\r\n    * @param to The address to transfer to.\r\n    * @param value The amount to be transferred.\r\n    */\r\n    function transfer(address to, uint256 value) public returns (bool) {\r\n        _transfer(msg.sender, to, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\r\n     * Beware that changing an allowance with this method brings the risk that someone may use both the old\r\n     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\r\n     * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     * @param spender The address which will spend the funds.\r\n     * @param value The amount of tokens to be spent.\r\n     */\r\n    function approve(address spender, uint256 value) public returns (bool) {\r\n        require(spender != address(0));\r\n\r\n        _allowed[msg.sender][spender] = value;\r\n        emit Approval(msg.sender, spender, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Transfer tokens from one address to another.\r\n     * Note that while this function emits an Approval event, this is not required as per the specification,\r\n     * and other compliant implementations may not emit the event.\r\n     * @param from address The address which you want to send tokens from\r\n     * @param to address The address which you want to transfer to\r\n     * @param value uint256 the amount of tokens to be transferred\r\n     */\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool) {\r\n        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);\r\n        _transfer(from, to, value);\r\n        emit Approval(from, msg.sender, _allowed[from][msg.sender]);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Increase the amount of tokens that an owner allowed to a spender.\r\n     * approve should be called when allowed_[_spender] == 0. To increment\r\n     * allowed value is better to use this function to avoid 2 calls (and wait until\r\n     * the first transaction is mined)\r\n     * From MonolithDAO Token.sol\r\n     * Emits an Approval event.\r\n     * @param spender The address which will spend the funds.\r\n     * @param addedValue The amount of tokens to increase the allowance by.\r\n     */\r\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\r\n        require(spender != address(0));\r\n\r\n        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);\r\n        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Decrease the amount of tokens that an owner allowed to a spender.\r\n     * approve should be called when allowed_[_spender] == 0. To decrement\r\n     * allowed value is better to use this function to avoid 2 calls (and wait until\r\n     * the first transaction is mined)\r\n     * From MonolithDAO Token.sol\r\n     * Emits an Approval event.\r\n     * @param spender The address which will spend the funds.\r\n     * @param subtractedValue The amount of tokens to decrease the allowance by.\r\n     */\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\r\n        require(spender != address(0));\r\n\r\n        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);\r\n        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n    * @dev Transfer token for a specified addresses\r\n    * @param from The address to transfer from.\r\n    * @param to The address to transfer to.\r\n    * @param value The amount to be transferred.\r\n    */\r\n    function _transfer(address from, address to, uint256 value) internal {\r\n        require(to != address(0));\r\n\r\n        _balances[from] = _balances[from].sub(value);\r\n        _balances[to] = _balances[to].add(value);\r\n        emit Transfer(from, to, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Internal function that mints an amount of the token and assigns it to\r\n     * an account. This encapsulates the modification of balances such that the\r\n     * proper events are emitted.\r\n     * @param account The account that will receive the created tokens.\r\n     * @param value The amount that will be created.\r\n     */\r\n    function _mint(address account, uint256 value) internal {\r\n        require(account != address(0));\r\n\r\n        _totalSupply = _totalSupply.add(value);\r\n        _balances[account] = _balances[account].add(value);\r\n        emit Transfer(address(0), account, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Internal function that burns an amount of the token of a given\r\n     * account.\r\n     * @param account The account whose tokens will be burnt.\r\n     * @param value The amount that will be burnt.\r\n     */\r\n    function _burn(address account, uint256 value) internal {\r\n        require(account != address(0));\r\n\r\n        _totalSupply = _totalSupply.sub(value);\r\n        _balances[account] = _balances[account].sub(value);\r\n        emit Transfer(account, address(0), value);\r\n    }\r\n\r\n    /**\r\n     * @dev Internal function that burns an amount of the token of a given\r\n     * account, deducting from the sender\u0027s allowance for said account. Uses the\r\n     * internal burn function.\r\n     * Emits an Approval event (reflecting the reduced allowance).\r\n     * @param account The account whose tokens will be burnt.\r\n     * @param value The amount that will be burnt.\r\n     */\r\n    function _burnFrom(address account, uint256 value) internal {\r\n        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);\r\n        _burn(account, value);\r\n        emit Approval(account, msg.sender, _allowed[account][msg.sender]);\r\n    }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/access/Roles.sol\r\n\r\n/**\r\n * @title Roles\r\n * @dev Library for managing addresses assigned to a Role.\r\n */\r\nlibrary Roles {\r\n    struct Role {\r\n        mapping (address =\u003E bool) bearer;\r\n    }\r\n\r\n    /**\r\n     * @dev give an account access to this role\r\n     */\r\n    function add(Role storage role, address account) internal {\r\n        require(account != address(0));\r\n        require(!has(role, account));\r\n\r\n        role.bearer[account] = true;\r\n    }\r\n\r\n    /**\r\n     * @dev remove an account\u0027s access to this role\r\n     */\r\n    function remove(Role storage role, address account) internal {\r\n        require(account != address(0));\r\n        require(has(role, account));\r\n\r\n        role.bearer[account] = false;\r\n    }\r\n\r\n    /**\r\n     * @dev check if an account has this role\r\n     * @return bool\r\n     */\r\n    function has(Role storage role, address account) internal view returns (bool) {\r\n        require(account != address(0));\r\n        return role.bearer[account];\r\n    }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/access/roles/MinterRole.sol\r\n\r\ncontract MinterRole {\r\n    using Roles for Roles.Role;\r\n\r\n    event MinterAdded(address indexed account);\r\n    event MinterRemoved(address indexed account);\r\n\r\n    Roles.Role private _minters;\r\n\r\n    constructor () internal {\r\n        _addMinter(msg.sender);\r\n    }\r\n\r\n    modifier onlyMinter() {\r\n        require(isMinter(msg.sender));\r\n        _;\r\n    }\r\n\r\n    function isMinter(address account) public view returns (bool) {\r\n        return _minters.has(account);\r\n    }\r\n\r\n    function addMinter(address account) public onlyMinter {\r\n        _addMinter(account);\r\n    }\r\n\r\n    function renounceMinter() public {\r\n        _removeMinter(msg.sender);\r\n    }\r\n\r\n    function _addMinter(address account) internal {\r\n        _minters.add(account);\r\n        emit MinterAdded(account);\r\n    }\r\n\r\n    function _removeMinter(address account) internal {\r\n        _minters.remove(account);\r\n        emit MinterRemoved(account);\r\n    }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol\r\n\r\n/**\r\n * @title ERC20Mintable\r\n * @dev ERC20 minting logic\r\n */\r\ncontract ERC20Mintable is ERC20, MinterRole {\r\n    /**\r\n     * @dev Function to mint tokens\r\n     * @param to The address that will receive the minted tokens.\r\n     * @param value The amount of tokens to mint.\r\n     * @return A boolean that indicates if the operation was successful.\r\n     */\r\n    function mint(address to, uint256 value) public onlyMinter returns (bool) {\r\n        _mint(to, value);\r\n        return true;\r\n    }\r\n}\r\n\r\n/*\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with GSN meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\ncontract Context {\r\n    // Empty internal constructor, to prevent people from mistakenly deploying\r\n    // an instance of this contract, which should be used via inheritance.\r\n    constructor () internal { }\r\n    // solhint-disable-previous-line no-empty-blocks\r\n\r\n    function _msgSender() internal view returns (address payable) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}\r\n\r\n/**\r\n * @dev Extension of {ERC20} that allows token holders to destroy both their own\r\n * tokens and those that they have an allowance for, in a way that can be\r\n * recognized off-chain (via event analysis).\r\n */\r\ncontract ERC20Burnable is Context, ERC20 {\r\n    /**\r\n     * @dev Destroys \u0060amount\u0060 tokens from the caller.\r\n     *\r\n     * See {ERC20-_burn}.\r\n     */\r\n    function burn(uint256 amount) public {\r\n        _burn(_msgSender(), amount);\r\n    }\r\n\r\n    /**\r\n     * @dev See {ERC20-_burnFrom}.\r\n     */\r\n    function burnFrom(address account, uint256 amount) public {\r\n        _burnFrom(account, amount);\r\n    }\r\n}\r\n\r\n// File: contracts/Token.sol\r\n\r\ncontract Token is ERC20Detailed, ERC20Mintable, ERC20Burnable {\r\n\r\n  constructor() ERC20Detailed(\u0022Words by Toby Shorin\u0022, \u0022WORD\u0022, 0) public {\r\n  }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnFrom\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addMinter\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceMinter\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isMinter\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022MinterAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022MinterRemoved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Token","CompilerVersion":"v0.5.0\u002Bcommit.1d4f565a","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://b19d17c5a76d59b4d92fcb02a453fcaadd23597555af5ed9a4a25e0f2f828876"}]