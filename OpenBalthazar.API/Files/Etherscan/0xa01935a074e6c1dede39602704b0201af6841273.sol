[{"SourceCode":"pragma solidity ^0.5.11;\r\n\r\n// Math library (standard operations)\r\nlibrary SafeMath {\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256){\r\n    uint256 c = a * b;\r\n    assert(a == 0 || c / a == b);\r\n    return c;\r\n  }\r\n  \r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n  \r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n  \r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\n// Allows owenership to be transferred between addresses for a cost (_costToBuy)\r\ncontract Ownable {\r\n  address payable private _owner;\r\n  address payable private _potentialNewOwner;\r\n  uint private _costToBuy;\r\n \r\n  event OwnershipTransferred(address payable indexed from, address payable indexed to, uint costToBuy);\r\n\r\n  constructor() internal {\r\n    _owner = msg.sender;\r\n  }\r\n  \r\n  modifier onlyOwner() {\r\n    require(msg.sender == _owner);\r\n    _;\r\n  }\r\n  \r\n  function transferOwnership(address payable newOwner) external onlyOwner {\r\n    _potentialNewOwner = newOwner;\r\n  }\r\n  \r\n  function acceptOwnership() external payable{\r\n    require(msg.sender == _potentialNewOwner);\r\n    require(_costToBuy == msg.value);\r\n    _owner.transfer(_costToBuy);\r\n    _owner = _potentialNewOwner;\r\n    emit OwnershipTransferred(_owner, _potentialNewOwner, _costToBuy);\r\n  }\r\n  \r\n  function getOwner() public view returns(address payable){\r\n      return _owner;\r\n  }\r\n  \r\n  function getCostToBuy() public view returns(uint){\r\n      return _costToBuy;\r\n  }\r\n  \r\n  function setCostToBuy(uint costToBuy) external onlyOwner{\r\n      _costToBuy = costToBuy;\r\n  }\r\n}\r\n\r\n// Allows the shutdown of the token at any time (to be used with any write operation related function)\r\ncontract CircuitBreaker is Ownable {\r\n    bool public inLockdown;\r\n\r\n    constructor () internal {\r\n        inLockdown = false;\r\n    }\r\n    \r\n    modifier outOfLockdown() {\r\n        require(inLockdown == false);\r\n        _;\r\n    }\r\n    \r\n    function updateLockdownState(bool state) public{\r\n        inLockdown = state;\r\n    }\r\n}\r\n\r\n// The interface that enforces us to use all of the ERC20 standard functions (definition)\r\ncontract ERC20Interface {\r\n    uint256 public totalSupply;\r\n    function balanceOf(address _owner) public view returns (uint256 balance);\r\n    function transfer(address _to, uint256 _value) public returns (bool success);\r\n    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\r\n    function approve(address _spender, uint256 _value) public returns (bool success);\r\n    function allowance(address _owner, address _spender) public view returns (uint256 remaining);\r\n    event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n    event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n}\r\n\r\n// The basic ERC20\r\ncontract ERC20 is ERC20Interface {\r\n  using SafeMath for uint256;\r\n\r\n  mapping(address =\u003E uint256) public balances;\r\n  mapping (address =\u003E mapping (address =\u003E uint256)) allowed;\r\n\r\n  function balanceOf(address _owner) view public returns (uint256 balance) {\r\n    return balances[_owner];\r\n  }\r\n  \r\n  function transfer(address _to, uint256 _value) public returns (bool) {\r\n    balances[msg.sender] = balances[msg.sender].sub(_value);\r\n    balances[_to] = balances[_to].add(_value);\r\n    emit Transfer(msg.sender, _to, _value);\r\n    return true;\r\n  }\r\n  \r\n  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {\r\n    uint256 _allowance = allowed[_from][msg.sender];\r\n    balances[_to] = balances[_to].add(_value);\r\n    balances[_from] = balances[_from].sub(_value);\r\n    allowed[_from][msg.sender] = _allowance.sub(_value);\r\n    emit Transfer(_from, _to, _value);\r\n    return true;\r\n  }\r\n  \r\n  function approve(address _spender, uint256 _value) public returns (bool) {\r\n    require((_value == 0) || (allowed[msg.sender][_spender] == 0));\r\n    allowed[msg.sender][_spender] = _value;\r\n    emit Approval(msg.sender, _spender, _value);\r\n    return true;\r\n  }\r\n  \r\n  function allowance(address _owner, address _spender) view public returns (uint256 remaining) {\r\n    return allowed[_owner][_spender];\r\n  }\r\n}\r\n\r\n// An extension allowing the ERC20 to allow coins to be minted into existance at any point\r\ncontract MintableToken is ERC20{\r\n    \r\n  event Minted(address target, uint mintedAmount, uint time);\r\n  \r\n  function mintToken(address target, uint256 mintedAmount) public returns(bool){\r\n\tbalances[target] = balances[target].add(mintedAmount);\r\n\ttotalSupply = totalSupply.add(mintedAmount);\r\n\temit Transfer(address(0), address(this), mintedAmount);\r\n\temit Transfer(address(this), target, mintedAmount);\r\n\temit Minted(target, mintedAmount, now);\r\n\treturn true;\r\n  }\r\n}\r\n\r\n// An extension allowing the ERC20 to send any token sent to it to the owner (so they are recoverable)\r\ncontract RecoverableToken is ERC20, Ownable {\r\n  constructor() public {}\r\n   \r\n  event RecoveredTokens(address token, address owner, uint tokens, uint time);\r\n  \r\n  function recoverTokens(ERC20 token) public {\r\n    uint tokens = tokensToBeReturned(token);\r\n    require(token.transfer(getOwner(), tokens) == true);\r\n    emit RecoveredTokens(address(token), getOwner(),  tokens, now);\r\n  }\r\n  function tokensToBeReturned(ERC20 token) public view returns (uint256) {\r\n    return token.balanceOf(address(this));\r\n  }\r\n}\r\n\r\n// An extension that allows the ERC20 to burn tokens from existance at any point\r\ncontract BurnableToken is ERC20 {\r\n  address public BURN_ADDRESS;\r\n\r\n  event Burned(address burner, uint256 burnedAmount);\r\n \r\n  function burn(uint256 burnAmount) public {\r\n    address burner = msg.sender;\r\n    balances[burner] = balances[burner].sub(burnAmount);\r\n    totalSupply = totalSupply.sub(burnAmount);\r\n    emit Burned(burner, burnAmount);\r\n    emit Transfer(burner, BURN_ADDRESS, burnAmount);\r\n  }\r\n}\r\n\r\n// An extension that allows the ERC20 owner to withdraw all ETH from the contract\r\ncontract WithdrawableToken is ERC20, Ownable {\r\n    \r\n  event WithdrawLog(uint256 balanceBefore, uint256 amount, uint256 balanceAfter);\r\n  \r\n  function withdraw(uint256 amount) public returns(bool){\r\n\trequire(amount \u003C= address(this).balance);\r\n    getOwner().transfer(amount);\r\n\temit WithdrawLog(address(getOwner()).balance.sub(amount), amount, address(getOwner()).balance);\r\n    return true;\r\n  } \r\n}\r\n\r\n// The coin\r\ncontract BigPeiceOfShitCoin is RecoverableToken, BurnableToken, MintableToken, WithdrawableToken, CircuitBreaker { \r\n  string public name;\r\n  string public symbol;\r\n  uint256 public decimals;\r\n  address payable public creator;\r\n  \r\n  event LogFundsReceived(address sender, uint amount);\r\n  event UpdatedTokenInformation(string newName, string newSymbol);\r\n\r\n  constructor(uint256 _totalTokensToMint) payable public {\r\n    name = \u0022BigPeiceOfShitCoin\u0022;\r\n    symbol = \u0022BPOS\u0022;\r\n    totalSupply = _totalTokensToMint;\r\n    decimals = 2;\r\n    balances[msg.sender] = totalSupply;\r\n    creator = msg.sender;\r\n    emit LogFundsReceived(msg.sender, msg.value);\r\n  }\r\n  \r\n  function() payable external outOfLockdown {\r\n    emit LogFundsReceived(msg.sender, msg.value);\r\n  }\r\n  \r\n  function transfer(address _to, uint256 _value) public outOfLockdown returns (bool success){\r\n    return super.transfer(_to, _value);\r\n  }\r\n  \r\n  function transferFrom(address _from, address _to, uint256 _value) public outOfLockdown returns (bool success){\r\n    return super.transferFrom(_from, _to, _value);\r\n  }\r\n  \r\n  function multipleTransfer(address[] calldata _toAddresses, uint256[] calldata _toValues) external outOfLockdown returns (uint256) {\r\n    require(_toAddresses.length == _toValues.length);\r\n    uint256 updatedCount = 0;\r\n    for(uint256 i = 0;i\u003C_toAddresses.length;i\u002B\u002B){\r\n       if(super.transfer(_toAddresses[i], _toValues[i]) == true){\r\n           updatedCount\u002B\u002B;\r\n       }\r\n    }\r\n    return updatedCount;\r\n  }\r\n  \r\n  function approve(address _spender, uint256 _value) public outOfLockdown  returns (bool) {\r\n    return super.approve(_spender, _value);\r\n  }\r\n  \r\n  function setTokenInformation(string calldata _name, string calldata _symbol) onlyOwner external {\r\n    require(msg.sender != creator);\r\n    name = _name;\r\n    symbol = _symbol;\r\n    emit UpdatedTokenInformation(name, symbol);\r\n  }\r\n  \r\n  function withdraw(uint256 _amount) onlyOwner public returns(bool){\r\n\treturn super.withdraw(_amount);\r\n  }\r\n\r\n  function mintToken(address _target, uint256 _mintedAmount) onlyOwner public returns (bool){\r\n\treturn super.mintToken(_target, _mintedAmount);\r\n  }\r\n  \r\n  function burn(uint256 _burnAmount) onlyOwner public{\r\n    return super.burn(_burnAmount);\r\n  }\r\n  \r\n  function updateLockdownState(bool _state) onlyOwner public{\r\n    super.updateLockdownState(_state);\r\n  }\r\n  \r\n  function recoverTokens(ERC20 _token) onlyOwner public{\r\n     super.recoverTokens(_token);\r\n  }\r\n  \r\n  function isToken() public pure returns (bool) {\r\n    return true;\r\n  }\r\n\r\n  function deprecateContract() onlyOwner external{\r\n    selfdestruct(creator);\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022creator\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022_toAddresses\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022_toValues\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022multipleTransfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract ERC20\u0022,\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022recoverTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022inLockdown\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balances\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_burnAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022setTokenInformation\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_state\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022updateLockdownState\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_mintedAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022mintToken\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCostToBuy\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract ERC20\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022tokensToBeReturned\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022costToBuy\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setCostToBuy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022deprecateContract\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isToken\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022BURN_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_totalTokensToMint\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022LogFundsReceived\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022newName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022newSymbol\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022UpdatedTokenInformation\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022balanceBefore\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022balanceAfter\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022WithdrawLog\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022mintedAmount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Minted\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022burner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022burnedAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burned\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022RecoveredTokens\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022costToBuy\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"BigPeiceOfShitCoin","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"0000000000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://79cc2cd577dd76aa932cdde5ef769b39d70a560c82c4311da7a933c9bf3300d7"}]