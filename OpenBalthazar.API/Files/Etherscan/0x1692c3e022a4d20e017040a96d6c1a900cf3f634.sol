[{"SourceCode":"pragma solidity ^0.4.19;\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n\r\n  /**\r\n  * @dev Multiplies two numbers, throws on overflow.\r\n  */\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Integer division of two numbers, truncating the quotient.\r\n  */\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n  */\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  /**\r\n  * @dev Adds two numbers, throws on overflow.\r\n  */\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n  address public owner;\r\n\r\n\r\n  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n\r\n  /**\r\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n  function Ownable() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param newOwner The address to transfer ownership to.\r\n   */\r\n  function transferOwnership(address newOwner) public onlyOwner {\r\n    require(newOwner != address(0));\r\n    OwnershipTransferred(owner, newOwner);\r\n    owner = newOwner;\r\n  }\r\n\r\n}\r\n\r\n/**\r\n * @title ERC20Basic\r\n * @dev Simpler version of ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/179\r\n */\r\ncontract ERC20Basic {\r\n  function totalSupply() public view returns (uint256);\r\n  function balanceOf(address who) public view returns (uint256);\r\n  function transfer(address to, uint256 value) public returns (bool);\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ncontract ERC20 is ERC20Basic {\r\n  function allowance(address owner, address spender) public view returns (uint256);\r\n  function transferFrom(address from, address to, uint256 value) public returns (bool);\r\n  function approve(address spender, uint256 value) public returns (bool);\r\n  event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n/**\r\n * @title Basic token\r\n * @dev Basic version of StandardToken, with no allowances.\r\n */\r\ncontract BasicToken is ERC20Basic, Ownable {\r\n  using SafeMath for uint256;\r\n\r\n  mapping(address =\u003E uint256) balances;\r\n\r\n uint256 totalSupply_;\r\n\r\n  /**\r\n  * @dev total number of tokens in existence\r\n  */\r\n  function totalSupply() public view returns (uint256) {\r\n    return totalSupply_;\r\n  }\r\n\r\n\r\n  /**\r\n  * @dev transfer token for a specified address\r\n  * @param _to The address to transfer to.\r\n  * @param _value The amount to be transferred.\r\n  */\r\n function transfer(address _to, uint256 _value) public returns (bool) {\r\n    require(_to != address(0));\r\n    require(_value \u003C= balances[msg.sender]);\r\n\r\n    // SafeMath.sub will throw if there is not enough balance.\r\n    balances[msg.sender] = balances[msg.sender].sub(_value);\r\n    balances[_to] = balances[_to].add(_value);\r\n    Transfer(msg.sender, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n  * @dev Gets the balance of the specified address.\r\n  * @param _owner The address to query the the balance of.\r\n  * @return An uint256 representing the amount owned by the passed address.\r\n  */\r\n  function balanceOf(address _owner) public view returns (uint256 balance) {\r\n    return balances[_owner];\r\n  }\r\n\r\n}\r\n\r\n\r\n/**\r\n * @title Standard ERC20 token\r\n *\r\n * @dev Implementation of the basic standard token.\r\n * @dev https://github.com/ethereum/EIPs/issues/20\r\n * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol\r\n */\r\ncontract StandardToken is ERC20, BasicToken {\r\n\r\n  mapping (address =\u003E mapping (address =\u003E uint256)) internal allowed;\r\n\r\n\r\n  /**\r\n   * @dev Transfer tokens from one address to another\r\n   * @param _from address The address which you want to send tokens from\r\n   * @param _to address The address which you want to transfer to\r\n   * @param _value uint256 the amount of tokens to be transfered\r\n   */\r\n  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {\r\n    require(_to != address(0));\r\n    require(_value \u003C= balances[_from]);\r\n    require(_value \u003C= allowed[_from][msg.sender]);\r\n\r\n    balances[_from] = balances[_from].sub(_value);\r\n    balances[_to] = balances[_to].add(_value);\r\n    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n    Transfer(_from, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\r\n   * @param _spender The address which will spend the funds.\r\n   * @param _value The amount of tokens to be spent.\r\n   */\r\n function approve(address _spender, uint256 _value) public returns (bool) {\r\n    allowed[msg.sender][_spender] = _value;\r\n    Approval(msg.sender, _spender, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Function to check the amount of tokens that an owner allowed to a spender.\r\n   * @param _owner address The address which owns the funds.\r\n   * @param _spender address The address which will spend the funds.\r\n   * @return A uint256 specifying the amount of tokens still available for the spender.\r\n   */\r\n   function allowance(address _owner, address _spender) public view returns (uint256) {\r\n    return allowed[_owner][_spender];\r\n  }\r\n\r\n  /** @dev Creates \u0060amount\u0060 tokens and assigns them to \u0060account\u0060, increasing\r\n * the total supply.\r\n * Requirements\r\n *\r\n * - \u0060to\u0060 cannot be the zero address.\r\n */\r\nfunction _mint(address account, uint256 amount) internal {\r\n    require(account != address(0));\r\n\r\n    totalSupply_ = totalSupply_.add(amount);\r\n    balances[account] = balances[account].add(amount);\r\n      Transfer(address(0), account, amount);\r\n}\r\n\r\n /**\r\n     * @dev See \u0060ERC20._mint\u0060.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - the caller must have the \u0060Owner Role\u0060.\r\n     */\r\n function mint(address account, uint256 amount) public onlyOwner returns (bool) {\r\n        _mint(account, amount);\r\n        return true;\r\n    }\r\n\r\n  /**\r\n   * @dev Function to revert eth transfers to this contract\r\n    */\r\n    function() public payable {\r\n\t    revert();\r\n\t}\r\n\r\n\r\n   /**\r\n   * @dev  Owner can transfer out any accidentally sent ERC20 tokens\r\n   */\r\n function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {\r\n        return BasicToken(tokenAddress).transfer(owner, tokens);\r\n    }\r\n\r\n  /**\r\n    * @dev Transfer the specified amounts of tokens to the specified addresses.\r\n    * @dev Be aware that there is no check for duplicate recipients.\r\n    *\r\n    * @param _toAddresses Receiver addresses.\r\n    * @param _amounts Amounts of tokens that will be transferred.\r\n    */\r\n    function multiSend(address[] _toAddresses, uint256[] _amounts) public {\r\n        /* Ensures _toAddresses array is less than or equal to 255 */\r\n        require(_toAddresses.length \u003C= 255);\r\n        /* Ensures _toAddress and _amounts have the same number of entries. */\r\n        require(_toAddresses.length == _amounts.length);\r\n\r\n        for (uint8 i = 0; i \u003C _toAddresses.length; i\u002B\u002B) {\r\n            transfer(_toAddresses[i], _amounts[i]);\r\n        }\r\n    }\r\n\r\n    /**\r\n    * @dev Transfer the specified amounts of tokens to the specified addresses from authorized balance of sender.\r\n    * @dev Be aware that there is no check for duplicate recipients.\r\n    *\r\n    * @param _from The address of the sender\r\n    * @param _toAddresses The addresses of the recipients (MAX 255)\r\n    * @param _amounts The amounts of tokens to be transferred\r\n    */\r\n    function multiSendFrom(address _from, address[] _toAddresses, uint256[] _amounts) public {\r\n        /* Ensures _toAddresses array is less than or equal to 255 */\r\n        require(_toAddresses.length \u003C= 255);\r\n        /* Ensures _toAddress and _amounts have the same number of entries. */\r\n        require(_toAddresses.length == _amounts.length);\r\n\r\n        for (uint8 i = 0; i \u003C _toAddresses.length; i\u002B\u002B) {\r\n            transferFrom(_from, _toAddresses[i], _amounts[i]);\r\n        }\r\n    }\r\n\r\n}\r\n\r\n\r\n\r\n /**\r\n * @title Burnable Token\r\n * @dev Token that can be irreversibly burned (destroyed).\r\n */\r\ncontract BurnableToken is BasicToken {\r\n\r\n  event Burn(address indexed burner, uint256 value);\r\n\r\n\r\n   /**\r\n   * @dev Burns a specific amount of tokens.\r\n   * @param _value The amount of token to be burned.\r\n   */\r\n  function burn(uint256 _value) public onlyOwner {\r\n    require(_value \u003C= balances[msg.sender]);\r\n    // no need to require value \u003C= totalSupply, since that would imply the\r\n    // sender\u0027s balance is greater than the totalSupply, which *should* be an assertion failure\r\n\r\n    address burner = msg.sender;\r\n    balances[burner] = balances[burner].sub(_value);\r\n    totalSupply_ = totalSupply_.sub(_value);\r\n    Burn(burner, _value);\r\n    Transfer(burner, address(0), _value);\r\n  }\r\n  }\r\n\r\n\r\ncontract ExRPiToken is StandardToken, BurnableToken{\r\n\r\n  string public constant name = \u0022ExRPi\u0022;\r\n  string public constant symbol = \u0022XRP\u0022;\r\n  uint8 public constant decimals = 2;\r\n\r\n  uint256 public constant INITIAL_SUPPLY = 100000000 * (10 ** uint256(decimals));\r\n\r\n\r\n  function ExRPiToken() public {\r\n    totalSupply_ = INITIAL_SUPPLY;\r\n    balances[msg.sender] = INITIAL_SUPPLY;\r\n    Transfer(0x0, msg.sender, INITIAL_SUPPLY);\r\n  }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022INITIAL_SUPPLY\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_toAddresses\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_amounts\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022multiSendFrom\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_toAddresses\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_amounts\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022multiSend\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferAnyERC20Token\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022burner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"ExRPiToken","CompilerVersion":"v0.4.19\u002Bcommit.c4cbbb05","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://7acc92b8bb602871b826b9a43e525af3a4f6a0459d75ac97dabf32270875208c"}]