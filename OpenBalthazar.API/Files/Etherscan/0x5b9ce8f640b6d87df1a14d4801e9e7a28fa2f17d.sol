[{"SourceCode":"pragma solidity ^0.5.2;\r\n/**\r\n* @title ERC20 interface \r\n* @dev see https://eips.ethereum.org/EIPS/eip-20 \r\n*/\r\ninterface IERC20 { \r\n    function transfer(address to, uint256 value) external returns (bool); \r\n    \r\n    function approve(address spender, uint256 value) external returns (bool); \r\n    \r\n    function transferFrom(address from, address to, uint256 value) external returns (bool); \r\n    \r\n    function totalSupply() external view returns (uint256); \r\n    \r\n    function balanceOf(address who) external view returns (uint256); \r\n    \r\n    function allowance(address owner, address spender) external view returns (uint256); \r\n    \r\n    event Transfer(address indexed from, address indexed to, uint256 value); \r\n    \r\n    event Approval(address indexed owner, address indexed spender, uint256 value); \r\n}\r\n\r\n/**\r\n* @title SafeMath \r\n* @dev Unsigned math operations with safety checks that revert on error\r\n*/\r\nlibrary SafeMath { \r\n    /**\r\n    * @dev Multiplies two unsigned integers, reverts on overflow. \r\n    */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) { \r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the \r\n        // benefit is lost if \u0027b\u0027 is also tested. \r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522 \r\n        if (a == 0) { \r\n            return 0;\r\n        }\r\n        uint256 c = a * b; \r\n        require(c / a == b); \r\n        return c; \r\n    }\r\n    /**\r\n    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero. \r\n    */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) \r\n    {\r\n        // Solidity only automatically asserts when dividing by 0 \r\n        require(b \u003E 0); \r\n        uint256 c = a / b; \r\n        //assert(a == b * c \u002B a % b); //There is no case in which this doesn\u0027t hold \r\n        return c; \r\n    }\r\n    /**\r\n    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend). \r\n    */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) \r\n    { \r\n        require(b \u003C= a); \r\n        uint256 c = a - b; \r\n        return c; \r\n    }\r\n    /**\r\n    * @dev Adds two unsigned integers, reverts on overflow. \r\n    */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) \r\n    { \r\n        uint256 c = a \u002B b; \r\n        require(c \u003E= a); \r\n        return c; \r\n    }\r\n    /**\r\n    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo), \r\n    * reverts when dividing by zero. \r\n    */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) \r\n    { \r\n        require(b != 0); \r\n        return a % b; \r\n    }\r\n}\r\n\r\n/**\r\n* @title Standard ERC20 token *\r\n* @dev Implementation of the basic standard token. \r\n* https://eips.ethereum.org/EIPS/eip-20 \r\n* Originally based on code by FirstBlood: \r\n* https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol \r\n*\r\n* This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for \r\n* all accounts just by listening to said events. Note that this isn\u0027t required by the specification, and other \r\n* compliant implementations may not do it. \r\n*/\r\ncontract QYBC is IERC20 {\r\n    using SafeMath for uint256;//\u901A\u8FC7\u8FD9\u79CD\u65B9\u5F0F\u5E94\u7528 SafeMath \u66F4\u65B9\u4FBF\r\n\r\n    string private _name; \r\n    string private _symbol; \r\n    uint8 private _decimals; \r\n\r\n    mapping (address =\u003E uint256) private _balances; \r\n    mapping (address =\u003E mapping (address =\u003E uint256)) private _allowed; \r\n    uint256 private _totalSupply;\r\n\r\n    //\u4F7F\u7528\u6784\u9020\u51FD\u6570\u521D\u59CB\u5316\u64CD\u4F5C\r\n    constructor( uint256 initialSupply, string memory tokenName, uint8 decimalUnits, string memory tokenSymbol ) public \r\n    { \r\n        _balances[msg.sender] = initialSupply; \r\n        // Give the creator all initial tokens \r\n        _totalSupply = initialSupply; \r\n        // Update total supply \r\n        _name = tokenName; \r\n        // Set the name for display purposes \r\n        _symbol = tokenSymbol; \r\n        // Set the symbol for display purposes \r\n        _decimals = decimalUnits; \r\n        // Amount of decimals for display purposes \r\n    }\r\n\r\n    /**\r\n    * @dev Name of tokens in existence \r\n    */\r\n    function name() public view returns (string memory) \r\n    { \r\n        return _name; \r\n    }\r\n\r\n    /**\r\n    * @dev Symbol of tokens in existence \r\n    */\r\n    function symbol() public view returns (string memory) \r\n    { \r\n        return _symbol; \r\n    }\r\n\r\n    /**\r\n    * @dev decimals of tokens in existence \r\n    */\r\n    function decimals() public view returns (uint8) \r\n    { \r\n        return _decimals; \r\n    }\r\n\r\n    /**\r\n    * @dev Total number of tokens in existence \r\n    */\r\n    function totalSupply() public view returns (uint256) \r\n    { \r\n        return _totalSupply; \r\n    }\r\n\r\n    /**\r\n    * @dev Gets the balance of the specified address. \r\n    * @param owner The address to query the balance of. \r\n    * @return A uint256 representing the amount owned by the passed address. \r\n    */\r\n    function balanceOf(address owner) public view returns (uint256) \r\n    { \r\n        return _balances[owner]; \r\n    }\r\n\r\n    /**\r\n    * @dev Function to check the amount of tokens that an owner allowed to a spender. \r\n    * @param owner address The address which owns the funds. \r\n    * @param spender address The address which will spend the funds. \r\n    * @return A uint256 specifying the amount of tokens still available for the spender. \r\n    */\r\n    function allowance(address owner, address spender) public view returns (uint256) \r\n    { \r\n        return _allowed[owner][spender]; \r\n    }\r\n\r\n    /**\r\n    * @dev Transfer token to a specified address \r\n    * @param to The address to transfer to. \r\n    * @param value The amount to be transferred. \r\n    */\r\n    function transfer(address to, uint256 value) public returns (bool) \r\n    { \r\n        _transfer(msg.sender, to, value); \r\n        return true; \r\n    }\r\n\r\n    /**\r\n    * @dev Burns a specific amount of tokens. * @param value The amount of token to be burned. \r\n    */\r\n    function burn(uint256 value) public \r\n    { \r\n        _burn(msg.sender, value); \r\n    }\r\n\r\n    /**\r\n    * @dev Burns a specific amount of tokens from the target address and decrements allowance \r\n    * @param from address The account whose tokens will be burned. \r\n    * @param value uint256 The amount of token to be burned. \r\n    */\r\n    function burnFrom(address from, uint256 value) public \r\n    { \r\n        _burnFrom(from, value); \r\n    }\r\n\r\n    /**\r\n    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender. \r\n    * Beware that changing an allowance with this method brings the risk that someone may use both the old \r\n    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this \r\n    * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards: \r\n    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729 \r\n    * @param spender The address which will spend the funds. \r\n    * @param value The amount of tokens to be spent. \r\n    */\r\n    function approve(address spender, uint256 value) public returns (bool) \r\n    { \r\n        _approve(msg.sender, spender, value); \r\n        return true; \r\n    }\r\n\r\n    /**\r\n    * @dev Transfer tokens from one address to another. \r\n    * Note that while this function emits an Approval event, this is not required as per the specification, \r\n    * and other compliant implementations may not emit the event. \r\n    * @param from address The address which you want to send tokens from \r\n    * @param to address The address which you want to transfer to \r\n    * @param value uint256 the amount of tokens to be transferred \r\n    */\r\n    function transferFrom(address from, address to, uint256 value) public returns (bool) \r\n    { \r\n        _transfer(from, to, value); \r\n        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value)); \r\n        return true; \r\n    }\r\n\r\n    /**\r\n    * @dev Increase the amount of tokens that an owner allowed to a spender. \r\n    * approve should be called when _allowed[msg.sender][spender] == 0. To increment \r\n    * allowed value is better to use this function to avoid 2 calls (and wait until \r\n    * the first transaction is mined) \r\n    * From MonolithDAO Token.sol \r\n    * Emits an Approval event. \r\n    * @param spender The address which will spend the funds. \r\n    * @param addedValue The amount of tokens to increase the allowance by. \r\n    */\r\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) \r\n    { \r\n        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue)); \r\n        return true; \r\n    }\r\n\r\n    /**\r\n    * @dev Decrease the amount of tokens that an owner allowed to a spender. \r\n    * approve should be called when _allowed[msg.sender][spender] == 0. To decrement \r\n    * allowed value is better to use this function to avoid 2 calls (and wait until \r\n    * the first transaction is mined) \r\n    * From MonolithDAO Token.sol * Emits an Approval event.\r\n    * @param spender The address which will spend the funds. \r\n    * @param subtractedValue The amount of tokens to decrease the allowance by. \r\n    */\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) \r\n    { \r\n        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue)); \r\n        return true; \r\n    }\r\n\r\n    /**\r\n    * @dev Transfer token for a specified addresses \r\n    * @param from The address to transfer from. \r\n    * @param to The address to transfer to. \r\n    * @param value The amount to be transferred. \r\n    */\r\n    function _transfer(address from, address to, uint256 value) internal \r\n    { \r\n        require(to != address(0));\r\n        //\u68C0\u67E5\u5730\u5740\u662F\u5426\u4E3A\u7A7A \r\n        _balances[from] = _balances[from].sub(value);\r\n        //\u5148\u51CF\u540E\u52A0\uFF0C\u7B26\u5408\u63A8\u8350\u64CD\u4F5C\uFF0C\u4F7F\u7528 SafeMath \u51FD\u6570\u8FDB\u884C\u6570\u503C\u8FD0\u7B97\u64CD\u4F5C\uFF0C\u7B26\u5408\u89C4\u8303\r\n        _balances[to] = _balances[to].add(value); \r\n        emit Transfer(from, to, value); \r\n    }\r\n    \r\n    /**\r\n    * @dev Internal function that burns an amount of the token of a given \r\n    * account. \r\n    * @param account The account whose tokens will be burnt. \r\n    * @param value The amount that will be burnt. \r\n    */\r\n    function _burn(address account, uint256 value) internal \r\n    { \r\n        require(account != address(0));\r\n        //\u68C0\u67E5\u5730\u5740\u662F\u5426\u4E3A\u7A7A\r\n        _totalSupply = _totalSupply.sub(value);\r\n        _balances[account] = _balances[account].sub(value);\r\n        emit Transfer(account, address(0), value);\r\n    }\r\n\r\n    /**\r\n    * @dev Approve an address to spend another addresses\u0027 tokens. \r\n    * @param owner The address that owns the tokens. \r\n    * @param spender The address that will spend the tokens. \r\n    * @param value The number of tokens that can be spent. \r\n    */\r\n    function _approve(address owner, address spender, uint256 value) internal \r\n    { \r\n        require(spender != address(0));\r\n        //\u68C0\u67E5\u5730\u5740\u662F\u5426\u4E3A\u7A7A \r\n        require(owner != address(0));\r\n        //\u68C0\u67E5\u5730\u5740\u662F\u5426\u4E3A\u7A7A\r\n        //\u6B64\u5904\u5B58\u5728\u4E8B\u52A1\u987A\u5E8F\u4F9D\u8D56\u98CE\u9669\uFF0C\u5EFA\u8BAE\u589E\u52A0\u4EE5\u4E0B\u8BED\u53E5\u9632\u6B62\r\n        require(value == 0 || (_allowed[owner][spender] == 0));\r\n        _allowed[owner][spender] = value; \r\n        emit Approval(owner, spender, value); \r\n    }\r\n    /**\r\n    * @dev Internal function that burns an amount of the token of a given \r\n    * account, deducting from the sender\u0027s allowance for said account. Uses the \r\n    * internal burn function. \r\n    * Emits an Approval event (reflecting the reduced allowance). \r\n    * @param account The account whose tokens will be burnt. \r\n    * @param value The amount that will be burnt. \r\n    */\r\n    function _burnFrom(address account, uint256 value) internal \r\n    { \r\n        _burn(account, value); \r\n        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value)); \r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnFrom\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022initialSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022tokenName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022decimalUnits\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022tokenSymbol\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"QYBC","CompilerVersion":"v0.5.2\u002Bcommit.1df8f40c","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"0000000000000000000000000000000000000000000000000de0b6b3a76400000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000004515942430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045159424300000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://a3f1b1cffb7bf621d7fe1c3585d85c252ea8d501d518be04cd2fa3909afa87fa"}]