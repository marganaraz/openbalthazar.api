[{"SourceCode":"pragma solidity ^0.5.1;\r\n\r\ncontract ERC20Interface {\r\n  function totalSupply() public view returns (uint);\r\n  function balanceOf(address tokenOwner) public view returns (uint balance);\r\n  function allowance(address tokenOwner, address spender) public view returns (uint remaining);\r\n  function transfer(address to, uint tokens) public returns (bool success);\r\n  function approve(address spender, uint tokens) public returns (bool success);\r\n  function transferFrom(address from, address to, uint tokens) public returns (bool success);\r\n  event Transfer(address indexed from, address indexed to, uint tokens);\r\n  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);\r\n}\r\n\r\nlibrary SafeMath {\r\n  function add(uint a, uint b) internal pure returns (uint) {\r\n    uint c = a \u002B b;\r\n    require(c \u003E= a);\r\n    return c;\r\n  }\r\n\r\n  function sub(uint a, uint b) internal pure returns (uint) {\r\n    require(b \u003C= a);\r\n    uint c = a - b;\r\n    return c;\r\n  }\r\n\r\n  function mul(uint a, uint b) internal pure returns (uint) {\r\n    uint c = a * b;\r\n    require(a == 0 || c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint a, uint b) internal pure returns (uint) {\r\n    require(b \u003E 0);\r\n    uint c = a / b;\r\n    return c;\r\n  }\r\n}\r\n\r\nlibrary Math {\r\n    function max(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a \u003E= b ? a : b;\r\n    }\r\n\r\n    function min(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a \u003C b ? a : b;\r\n    }\r\n\r\n    function average(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // (a \u002B b) / 2 can overflow, so we distribute\r\n        return (a / 2) \u002B (b / 2) \u002B ((a % 2 \u002B b % 2) / 2);\r\n    }\r\n}\r\n\r\ncontract triskaidekaphobia is ERC20Interface {\r\n\r\n  using SafeMath for uint;\r\n  using Math for uint;\r\n  uint8 public constant decimals = 18;\r\n  uint8 public constant maxRank = 15;\r\n  string public constant symbol = \u0022 TRIS\u0022;\r\n  string public constant name = \u0022TRISKAIDEKAPHOBIA\u0022;\r\n  uint public constant maxSupply = 1000000 * 10**uint(decimals);\r\n  uint private _totalSupply = 0;\r\n  uint private _minted = 0;\r\n  uint private _nextAirdrop = 10000 * 10**uint(decimals);\r\n  address rankHead = address(0);\r\n  address devAddress = address(0x3409E6883b3CB6DDc9aEA58f24593F7218B830c7);\r\n\r\n  mapping (address =\u003E uint) private _balances;\r\n  mapping (address =\u003E mapping (address =\u003E uint)) private _allowances;\r\n  mapping (address =\u003E bool) private _airdropped; //keep database of accounts already claimed airdrop\r\n  mapping(address =\u003E bool) ranked;\r\n  mapping(address =\u003E address) rankList;\r\n\r\n  function totalSupply() public view returns (uint) {\r\n    return _totalSupply;\r\n  }\r\n\r\n  function balanceOf(address account) public view returns (uint balance) {\r\n    return _balances[account];\r\n  }\r\n\r\n  function allowance(address owner, address spender) public view returns (uint remaining) {\r\n    return _allowances[owner][spender];\r\n  }\r\n\r\n  function transfer(address to, uint amount) public returns (bool success) {\r\n    _transfer(msg.sender, to, amount);\r\n    return true;\r\n  }\r\n\r\n  function approve(address spender, uint amount) public returns (bool success) {\r\n    _approve(msg.sender, spender, amount);\r\n    return true;\r\n  }\r\n\r\n  function transferFrom(address sender, address recipient, uint amount) public returns (bool success) {\r\n    _transfer(sender, recipient, amount);\r\n    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));\r\n    return true;\r\n  }\r\n\r\n  //internal functions\r\n  function _approve(address owner, address spender, uint amount) internal {\r\n    require(owner != address(0), \u0022ERC20: approve from the zero address\u0022);\r\n    require(spender != address(0), \u0022ERC20: approve to the zero address\u0022);\r\n\r\n    _allowances[owner][spender] = amount;\r\n    emit Approval(owner, spender, amount);\r\n  }\r\n\r\n  function _transfer(address sender, address recipient, uint amount) internal {\r\n    require(sender != address(0), \u0022ERC20: transfer from the zero address\u0022);\r\n    require(recipient != address(0), \u0022ERC20: transfer to the zero address\u0022);\r\n\r\n    // If transfer amount is zero emit event and stop execution\r\n    if (amount == 0) {\r\n      emit Transfer(sender, recipient, 0);\r\n      return;\r\n    }\r\n\r\n    _balances[sender] = _balances[sender].sub(amount);\r\n    _balances[recipient] = _balances[recipient].add(amount);\r\n    emit Transfer(sender, recipient, amount);\r\n\r\n    //takeout sender \u0026 recipient from the linkedlist and re-insert them in the correct order\r\n    _pop(sender);\r\n    _pop(recipient);\r\n    _insert(sender);\r\n    _insert(recipient);\r\n    _slash();\r\n  }\r\n\r\n  function _slash() internal {\r\n    if(_minted \u003E= 400000 * 10**uint(decimals)){\r\n    address rankThirteen = _getRankThirteen();\r\n    address rankFourteen = rankList[rankThirteen];\r\n    if( (rankThirteen != address(0)) \u0026\u0026 (balanceOf(rankThirteen) \u003E 0) ) {\r\n      uint alterBalance = balanceOf(rankThirteen).div(3);\r\n      if(rankFourteen != address(0)){\r\n        _burn(rankThirteen,alterBalance);\r\n        _balances[rankThirteen] = _balances[rankThirteen].sub(alterBalance);\r\n        _balances[rankFourteen] = _balances[rankFourteen].add(alterBalance);\r\n        emit Transfer(rankThirteen, rankFourteen, alterBalance);\r\n        _pop(rankThirteen);\r\n        _pop(rankFourteen);\r\n        _insert(rankThirteen);\r\n        _insert(rankFourteen);\r\n      }\r\n      else {\r\n        _burn(rankThirteen,2*alterBalance);\r\n        _pop(rankThirteen);\r\n        _insert(rankThirteen);\r\n      }\r\n    }\r\n    }\r\n  }\r\n\r\n  function _burn(address account, uint amount) internal {\r\n    _balances[account] = _balances[account].sub(amount);\r\n    _totalSupply = _totalSupply.sub(amount);\r\n    emit Transfer(account, address(0), amount);\r\n  }\r\n\r\n  function _mint(address account, uint amount) internal {\r\n    _totalSupply = _totalSupply.add(amount);\r\n    _minted = _minted.add(amount);\r\n    _airdropped[account] = true;\r\n    uint devReward = (amount.mul(5)).div(100);\r\n    uint accountMint = amount.sub(devReward);\r\n    _balances[devAddress] = _balances[devAddress].add(devReward);\r\n    _balances[account] = _balances[account].add(accountMint);\r\n    emit Transfer(address(0), account, accountMint);\r\n    emit Transfer(address(0), devAddress, devReward);\r\n  }\r\n\r\n  function _airdrop(address account) internal {\r\n    require(account != address(0));\r\n    require(_minted \u003C maxSupply); // check on total suppy\r\n    require(_airdropped[account] != true); //airdrop can be claimed only once per account\r\n    require(_nextAirdrop \u003E 0); //additional check if airdrop is still on\r\n\r\n    _mint(account,_nextAirdrop);\r\n    _nextAirdrop = Math.min((_nextAirdrop.mul(99)).div(100),(maxSupply - _minted));\r\n    _insert(account);\r\n  }\r\n\r\n  function () external payable {\r\n    if(msg.value \u003E 0){\r\n      revert();\r\n    }\r\n    else {\r\n      _airdrop(msg.sender);\r\n    }\r\n  }\r\n\r\n  function _insert(address addr) internal { // function to add a new element to the linkedlist\r\n    require(addr != address(0));\r\n    if(ranked[addr] != true){ //attempt to add the element in the list only if it doesn\u0027t already exist in it\r\n      if(rankHead == address(0)){ // linkedlist getting created for the first time\r\n        rankHead = addr; //add address as the first in the linkedlist\r\n        rankList[addr] = address(0); //address(0) will always mark as the end of the linkedlist\r\n        ranked[addr] = true;\r\n        return;\r\n      }\r\n      else if(_balances[addr] \u003E _balances[rankHead]){ //new element has the largest value and needs to be at the top of the list\r\n        rankList[addr] = rankHead; //add the existing list at the end of the new element\r\n        rankHead = addr; //rankHead points to new element\r\n        ranked[addr] = true;\r\n        return;\r\n      }\r\n      else { //see if new element belongs to anywhere else on the list\r\n        address tracker = rankHead; //start at the beginning of the list\r\n        for(uint8 i = 1; i\u003C=maxRank; i\u002B\u002B){ //loop till maximum allowable length of the list\r\n          //if balance of new element is greater than balance of next element in the list or next element is the end of the list\r\n          if(_balances[addr] \u003E _balances[rankList[tracker]] || rankList[tracker] == address(0)){\r\n            rankList[addr] = rankList[tracker]; //attack existing remainder of list at the back of new element\r\n            rankList[tracker] = addr; //inset new element to the list after the tracker position\r\n            ranked[addr] = true;\r\n            return;\r\n          }\r\n          tracker = rankList[tracker];\r\n        }\r\n      }\r\n    }\r\n  }\r\n\r\n  function _pop(address addr) internal { // function to take out an element from the linkedlist because it\u0027s holding has changed\r\n    if(ranked[addr] == true) { // function only runs if address is in the linkedlis tracking top 25 holders\r\n      address tracker = rankHead; //start at the beginning of the list\r\n      if(tracker == addr){ // if the first element needs to be popped\r\n        rankHead = rankList[tracker]; //point rankHead to the second element in the list\r\n        ranked[addr] = false; // flagging top element as not on the list anymore\r\n        return;\r\n      }\r\n      else{\r\n        //if not the first element then loop to check successive elements\r\n        while (rankList[tracker] != address(0)){ //loop till the last valid element in the list\r\n          if(rankList[tracker] == addr){ //if the next element in the list is the searched address\r\n            rankList[tracker] = rankList[addr]; //link current element to next of next element\r\n            ranked[addr] = false; //flag next element as not on the list\r\n            return;\r\n          }\r\n          tracker = rankList[tracker]; //move tracker to next element on the list\r\n        }\r\n        ranked[addr] = false;//essentially error mitigation, list doesn\u0027t have address and yet address has been flagged as in the list\r\n        return;\r\n      }\r\n    }\r\n  }\r\n\r\n  function getRank() public view returns(uint) { //function to get rank of an address in the top holders\u0027 list\r\n    if(ranked[msg.sender] == true){ //function to check if address has been flagged as among the top holders\u0027 list\r\n      address tracker = rankHead;\r\n      for(uint8 i = 1; i \u003C= maxRank; i\u002B\u002B ){ //rank starts at 1 and not 0 | 0 rank means not present in the list\r\n        if(msg.sender == tracker){\r\n          return uint(i);\r\n        }\r\n        tracker = rankList[tracker];\r\n      }\r\n    }\r\n    return 0; // else rank = 0, means address not on the list\r\n  }\r\n\r\n  function _getRankThirteen() internal returns(address) {\r\n    address tracker = rankHead;\r\n    for(uint i = 1; i \u003C 13; i\u002B\u002B ){\r\n      if(tracker == address(0)){ // linkedlist ended before rank 13 was reached\r\n        return address(0); //return address(0) as an indication that rank 13 doesn\u0027t exist\r\n      }\r\n      tracker = rankList[tracker];\r\n    }\r\n    return tracker; //for loop ending is an indication that tracker is on 13th element without any unexpected return from for loop\r\n  }\r\n\r\n  function burned() public view returns(uint) {\r\n    return _minted-_totalSupply;\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022approve\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022maxRank\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022burned\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getRank\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022maxSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022remaining\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022tokenOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Approval\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"triskaidekaphobia","CompilerVersion":"v0.5.1\u002Bcommit.c8a2cb62","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://d71089ea69c1363af3c63fcf7feddadf4e83407d63ffd733e12c1936445cd39b"}]