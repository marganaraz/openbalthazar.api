[{"SourceCode":"pragma solidity ^0.5.1;\r\n\r\n\r\nlibrary IterableMapping {\r\n  struct itmap\r\n  {\r\n    mapping(address =\u003E IndexValue) data;\r\n    KeyFlag[] keys;\r\n    uint size;\r\n  }\r\n  struct IndexValue { uint keyIndex; uint value; }\r\n  struct KeyFlag { address key; bool deleted; }\r\n  function insert(itmap storage self, address key, uint value) public returns (bool replaced)\r\n  {\r\n    uint keyIndex = self.data[key].keyIndex;\r\n    self.data[key].value = value;\r\n    if (keyIndex \u003E 0)\r\n      return true;\r\n    else\r\n    {\r\n      keyIndex = self.keys.length\u002B\u002B;\r\n      self.data[key].keyIndex = keyIndex \u002B 1;\r\n      self.keys[keyIndex].key = key;\r\n      self.size\u002B\u002B;\r\n      return false;\r\n    }\r\n  }\r\n  function remove(itmap storage self, address key) public returns (bool success)\r\n  {\r\n    uint keyIndex = self.data[key].keyIndex;\r\n    if (keyIndex == 0)\r\n      return false;\r\n    delete self.data[key];\r\n    self.keys[keyIndex - 1].deleted = true;\r\n    self.size --;\r\n  }\r\n  function contains(itmap storage self, address key) public view returns (bool)\r\n  {\r\n    return self.data[key].keyIndex \u003E 0;\r\n  }\r\n  function iterate_start(itmap storage self) public view returns (uint keyIndex)\r\n  {\r\n    return iterate_next(self, uint(-1));\r\n  }\r\n  function iterate_valid(itmap storage self, uint keyIndex) public view returns (bool)\r\n  {\r\n    return keyIndex \u003C self.keys.length;\r\n  }\r\n  function iterate_next(itmap storage self, uint keyIndex) public view returns (uint)\r\n  {\r\n    uint _tmpKeyIndex = keyIndex;\r\n    _tmpKeyIndex\u002B\u002B;\r\n    while (_tmpKeyIndex \u003C self.keys.length \u0026\u0026 self.keys[_tmpKeyIndex].deleted)\r\n      _tmpKeyIndex\u002B\u002B;\r\n    return _tmpKeyIndex;\r\n  }\r\n  function iterate_get(itmap storage self, uint keyIndex) public view returns (address key, uint value)\r\n  {\r\n    key = self.keys[keyIndex].key;\r\n    value = self.data[key].value;\r\n  }\r\n  function iterate_getValue(itmap storage self, address key) public view returns (uint value) {\r\n      return self.data[key].value;\r\n  }\r\n}\r\n\r\n// File: zeppelin-solidity/contracts/ownership/Ownable.sol\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n  address public owner;\r\n\r\n\r\n  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n\r\n  /**\r\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n    constructor () public {\r\n    \towner = msg.sender;\r\n    }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner,\u0022called by any account other than the owner\u0022);\r\n    _;\r\n  }\r\n\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param newOwner The address to transfer ownership to.\r\n   */\r\n  function transferOwnership(address newOwner) public onlyOwner {\r\n    require(newOwner != address(0),\u0022owner address should not 0\u0022);\r\n    emit OwnershipTransferred(owner, newOwner);\r\n    owner = newOwner;\r\n  }\r\n\r\n}\r\n\r\n// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol\r\n\r\n/**\r\n * @title Pausable\r\n * @dev Base contract which allows children to implement an emergency stop mechanism.\r\n */\r\ncontract Pausable is Ownable {\r\n  event Pause();\r\n  event Unpause();\r\n\r\n  bool public paused = false;\r\n\r\n\r\n  /**\r\n   * @dev Modifier to make a function callable only when the contract is not paused.\r\n   */\r\n  modifier whenNotPaused() {\r\n    require(!paused,\u0022callable when the contract is not paused\u0022);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Modifier to make a function callable only when the contract is paused.\r\n   */\r\n  modifier whenPaused() {\r\n    require(paused,\u0022callable when the contract is paused\u0022);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev called by the owner to pause, triggers stopped state\r\n   */\r\n  function pause() public onlyOwner whenNotPaused {\r\n    paused = true;\r\n    emit Pause();\r\n  }\r\n\r\n  /**\r\n   * @dev called by the owner to unpause, returns to normal state\r\n   */\r\n  function unpause() public onlyOwner whenPaused  {\r\n    paused = false;\r\n    emit Unpause();\r\n  }\r\n}\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n\r\n  /**\r\n  * @dev Multiplies two numbers, throws on overflow.\r\n  */\r\n  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {\r\n    // Gas optimization: this is cheaper than asserting \u0027a\u0027 not being zero, but the\r\n    // benefit is lost if \u0027b\u0027 is also tested.\r\n    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n    if (_a == 0) {\r\n      return 0;\r\n    }\r\n\r\n    c = _a * _b;\r\n    assert(c / _a == _b);\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Integer division of two numbers, truncating the quotient.\r\n  */\r\n  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n    assert(_b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    uint256 c = _a / _b;\r\n    assert(_a == _b * c \u002B _a % _b); // There is no case in which this doesn\u0027t hold\r\n    return _a / _b;\r\n  }\r\n\r\n  /**\r\n  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n  */\r\n  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n    assert(_b \u003C= _a);\r\n    return _a - _b;\r\n  }\r\n\r\n  /**\r\n  * @dev Adds two numbers, throws on overflow.\r\n  */\r\n  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {\r\n    c = _a \u002B _b;\r\n    assert(c \u003E= _a);\r\n    return c;\r\n  }\r\n}\r\n\r\n/**\r\n * @title ERC20Basic\r\n * @dev Simpler version of ERC20 interface\r\n * See https://github.com/ethereum/EIPs/issues/179\r\n */\r\ncontract ERC20Basic {\r\n  function totalSupply() public view returns (uint256);\r\n  function balanceOf(address _who) public view returns (uint256);\r\n  function transfer(address _to, uint256 _value) public returns (bool);\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\n\r\n/**\r\n * @title Basic token\r\n * @dev Basic version of StandardToken, with no allowances.\r\n */\r\ncontract BasicToken is ERC20Basic {\r\n  using SafeMath for uint256;\r\n  IterableMapping.itmap balances;\r\n\r\n  uint256 internal totalSupply_;\r\n\r\n  /**\r\n  * @dev Total number of tokens in existence\r\n  */\r\n  function totalSupply() public view returns (uint256) {\r\n    return totalSupply_;\r\n  }\r\n\r\n  /**\r\n  * @dev Transfer token for a specified address\r\n  * @param _to The address to transfer to.\r\n  * @param _value The amount to be transferred.\r\n  */\r\n  function transfer(address _to, uint256 _value) public returns (bool) {\r\n\r\n    require(_value \u003C= IterableMapping.iterate_getValue(balances, msg.sender),\u0022not enough balances\u0022);\r\n    require(_to != address(0),\u00220 address not allow\u0022);\r\n\r\n    IterableMapping.insert(balances, msg.sender, IterableMapping.iterate_getValue(balances, msg.sender).sub(_value));\r\n    IterableMapping.insert(balances, _to, IterableMapping.iterate_getValue(balances, _to).add(_value));\r\n    emit Transfer(msg.sender, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n  * @dev Gets the balance of the specified address.\r\n  * @param _owner The address to query the the balance of.\r\n  * @return An uint256 representing the amount owned by the passed address.\r\n  */\r\n  function balanceOf(address _owner) public view returns (uint256) {\r\n      return IterableMapping.iterate_getValue(balances, _owner);\r\n  }\r\n\r\n}\r\n\r\n\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ncontract ERC20 is ERC20Basic {\r\n  function allowance(address _owner, address _spender)\r\n    public view returns (uint256);\r\n\r\n  function transferFrom(address _from, address _to, uint256 _value)\r\n    public returns (bool);\r\n\r\n  function approve(address _spender, uint256 _value) public returns (bool);\r\n  event Approval(\r\n    address indexed owner,\r\n    address indexed spender,\r\n    uint256 value\r\n  );\r\n}\r\n\r\n/**\r\n * @title Standard ERC20 token\r\n *\r\n * @dev Implementation of the basic standard token.\r\n * https://github.com/ethereum/EIPs/issues/20\r\n * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol\r\n */\r\ncontract StandardToken is ERC20, BasicToken {\r\n\r\n  mapping (address =\u003E mapping (address =\u003E uint256)) internal allowed;\r\n\r\n\r\n  /**\r\n   * @dev Transfer tokens from one address to another\r\n   * @param _from address The address which you want to send tokens from\r\n   * @param _to address The address which you want to transfer to\r\n   * @param _value uint256 the amount of tokens to be transferred\r\n   */\r\n  function transferFrom(\r\n    address _from,\r\n    address _to,\r\n    uint256 _value\r\n  )\r\n    public\r\n    returns (bool)\r\n  {\r\n\r\n    require(_value \u003C= IterableMapping.iterate_getValue(balances, _from),\u0022balance not enough\u0022);\r\n    require(_value \u003C= allowed[_from][msg.sender],\u0022balance not enough\u0022);\r\n    require(_to != address(0),\u00220 address not allow\u0022);\r\n\r\n    IterableMapping.insert(balances, _from, IterableMapping.iterate_getValue(balances, _from).sub(_value));\r\n    IterableMapping.insert(balances, _to, IterableMapping.iterate_getValue(balances, _to).add(_value));\r\n    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n    emit Transfer(_from, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\r\n   * Beware that changing an allowance with this method brings the risk that someone may use both the old\r\n   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\r\n   * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\r\n   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n   * @param _spender The address which will spend the funds.\r\n   * @param _value The amount of tokens to be spent.\r\n   */\r\n  function approve(address _spender, uint256 _value) public returns (bool) {\r\n    allowed[msg.sender][_spender] = _value;\r\n    emit Approval(msg.sender, _spender, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Function to check the amount of tokens that an owner allowed to a spender.\r\n   * @param _owner address The address which owns the funds.\r\n   * @param _spender address The address which will spend the funds.\r\n   * @return A uint256 specifying the amount of tokens still available for the spender.\r\n   */\r\n  function allowance(\r\n    address _owner,\r\n    address _spender\r\n   )\r\n    public\r\n    view\r\n    returns (uint256)\r\n  {\r\n    return allowed[_owner][_spender];\r\n  }\r\n\r\n  /**\r\n   * @dev Increase the amount of tokens that an owner allowed to a spender.\r\n   * approve should be called when allowed[_spender] == 0. To increment\r\n   * allowed value is better to use this function to avoid 2 calls (and wait until\r\n   * the first transaction is mined)\r\n   * From MonolithDAO Token.sol\r\n   * @param _spender The address which will spend the funds.\r\n   * @param _addedValue The amount of tokens to increase the allowance by.\r\n   */\r\n  function increaseApproval(\r\n    address _spender,\r\n    uint256 _addedValue\r\n  )\r\n    public\r\n    returns (bool)\r\n  {\r\n    allowed[msg.sender][_spender] = (\r\n      allowed[msg.sender][_spender].add(_addedValue));\r\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Decrease the amount of tokens that an owner allowed to a spender.\r\n   * approve should be called when allowed[_spender] == 0. To decrement\r\n   * allowed value is better to use this function to avoid 2 calls (and wait until\r\n   * the first transaction is mined)\r\n   * From MonolithDAO Token.sol\r\n   * @param _spender The address which will spend the funds.\r\n   * @param _subtractedValue The amount of tokens to decrease the allowance by.\r\n   */\r\n  function decreaseApproval(\r\n    address _spender,\r\n    uint256 _subtractedValue\r\n  )\r\n    public\r\n    returns (bool)\r\n  {\r\n    uint256 oldValue = allowed[msg.sender][_spender];\r\n    if (_subtractedValue \u003E= oldValue) {\r\n      allowed[msg.sender][_spender] = 0;\r\n    } else {\r\n      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\r\n    }\r\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n    return true;\r\n  }\r\n\r\n}\r\n\r\n/**\r\n * @title Pausable token\r\n *\r\n * @dev StandardToken modified with pausable transfers.\r\n **/\r\n\r\ncontract PausableToken is StandardToken, Pausable {\r\n\r\n  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {\r\n    return super.transfer(_to, _value);\r\n  }\r\n\r\n  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {\r\n    return super.transferFrom(_from, _to, _value);\r\n  }\r\n\r\n  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {\r\n    return super.approve(_spender, _value);\r\n  }\r\n\r\n  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {\r\n    return super.increaseApproval(_spender, _addedValue);\r\n  }\r\n\r\n  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {\r\n    return super.decreaseApproval(_spender, _subtractedValue);\r\n  }\r\n}\r\n\r\ncontract LKBT is PausableToken {\r\n    string public name = \u0022LKBT Token\u0022;\r\n    string public symbol = \u0022LKBT\u0022;\r\n    uint8 public decimals = 18;\r\n    uint256 public INITIAL_SUPPLY = 10000000000 ether;\r\n\r\n    constructor () public {\r\n    \ttotalSupply_ = INITIAL_SUPPLY;\r\n    \tIterableMapping.insert(balances, msg.sender, INITIAL_SUPPLY);\r\n    }\r\n\r\n    function balancesStart() public view returns(uint256) {\r\n        return IterableMapping.iterate_start(balances);\r\n    }\r\n\r\n    function balancesGetBool(uint256 num) public view returns(bool){\r\n        return IterableMapping.iterate_valid(balances, num);\r\n    }\r\n\r\n    function balancesGetNext(uint256 num) public view returns(uint256) {\r\n        return IterableMapping.iterate_next(balances, num);\r\n    }\r\n    function balancesGetValue(uint256 num) public view returns(address, uint256) {\r\n        address key;\r\n        uint256 value;\r\n        (key, value) = IterableMapping.iterate_get(balances, num);\r\n        return (key, value);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022INITIAL_SUPPLY\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022num\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022balancesGetValue\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022balancesStart\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022num\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022balancesGetNext\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022num\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022balancesGetBool\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Pause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Unpause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"LKBT","CompilerVersion":"v0.5.1\u002Bcommit.c8a2cb62","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"IterableMapping:99f8606945b9851f46cb970d2d63bfcb3b95f078","SwarmSource":"bzzr://f6bda5a8a02c9fd19601a8a0bf07c92585d725fcdeffa2a74e8204ccb30fa888"}]