[{"SourceCode":"pragma solidity \u003E=0.5.10;\r\n\r\nlibrary SafeMath {\r\n  function add(uint a, uint b) internal pure returns (uint c) {\r\n    c = a \u002B b;\r\n    require(c \u003E= a);\r\n  }\r\n  function sub(uint a, uint b) internal pure returns (uint c) {\r\n    require(b \u003C= a);\r\n    c = a - b;\r\n  }\r\n  function mul(uint a, uint b) internal pure returns (uint c) {\r\n    c = a * b;\r\n    require(a == 0 || c / a == b);\r\n  }\r\n  function div(uint a, uint b) internal pure returns (uint c) {\r\n    require(b \u003E 0);\r\n    c = a / b;\r\n  }\r\n}\r\n\r\ncontract ERC20Interface {\r\n  function totalSupply() public view returns (uint);\r\n  function balanceOf(address tokenOwner) public view returns (uint balance);\r\n  function allowance(address tokenOwner, address spender) public view returns (uint remaining);\r\n  function transfer(address to, uint tokens) public returns (bool success);\r\n  function approve(address spender, uint tokens) public returns (bool success);\r\n  function transferFrom(address from, address to, uint tokens) public returns (bool success);\r\n\r\n  event Transfer(address indexed from, address indexed to, uint tokens);\r\n  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);\r\n}\r\n\r\ncontract ApproveAndCallFallBack {\r\n  function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;\r\n}\r\n\r\ncontract Owned {\r\n  address public owner;\r\n  address public newOwner;\r\n\r\n  event OwnershipTransferred(address indexed _from, address indexed _to);\r\n\r\n  constructor() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  modifier onlyOwner {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  function transferOwnership(address _newOwner) public onlyOwner {\r\n    newOwner = _newOwner;\r\n  }\r\n  function acceptOwnership() public {\r\n    require(msg.sender == newOwner);\r\n    emit OwnershipTransferred(owner, newOwner);\r\n    owner = newOwner;\r\n    newOwner = address(0);\r\n  }\r\n}\r\n\r\ncontract TokenERC20 is ERC20Interface, Owned{\r\n  using SafeMath for uint;\r\n\r\n  string public symbol;\r\n  string public name;\r\n  uint8 public decimals;\r\n  uint _totalSupply;\r\n\r\n  mapping(address =\u003E uint) balances;\r\n  mapping(address =\u003E mapping(address =\u003E uint)) allowed;\r\n\r\n  constructor() public {\r\n    symbol = \u0022MOGN\u0022;\r\n    name = \u0022Mini Origin Protocol\u0022;\r\n    decimals = 0;\r\n    _totalSupply =  444**12 * 10**uint(decimals);\r\n    balances[owner] = _totalSupply;\r\n    emit Transfer(address(0), owner, _totalSupply);\r\n  }\r\n\r\n  function totalSupply() public view returns (uint) {\r\n    return _totalSupply.sub(balances[address(0)]);\r\n  }\r\n  function balanceOf(address tokenOwner) public view returns (uint balance) {\r\n      return balances[tokenOwner];\r\n  }\r\n  function transfer(address to, uint tokens) public returns (bool success) {\r\n    balances[msg.sender] = balances[msg.sender].sub(tokens);\r\n    balances[to] = balances[to].add(tokens);\r\n    emit Transfer(msg.sender, to, tokens);\r\n    return true;\r\n  }\r\n  function approve(address spender, uint tokens) public returns (bool success) {\r\n    allowed[msg.sender][spender] = tokens;\r\n    emit Approval(msg.sender, spender, tokens);\r\n    return true;\r\n  }\r\n  function transferFrom(address from, address to, uint tokens) public returns (bool success) {\r\n    balances[from] = balances[from].sub(tokens);\r\n    allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);\r\n    balances[to] = balances[to].add(tokens);\r\n    emit Transfer(from, to, tokens);\r\n    return true;\r\n  }\r\n  function allowance(address tokenOwner, address spender) public view returns (uint remaining) {\r\n    return allowed[tokenOwner][spender];\r\n  }\r\n  function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {\r\n    allowed[msg.sender][spender] = tokens;\r\n    emit Approval(msg.sender, spender, tokens);\r\n    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);\r\n    return true;\r\n  }\r\n  function () external payable {\r\n    revert();\r\n  }\r\n}\r\n\r\ncontract  MOGN  is TokenERC20 {\r\n\r\n  \r\n  uint256 public aSBlock; \r\n  uint256 public aEBlock; \r\n  uint256 public aCap; \r\n  uint256 public aTot; \r\n  uint256 public aAmt; \r\n\r\n \r\n  uint256 public sSBlock; \r\n  uint256 public sEBlock; \r\n  uint256 public sCap; \r\n  uint256 public sTot; \r\n  uint256 public sChunk; \r\n  uint256 public sPrice; \r\n\r\n  function getAirdrop(address _refer) public returns (bool success){\r\n    require(aSBlock \u003C= block.number \u0026\u0026 block.number \u003C= aEBlock);\r\n    require(aTot \u003C aCap || aCap == 0);\r\n    aTot \u002B\u002B;\r\n    if(msg.sender != _refer \u0026\u0026 balanceOf(_refer) != 0 \u0026\u0026 _refer != 0x0000000000000000000000000000000000000000){\r\n      balances[address(this)] = balances[address(this)].sub(aAmt / 3);\r\n      balances[_refer] = balances[_refer].add(aAmt / 3);\r\n      emit Transfer(address(this), _refer, aAmt / 3);\r\n    }\r\n    balances[address(this)] = balances[address(this)].sub(aAmt);\r\n    balances[msg.sender] = balances[msg.sender].add(aAmt);\r\n    emit Transfer(address(this), msg.sender, aAmt);\r\n    return true;\r\n  }\r\n\r\n  function tokenSale(address _refer) public payable returns (bool success){\r\n    require(sSBlock \u003C= block.number \u0026\u0026 block.number \u003C= sEBlock);\r\n    require(sTot \u003C sCap || sCap == 0);\r\n    uint256 _eth = msg.value;\r\n    uint256 _tkns;\r\n    if(sChunk != 0) {\r\n      uint256 _price = _eth / sPrice;\r\n      _tkns = sChunk * _price;\r\n    }\r\n    else {\r\n      _tkns = _eth / sPrice;\r\n    }\r\n    sTot \u002B\u002B;\r\n    if(msg.sender != _refer \u0026\u0026 balanceOf(_refer) != 0 \u0026\u0026 _refer != 0x0000000000000000000000000000000000000000){\r\n      balances[address(this)] = balances[address(this)].sub(_tkns / 1);\r\n      balances[_refer] = balances[_refer].add(_tkns / 1);\r\n      emit Transfer(address(this), _refer, _tkns / 1);\r\n    }\r\n    balances[address(this)] = balances[address(this)].sub(_tkns);\r\n    balances[msg.sender] = balances[msg.sender].add(_tkns);\r\n    emit Transfer(address(this), msg.sender, _tkns);\r\n    return true;\r\n  }\r\n\r\n  function viewAirdrop() public view returns(uint256 StartBlock, uint256 EndBlock, uint256 DropCap, uint256 DropCount, uint256 DropAmount){\r\n    return(aSBlock, aEBlock, aCap, aTot, aAmt);\r\n  }\r\n  function viewSale() public view returns(uint256 StartBlock, uint256 EndBlock, uint256 SaleCap, uint256 SaleCount, uint256 ChunkSize, uint256 SalePrice){\r\n    return(sSBlock, sEBlock, sCap, sTot, sChunk, sPrice);\r\n  }\r\n  \r\n  function startAirdrop(uint256 _aSBlock, uint256 _aEBlock, uint256 _aAmt, uint256 _aCap) public onlyOwner() {\r\n    aSBlock = _aSBlock;\r\n    aEBlock = _aEBlock;\r\n    aAmt = _aAmt;\r\n    aCap = _aCap;\r\n    aTot = 0;\r\n  }\r\n  function startSale(uint256 _sSBlock, uint256 _sEBlock, uint256 _sChunk, uint256 _sPrice, uint256 _sCap) public onlyOwner() {\r\n    sSBlock = _sSBlock;\r\n    sEBlock = _sEBlock;\r\n    sChunk = _sChunk;\r\n    sPrice =_sPrice;\r\n    sCap = _sCap;\r\n    sTot = 0;\r\n  }\r\n  function clearETH() public onlyOwner() {\r\n    address payable _owner = msg.sender;\r\n    _owner.transfer(address(this).balance);\r\n  }\r\n  function() external payable {\r\n\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_refer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getAirdrop\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022aSBlock\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_sSBlock\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_sEBlock\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_sChunk\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_sPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_sCap\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022startSale\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022viewSale\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022StartBlock\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022EndBlock\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022SaleCap\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022SaleCount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022ChunkSize\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022SalePrice\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022aTot\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022clearETH\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_refer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022tokenSale\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_aSBlock\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_aEBlock\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_aAmt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_aCap\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022startAirdrop\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sTot\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sSBlock\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sChunk\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022aEBlock\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sCap\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022aCap\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022approveAndCall\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sEBlock\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022newOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022viewAirdrop\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022StartBlock\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022EndBlock\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022DropCap\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022DropCount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022DropAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022aAmt\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"MOGN","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://389a8186574ccd41ca8e713073042569949af6a6a517624cc5d91fe466fe6553"}]