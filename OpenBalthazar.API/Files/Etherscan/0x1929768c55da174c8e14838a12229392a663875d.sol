[{"SourceCode":"/**\r\n BCO \r\n */\r\n\r\n\r\npragma solidity 0.4.23;\r\n\r\ncontract ERC20Basic {\r\n  function totalSupply() public view returns (uint256);\r\n  function balanceOf(address who) public view returns (uint256);\r\n  function transfer(address to, uint256 value) public returns (bool);\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n}\r\n\r\n\r\n\r\ncontract ERC20 is ERC20Basic {\r\n  function allowance(address owner, address spender) public view returns (uint256);\r\n  function transferFrom(address from, address to, uint256 value) public returns (bool);\r\n  function approve(address spender, uint256 value) public returns (bool);\r\n  event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\n\r\n\r\ncontract DetailedERC20 is ERC20 {\r\n  string public name;\r\n  string public symbol;\r\n  uint8 public decimals;\r\n\r\n  constructor(string _name, string _symbol, uint8 _decimals) public {\r\n    name = _name;\r\n    symbol = _symbol;\r\n    decimals = _decimals;\r\n  }\r\n}\r\n\r\n\r\n\r\ncontract Ownable {\r\n  address public owner;\r\n  address public admin;\r\n\r\n  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n  /**\r\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n   * account.\r\n   */\r\n  constructor() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  modifier onlyOwnerOrAdmin() {\r\n    require(msg.sender != address(0) \u0026\u0026 (msg.sender == owner || msg.sender == admin));\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n   * @param newOwner The address to transfer ownership to.\r\n   */\r\n  function transferOwnership(address newOwner) onlyOwner public {\r\n    require(newOwner != address(0));\r\n    require(newOwner != owner);\r\n    require(newOwner != admin);\r\n\r\n    emit OwnershipTransferred(owner, newOwner);\r\n    owner = newOwner;\r\n  }\r\n\r\n  function setAdmin(address newAdmin) onlyOwner public {\r\n    require(admin != newAdmin);\r\n    require(owner != newAdmin);\r\n\r\n    admin = newAdmin;\r\n  }\r\n}\r\n\r\n\r\n\r\nlibrary SafeMath {\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0 || b == 0) {\r\n      return 0;\r\n    }\r\n\r\n    uint256 c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a); // overflow check\r\n    return c;\r\n  }\r\n}\r\n\r\n\r\n\r\ncontract BasicToken is ERC20Basic {\r\n  using SafeMath for uint256;\r\n\r\n  mapping(address =\u003E uint256) balances;\r\n\r\n  uint256 _totalSupply;\r\n\r\n  /**\r\n  * @dev total number of tokens in existence\r\n  */\r\n  function totalSupply() public view returns (uint256) {\r\n    return _totalSupply;\r\n  }\r\n\r\n  /**\r\n  * @dev transfer token for a specified address\r\n  * @param _to The address to transfer to.\r\n  * @param _value The amount to be transferred.\r\n  */\r\n  function transfer(address _to, uint256 _value) public returns (bool) {\r\n    require(_to != address(0));\r\n    require(_value \u003E 0);\r\n    require(_value \u003C= balances[msg.sender]);\r\n\r\n    // SafeMath.sub will throw if there is not enough balance.\r\n    balances[msg.sender] = balances[msg.sender].sub(_value);\r\n    balances[_to] = balances[_to].add(_value);\r\n    emit Transfer(msg.sender, _to, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n  * @dev Gets the balance of the specified address.\r\n  * @param _owner The address to query the the balance of.\r\n  * @return An uint256 representing the amount owned by the passed address.\r\n  */\r\n  function balanceOf(address _owner) public view returns (uint256 balance) {\r\n    return balances[_owner];\r\n  }\r\n}\r\n\r\ncontract ERC20Token is BasicToken, ERC20 {\r\n  using SafeMath for uint256;\r\n  mapping (address =\u003E mapping (address =\u003E uint256)) allowed;\r\n\r\n  function approve(address _spender, uint256 _value) public returns (bool) {\r\n    require(_value == 0 || allowed[msg.sender][_spender] == 0);\r\n\r\n    allowed[msg.sender][_spender] = _value;\r\n    emit Approval(msg.sender, _spender, _value);\r\n\r\n    return true;\r\n  }\r\n\r\n  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {\r\n    return allowed[_owner][_spender];\r\n  }\r\n\r\n  function increaseApproval(address _spender, uint256 _addedValue) public returns (bool success) {\r\n    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);\r\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n    return true;\r\n  }\r\n\r\n  function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool success) {\r\n    uint256 oldValue = allowed[msg.sender][_spender];\r\n    if (_subtractedValue \u003E= oldValue) {\r\n      allowed[msg.sender][_spender] = 0;\r\n    } else {\r\n      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\r\n    }\r\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\r\n    return true;\r\n  }\r\n\r\n}\r\n/**\r\n * @title Mintable token\r\n * @dev Simple ERC20 Token example, with mintable token creation\r\n * @dev Issue: * https://github.com/OpenZeppelin/openzeppelin-solidity/issues/120\r\n * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol\r\n */\r\ncontract MintableToken is BasicToken, Ownable {\r\n  event Mint(address indexed to, uint256 amount);\r\n  event MintFinished();\r\n\r\n  bool public mintingFinished = false;\r\n\r\n\r\n  modifier canMint() {\r\n    require(!mintingFinished);\r\n    _;\r\n  }\r\n\r\n  modifier hasMintPermission() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Function to mint tokens\r\n   * @param _to The address that will receive the minted tokens.\r\n   * @param _value The amount of tokens to mint.\r\n   * @return A boolean that indicates if the operation was successful.\r\n   */\r\n  function mint(\r\n    address _to,\r\n    uint256 _value\r\n  )\r\n    hasMintPermission\r\n    canMint\r\n    onlyOwner\r\n    public\r\n    returns (bool)\r\n  {\r\n    balances[msg.sender] = balances[msg.sender].add(_value);\r\n    _totalSupply = _totalSupply.add(_value);\r\n    \r\n    emit Mint(_to, _value);\r\n    emit Transfer(address(0), _to, _value);\r\n    return true;\r\n  }\r\n\r\n  /**\r\n   * @dev Function to stop minting new tokens.\r\n   * @return True if the operation was successful.\r\n   */\r\n  function finishMinting() onlyOwner canMint public returns (bool) {\r\n    mintingFinished = true;\r\n    emit MintFinished();\r\n    return true;\r\n  }\r\n}\r\n\r\n\r\ncontract BurnableToken is BasicToken, Ownable {\r\n  // events\r\n  event Burn(address indexed burner, uint256 amount);\r\n\r\n  // reduce sender balance and Token total supply\r\n  function burn(uint256 _value) onlyOwner public {\r\n    balances[msg.sender] = balances[msg.sender].sub(_value);\r\n    _totalSupply = _totalSupply.sub(_value);\r\n    emit Burn(msg.sender, _value);\r\n    emit Transfer(msg.sender, address(0), _value);\r\n  }\r\n}\r\n\r\n\r\ncontract TokenLock is Ownable {\r\n  using SafeMath for uint256;\r\n\r\n  bool public transferEnabled = false; // indicates that token is transferable or not\r\n  bool public noTokenLocked = false; // indicates all token is released or not\r\n\r\n  struct TokenLockInfo { // token of \u0060amount\u0060 cannot be moved before \u0060time\u0060\r\n    uint256 amount; // locked amount\r\n    uint256 time; // unix timestamp\r\n  }\r\n\r\n  struct TokenLockState {\r\n    uint256 latestReleaseTime;\r\n    TokenLockInfo[] tokenLocks; // multiple token locks can exist\r\n  }\r\n\r\n  mapping(address =\u003E TokenLockState) lockingStates;\r\n  event AddTokenLock(address indexed to, uint256 time, uint256 amount);\r\n\r\n  function unlockAllTokens() public onlyOwner {\r\n    noTokenLocked = true;\r\n  }\r\n\r\n  function enableTransfer(bool _enable) public onlyOwner {\r\n    transferEnabled = _enable;\r\n  }\r\n\r\n  // calculate the amount of tokens an address can use\r\n  function getMinLockedAmount(address _addr) view public returns (uint256 locked) {\r\n    uint256 i;\r\n    uint256 a;\r\n    uint256 t;\r\n    uint256 lockSum = 0;\r\n\r\n    // if the address has no limitations just return 0\r\n    TokenLockState storage lockState = lockingStates[_addr];\r\n    if (lockState.latestReleaseTime \u003C now) {\r\n      return 0;\r\n    }\r\n\r\n    for (i=0; i\u003ClockState.tokenLocks.length; i\u002B\u002B) {\r\n      a = lockState.tokenLocks[i].amount;\r\n      t = lockState.tokenLocks[i].time;\r\n\r\n      if (t \u003E now) {\r\n        lockSum = lockSum.add(a);\r\n      }\r\n    }\r\n\r\n    return lockSum;\r\n  }\r\n\r\n  function addTokenLock(address _addr, uint256 _value, uint256 _release_time) onlyOwnerOrAdmin public {\r\n    require(_addr != address(0));\r\n    require(_value \u003E 0);\r\n    require(_release_time \u003E now);\r\n\r\n    TokenLockState storage lockState = lockingStates[_addr]; // assigns a pointer. change the member value will update struct itself.\r\n    if (_release_time \u003E lockState.latestReleaseTime) {\r\n      lockState.latestReleaseTime = _release_time;\r\n    }\r\n    lockState.tokenLocks.push(TokenLockInfo(_value, _release_time));\r\n\r\n    emit AddTokenLock(_addr, _release_time, _value);\r\n  }\r\n}\r\n\r\n\r\ncontract BCO is MintableToken, BurnableToken, DetailedERC20, ERC20Token, TokenLock {\r\n  using SafeMath for uint256;\r\n\r\n  // events\r\n  event Approval(address indexed owner, address indexed spender, uint256 value);\r\n\r\n  string public constant symbol = \u0022BCO\u0022;\r\n  string public constant name = \u0022BCO\u0022;\r\n  uint8 public constant decimals = 8;\r\n  uint256 public constant TOTAL_SUPPLY = 1*(10**10)*(10**uint256(decimals));\r\n\r\n  constructor() DetailedERC20(name, symbol, decimals) public {\r\n    _totalSupply = TOTAL_SUPPLY;\r\n\r\n    // initial supply belongs to owner\r\n    balances[owner] = _totalSupply;\r\n    emit Transfer(address(0x0), msg.sender, _totalSupply);\r\n  }\r\n\r\n  // modifiers\r\n  // checks if the address can transfer tokens\r\n  modifier canTransfer(address _sender, uint256 _value) {\r\n    require(_sender != address(0));\r\n    require(\r\n      (_sender == owner || _sender == admin) || (\r\n        transferEnabled \u0026\u0026 (\r\n          noTokenLocked ||\r\n          canTransferIfLocked(_sender, _value)\r\n        )\r\n      )\r\n    );\r\n\r\n    _;\r\n  }\r\n\r\n  function setAdmin(address newAdmin) onlyOwner public {\r\n    address oldAdmin = admin;\r\n    super.setAdmin(newAdmin);\r\n    approve(oldAdmin, 0);\r\n    approve(newAdmin, TOTAL_SUPPLY);\r\n  }\r\n\r\n  modifier onlyValidDestination(address to) {\r\n    require(to != address(0x0));\r\n    require(to != address(this));\r\n    require(to != owner);\r\n    _;\r\n  }\r\n\r\n  function canTransferIfLocked(address _sender, uint256 _value) public view returns(bool) {\r\n    uint256 after_math = balances[_sender].sub(_value);\r\n    return after_math \u003E= getMinLockedAmount(_sender);\r\n  }\r\n\r\n  // override function using canTransfer on the sender address\r\n  function transfer(address _to, uint256 _value) onlyValidDestination(_to) canTransfer(msg.sender, _value) public returns (bool success) {\r\n    return super.transfer(_to, _value);\r\n  }\r\n\r\n  // transfer tokens from one address to another\r\n  function transferFrom(address _from, address _to, uint256 _value) onlyValidDestination(_to) canTransfer(_from, _value) public returns (bool success) {\r\n    // SafeMath.sub will throw if there is not enough balance.\r\n    balances[_from] = balances[_from].sub(_value);\r\n    balances[_to] = balances[_to].add(_value);\r\n    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value); // this will throw if we don\u0027t have enough allowance\r\n\r\n    // this event comes from BasicToken.sol\r\n    emit Transfer(_from, _to, _value);\r\n\r\n    return true;\r\n  }\r\n\r\n  function() public payable { // don\u0027t send eth directly to token contract\r\n    revert();\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022mintingFinished\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_release_time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022addTokenLock\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022noTokenLocked\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022mint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022transferEnabled\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unlockAllTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newAdmin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getMinLockedAmount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022locked\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022canTransferIfLocked\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022finishMinting\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TOTAL_SUPPLY\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_enable\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022enableTransfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022admin\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022AddTokenLock\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022burner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Mint\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MintFinished\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"BCO","CompilerVersion":"v0.4.23\u002Bcommit.124ca40d","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://4437b64d0049c52171f678cd68f38293fd5f3ade238c4ae0a541dbe63e2db683"}]