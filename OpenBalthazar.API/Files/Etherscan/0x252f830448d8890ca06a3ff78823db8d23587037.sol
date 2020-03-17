[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\ninterface IERC20 {\r\n  function totalSupply() external view returns (uint256);\r\n  function balanceOf(address who) external view returns (uint256);\r\n  function allowance(address owner, address spender) external view returns (uint256);\r\n  function transfer(address to, uint256 value) external returns (bool);\r\n  function approve(address spender, uint256 value) external returns (bool);\r\n  function transferFrom(address from, address to, uint256 value) external returns (bool);\r\n\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n  event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\nlibrary SafeMath {\r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a / b;\r\n    return c;\r\n  }\r\n\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n\r\n  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {\r\n    uint256 c = add(a,m);\r\n    uint256 d = sub(c,1);\r\n    return mul(div(d,m),m);\r\n  }\r\n}\r\n\r\ncontract ERC20Detailed is IERC20 {\r\n\r\n  string private _name;\r\n  string private _symbol;\r\n  uint8 private _decimals;\r\n\r\n  constructor(string memory name, string memory symbol, uint8 decimals) public {\r\n    _name = name;\r\n    _symbol = symbol;\r\n    _decimals = decimals;\r\n  }\r\n\r\n  function name() public view returns(string memory) {\r\n    return _name;\r\n  }\r\n\r\n  function symbol() public view returns(string memory) {\r\n    return _symbol;\r\n  }\r\n\r\n  function decimals() public view returns(uint8) {\r\n    return _decimals;\r\n  }\r\n}\r\n\r\ncontract BIGBOMBv2 is ERC20Detailed {\r\n\r\n  using SafeMath for uint256;\r\n  mapping (address =\u003E uint256) private _balances;\r\n  mapping (address =\u003E mapping (address =\u003E uint256)) private _allowed;\r\n\r\n  string constant tokenName = \u0022BIGBOMB\u0022;\r\n  string constant tokenSymbol = \u0022BBOMB\u0022;\r\n  uint8  constant tokenDecimals = 18;\r\n  uint256 _totalSupply = 800000000000000000000000;\r\n  uint256 public basePercent = 100;\r\n\r\n  constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {\r\n    _mint(msg.sender, _totalSupply);\r\n  }\r\n\r\n  function totalSupply() public view returns (uint256) {\r\n    return _totalSupply;\r\n  }\r\n\r\n  function balanceOf(address owner) public view returns (uint256) {\r\n    return _balances[owner];\r\n  }\r\n\r\n  function allowance(address owner, address spender) public view returns (uint256) {\r\n    return _allowed[owner][spender];\r\n  }\r\n\r\n  function findfourPercent(uint256 value) public view returns (uint256)  {\r\n    uint256 roundValue = value.ceil(basePercent);\r\n    uint256 fourPercent = roundValue.mul(basePercent).div(2500);\r\n    return fourPercent;\r\n  }\r\n\r\n  function transfer(address to, uint256 value) public returns (bool) {\r\n    require(value \u003C= _balances[msg.sender]);\r\n    require(to != address(0));\r\n\r\n    uint256 tokensToBurn = findfourPercent(value);\r\n    uint256 tokensToTransfer = value.sub(tokensToBurn);\r\n\r\n    _balances[msg.sender] = _balances[msg.sender].sub(value);\r\n    _balances[to] = _balances[to].add(tokensToTransfer);\r\n\r\n    _totalSupply = _totalSupply.sub(tokensToBurn);\r\n\r\n    emit Transfer(msg.sender, to, tokensToTransfer);\r\n    emit Transfer(msg.sender, address(0), tokensToBurn);\r\n    return true;\r\n  }\r\n\r\n  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {\r\n    for (uint256 i = 0; i \u003C receivers.length; i\u002B\u002B) {\r\n      transfer(receivers[i], amounts[i]);\r\n    }\r\n  }\r\n\r\n  function approve(address spender, uint256 value) public returns (bool) {\r\n    require(spender != address(0));\r\n    _allowed[msg.sender][spender] = value;\r\n    emit Approval(msg.sender, spender, value);\r\n    return true;\r\n  }\r\n\r\n  function transferFrom(address from, address to, uint256 value) public returns (bool) {\r\n    require(value \u003C= _balances[from]);\r\n    require(value \u003C= _allowed[from][msg.sender]);\r\n    require(to != address(0));\r\n\r\n    _balances[from] = _balances[from].sub(value);\r\n\r\n    uint256 tokensToBurn = findfourPercent(value);\r\n    uint256 tokensToTransfer = value.sub(tokensToBurn);\r\n\r\n    _balances[to] = _balances[to].add(tokensToTransfer);\r\n    _totalSupply = _totalSupply.sub(tokensToBurn);\r\n\r\n    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);\r\n\r\n    emit Transfer(from, to, tokensToTransfer);\r\n    emit Transfer(from, address(0), tokensToBurn);\r\n\r\n    return true;\r\n  }\r\n\r\n  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\r\n    require(spender != address(0));\r\n    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));\r\n    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);\r\n    return true;\r\n  }\r\n\r\n  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\r\n    require(spender != address(0));\r\n    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));\r\n    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);\r\n    return true;\r\n  }\r\n\r\n  function _mint(address account, uint256 amount) internal {\r\n    require(amount != 0);\r\n    _balances[account] = _balances[account].add(amount);\r\n    emit Transfer(address(0), account, amount);\r\n  }\r\n\r\n  function burn(uint256 amount) external {\r\n    _burn(msg.sender, amount);\r\n  }\r\n\r\n  function _burn(address account, uint256 amount) internal {\r\n    require(amount != 0);\r\n    require(amount \u003C= _balances[account]);\r\n    _totalSupply = _totalSupply.sub(amount);\r\n    _balances[account] = _balances[account].sub(amount);\r\n    emit Transfer(account, address(0), amount);\r\n  }\r\n\r\n  function burnFrom(address account, uint256 amount) external {\r\n    require(amount \u003C= _allowed[account][msg.sender]);\r\n    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);\r\n    _burn(account, amount);\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address[]\u0022,\u0022name\u0022:\u0022receivers\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022internalType\u0022:\u0022uint256[]\u0022,\u0022name\u0022:\u0022amounts\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022multiTransfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022addedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseAllowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burn\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022burnFrom\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022subtractedValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decreaseAllowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022basePercent\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022findfourPercent\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"BIGBOMBv2","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://f9a329fbb7da592c0b03fca1371f17a9ad0d7108a97bbcd683aff2b18fe40362"}]