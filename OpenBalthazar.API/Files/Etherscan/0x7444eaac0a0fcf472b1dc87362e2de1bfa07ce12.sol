[{"SourceCode":"pragma solidity ^0.4.23;\r\n\r\n/**\r\n * SCANETCHAIN is the first commercial dApp built on the NEM platform\r\n * Developed for Blockchain Commercialization.\r\n */\r\n\r\n /**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n  address public owner;\r\n\r\n\r\n  event OwnershipRenounced(address indexed previousOwner);\r\n  event OwnershipTransferred(\r\n    address indexed previousOwner,\r\n    address indexed newOwner\r\n  );\r\n\r\n\r\n  /**\r\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n  constructor() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to relinquish control of the contract.\r\n   */\r\n  function renounceOwnership() public onlyOwner {\r\n    emit OwnershipRenounced(owner);\r\n    owner = address(0);\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param _newOwner The address to transfer ownership to.\r\n   */\r\n  function transferOwnership(address _newOwner) public onlyOwner {\r\n    _transferOwnership(_newOwner);\r\n  }\r\n\r\n  /**\r\n   * @dev Transfers control of the contract to a newOwner.\r\n   * @param _newOwner The address to transfer ownership to.\r\n   */\r\n  function _transferOwnership(address _newOwner) internal {\r\n    require(_newOwner != address(0));\r\n    emit OwnershipTransferred(owner, _newOwner);\r\n    owner = _newOwner;\r\n  }\r\n}\r\n\r\n\r\n/**\r\n * @title Pausable\r\n * @dev Base contract which allows children to implement an emergency stop mechanism.\r\n */\r\ncontract Pausable is Ownable {\r\n  event Pause();\r\n  event Unpause();\r\n\r\n  bool public paused = false;\r\n\r\n\r\n  /**\r\n   * @dev Modifier to make a function callable only when the contract is not paused.\r\n   */\r\n  modifier whenNotPaused() {\r\n    require(!paused);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Modifier to make a function callable only when the contract is paused.\r\n   */\r\n  modifier whenPaused() {\r\n    require(paused);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev called by the owner to pause, triggers stopped state\r\n   */\r\n  function pause() onlyOwner whenNotPaused public {\r\n    paused = true;\r\n    emit Pause();\r\n  }\r\n\r\n  /**\r\n   * @dev called by the owner to unpause, returns to normal state\r\n   */\r\n  function unpause() onlyOwner whenPaused public {\r\n    paused = false;\r\n    emit Unpause();\r\n  }\r\n}\r\n\r\n\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n\r\n  /**\r\n  * @dev Multiplies two numbers, throws on overflow.\r\n  */\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n    // Gas optimization: this is cheaper than asserting \u0027a\u0027 not being zero, but the\r\n    // benefit is lost if \u0027b\u0027 is also tested.\r\n    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n\r\n    c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Integer division of two numbers, truncating the quotient.\r\n  */\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    // uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return a / b;\r\n  }\r\n\r\n  /**\r\n  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n  */\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  /**\r\n  * @dev Adds two numbers, throws on overflow.\r\n  */\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n    c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\n\r\n/**\r\n * @title ERC20Basic\r\n * @dev Simpler version of ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/179\r\n */\r\ncontract ERC20Basic {\r\n  function totalSupply() public view returns (uint256);\r\n  function balanceOf(address who) public view returns (uint256);\r\n  function transfer(address to, uint256 value) public returns (bool);\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\n\r\n/**\r\n * @title Basic token\r\n * @dev Basic version of StandardToken, with no allowances.\r\n */\r\ncontract BasicToken is ERC20Basic {\r\n  using SafeMath for uint256;\r\n\r\n  mapping(address =\u003E uint256) balances;\r\n\r\n  uint256 totalSupply_;\r\n\r\n  /**\r\n  * @dev Total number of tokens in existence\r\n  */\r\n  function totalSupply() public view returns (uint256) {\r\n    return totalSupply_;\r\n  }\r\n\r\n  /**\r\n  * @dev Transfer token for a specified address\r\n  * @param _to The address to transfer to.\r\n  * @param _value The amount to be transferred.\r\n  */\r\n  function transfer(address _to, uint256 _value) public returns (bool) {\r\n    require(_to != address(0));\r\n    require(_value \u003C= balances[msg.sender]);\r\n\r\n    balances[msg.sender] = balances[msg.sender].sub(_value);\r\n    balances[_to] = balances[_to].add(_value);\r\n    emit Transfer(msg.sender, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n  * @dev Gets the balance of the specified address.\r\n  * @param _owner The address to query the the balance of.\r\n  * @return An uint256 representing the amount owned by the passed address.\r\n  */\r\n  function balanceOf(address _owner) public view returns (uint256) {\r\n    return balances[_owner];\r\n  }\r\n\r\n}\r\n\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ncontract ERC20 is ERC20Basic {\r\n  function allowance(address owner, address spender)\r\n    public view returns (uint256);\r\n\r\n  function transferFrom(address from, address to, uint256 value)\r\n    public returns (bool);\r\n\r\n  function approve(address spender, uint256 value) public returns (bool);\r\n  event Approval(\r\n    address indexed owner,\r\n    address indexed spender,\r\n    uint256 value\r\n  );\r\n\r\n  function () public payable {\r\n         revert();\r\n     }\r\n}\r\n\r\n/**\r\n * @title Standard ERC20 token\r\n *\r\n * @dev Implementation of the basic standard token.\r\n * @dev https://github.com/ethereum/EIPs/issues/20\r\n * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol\r\n */\r\ncontract StandardToken is ERC20, BasicToken {\r\n\r\n  mapping (address =\u003E mapping (address =\u003E uint256)) internal allowed;\r\n\r\n\r\n  /**\r\n   * @dev Transfer tokens from one address to another\r\n   * @param _from address The address which you want to send tokens from\r\n   * @param _to address The address which you want to transfer to\r\n   * @param _value uint256 the amount of tokens to be transferred\r\n   */\r\n  function transferFrom(\r\n    address _from,\r\n    address _to,\r\n    uint256 _value\r\n  )\r\n    public\r\n\r\n    returns (bool)\r\n  {\r\n    require(_to != address(0));\r\n    require(_value \u003C= balances[_from]);\r\n    require(_value \u003C= allowed[_from][msg.sender]);\r\n\r\n    balances[_from] = balances[_from].sub(_value);\r\n    balances[_to] = balances[_to].add(_value);\r\n    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n    emit Transfer(_from, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\r\n   *\r\n   * Beware that changing an allowance with this method brings the risk that someone may use both the old\r\n   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\r\n   * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\r\n   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n   * @param _spender The address which will spend the funds.\r\n   * @param _value The amount of tokens to be spent.\r\n   */\r\n  function approve(address _spender, uint256 _value) public returns (bool) {\r\n    allowed[msg.sender][_spender] = _value;\r\n    emit Approval(msg.sender, _spender, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Function to check the amount of tokens that an owner allowed to a spender.\r\n   * @param _owner address The address which owns the funds.\r\n   * @param _spender address The address which will spend the funds.\r\n   * @return A uint256 specifying the amount of tokens still available for the spender.\r\n   */\r\n  function allowance(\r\n    address _owner,\r\n    address _spender\r\n   )\r\n    public\r\n    view\r\n    returns (uint256)\r\n  {\r\n    return allowed[_owner][_spender];\r\n  }\r\n\r\n  /**\r\n   * @dev Increase the amount of tokens that an owner allowed to a spender.\r\n   *\r\n   * approve should be called when allowed[_spender] == 0. To increment\r\n   * allowed value is better to use this function to avoid 2 calls (and wait until\r\n   * the first transaction is mined)\r\n   * From MonolithDAO Token.sol\r\n   * @param _spender The address which will spend the funds.\r\n   * @param _addedValue The amount of tokens to increase the allowance by.\r\n   */\r\n  function increaseApproval(\r\n    address _spender,\r\n    uint _addedValue\r\n  )\r\n    public\r\n    returns (bool)\r\n  {\r\n    allowed[msg.sender][_spender] = (\r\n      allowed[msg.sender][_spender].add(_addedValue));\r\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Decrease the amount of tokens that an owner allowed to a spender.\r\n   *\r\n   * approve should be called when allowed[_spender] == 0. To decrement\r\n   * allowed value is better to use this function to avoid 2 calls (and wait until\r\n   * the first transaction is mined)\r\n   * From MonolithDAO Token.sol\r\n   * @param _spender The address which will spend the funds.\r\n   * @param _subtractedValue The amount of tokens to decrease the allowance by.\r\n   */\r\n  function decreaseApproval(\r\n    address _spender,\r\n    uint _subtractedValue\r\n  )\r\n    public\r\n    returns (bool)\r\n  {\r\n    uint oldValue = allowed[msg.sender][_spender];\r\n    if (_subtractedValue \u003E oldValue) {\r\n      allowed[msg.sender][_spender] = 0;\r\n    } else {\r\n      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\r\n    }\r\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n    return true;\r\n  }\r\n\r\n}\r\n\r\n\r\n/**\r\n * @title Pausable token\r\n * @dev StandardToken modified with pausable transfers.\r\n **/\r\ncontract PausableToken is StandardToken, Pausable {\r\n\r\n  function transfer(\r\n    address _to,\r\n    uint256 _value\r\n  )\r\n    public\r\n    whenNotPaused\r\n    returns (bool)\r\n  {\r\n    return super.transfer(_to, _value);\r\n  }\r\n\r\n  function transferFrom(\r\n    address _from,\r\n    address _to,\r\n    uint256 _value\r\n  )\r\n    public\r\n    whenNotPaused\r\n    returns (bool)\r\n  {\r\n    return super.transferFrom(_from, _to, _value);\r\n  }\r\n\r\n  function approve(\r\n    address _spender,\r\n    uint256 _value\r\n  )\r\n    public\r\n    whenNotPaused\r\n    returns (bool)\r\n  {\r\n    return super.approve(_spender, _value);\r\n  }\r\n\r\n  function increaseApproval(\r\n    address _spender,\r\n    uint _addedValue\r\n  )\r\n    public\r\n    whenNotPaused\r\n    returns (bool success)\r\n  {\r\n    return super.increaseApproval(_spender, _addedValue);\r\n  }\r\n\r\n  function decreaseApproval(\r\n    address _spender,\r\n    uint _subtractedValue\r\n  )\r\n    public\r\n    whenNotPaused\r\n    returns (bool success)\r\n  {\r\n    return super.decreaseApproval(_spender, _subtractedValue);\r\n  }\r\n}\r\n\r\n/**\r\n * @title SimpleToken\r\n * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.\r\n * Note they can later distribute these tokens as they wish using \u0060transfer\u0060 and other\r\n * \u0060StandardToken\u0060 functions.\r\n */\r\ncontract Scanetchain is StandardToken, PausableToken {\r\n\r\n  string public constant name = \u0022Scanetchain\u0022; \r\n  string public constant symbol = \u0022SWC\u0022;\r\n  uint8 public constant decimals = 18;\r\n\r\n  uint256 public constant INITIAL_SUPPLY = 5000000000 * (10 ** uint256(decimals));\r\n\r\n  /**\r\n   * @dev Constructor that gives msg.sender all of existing tokens.\r\n   */\r\n  constructor() public {\r\n    totalSupply_ = INITIAL_SUPPLY;\r\n    balances[msg.sender] = INITIAL_SUPPLY;\r\n    emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);\r\n  }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022INITIAL_SUPPLY\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Pause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Unpause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipRenounced\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Scanetchain","CompilerVersion":"v0.4.23\u002Bcommit.124ca40d","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://42e835a7c2dc7fd659f02c4696d4ee474012e2fabed01efe9e096e7acd259b57"}]