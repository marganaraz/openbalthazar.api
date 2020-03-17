[{"SourceCode":"pragma solidity ^0.4.12;\r\n\r\ncontract Log {\r\n  struct Message {\r\n    address Sender;\r\n    string Data;\r\n    uint Time;\r\n  }\r\n\r\n  Message[] public History;\r\n\r\n  Message LastMsg;\r\n\r\n  function addMessage(string memory _data) public {\r\n    LastMsg.Sender = msg.sender;\r\n    LastMsg.Time = now;\r\n    LastMsg.Data = _data;\r\n    History.push(LastMsg);\r\n  }\r\n}\r\n\r\ncontract Ownable {\r\n  address public owner;\r\n  function Ownable() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  modifier onlyOwner() {\r\n    if (msg.sender != owner){\r\n      revert();\r\n    }\r\n    _;\r\n  }\r\n\r\n  modifier protected() {\r\n      if(msg.sender != address(this)){\r\n        revert();\r\n      }\r\n      _;\r\n  }\r\n\r\n  function transferOwnership(address newOwner) public onlyOwner {\r\n    if (newOwner == address(0)) {\r\n      revert();\r\n    }\r\n    owner = newOwner;\r\n  }\r\n\r\n  function withdraw() public onlyOwner {\r\n    msg.sender.transfer(address(this).balance);\r\n  }\r\n}\r\n\r\ncontract CaptureTheFlag is Ownable {\r\n  address owner;\r\n  event WhereAmI(address, string);\r\n  Log TransferLog;\r\n  uint256 public jackpot = 0;\r\n  uint256 MinDeposit = 1 ether;\r\n  uint256 minInvestment = 1 ether;\r\n  uint public sumInvested;\r\n  uint public sumDividend;\r\n  bool inProgress = false;\r\n\r\n  mapping(address =\u003E uint256) public balances;\r\n  struct Osakako {\r\n    address me;\r\n  }\r\n  struct investor {\r\n    uint256 investment;\r\n    string username;\r\n  }\r\n  event Transfer(\r\n    uint amount,\r\n    bytes32 message,\r\n    address target,\r\n    address currentOwner\r\n  );\r\n\r\n  mapping(address =\u003E investor) public investors;\r\n\r\n  function CaptureTheFlag(address _log) public {\r\n    TransferLog = Log(_log);\r\n    owner = msg.sender;\r\n  }\r\n\r\n  // Payday!!\r\n  function() public payable {\r\n    if( msg.value \u003E= jackpot ){\r\n      owner = msg.sender;\r\n    }\r\n    jackpot \u002B= msg.value; // add to our jackpot\r\n  }\r\n\r\n  modifier onlyUsers() {\r\n    require(users[msg.sender] != false);\r\n    _;\r\n  }\r\n\r\n  mapping(address =\u003E bool) users;\r\n\r\n  function registerAllPlayers(address[] players) public onlyOwner {\r\n    require(inProgress == false);\r\n\r\n    for (uint32 i = 0; i \u003C players.length; i\u002B\u002B) {\r\n      users[players[i]] = true;\r\n    }\r\n    inProgress = true;\r\n  }\r\n\r\n  function takeAll() external onlyOwner {\r\n    msg.sender.transfer(this.balance); // payout\r\n    jackpot = 0; // reset the jackpot\r\n  }\r\n  // Payday!!\r\n\r\n  // Bank\r\n  function Deposit() public payable {\r\n    if ( msg.value \u003E= MinDeposit ){\r\n      balances[msg.sender] \u002B= msg.value;\r\n      TransferLog.addMessage(\u0022 Deposit \u0022);\r\n    }\r\n  }\r\n\r\n  function CashOut(uint amount) public onlyUsers {\r\n    if( amount \u003C= balances[msg.sender] ){\r\n      if(msg.sender.call.value(amount)()){\r\n        balances[msg.sender] -= amount;\r\n        TransferLog.addMessage(\u0022 CashOut \u0022);\r\n      }\r\n    }\r\n  }\r\n  // Bank\r\n\r\n  //--- Hmmm\r\n  function invest() public payable {\r\n    if ( msg.value \u003E= minInvestment ){\r\n      investors[msg.sender].investment \u002B= msg.value;\r\n    }\r\n  }\r\n\r\n  function divest(uint amount) public onlyUsers {\r\n    if ( investors[msg.sender].investment == 0 || amount == 0) {\r\n      revert();\r\n    }\r\n    // no need to test, this will throw if amount \u003E investment\r\n    investors[msg.sender].investment -= amount;\r\n    sumInvested -= amount;\r\n    this.loggedTransfer(amount, \u0022\u0022, msg.sender, owner);\r\n  }\r\n\r\n  function loggedTransfer(uint amount, bytes32 message, address target, address currentOwner) public protected onlyUsers {\r\n    if(!target.call.value(amount)()){\r\n      revert();\r\n    }\r\n\r\n    Transfer(amount, message, target, currentOwner);\r\n  }\r\n  //--- Empty String Literal\r\n\r\n  function osaka(string message) public onlyUsers {\r\n    Osakako osakako;\r\n    osakako.me = msg.sender;\r\n    WhereAmI(osakako.me, message);\r\n  }\r\n\r\n  function tryMeLast() public payable onlyUsers {\r\n    if ( msg.value \u003E= 0.1 ether ) {\r\n      uint256 multi = 0;\r\n      uint256 amountToTransfer = 0;\r\n      for (var i = 0; i \u003C 2 * msg.value; i\u002B\u002B) {\r\n        multi = i * 2;\r\n        if (multi \u003C amountToTransfer) {\r\n          break;\r\n        }\r\n        amountToTransfer = multi;\r\n      }\r\n      msg.sender.transfer(amountToTransfer);\r\n    }\r\n  }\r\n\r\n  function easyMode( address addr ) external payable onlyUsers {\r\n    if ( msg.value \u003E= this.balance ){\r\n      addr.transfer(this.balance \u002B msg.value);\r\n    }\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022easyMode\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balances\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sumDividend\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022players\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022registerAllPlayers\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022currentOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022loggedTransfer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022jackpot\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022investors\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022investment\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022username\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tryMeLast\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022osaka\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022divest\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022CashOut\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sumInvested\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022takeAll\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022invest\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Deposit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_log\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022WhereAmI\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022message\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022target\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022currentOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"CaptureTheFlag","CompilerVersion":"v0.4.12\u002Bcommit.194ff033","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000c7762a3bed2afd8f823694b5c5ec3f17e98e66f8","Library":"","SwarmSource":"bzzr://9b8db614363f971c49440d4d498b8c0b653688f10fdeacb9a9d722b11172bc63"}]