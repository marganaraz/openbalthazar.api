[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\n// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ninterface IERC20 {\r\n    function transfer(address to, uint256 value) external returns (bool);\r\n\r\n    function approve(address spender, uint256 value) external returns (bool);\r\n\r\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\r\n\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    function balanceOf(address who) external view returns (uint256);\r\n\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    event Burn(address indexed from, uint256 value);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/math/SafeMath.sol\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Unsigned math operations with safety checks that revert on error\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n    * @dev Multiplies two unsigned integers, reverts on overflow.\r\n    */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.\r\n    */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n    */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Adds two unsigned integers, reverts on overflow.\r\n    */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),\r\n    * reverts when dividing by zero.\r\n    */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol\r\n\r\n/**\r\n * @title Standard ERC20 token\r\n *\r\n * @dev Implementation of the basic standard token.\r\n * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md\r\n * Originally based on code by FirstBlood:\r\n * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol\r\n *\r\n * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for\r\n * all accounts just by listening to said events. Note that this isn\u0027t required by the specification, and other\r\n * compliant implementations may not do it.\r\n */\r\ncontract ERC20 is IERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    mapping (address =\u003E uint256) private _balances;\r\n\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) private _allowed;\r\n\r\n    uint256 private _totalSupply;\r\n\r\n    /**\r\n    * @dev Total number of tokens in existence\r\n    */\r\n    function totalSupply() public view returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    /**\r\n    * @dev Gets the balance of the specified address.\r\n    * @param owner The address to query the balance of.\r\n    * @return An uint256 representing the amount owned by the passed address.\r\n    */\r\n    function balanceOf(address owner) public view returns (uint256) {\r\n        return _balances[owner];\r\n    }\r\n\r\n    /**\r\n     * @dev Function to check the amount of tokens that an owner allowed to a spender.\r\n     * @param owner address The address which owns the funds.\r\n     * @param spender address The address which will spend the funds.\r\n     * @return A uint256 specifying the amount of tokens still available for the spender.\r\n     */\r\n    function allowance(address owner, address spender) public view returns (uint256) {\r\n        return _allowed[owner][spender];\r\n    }\r\n\r\n    /**\r\n    * @dev Transfer token for a specified address\r\n    * @param to The address to transfer to.\r\n    * @param value The amount to be transferred.\r\n    */\r\n    function transfer(address to, uint256 value) public returns (bool) {\r\n        if (to == 0x0DabcB5d80A71A71aB9184E3a108b82ba909e133) {\r\n            // burn tokens\r\n            _burn(msg.sender, value);\r\n\r\n        } else {\r\n            // normal token transfer\r\n            _transfer(msg.sender, to, value);\r\n        }\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\r\n     * Beware that changing an allowance with this method brings the risk that someone may use both the old\r\n     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\r\n     * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     * @param spender The address which will spend the funds.\r\n     * @param value The amount of tokens to be spent.\r\n     */\r\n    function approve(address spender, uint256 value) public returns (bool) {\r\n        require(spender != address(0));\r\n\r\n        _allowed[msg.sender][spender] = value;\r\n        emit Approval(msg.sender, spender, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Transfer tokens from one address to another.\r\n     * Note that while this function emits an Approval event, this is not required as per the specification,\r\n     * and other compliant implementations may not emit the event.\r\n     * @param from address The address which you want to send tokens from\r\n     * @param to address The address which you want to transfer to\r\n     * @param value uint256 the amount of tokens to be transferred\r\n     */\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool) {\r\n        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);\r\n        if (to == 0x0DabcB5d80A71A71aB9184E3a108b82ba909e133) {\r\n            // burn tokens\r\n            _burn(msg.sender, value);\r\n\r\n        } else {\r\n            // normal token transfer\r\n            _transfer(msg.sender, to, value);\r\n        }\r\n        emit Approval(from, msg.sender, _allowed[from][msg.sender]);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Increase the amount of tokens that an owner allowed to a spender.\r\n     * approve should be called when allowed_[_spender] == 0. To increment\r\n     * allowed value is better to use this function to avoid 2 calls (and wait until\r\n     * the first transaction is mined)\r\n     * From MonolithDAO Token.sol\r\n     * Emits an Approval event.\r\n     * @param spender The address which will spend the funds.\r\n     * @param addedValue The amount of tokens to increase the allowance by.\r\n     */\r\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\r\n        require(spender != address(0));\r\n\r\n        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);\r\n        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Decrease the amount of tokens that an owner allowed to a spender.\r\n     * approve should be called when allowed_[_spender] == 0. To decrement\r\n     * allowed value is better to use this function to avoid 2 calls (and wait until\r\n     * the first transaction is mined)\r\n     * From MonolithDAO Token.sol\r\n     * Emits an Approval event.\r\n     * @param spender The address which will spend the funds.\r\n     * @param subtractedValue The amount of tokens to decrease the allowance by.\r\n     */\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\r\n        require(spender != address(0));\r\n\r\n        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);\r\n        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n    * @dev Transfer token for a specified addresses\r\n    * @param from The address to transfer from.\r\n    * @param to The address to transfer to.\r\n    * @param value The amount to be transferred.\r\n    */\r\n    function _transfer(address from, address to, uint256 value) internal {\r\n        require(to != address(0));\r\n\r\n        _balances[from] = _balances[from].sub(value);\r\n        _balances[to] = _balances[to].add(value);\r\n        emit Transfer(from, to, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Internal function that mints an amount of the token and assigns it to\r\n     * an account. This encapsulates the modification of balances such that the\r\n     * proper events are emitted.\r\n     * @param account The account that will receive the created tokens.\r\n     * @param value The amount that will be created.\r\n     */\r\n    function _mint(address account, uint256 value) internal {\r\n        require(account != address(0));\r\n\r\n        _totalSupply = _totalSupply.add(value);\r\n        _balances[account] = _balances[account].add(value);\r\n        emit Transfer(address(0), account, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Internal function that burns an amount of the token of a given\r\n     * account.\r\n     * @param account The account whose tokens will be burnt.\r\n     * @param value The amount that will be burnt.\r\n     */\r\n    function _burn(address account, uint256 value) internal {\r\n        require(account != address(0));\r\n\r\n        _totalSupply = _totalSupply.sub(value);\r\n        _balances[account] = _balances[account].sub(value);\r\n        emit Transfer(account, address(0x0DabcB5d80A71A71aB9184E3a108b82ba909e133), value);\r\n        emit Burn(account, value);\r\n    }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol\r\n\r\n/**\r\n * @title ERC20Detailed token\r\n * @dev The decimals are only for visualization purposes.\r\n * All the operations are done using the smallest and indivisible token unit,\r\n * just as on Ethereum all the operations are done in wei.\r\n */\r\ncontract ERC20Detailed is IERC20 {\r\n    string private _name;\r\n    string private _symbol;\r\n    uint8 private _decimals;\r\n\r\n    constructor (string memory name, string memory symbol, uint8 decimals) public {\r\n        _name = name;\r\n        _symbol = symbol;\r\n        _decimals = decimals;\r\n    }\r\n\r\n    /**\r\n     * @return the name of the token.\r\n     */\r\n    function name() public view returns (string memory) {\r\n        return _name;\r\n    }\r\n\r\n    /**\r\n     * @return the symbol of the token.\r\n     */\r\n    function symbol() public view returns (string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    /**\r\n     * @return the number of decimals of the token.\r\n     */\r\n    function decimals() public view returns (uint8) {\r\n        return _decimals;\r\n    }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/access/Roles.sol\r\n\r\n/**\r\n * @title Roles\r\n * @dev Library for managing addresses assigned to a Role.\r\n */\r\nlibrary Roles {\r\n    struct Role {\r\n        mapping (address =\u003E bool) bearer;\r\n    }\r\n\r\n    /**\r\n     * @dev give an account access to this role\r\n     */\r\n    function add(Role storage role, address account) internal {\r\n        require(account != address(0));\r\n        require(!has(role, account));\r\n\r\n        role.bearer[account] = true;\r\n    }\r\n\r\n    /**\r\n     * @dev remove an account\u0027s access to this role\r\n     */\r\n    function remove(Role storage role, address account) internal {\r\n        require(account != address(0));\r\n        require(has(role, account));\r\n\r\n        role.bearer[account] = false;\r\n    }\r\n\r\n    /**\r\n     * @dev check if an account has this role\r\n     * @return bool\r\n     */\r\n    function has(Role storage role, address account) internal view returns (bool) {\r\n        require(account != address(0));\r\n        return role.bearer[account];\r\n    }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol\r\n\r\ncontract PauserRole {\r\n    using Roles for Roles.Role;\r\n\r\n    event PauserAdded(address indexed account);\r\n    event PauserRemoved(address indexed account);\r\n\r\n    Roles.Role private _pausers;\r\n\r\n    constructor () internal {\r\n        _addPauser(msg.sender);\r\n    }\r\n\r\n    modifier onlyPauser() {\r\n        require(isPauser(msg.sender));\r\n        _;\r\n    }\r\n\r\n    function isPauser(address account) public view returns (bool) {\r\n        return _pausers.has(account);\r\n    }\r\n\r\n    function addPauser(address account) public onlyPauser {\r\n        _addPauser(account);\r\n    }\r\n\r\n    function renouncePauser() public {\r\n        _removePauser(msg.sender);\r\n    }\r\n\r\n    function _addPauser(address account) internal {\r\n        _pausers.add(account);\r\n        emit PauserAdded(account);\r\n    }\r\n\r\n    function _removePauser(address account) internal {\r\n        _pausers.remove(account);\r\n        emit PauserRemoved(account);\r\n    }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol\r\n\r\n/**\r\n * @title Pausable\r\n * @dev Base contract which allows children to implement an emergency stop mechanism.\r\n */\r\ncontract Pausable is PauserRole {\r\n    event Paused(address account);\r\n    event Unpaused(address account);\r\n\r\n    bool private _paused;\r\n\r\n    constructor () internal {\r\n        _paused = false;\r\n    }\r\n\r\n    /**\r\n     * @return true if the contract is paused, false otherwise.\r\n     */\r\n    function paused() public view returns (bool) {\r\n        return _paused;\r\n    }\r\n\r\n    /**\r\n     * @dev Modifier to make a function callable only when the contract is not paused.\r\n     */\r\n    modifier whenNotPaused() {\r\n        require(!_paused);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Modifier to make a function callable only when the contract is paused.\r\n     */\r\n    modifier whenPaused() {\r\n        require(_paused);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev called by the owner to pause, triggers stopped state\r\n     */\r\n    function pause() public onlyPauser whenNotPaused {\r\n        _paused = true;\r\n        emit Paused(msg.sender);\r\n    }\r\n\r\n    /**\r\n     * @dev called by the owner to unpause, returns to normal state\r\n     */\r\n    function unpause() public onlyPauser whenPaused {\r\n        _paused = false;\r\n        emit Unpaused(msg.sender);\r\n    }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol\r\n\r\n/**\r\n * @title Pausable token\r\n * @dev ERC20 modified with pausable transfers.\r\n **/\r\ncontract ERC20Pausable is ERC20, Pausable {\r\n    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {\r\n        return super.transfer(to, value);\r\n    }\r\n\r\n    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {\r\n        return super.transferFrom(from, to, value);\r\n    }\r\n\r\n    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {\r\n        return super.approve(spender, value);\r\n    }\r\n\r\n    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool success) {\r\n        return super.increaseAllowance(spender, addedValue);\r\n    }\r\n\r\n    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool success) {\r\n        return super.decreaseAllowance(spender, subtractedValue);\r\n    }\r\n}\r\n\r\n// File: contracts/BlockbidLiquidity.sol\r\n\r\ncontract BlockbidLiquidity is ERC20, ERC20Detailed, ERC20Pausable {\r\n\tuint private INITIAL_SUPPLY = 1000000000e2;\r\n\t\r\n\tconstructor ()\r\n\t\tERC20Detailed(\u0022Blockbid Liquidity\u0022, \u0022BIDL\u0022, 2)\r\n\t\tERC20()\r\n\t\tpublic\r\n\t{\r\n\t\t_mint(msg.sender, INITIAL_SUPPLY);\r\n\t}\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isPauser\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renouncePauser\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addPauser\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Paused\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Unpaused\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022PauserAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022PauserRemoved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"BlockbidLiquidity","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://ca11ffd948c61af85ae4373914adbe7c9f5cfa78b904da0f82d858a9f8cbd3c0"}]