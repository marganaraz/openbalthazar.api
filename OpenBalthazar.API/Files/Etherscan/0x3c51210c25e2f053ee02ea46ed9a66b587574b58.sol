[{"SourceCode":"pragma solidity ^0.5.1;\r\n/**\r\n* this is the official contract deployed for XLG token \r\n* all code is pulled from the open-zeplin github and then flattened into one file. \r\n*/\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that revert on error\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n    * @dev Multiplies two numbers, reverts on overflow.\r\n    */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.\r\n    */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n    */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Adds two numbers, reverts on overflow.\r\n    */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),\r\n    * reverts when dividing by zero.\r\n    */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ninterface IERC20 {\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    function balanceOf(address who) external view returns (uint256);\r\n\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    function transfer(address to, uint256 value) external returns (bool);\r\n\r\n    function approve(address spender, uint256 value) external returns (bool);\r\n\r\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n/**\r\n * @title Standard ERC20 token\r\n * @dev Implementation of the basic standard token.\r\n * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md\r\n * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol\r\n *\r\n * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for\r\n * all accounts just by listening to said events. Note that this isn\u0027t required by the specification, and other\r\n * compliant implementations may not do it.\r\n */\r\ncontract ERC20 is IERC20 {\r\n    using SafeMath for uint256;\r\n    mapping (address =\u003E uint256) private _balances;\r\n\r\n    mapping (address =\u003E mapping (address =\u003E uint256)) private _allowed;\r\n\r\n    uint256 private _totalSupply;\r\n    string private _name;\r\n    string private _symbol;\r\n    uint8 private _decimals;\r\n\r\n    constructor (string memory name, string memory symbol, uint8 decimals) public {\r\n        _name = name;\r\n        _symbol = symbol;\r\n        _decimals = decimals;\r\n    }\r\n\r\n    /**\r\n     * @return the name of the token.\r\n     */\r\n    function name() public view returns (string memory) {\r\n        return _name;\r\n    }\r\n\r\n    /**\r\n     * @return the symbol of the token.\r\n     */\r\n    function symbol() public view returns (string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    /**\r\n     * @return the number of decimals of the token.\r\n     */\r\n    function decimals() public view returns (uint8) {\r\n        return _decimals;\r\n    }\r\n\r\n    /**\r\n    * @dev Total number of tokens in existence\r\n    */\r\n    function totalSupply() public view returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    /**\r\n    * @dev Gets the balance of the specified address.\r\n    * @param owner The address to query the balance of.\r\n    * @return An uint256 representing the amount owned by the passed address.\r\n    */\r\n    function balanceOf(address owner) public view returns (uint256) {\r\n        return _balances[owner];\r\n    }\r\n\r\n    /**\r\n     * @dev Function to check the amount of tokens that an owner allowed to a spender.\r\n     * @param owner address The address which owns the funds.\r\n     * @param spender address The address which will spend the funds.\r\n     * @return A uint256 specifying the amount of tokens still available for the spender.\r\n     */\r\n    function allowance(address owner, address spender) public view returns (uint256) {\r\n        return _allowed[owner][spender];\r\n    }\r\n\r\n    /**\r\n    * @dev Transfer token for a specified address\r\n    * @param to The address to transfer to.\r\n    * @param value The amount to be transferred.\r\n    */\r\n    function transfer(address to, uint256 value) public returns (bool) {\r\n        _transfer(msg.sender, to, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n    * @dev Token that can be irreversibly burned (destroyed).\r\n    */\r\n    function burn(uint256 value) public {\r\n        _burn(msg.sender, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Burns a specific amount of tokens from the target address and decrements allowance\r\n     * @param from address The address which you want to send tokens from\r\n     * @param value uint256 The amount of token to be burned\r\n     */\r\n    function burnFrom(address from, uint256 value) public {\r\n        _burnFrom(from, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\r\n     * Beware that changing an allowance with this method brings the risk that someone may use both the old\r\n     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\r\n     * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     * @param spender The address which will spend the funds.\r\n     * @param value The amount of tokens to be spent.\r\n     */\r\n    function approve(address spender, uint256 value) public returns (bool) {\r\n        require(spender != address(0));\r\n\r\n        _allowed[msg.sender][spender] = value;\r\n        emit Approval(msg.sender, spender, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Transfer tokens from one address to another.\r\n     * Note that while this function emits an Approval event, this is not required as per the specification,\r\n     * and other compliant implementations may not emit the event.\r\n     * @param from address The address which you want to send tokens from\r\n     * @param to address The address which you want to transfer to\r\n     * @param value uint256 the amount of tokens to be transferred\r\n     */\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool) {\r\n        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);\r\n        _transfer(from, to, value);\r\n        emit Approval(from, msg.sender, _allowed[from][msg.sender]);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Increase the amount of tokens that an owner allowed to a spender.\r\n     * approve should be called when allowed_[_spender] == 0. To increment\r\n     * allowed value is better to use this function to avoid 2 calls (and wait until\r\n     * the first transaction is mined)\r\n     * From MonolithDAO Token.sol\r\n     * Emits an Approval event.\r\n     * @param spender The address which will spend the funds.\r\n     * @param addedValue The amount of tokens to increase the allowance by.\r\n     */\r\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\r\n        require(spender != address(0));\r\n\r\n        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);\r\n        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Decrease the amount of tokens that an owner allowed to a spender.\r\n     * approve should be called when allowed_[_spender] == 0. To decrement\r\n     * allowed value is better to use this function to avoid 2 calls (and wait until\r\n     * the first transaction is mined)\r\n     * From MonolithDAO Token.sol\r\n     * Emits an Approval event.\r\n     * @param spender The address which will spend the funds.\r\n     * @param subtractedValue The amount of tokens to decrease the allowance by.\r\n     */\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\r\n        require(spender != address(0));\r\n\r\n        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);\r\n        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n    * @dev Transfer token for a specified addresses\r\n    * @param from The address to transfer from.\r\n    * @param to The address to transfer to.\r\n    * @param value The amount to be transferred.\r\n    */\r\n    function _transfer(address from, address to, uint256 value) internal {\r\n        require(to != address(0));\r\n\r\n        _balances[from] = _balances[from].sub(value);\r\n        _balances[to] = _balances[to].add(value);\r\n        emit Transfer(from, to, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Internal function that mints an amount of the token and assigns it to\r\n     * an account. This encapsulates the modification of balances such that the\r\n     * proper events are emitted.\r\n     * @param account The account that will receive the created tokens.\r\n     * @param value The amount that will be created.\r\n     */\r\n    function _mint(address account, uint256 value) internal {\r\n        require(account != address(0));\r\n\r\n        _totalSupply = _totalSupply.add(value);\r\n        _balances[account] = _balances[account].add(value);\r\n        emit Transfer(address(0), account, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Internal function that burns an amount of the token of a given\r\n     * account.\r\n     * @param account The account whose tokens will be burnt.\r\n     * @param value The amount that will be burnt.\r\n     */\r\n    function _burn(address account, uint256 value) internal {\r\n        require(account != address(0));\r\n\r\n        _totalSupply = _totalSupply.sub(value);\r\n        _balances[account] = _balances[account].sub(value);\r\n        emit Transfer(account, address(0), value);\r\n    }\r\n\r\n    /**\r\n     * @dev Internal function that burns an amount of the token of a given\r\n     * account, deducting from the sender\u0027s allowance for said account. Uses the\r\n     * internal burn function.\r\n     * Emits an Approval event (reflecting the reduced allowance).\r\n     * @param account The account whose tokens will be burnt.\r\n     * @param value The amount that will be burnt.\r\n     */\r\n    function _burnFrom(address account, uint256 value) internal {\r\n        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);\r\n        _burn(account, value);\r\n        emit Approval(account, msg.sender, _allowed[account][msg.sender]);\r\n    }\r\n\r\n\r\n}\r\n\r\n/** Below this is the actual token deploymet code **/\r\n/**\r\n * @title LedgeriumToken\r\n * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.\r\n * taken directly from open-zepplin examples.\r\n * Note they can later distribute these tokens as they wish using \u0060transfer\u0060 and other\r\n * \u0060ERC20\u0060 functions.\r\n */\r\ncontract XLGToken is ERC20 {\r\n    uint256 public constant INITIAL_SUPPLY = 20000000000000000;\r\n    /**\r\n    * Total during ERC-20 stage is 200 million. \r\n    */\r\n\r\n    /**\r\n     * @dev Constructor that gives msg.sender all of existing tokens.\r\n     */\r\n    constructor () public ERC20(\u0022XLG\u0022, \u0022XLG\u0022, 8) {\r\n        _mint(msg.sender, INITIAL_SUPPLY);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022INITIAL_SUPPLY\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnFrom\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"XLGToken","CompilerVersion":"v0.5.1\u002Bcommit.c8a2cb62","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://6f2af44615b0f217a4fd723c35df6a6f8617faba6c7441892533d0712749997d"}]