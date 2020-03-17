[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\n// File: node_modules\\zeppelin-solidity\\contracts\\math\\SafeMath.sol\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n\r\n  /**\r\n  * @dev Multiplies two numbers, throws on overflow.\r\n  */\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n    // Gas optimization: this is cheaper than asserting \u0027a\u0027 not being zero, but the\r\n    // benefit is lost if \u0027b\u0027 is also tested.\r\n    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n\r\n    c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Integer division of two numbers, truncating the quotient.\r\n  */\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    // uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return a / b;\r\n  }\r\n\r\n  /**\r\n  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n  */\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  /**\r\n  * @dev Adds two numbers, throws on overflow.\r\n  */\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {\r\n    c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\n// File: node_modules\\zeppelin-solidity\\contracts\\ownership\\Ownable.sol\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n  address public owner;\r\n\r\n  event OwnershipTransferred(\r\n    address indexed previousOwner,\r\n    address indexed newOwner\r\n  );\r\n\r\n\r\n  /**\r\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n  constructor() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param _newOwner The address to transfer ownership to.\r\n   */\r\n  function transferOwnership(address _newOwner) public onlyOwner {\r\n    _transferOwnership(_newOwner);\r\n  }\r\n\r\n  /**\r\n   * @dev Transfers control of the contract to a newOwner.\r\n   * @param _newOwner The address to transfer ownership to.\r\n   */\r\n  function _transferOwnership(address _newOwner) internal {\r\n    require(_newOwner != address(0));\r\n    emit OwnershipTransferred(owner, _newOwner);\r\n    owner = _newOwner;\r\n  }\r\n}\r\n\r\n// File: node_modules\\zeppelin-solidity\\contracts\\token\\ERC20\\ERC20Basic.sol\r\n\r\n/**\r\n * @title ERC20Basic\r\n * @dev Simpler version of ERC20 interface\r\n * See https://github.com/ethereum/EIPs/issues/179\r\n */\r\ncontract ERC20Basic {\r\n  function totalSupply() public view returns (uint256);\r\n  function balanceOf(address who) public view returns (uint256);\r\n  function transfer(address to, uint256 value) public returns (bool);\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\n// File: node_modules\\zeppelin-solidity\\contracts\\token\\ERC20\\BasicToken.sol\r\n\r\n/**\r\n * @title Basic token\r\n * @dev Basic version of StandardToken, with no allowances.\r\n */\r\ncontract BasicToken is ERC20Basic {\r\n  using SafeMath for uint256;\r\n\r\n  mapping(address =\u003E uint256) balances;\r\n\r\n  uint256 totalSupply_;\r\n\r\n  /**\r\n  * @dev Total number of tokens in existence\r\n  */\r\n  function totalSupply() public view returns (uint256) {\r\n    return totalSupply_;\r\n  }\r\n\r\n  /**\r\n  * @dev Transfer token for a specified address\r\n  * @param _to The address to transfer to.\r\n  * @param _value The amount to be transferred.\r\n  */\r\n  function transfer(address _to, uint256 _value) public returns (bool) {\r\n    require(_to != address(0));\r\n    require(_value \u003C= balances[msg.sender]);\r\n\r\n    balances[msg.sender] = balances[msg.sender].sub(_value);\r\n    balances[_to] = balances[_to].add(_value);\r\n    emit Transfer(msg.sender, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n  * @dev Gets the balance of the specified address.\r\n  * @param _owner The address to query the the balance of.\r\n  * @return An uint256 representing the amount owned by the passed address.\r\n  */\r\n  function balanceOf(address _owner) public view returns (uint256) {\r\n    return balances[_owner];\r\n  }\r\n\r\n}\r\n\r\n// File: node_modules\\zeppelin-solidity\\contracts\\token\\ERC20\\ERC20.sol\r\n\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ncontract ERC20 is ERC20Basic {\r\n  function allowance(address owner, address spender)\r\n    public view returns (uint256);\r\n\r\n  function transferFrom(address from, address to, uint256 value)\r\n    public returns (bool);\r\n\r\n  function approve(address spender, uint256 value) public returns (bool);\r\n  event Approval(\r\n    address indexed owner,\r\n    address indexed spender,\r\n    uint256 value\r\n  );\r\n}\r\n\r\n// File: node_modules\\zeppelin-solidity\\contracts\\token\\ERC20\\StandardToken.sol\r\n\r\n/**\r\n * @title Standard ERC20 token\r\n *\r\n * @dev Implementation of the basic standard token.\r\n * https://github.com/ethereum/EIPs/issues/20\r\n * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol\r\n */\r\ncontract StandardToken is ERC20, BasicToken {\r\n\r\n  mapping (address =\u003E mapping (address =\u003E uint256)) internal allowed;\r\n\r\n\r\n  /**\r\n   * @dev Transfer tokens from one address to another\r\n   * @param _from address The address which you want to send tokens from\r\n   * @param _to address The address which you want to transfer to\r\n   * @param _value uint256 the amount of tokens to be transferred\r\n   */\r\n  function transferFrom(\r\n    address _from,\r\n    address _to,\r\n    uint256 _value\r\n  )\r\n    public\r\n    returns (bool)\r\n  {\r\n    require(_to != address(0));\r\n    require(_value \u003C= balances[_from]);\r\n    require(_value \u003C= allowed[_from][msg.sender]);\r\n\r\n    balances[_from] = balances[_from].sub(_value);\r\n    balances[_to] = balances[_to].add(_value);\r\n    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\r\n    emit Transfer(_from, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\r\n   * Beware that changing an allowance with this method brings the risk that someone may use both the old\r\n   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\r\n   * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\r\n   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n   * @param _spender The address which will spend the funds.\r\n   * @param _value The amount of tokens to be spent.\r\n   */\r\n  function approve(address _spender, uint256 _value) public returns (bool) {\r\n    allowed[msg.sender][_spender] = _value;\r\n    emit Approval(msg.sender, _spender, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Function to check the amount of tokens that an owner allowed to a spender.\r\n   * @param _owner address The address which owns the funds.\r\n   * @param _spender address The address which will spend the funds.\r\n   * @return A uint256 specifying the amount of tokens still available for the spender.\r\n   */\r\n  function allowance(\r\n    address _owner,\r\n    address _spender\r\n   )\r\n    public\r\n    view\r\n    returns (uint256)\r\n  {\r\n    return allowed[_owner][_spender];\r\n  }\r\n\r\n  /**\r\n   * @dev Increase the amount of tokens that an owner allowed to a spender.\r\n   * approve should be called when allowed[_spender] == 0. To increment\r\n   * allowed value is better to use this function to avoid 2 calls (and wait until\r\n   * the first transaction is mined)\r\n   * From MonolithDAO Token.sol\r\n   * @param _spender The address which will spend the funds.\r\n   * @param _addedValue The amount of tokens to increase the allowance by.\r\n   */\r\n  function increaseApproval(\r\n    address _spender,\r\n    uint256 _addedValue\r\n  )\r\n    public\r\n    returns (bool)\r\n  {\r\n    allowed[msg.sender][_spender] = (\r\n      allowed[msg.sender][_spender].add(_addedValue));\r\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Decrease the amount of tokens that an owner allowed to a spender.\r\n   * approve should be called when allowed[_spender] == 0. To decrement\r\n   * allowed value is better to use this function to avoid 2 calls (and wait until\r\n   * the first transaction is mined)\r\n   * From MonolithDAO Token.sol\r\n   * @param _spender The address which will spend the funds.\r\n   * @param _subtractedValue The amount of tokens to decrease the allowance by.\r\n   */\r\n  function decreaseApproval(\r\n    address _spender,\r\n    uint256 _subtractedValue\r\n  )\r\n    public\r\n    returns (bool)\r\n  {\r\n    uint256 oldValue = allowed[msg.sender][_spender];\r\n    if (_subtractedValue \u003E= oldValue) {\r\n      allowed[msg.sender][_spender] = 0;\r\n    } else {\r\n      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\r\n    }\r\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n    return true;\r\n  }\r\n\r\n}\r\n\r\n// File: node_modules\\zeppelin-solidity\\contracts\\lifecycle\\Pausable.sol\r\n\r\n/**\r\n * @title Pausable\r\n * @dev Base contract which allows children to implement an emergency stop mechanism.\r\n */\r\ncontract Pausable is Ownable {\r\n  event Pause();\r\n  event Unpause();\r\n\r\n  bool public paused = false;\r\n\r\n\r\n  /**\r\n   * @dev Modifier to make a function callable only when the contract is not paused.\r\n   */\r\n  modifier whenNotPaused() {\r\n    require(!paused);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Modifier to make a function callable only when the contract is paused.\r\n   */\r\n  modifier whenPaused() {\r\n    require(paused);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev called by the owner to pause, triggers stopped state\r\n   */\r\n  function pause() onlyOwner whenNotPaused public {\r\n    paused = true;\r\n    emit Pause();\r\n  }\r\n\r\n  /**\r\n   * @dev called by the owner to unpause, returns to normal state\r\n   */\r\n  function unpause() onlyOwner whenPaused public {\r\n    paused = false;\r\n    emit Unpause();\r\n  }\r\n}\r\n\r\n// File: node_modules\\zeppelin-solidity\\contracts\\token\\ERC20\\PausableToken.sol\r\n\r\n/**\r\n * @title Pausable token\r\n * @dev StandardToken modified with pausable transfers.\r\n **/\r\ncontract PausableToken is StandardToken, Pausable {\r\n\r\n  function transfer(\r\n    address _to,\r\n    uint256 _value\r\n  )\r\n    public\r\n    whenNotPaused\r\n    returns (bool)\r\n  {\r\n    return super.transfer(_to, _value);\r\n  }\r\n\r\n  function transferFrom(\r\n    address _from,\r\n    address _to,\r\n    uint256 _value\r\n  )\r\n    public\r\n    whenNotPaused\r\n    returns (bool)\r\n  {\r\n    return super.transferFrom(_from, _to, _value);\r\n  }\r\n\r\n  function approve(\r\n    address _spender,\r\n    uint256 _value\r\n  )\r\n    public\r\n    whenNotPaused\r\n    returns (bool)\r\n  {\r\n    return super.approve(_spender, _value);\r\n  }\r\n\r\n  function increaseApproval(\r\n    address _spender,\r\n    uint _addedValue\r\n  )\r\n    public\r\n    whenNotPaused\r\n    returns (bool success)\r\n  {\r\n    return super.increaseApproval(_spender, _addedValue);\r\n  }\r\n\r\n  function decreaseApproval(\r\n    address _spender,\r\n    uint _subtractedValue\r\n  )\r\n    public\r\n    whenNotPaused\r\n    returns (bool success)\r\n  {\r\n    return super.decreaseApproval(_spender, _subtractedValue);\r\n  }\r\n}\r\n\r\n// File: contracts\\HKExCoin.sol\r\n\r\n/*****************************************************************************\r\n *\r\n *Copyright 2018 HKExCoin\r\n *\r\n *Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n *you may not use this file except in compliance with the License.\r\n *You may obtain a copy of the License at\r\n *\r\n *    http://www.apache.org/licenses/LICENSE-2.0\r\n *\r\n *Unless required by applicable law or agreed to in writing, software\r\n *distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n *WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n *See the License for the specific language governing permissions and\r\n *limitations under the License.\r\n *\r\n *****************************************************************************/\r\n\r\ncontract HKExCoin is PausableToken\r\n{\r\n  using SafeMath for uint256;\r\n  \r\n  // ERC20 constants\r\n  string public name=\u0022HKExCoin\u0022;\r\n  string public symbol=\u0022HKC\u0022;\r\n  string public standard=\u0022ERC20\u0022;\r\n  \r\n  uint8 public constant decimals = 18; // solium-disable-line uppercase\r\n  \r\n  uint256 public constant INITIAL_SUPPLY = 10 *(10**8)*(10 ** uint256(decimals));\r\n  \r\n  event NewLock(address indexed target,uint256 indexed locktime,uint256 lockamount);\r\n  event UnLock(address indexed target,uint256 indexed unlocktime,uint256 unlockamount);\r\n    \r\n  mapping(address =\u003E TimeLock[]) public allocations;\r\n  \r\n  struct TimeLock\r\n  {\r\n      uint256 releaseTime;\r\n      uint256 balance;\r\n  }\r\n\r\n  /*Here is the constructor function that is executed when the instance is created*/\r\n  constructor() public \r\n  {\r\n    totalSupply_ = INITIAL_SUPPLY;\r\n    balances[msg.sender] = INITIAL_SUPPLY;\r\n    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);\r\n  }\r\n\r\n  function transfer(address _to, uint256 _value) public returns (bool) \r\n  {\r\n      require(canSubAllocation(msg.sender, _value));\r\n    \r\n      subAllocation(msg.sender);\r\n    \r\n      return super.transfer(_to, _value); \r\n  }\r\n\r\n  function transferFrom(address _from, address _to,uint256 _value) public returns (bool)\r\n  {\r\n      require(canSubAllocation(_from, _value));\r\n\r\n      subAllocation(_from);\r\n\r\n      return super.transferFrom(_from,_to, _value); \r\n  }\r\n\r\n  function canSubAllocation(address sender, uint256 sub_value) constant private returns (bool)\r\n  {\r\n      if (sub_value==0)\r\n      {\r\n          return false;\r\n      }\r\n      \r\n      if (balances[sender] \u003C sub_value)\r\n      {\r\n          return false;\r\n      }\r\n\r\n      if (allocations[sender].length == 0)\r\n      {\r\n          return true;\r\n      }\r\n      \r\n      uint256 alllock_sum = 0;\r\n      for (uint j=0; j\u003Callocations[sender].length; j\u002B\u002B)\r\n      {\r\n          if (allocations[sender][j].releaseTime \u003E= block.timestamp)\r\n          {\r\n              alllock_sum = alllock_sum.add(allocations[sender][j].balance);\r\n          }\r\n      }\r\n      \r\n      uint256 can_unlock = balances[sender].sub(alllock_sum);\r\n      \r\n      return can_unlock \u003E= sub_value;\r\n  }\r\n\r\n  function subAllocation(address sender) private\r\n  {\r\n      uint256 total_lockamount = 0;\r\n      uint256 total_unlockamount = 0;\r\n      for (uint j=0; j\u003Callocations[sender].length; j\u002B\u002B)\r\n      {\r\n          if (allocations[sender][j].releaseTime \u003C block.timestamp)\r\n          {\r\n              total_unlockamount = total_unlockamount.add(allocations[sender][j].balance);\r\n              allocations[sender][j].balance = 0;\r\n          }\r\n          else\r\n          {\r\n              total_lockamount = total_lockamount.add(allocations[sender][j].balance);\r\n          }\r\n      }\r\n\r\n      if (total_unlockamount \u003E 0)\r\n      {\r\n        emit UnLock(sender, block.timestamp, total_unlockamount);\r\n      }\r\n      \r\n      if(total_lockamount == 0 \u0026\u0026 allocations[sender].length \u003E 0)\r\n      {\r\n          delete allocations[sender];\r\n      }\r\n  }\r\n\r\n  function setAllocation(address _address, uint256 total_value, uint[] times, uint256[] balanceRequires) public onlyOwner returns (bool)\r\n  {\r\n      require(times.length == balanceRequires.length);\r\n      require(balances[msg.sender]\u003E=total_value);   \r\n      uint256 sum = 0;\r\n      for (uint x=0; x\u003CbalanceRequires.length; x\u002B\u002B)\r\n      {\r\n          require(balanceRequires[x]\u003E0);\r\n          sum = sum.add(balanceRequires[x]);\r\n      }\r\n      \r\n      require(total_value \u003E= sum);\r\n\r\n      for (uint i=0; i\u003Ctimes.length; i\u002B\u002B)\r\n      {\r\n          bool find = false;\r\n          \r\n          for (uint j=0; j\u003Callocations[_address].length; j\u002B\u002B)\r\n          {\r\n              if (allocations[_address][j].releaseTime == times[i])\r\n              {\r\n                  allocations[_address][j].balance = allocations[_address][j].balance.add(balanceRequires[i]);\r\n                  find = true;\r\n                  break;\r\n              }\r\n          }\r\n          \r\n          if (!find)\r\n          {\r\n              allocations[_address].push(TimeLock(times[i], balanceRequires[i]));\r\n          }\r\n      }\r\n\r\n      emit NewLock(_address, block.timestamp, sum);\r\n      \r\n      return super.transfer(_address, total_value); \r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022allocations\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022releaseTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022INITIAL_SUPPLY\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022standard\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022total_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022times\u0022,\u0022type\u0022:\u0022uint256[]\u0022},{\u0022name\u0022:\u0022balanceRequires\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022setAllocation\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022locktime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022lockamount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022NewLock\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022unlocktime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022unlockamount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022UnLock\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Pause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Unpause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"HKExCoin","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://54ca0bed880059f64550c974655933c7cc513aa022c32d106f213f091221ac6d"}]