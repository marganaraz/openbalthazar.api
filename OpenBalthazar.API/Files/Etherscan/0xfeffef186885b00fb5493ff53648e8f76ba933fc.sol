[{"SourceCode":"// File: contracts/tokens/ERC20.sol\r\n\r\npragma solidity 0.5.14;\r\n\r\n/**\r\n* Abstract contract(interface) for the full ERC 20 Token standard\r\n* see https://github.com/ethereum/EIPs/issues/20\r\n* This is a simple fixed supply token contract.\r\n*/\r\ncontract ERC20 {\r\n\r\n  /**\r\n  * Get the total token supply\r\n  */\r\n  function totalSupply() public view returns (uint256 supply);\r\n\r\n  /**\r\n  * Get the account balance of an account with address _owner\r\n  */\r\n  function balanceOf(address _owner) public view returns (uint256 balance);\r\n\r\n  /**\r\n  * Send _value amount of tokens to address _to\r\n  * Only the owner can call this function\r\n  */\r\n  function transfer(address _to, uint256 _value) public returns (bool success);\r\n\r\n  /**\r\n  * Send _value amount of tokens from address _from to address _to\r\n  */\r\n  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\r\n\r\n  /** Allow _spender to withdraw from your account, multiple times, up to the _value amount.\r\n  * If this function is called again it overwrites the current allowance with _value.\r\n  * this function is required for some DEX functionality\r\n  */\r\n  function approve(address _spender, uint256 _value) public returns (bool success);\r\n\r\n  /**\r\n  * Returns the amount which _spender is still allowed to withdraw from _owner\r\n  */\r\n  function allowance(address _owner, address _spender) public view returns (uint256 remaining);\r\n\r\n  /**\r\n  * Triggered when tokens are transferred from one address to another\r\n  */\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n  /**\r\n  * Triggered whenever approve(address spender, uint256 value) is called.\r\n  */\r\n  event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n// File: contracts/tokens/SafeMath.sol\r\n\r\npragma solidity 0.5.14;\r\n\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that revert on error\r\n */\r\nlibrary SafeMath {\r\n\r\n  /**\r\n  * @dev Multiplies two numbers, reverts on overflow.\r\n  */\r\n  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n    // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n    // benefit is lost if \u0027b\u0027 is also tested.\r\n    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n    if (_a == 0) {\r\n      return 0;\r\n    }\r\n\r\n    uint256 c = _a * _b;\r\n    require(c / _a == _b);\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.\r\n  */\r\n  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n    require(_b \u003E 0);\r\n    // Solidity only automatically asserts when dividing by 0\r\n    uint256 c = _a / _b;\r\n    // assert(_a == _b * c \u002B _a % _b); // There is no case in which this doesn\u0027t hold\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n  */\r\n  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n    require(_b \u003C= _a);\r\n    uint256 c = _a - _b;\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Adds two numbers, reverts on overflow.\r\n  */\r\n  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n    uint256 c = _a \u002B _b;\r\n    require(c \u003E= _a);\r\n\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),\r\n  * reverts when dividing by zero.\r\n  */\r\n  function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    require(b != 0);\r\n    return a % b;\r\n  }\r\n}\r\n\r\n// File: contracts/tokens/StandardToken.sol\r\n\r\npragma solidity 0.5.14;\r\n\r\n\r\n\r\n\r\n/**\r\n * @title Standard ERC20 token\r\n *\r\n * @dev Implementation of the basic standard token.\r\n * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md\r\n * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol\r\n */\r\ncontract StandardToken is ERC20 {\r\n  using SafeMath for uint256;\r\n\r\n  mapping(address =\u003E uint256) internal balances;\r\n\r\n  mapping(address =\u003E mapping(address =\u003E uint256)) private allowed;\r\n\r\n  uint256 internal totalSupply_;\r\n\r\n  /**\r\n  * @dev Total number of tokens in existence\r\n  */\r\n  function totalSupply() public view returns (uint256) {\r\n    return totalSupply_;\r\n  }\r\n\r\n  /**\r\n  * @dev Gets the balance of the specified address.\r\n  * @param _owner The address to query the the balance of.\r\n  * @return An uint256 representing the amount owned by the passed address.\r\n  */\r\n  function balanceOf(address _owner) public view returns (uint256) {\r\n    return balances[_owner];\r\n  }\r\n\r\n  /**\r\n   * @dev Function to check the amount of tokens that an owner allowed to a spender.\r\n   * @param _owner address The address which owns the funds.\r\n   * @param _spender address The address which will spend the funds.\r\n   * @return A uint256 specifying the amount of tokens still available for the spender.\r\n   */\r\n  function allowance(address _owner, address _spender) public view returns (uint256) {\r\n    return allowed[_owner][_spender];\r\n  }\r\n\r\n  /**\r\n  * @dev Transfer token for a specified address\r\n  * @param _to The address to transfer to.\r\n  * @param _value The amount to be transferred.\r\n  */\r\n  function transfer(address _to, uint256 _value) public returns (bool) {\r\n    require(_value \u003C= balances[msg.sender]);\r\n    require(_to != address(0));\r\n\r\n    balances[msg.sender] = balances[msg.sender].sub(_value);\r\n    balances[_to] = balances[_to].add(_value);\r\n    emit Transfer(msg.sender, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\r\n   * Beware that changing an allowance with this method brings the risk that someone may use both the old\r\n   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\r\n   * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\r\n   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n   * @param _spender The address which will spend the funds.\r\n   * @param _value The amount of tokens to be spent.\r\n   */\r\n  function approve(address _spender, uint256 _value) public returns (bool) {\r\n    allowed[msg.sender][_spender] = _value;\r\n    emit Approval(msg.sender, _spender, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Transfer tokens from one address to another\r\n   * @param _from address The address which you want to send tokens from\r\n   * @param _to address The address which you want to transfer to\r\n   * @param _value uint256 the amount of tokens to be transferred\r\n   */\r\n  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {\r\n    require(_value \u003C= balances[_from]);\r\n    require(_value \u003C= allowed[_from][msg.sender]);\r\n    require(_to != address(0));\r\n\r\n    balances[_from] = balances[_from].sub(_value);\r\n    balances[_to] = balances[_to].add(_value);\r\n    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n    emit Transfer(_from, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Increase the amount of tokens that an owner allowed to a spender.\r\n   * approve should be called when allowed[_spender] == 0. To increment\r\n   * allowed value is better to use this function to avoid 2 calls (and wait until\r\n   * the first transaction is mined)\r\n   * From MonolithDAO Token.sol\r\n   * @param _spender The address which will spend the funds.\r\n   * @param _addedValue The amount of tokens to increase the allowance by.\r\n   */\r\n  function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {\r\n    allowed[msg.sender][_spender] = (\r\n    allowed[msg.sender][_spender].add(_addedValue));\r\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Decrease the amount of tokens that an owner allowed to a spender.\r\n   * approve should be called when allowed[_spender] == 0. To decrement\r\n   * allowed value is better to use this function to avoid 2 calls (and wait until\r\n   * the first transaction is mined)\r\n   * From MonolithDAO Token.sol\r\n   * @param _spender The address which will spend the funds.\r\n   * @param _subtractedValue The amount of tokens to decrease the allowance by.\r\n   */\r\n  function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {\r\n    uint256 oldValue = allowed[msg.sender][_spender];\r\n    if (_subtractedValue \u003E= oldValue) {\r\n      allowed[msg.sender][_spender] = 0;\r\n    } else {\r\n      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\r\n    }\r\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Internal function that mints an amount of the token and assigns it to\r\n   * an account. This encapsulates the modification of balances such that the\r\n   * proper events are emitted.\r\n   * @param _account The account that will receive the created tokens.\r\n   * @param _amount The amount that will be created.\r\n   */\r\n  function _mint(address _account, uint256 _amount) internal {\r\n    require(_account != address(0));\r\n    totalSupply_ = totalSupply_.add(_amount);\r\n    balances[_account] = balances[_account].add(_amount);\r\n    emit Transfer(address(0), _account, _amount);\r\n  }\r\n\r\n  /**\r\n   * @dev Internal function that burns an amount of the token of a given\r\n   * account.\r\n   * @param _account The account whose tokens will be burnt.\r\n   * @param _amount The amount that will be burnt.\r\n   */\r\n  function _burn(address _account, uint256 _amount) internal {\r\n    require(_account != address(0));\r\n    require(_amount \u003C= balances[_account]);\r\n\r\n    totalSupply_ = totalSupply_.sub(_amount);\r\n    balances[_account] = balances[_account].sub(_amount);\r\n    emit Transfer(_account, address(0), _amount);\r\n  }\r\n\r\n  /**\r\n   * @dev Internal function that burns an amount of the token of a given\r\n   * account, deducting from the sender\u0027s allowance for said account. Uses the\r\n   * internal _burn function.\r\n   * @param _account The account whose tokens will be burnt.\r\n   * @param _amount The amount that will be burnt.\r\n   */\r\n  function _burnFrom(address _account, uint256 _amount) internal {\r\n    require(_amount \u003C= allowed[_account][msg.sender]);\r\n\r\n    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,\r\n    // this function needs to emit an event with the updated approval.\r\n    allowed[_account][msg.sender] = allowed[_account][msg.sender].sub(_amount);\r\n    _burn(_account, _amount);\r\n  }\r\n}\r\n\r\n// File: contracts/tokens/Ownable.sol\r\n\r\npragma solidity 0.5.14;\r\n\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n  address public owner;\r\n\r\n  event OwnershipRenounced(address indexed previousOwner);\r\n\r\n  event OwnershipTransferred(\r\n    address indexed previousOwner,\r\n    address indexed newOwner\r\n  );\r\n\r\n  /**\r\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n  constructor() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to relinquish control of the contract.\r\n   * @notice Renouncing to ownership will leave the contract without an owner.\r\n   * It will not be possible to call the functions with the \u0060onlyOwner\u0060\r\n   * modifier anymore.\r\n   */\r\n  function renounceOwnership() public onlyOwner {\r\n    emit OwnershipRenounced(owner);\r\n    owner = address(0);\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param _newOwner The address to transfer ownership to.\r\n   */\r\n  function transferOwnership(address _newOwner) public onlyOwner {\r\n    _transferOwnership(_newOwner);\r\n  }\r\n\r\n  /**\r\n   * @dev Transfers control of the contract to a newOwner.\r\n   * @param _newOwner The address to transfer ownership to.\r\n   */\r\n  function _transferOwnership(address _newOwner) internal {\r\n    require(_newOwner != address(0));\r\n    emit OwnershipTransferred(owner, _newOwner);\r\n    owner = _newOwner;\r\n  }\r\n}\r\n\r\n// File: contracts/tokens/BurnableToken.sol\r\n\r\npragma solidity 0.5.14;\r\n\r\n\r\n\r\n/**\r\n * @title Burnable Token\r\n * @dev Token that can be irreversibly burned (destroyed).\r\n */\r\ncontract BurnableToken is StandardToken {\r\n\r\n  event Burn(address indexed burner, uint256 value);\r\n\r\n  /**\r\n   * @dev Burns a specific amount of tokens.\r\n   * @param _value The amount of token to be burned.\r\n   */\r\n  function burn(uint256 _value) public {\r\n    _burn(msg.sender, _value);\r\n  }\r\n\r\n  /**\r\n   * @dev Burns a specific amount of tokens from the target address and decrements allowance\r\n   * @param _from address The address which you want to send tokens from\r\n   * @param _value uint256 The amount of token to be burned\r\n   */\r\n  function burnFrom(address _from, uint256 _value) public {\r\n    _burnFrom(_from, _value);\r\n  }\r\n\r\n  /**\r\n   * @dev Overrides StandardToken._burn in order for burn and burnFrom to emit\r\n   * an additional Burn event.\r\n   */\r\n  function _burn(address _who, uint256 _value) internal {\r\n    super._burn(_who, _value);\r\n    emit Burn(_who, _value);\r\n  }\r\n}\r\n\r\n// File: contracts/tokens/SportValueCoin.sol\r\n\r\npragma solidity 0.5.14;\r\n\r\n\r\n/**\r\nImplements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20\r\n\r\nThis is a contract for a fixed supply coin.\r\n*/\r\ncontract SportValueCoin is BurnableToken {\r\n\r\n  // meta data\r\n  string public constant symbol = \u0022SVC\u0022;\r\n\r\n  string public version = \u00271.0\u0027;\r\n\r\n  string public constant name = \u0022Sport Value Coin\u0022;\r\n\r\n  uint256 public constant decimals = 18;\r\n\r\n  uint256 public constant INITIAL_SUPPLY = 100 * (10 ** 6) * 10 ** decimals; // 100 millions\r\n\r\n  constructor() public {\r\n    _mint(msg.sender, INITIAL_SUPPLY);\r\n  }\r\n\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022burner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022INITIAL_SUPPLY\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnFrom\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseApproval\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseApproval\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022version\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"SportValueCoin","CompilerVersion":"v0.5.14\u002Bcommit.1f1aaa4","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://309d9417fe32b7652bfff7c1dacc4537dd747f1afb27594eda717b6402f290cd"}]