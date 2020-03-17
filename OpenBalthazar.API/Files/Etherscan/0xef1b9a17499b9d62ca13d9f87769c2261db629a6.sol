[{"SourceCode":"/**\r\n *Submitted for verification at Etherscan.io on 2019-05-27\r\n*/\r\n\r\n/* -------------- IPMCOIN\u002B  ISSUE ----------\r\ncreatedate : 2019.10 \r\nToken name : IPMCOIN\u002B\r\nSymbol name : IPM\u002B\r\n----------------------------------------------------------*/\r\n\r\n\r\npragma solidity ^0.5.8;\r\n\r\nlibrary SafeMath {\r\n\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = a * b;\r\n    require(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    require(b \u003E 0);\r\n    uint256 c = a / b;\r\n    return c;\r\n  }\r\n\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    require(b \u003C= a);\r\n    uint256 c = a - b;\r\n    return c;\r\n  }\r\n\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    require(c \u003E= a);\r\n    return c;\r\n  }\r\n\r\n}\r\n\r\ninterface IERC20 {\r\n  function totalSupply() external view returns (uint256);\r\n  function balanceOf(address who) external view returns (uint256);\r\n  function allowance(address owner, address spender) external view returns (uint256);\r\n  function transfer(address to, uint256 value) external returns (bool);\r\n  function approve(address spender, uint256 value) external returns (bool);\r\n  function transferFrom(address from, address to, uint256 value) external returns (bool);\r\n  event Transfer(address indexed from,address indexed to,uint256 value);\r\n  event Approval(address indexed owner,address indexed spender,uint256 value);\r\n}\r\n\r\ncontract Owned {\r\n  address owner;\r\n  constructor () public {\r\n    owner = msg.sender;\r\n  }\r\n  modifier onlyOwner {\r\n    require(msg.sender == owner,\u0022Only owner can do it.\u0022);\r\n    _;\r\n  }\r\n}\r\n\r\ncontract IPMCOIN is IERC20 , Owned{\r\n\r\n  string public constant name = \u0022IPMCOIN\u002B\u0022;\r\n  string public constant symbol = \u0022IPM\u002B\u0022;\r\n  uint8 public constant decimals = 18;\r\n\r\n  uint256 private constant INITIAL_SUPPLY = 3000000000 * (10 ** uint256(decimals));\r\n\r\n  uint256 public role1_balance = INITIAL_SUPPLY.mul(4).div(100);\r\n\r\n  using SafeMath for uint256;\r\n\r\n  mapping (address =\u003E uint256) private _balances;\r\n\r\n  mapping (address =\u003E mapping (address =\u003E uint256)) private _allowed;\r\n\r\n  uint256 private _totalSupply;\r\n\r\n  uint256 public beginTime = 1559361600;\r\n\r\n  function setBeginTime(uint256 _begin) onlyOwner public{\r\n    beginTime = _begin;\r\n  }\r\n\r\n  struct Role {\r\n    uint256 releaseTime;\r\n    uint256 nolockRate;\r\n    uint256 releaseRate;\r\n  }\r\n\r\n  struct Account {\r\n    uint8 roleType;\r\n    uint256 ownAmount;\r\n    uint256 releasedAmount;\r\n  }\r\n\r\n  mapping(address =\u003E Account) private accountMapping;\r\n\r\n  mapping(address =\u003E bool) private nolockReleasedMapping;\r\n\r\n  mapping(address =\u003E uint256) private releasedRateMapping;\r\n\r\n  function allocateTokenByType(address accountAddress,uint256 amount,uint8 roleType) onlyOwner public {\r\n    require(accountAddress != address(0x0), \u0022accountAddress not right\u0022);\r\n    require(roleType \u003C=5 ,\u0022roleType must be 0~5\u0022);\r\n    require(now \u003C beginTime ,\u0022beginTime \u003C= now, so can not set\u0022);\r\n\r\n    amount = amount.mul(10 ** uint256(decimals));\r\n    Account memory _account = accountMapping[accountAddress];\r\n    if(_account.ownAmount == 0){\r\n         accountMapping[accountAddress] = Account(roleType,amount,0);\r\n    }else{\r\n        require(roleType == _account.roleType ,\u0022roleType must be same!\u0022);\r\n        accountMapping[accountAddress].ownAmount = _account.ownAmount.add(amount);\r\n        accountMapping[accountAddress].releasedAmount = 0;\r\n        delete nolockReleasedMapping[accountAddress];\r\n        delete releasedRateMapping[accountAddress];\r\n    }\r\n    _balances[accountAddress] = _balances[accountAddress].add(amount);\r\n    _balances[msg.sender] = _balances[msg.sender].sub(amount);\r\n    if(roleType == 1){\r\n        role1_balance = role1_balance.sub(amount);\r\n    }\r\n    releaseToken(accountAddress);\r\n  }\r\n\r\n  event Burn(address indexed from, uint256 value);\r\n\r\n  function burn(uint256 _value, uint8 _roleType) onlyOwner public returns (bool success) {\r\n    require(_value \u003E 0, \u0022_value \u003E 0\u0022);\r\n    _value = _value.mul(10 ** uint256(decimals));\r\n    require(_balances[msg.sender] \u003E= _value);\r\n    _balances[msg.sender] = _balances[msg.sender].sub(_value);\r\n    _totalSupply = _totalSupply.sub(_value);\r\n    if(_roleType == 1){\r\n        role1_balance = role1_balance.sub(_value);\r\n    }\r\n    emit Burn(msg.sender, _value);\r\n    return true;\r\n  }\r\n\r\n  function releaseToken(address accountAddress) private returns (bool) {\r\n    require(accountAddress != address(0x0), \u0022accountAddress not right\u0022);\r\n\r\n    Account memory _account = accountMapping[accountAddress];\r\n    if(_account.ownAmount == 0){\r\n      return true;\r\n    }\r\n    if(_account.releasedAmount == _account.ownAmount){\r\n      return true;\r\n    }\r\n    uint256 _releasedAmount = 0;\r\n    uint256 releaseTime;\r\n    uint256 nolockRate;\r\n    uint256 releaseRate;\r\n    (releaseTime,nolockRate,releaseRate) = getRoles(_account.roleType);\r\n\r\n    if(nolockRate \u003E 0 \u0026\u0026 nolockReleasedMapping[accountAddress] != true){\r\n      _releasedAmount = _releasedAmount.add(_account.ownAmount.mul(nolockRate).div(100));\r\n      nolockReleasedMapping[accountAddress] = true;\r\n    }\r\n    if(releaseTime \u003C= now){\r\n      uint256 _momth = now.sub(releaseTime).div(30 days).add(1);\r\n      if(releasedRateMapping[accountAddress] \u003C=  _momth) {\r\n        _releasedAmount = _releasedAmount.add(_account.ownAmount.mul(_momth-releasedRateMapping[accountAddress]).mul(releaseRate).div(100));\r\n        releasedRateMapping[accountAddress] = _momth;\r\n      }\r\n    }\r\n    if(_releasedAmount \u003E 0){\r\n        if(accountMapping[accountAddress].releasedAmount.add(_releasedAmount) \u003C= _account.ownAmount){\r\n            accountMapping[accountAddress].releasedAmount = accountMapping[accountAddress].releasedAmount.add(_releasedAmount);\r\n        }else{\r\n            accountMapping[accountAddress].releasedAmount = _account.ownAmount;\r\n        }\r\n      \r\n    }\r\n    return true;\r\n  }\r\n\r\n  function getRoles(uint8 _type) private pure returns(uint256,uint256,uint256) {\r\n    require(_type \u003C= 5);\r\n    if(_type == 0){\r\n      return (1559361600,0,100);\r\n    }\r\n    if(_type == 1){\r\n      return (1564632000,0,10);\r\n    }\r\n    if(_type == 2){\r\n      return (1575172800,0,2);\r\n    }\r\n    if(_type == 3){\r\n      return (1567310400,20,10);\r\n    }\r\n    if(_type == 4){\r\n      return (1559361600,10,5);\r\n    }\r\n    if(_type == 5){\r\n      return (1559361600,0,100);\r\n    }\r\n  }\r\n  \r\n  constructor() public {\r\n    _mint(msg.sender, INITIAL_SUPPLY);\r\n  }\r\n\r\n  function _mint(address account, uint256 value) internal {\r\n    require(account != address(0x0));\r\n    _totalSupply = _totalSupply.add(value);\r\n    _balances[account] = _balances[account].add(value);\r\n    emit Transfer(address(0), account, value);\r\n  }\r\n  \r\n  function totalSupply() public view returns (uint256) {\r\n    return _totalSupply;\r\n  }\r\n\r\n  function balanceOf(address owner) public view returns (uint256) {\r\n    return _balances[owner];\r\n  }\r\n\r\n  function allowance(\r\n    address owner,\r\n    address spender\r\n   )\r\n    public\r\n    view\r\n    returns (uint256)\r\n  {\r\n    return _allowed[owner][spender];\r\n  }\r\n\r\n  function transfer(address to, uint256 value) public returns (bool) {\r\n    if(_canTransfer(msg.sender,value)){ \r\n      _transfer(msg.sender, to, value);\r\n      return true;\r\n    } else {\r\n      return false;\r\n    }\r\n  }\r\n\r\n  function _canTransfer(address from,uint256 _amount) private returns (bool) {\r\n    if(now \u003C beginTime){\r\n      return false;\r\n    }\r\n    if((balanceOf(from))\u003C=0){\r\n      return false;\r\n    }\r\n    releaseToken(from);\r\n    Account memory _account = accountMapping[from];\r\n    if(_account.ownAmount == 0){\r\n      return true;\r\n    }\r\n    \r\n    if(balanceOf(from).sub(_amount) \u003C _account.ownAmount.sub(_account.releasedAmount)){\r\n      return false;\r\n    }\r\n\r\n    return true;\r\n  }\r\n\r\n  function approve(address spender, uint256 value) public returns (bool) {\r\n    require(spender != address(0));\r\n\r\n    _allowed[msg.sender][spender] = value;\r\n    emit Approval(msg.sender, spender, value);\r\n    return true;\r\n  }\r\n\r\n  function transferFrom(\r\n    address from,\r\n    address to,\r\n    uint256 value\r\n  )\r\n    public\r\n    returns (bool)\r\n  {\r\n    require(value \u003C= _allowed[from][msg.sender]);\r\n    \r\n    if (_canTransfer(from, value)) {\r\n        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);\r\n        _transfer(from, to, value);\r\n        return true;\r\n    } else {\r\n        return false;\r\n    }\r\n  }\r\n\r\n  function _transfer(address from, address to, uint256 value) internal {\r\n    require(value \u003C= _balances[from]);\r\n    require(to != address(0));\r\n    \r\n    _balances[from] = _balances[from].sub(value);\r\n    _balances[to] = _balances[to].add(value);\r\n    emit Transfer(from, to, value);\r\n    \r\n  }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022role1_balance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_begin\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setBeginTime\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_roleType\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022beginTime\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022accountAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022roleType\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022name\u0022:\u0022allocateTokenByType\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Burn\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"IPMCOIN","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://f25f7adec4bb108f32d9dae207491d31a2e06413a36f0d11733b1af7079df6be"}]