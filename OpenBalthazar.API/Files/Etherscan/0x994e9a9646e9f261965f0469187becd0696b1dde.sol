[{"SourceCode":"pragma solidity \u003E= 0.5.12;\r\n\r\nlibrary SafeMath {\r\n  function add(uint a, uint b) internal pure returns (uint c) {\r\n    c = a \u002B b;\r\n    require(c \u003E= a);\r\n  }\r\n  function sub(uint a, uint b) internal pure returns (uint c) {\r\n    require(b \u003C= a);\r\n    c = a - b;\r\n  }\r\n  function mul(uint a, uint b) internal pure returns (uint c) {\r\n    c = a * b;\r\n    require(a == 0 || c / a == b);\r\n  }\r\n  function div(uint a, uint b) internal pure returns (uint c) {\r\n    require(b \u003E 0);\r\n    c = a / b;\r\n  }\r\n}\r\n\r\ninterface IERC20 {\r\n  function totalSupply() external view returns (uint256);\r\n  function balanceOf(address account) external view returns (uint256);\r\n  function transfer(address recipient, uint256 amount) external returns (bool);\r\n  function allowance(address owner, address spender) external view returns (uint256);\r\n  function approve(address spender, uint256 amount) external returns (bool);\r\n  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n  event Transfer(address indexed from, address indexed to, uint256 value);\r\n  event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\ncontract Owned {\r\n  address public owner;\r\n  address public newOwner;\r\n\r\n  event OwnershipTransferred(address indexed _from, address indexed _to);\r\n\r\n  constructor() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  modifier onlyOwner {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  function transferOwnership(address _newOwner) public onlyOwner {\r\n    newOwner = _newOwner;\r\n  }\r\n  function acceptOwnership() public {\r\n    require(msg.sender == newOwner);\r\n    emit OwnershipTransferred(owner, newOwner);\r\n    owner = newOwner;\r\n    newOwner = address(0);\r\n  }\r\n}\r\n\r\ncontract LastBuy_beta_2 is Owned {\r\n  using SafeMath for uint;\r\n\r\n  event playerenter(address player, address token, uint256 amount, uint256 cost);\r\n  event winnerclaim(address winner, address token, uint256 amount);\r\n  event poolclaim(address player, address token, uint256 amount);\r\n\r\n  constructor() public {\r\n    //stt\r\n    tokenlist[0] = 0xaC9Bb427953aC7FDDC562ADcA86CF42D988047Fd;\r\n    tokenbase[tokenlist[0]] = 4 * 10**20;\r\n    //pyro\r\n    tokenlist[1] = 0x14409B0Fc5C7f87b5DAd20754fE22d29A3dE8217;\r\n    tokenbase[tokenlist[1]] = 1 * 10**20;\r\n    //shuf\r\n    tokenlist[2] = 0x3A9FfF453d50D4Ac52A6890647b823379ba36B9E;\r\n    tokenbase[tokenlist[2]] = 16 * 10**16;\r\n    //shock\r\n    tokenlist[3] = 0x62d69910f45b839903eFfd217559307AEc307076;\r\n    tokenbase[tokenlist[3]] = 3 * 10**17;\r\n  }\r\n\r\n\r\n  mapping(uint256 =\u003E address) public tokenlist;\r\n\r\n  uint256 public stopblock;\r\n  address public winner;\r\n\r\n  mapping(address =\u003E uint256) public entries;\r\n  mapping(address =\u003E uint256) public tokenbase;\r\n  mapping(address =\u003E uint256) public blockbalance;\r\n  mapping(address =\u003E uint256) public endbalance;\r\n  mapping(uint256 =\u003E address) public winpool;\r\n  mapping(uint256 =\u003E bool) public winpoolclaimed;\r\n\r\n  bool public jackpotclaimed;\r\n\r\n  bool public started;\r\n  bool public ended;\r\n\r\n  modifier notStarted {\r\n    require(started == false);\r\n    _;\r\n  }\r\n  modifier isStarted {\r\n    require(started == true);\r\n    _;\r\n  }\r\n  modifier notEnded {\r\n    require(ended == false);\r\n    _;\r\n  }\r\n  modifier isEnded {\r\n    require(ended == true);\r\n    _;\r\n  }\r\n\r\n\r\n\r\n  function enter(address token, uint256 amount) public isStarted() notEnded() {\r\n    require(amount \u003E 0);\r\n    require(tokenbase[token] != 0);\r\n\r\n    if(block.number \u003E= stopblock) {\r\n      endgame();\r\n    }\r\n    else {\r\n      IERC20 itoken = IERC20(token);\r\n      uint256 blockcost = getblockcost(token);\r\n      uint256 _cost = amount.mul(blockcost);\r\n\r\n      require(itoken.transferFrom(msg.sender, address(this), _cost));\r\n\r\n      if(stopblock \u002B amount - block.number \u003E 6000) {\r\n        stopblock = block.number \u002B 6000;\r\n      }\r\n      else {\r\n        stopblock = amount \u002B stopblock;\r\n      }\r\n      entries[token] = amount \u002B entries[token];\r\n      winner = msg.sender;\r\n      blockbalance[msg.sender] = blockbalance[msg.sender] \u002B amount;\r\n\r\n      poolhandler(msg.sender);\r\n\r\n      emit playerenter(msg.sender, token, amount, _cost);\r\n    }\r\n  }\r\n\r\n  function endgame() public isStarted() notEnded() {\r\n    if(block.number \u003E= stopblock) {\r\n      IERC20 _itmp;\r\n      for(uint256 i = 0; i \u003C 4; i\u002B\u002B) {\r\n        _itmp = IERC20(tokenlist[i]);\r\n        endbalance[tokenlist[i]] = _itmp.balanceOf(address(this));\r\n      }\r\n      ended = true;\r\n    }\r\n  }\r\n\r\n  function claim(uint256 plyr) public isEnded() {\r\n    require(winpoolclaimed[plyr] == false);\r\n    address _addr = winpool[plyr];\r\n    require(_addr != 0x0000000000000000000000000000000000000000);\r\n    IERC20 _itmp;\r\n    uint256 _shareamt;\r\n    winpoolclaimed[plyr] = true;\r\n    for(uint256 i = 0; i \u003C 4; i\u002B\u002B) {\r\n      _itmp = IERC20(tokenlist[i]);\r\n      _shareamt = endbalance[tokenlist[i]] / 40;\r\n      _itmp.transfer(_addr, _shareamt);\r\n      emit poolclaim(_addr, tokenlist[i], _shareamt);\r\n    }\r\n\r\n  }\r\n\r\n  function claimjackpot() public isEnded() {\r\n    require(jackpotclaimed == false);\r\n    IERC20 _itmp;\r\n    uint256 _contractbal;\r\n    uint256 _shareamt;\r\n    uint256 _winamt;\r\n    jackpotclaimed = true;\r\n    for(uint256 i = 0; i \u003C 4; i\u002B\u002B) {\r\n      _itmp = IERC20(tokenlist[i]);\r\n      _contractbal = endbalance[tokenlist[i]];\r\n      _shareamt = _contractbal / 40;\r\n      _winamt = _contractbal - _shareamt * 8;\r\n      _itmp.transfer(winner, _winamt);\r\n      emit winnerclaim(winner, tokenlist[i], _contractbal);\r\n    }\r\n  }\r\n\r\n  function poolhandler(address _addr) internal returns(bool) {\r\n\r\n    uint256 low = 0;\r\n\r\n    for(uint256 i = 0; i \u003C 8; i\u002B\u002B) {\r\n      if(winpool[i] == _addr){\r\n        return(false);\r\n      }\r\n      if(blockbalance[winpool[low]] \u003E blockbalance[winpool[i]]) {\r\n        low = i;\r\n      }\r\n    }\r\n\r\n    if(blockbalance[_addr] \u003E blockbalance[winpool[low]]) {\r\n      winpool[low] = _addr;\r\n    }\r\n    return(true);\r\n  }\r\n\r\n\r\n  //VIEW FUNCTIONS\r\n  function getblockcost(address token) public view returns(uint256) {\r\n    return(tokenbase[token] \u002B (entries[token] * tokenbase[token]) / 10**4);\r\n  }\r\n\r\n  //ADMIN FUNCTIONS\r\n\r\n  function adminStart(uint256 numblocks) public onlyOwner() notStarted() {\r\n    stopblock = block.number \u002B numblocks;\r\n    started = true;\r\n  }\r\n\r\n  function adminwithdrawal(address token, uint256 amount) public onlyOwner() isEnded() {\r\n    require(jackpotclaimed == true);\r\n    IERC20 itoken = IERC20(token);\r\n    itoken.transfer(msg.sender, amount);\r\n  }\r\n  function clearETH() public onlyOwner() {\r\n    address payable _owner = msg.sender;\r\n    _owner.transfer(address(this).balance);\r\n  }\r\n\r\n\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022player\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022cost\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022playerenter\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022player\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022poolclaim\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022winner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022winnerclaim\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022numblocks\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022adminStart\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022adminwithdrawal\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022blockbalance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022plyr\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022claim\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022claimjackpot\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022clearETH\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022endbalance\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022ended\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022endgame\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022enter\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022entries\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getblockcost\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022jackpotclaimed\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022newOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022started\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022stopblock\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022tokenbase\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022tokenlist\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022winner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022winpool\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022winpoolclaimed\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"LastBuy_beta_2","CompilerVersion":"v0.5.12\u002Bcommit.7709ece9","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://a38488478af5c3fa8ef1cf4a6b37bb5845d35e5fcd0c147915e4a12c2f808d15"}]