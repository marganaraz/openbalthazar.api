[{"SourceCode":"pragma solidity ^0.5.10;\r\n\r\n// BitcoinSov Token TimeLock - 7 DAY TEST CONTRACT \r\n//\r\n// SHORT TERM FREEZE TO VERIFY CODE FUNCTIONALITY!\r\n// THIS VERSION LOCKS TOKENS FOR 1 WEEK ONLY! \r\n//\r\n// DO NOT SEND TOKENS DIRECTLY TO THIS CONTRACT!!!\r\n// THEY WILL BE LOST FOREVER!!!\r\n//\r\n// For instructions on how to use this contract, please see the post on reddit.com/r/BitcoinSoV\r\n//\r\n// This contract locks all BSoV for 180 days once the contract is deployed. Tokens can be added at any TimeLock\r\n// within that period without resetting the timer.\r\n//\r\n// After the desired date is reached, users can withdraw tokens with a rate limit to prevent all holders\r\n// from withdrawing and selling at the same time. The limit is 1,000 BSoV per week once the 180 days is hit.\r\n\r\nlibrary SafeMath {\r\n    function add(uint a, uint b) internal pure returns(uint c) {\r\n        c = a \u002B b;\r\n        require(c \u003E= a);\r\n    }\r\n    function sub(uint a, uint b) internal pure returns(uint c) {\r\n        require(b \u003C= a);\r\n        c = a - b;\r\n    }\r\n    function mul(uint a, uint b) internal pure returns(uint c) {\r\n        c = a * b;\r\n        require(a == 0 || c / a == b);\r\n    }\r\n    function div(uint a, uint b) internal pure returns(uint c) {\r\n        require(b \u003E 0);\r\n        c = a / b;\r\n    }\r\n}\r\n\r\ncontract ERC20Interface {\r\n    function totalSupply() public view returns(uint);\r\n    function balanceOf(address tokenOwner) public view returns(uint balance);\r\n    function allowance(address tokenOwner, address spender) public view returns(uint remaining);\r\n    function transfer(address to, uint tokens) public returns(bool success);\r\n    function approve(address spender, uint tokens) public returns(bool success);\r\n    function transferFrom(address from, address to, uint tokens) public returns(bool success);\r\n    event Transfer(address indexed from, address indexed to, uint tokens);\r\n    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);\r\n}\r\n\r\ncontract LockMyBSOV {\r\n\r\n    using SafeMath for uint;\r\n    \r\n    address constant tokenContract = 0x26946adA5eCb57f3A1F91605050Ce45c482C9Eb1;\r\n\r\n    uint constant PRECISION = 100000000;\r\n    uint constant timeUntilUnlocked = 7 days;            // All tokens locked for 180 days after contract creation.\r\n    uint constant maxWithdrawalAmount = 1000 * PRECISION;  // Max withdrawal of 2.5k tokens per week per user once 180 days is hit.\r\n    uint constant timeBetweenWithdrawals = 1 hours;\r\n    uint unfreezeDate;\r\n\r\n\tmapping (address =\u003E uint) balance;\r\n\tmapping (address =\u003E uint) lastWithdrawal;\r\n\r\n    event TokensFrozen (\r\n        address indexed addr,\r\n        uint256 amt,\r\n        uint256 time\r\n\t);\r\n\r\n    event TokensUnfrozen (\r\n        address indexed addr,\r\n        uint256 amt,\r\n        uint256 time\r\n\t);\r\n\r\n    constructor() public {\r\n        unfreezeDate = now \u002B timeUntilUnlocked;\r\n    }\r\n\r\n    function withdraw(uint _amount) public {\r\n        require(balance[msg.sender] \u003E= _amount, \u0022You do not have enough tokens!\u0022);\r\n        require(now \u003E= unfreezeDate, \u0022Tokens are locked!\u0022);\r\n        require(_amount \u003C= maxWithdrawalAmount, \u0022Trying to withdraw too much at once!\u0022);\r\n        require(now \u003E= lastWithdrawal[msg.sender] \u002B timeBetweenWithdrawals, \u0022Trying to withdraw too frequently!\u0022);\r\n        require(ERC20Interface(tokenContract).transfer(msg.sender, _amount), \u0022Could not withdraw BSoV!\u0022);\r\n\r\n        balance[msg.sender] -= _amount;\r\n        lastWithdrawal[msg.sender] = now;\r\n        emit TokensUnfrozen(msg.sender, _amount, now);\r\n    }\r\n\r\n    function getBalance(address _addr) public view returns (uint256 _balance) {\r\n        return balance[_addr];\r\n    }\r\n    \r\n    function getLastWithdrawal(address _addr) public view returns (uint256 _lastWithdrawal) {\r\n        return lastWithdrawal[_addr];\r\n    }\r\n   \r\n    function getTimeLeft() public view returns (uint256 _timeLeft) {\r\n        require(unfreezeDate \u003E now, \u0022The future is here!\u0022);\r\n        return unfreezeDate - now;\r\n    } \r\n    \r\n    function receiveApproval(address _sender, uint256 _value, address _tokenContract, bytes memory _extraData) public {\r\n        require(_tokenContract == tokenContract, \u0022Can only deposit BSoV into this contract!\u0022);\r\n        require(_value \u003E 100, \u0022Must be greater than 100 Mundos to keep people from whining about the math!\u0022);\r\n        require(ERC20Interface(tokenContract).transferFrom(_sender, address(this), _value), \u0022Could not transfer BSoV to Time Lock contract address.\u0022);\r\n\r\n        uint _adjustedValue = _value.mul(99).div(100);\r\n        balance[_sender] \u002B= _adjustedValue;\r\n        emit TokensFrozen(_sender, _adjustedValue, now);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getLastWithdrawal\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_lastWithdrawal\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_tokenContract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_extraData\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022receiveApproval\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getTimeLeft\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_timeLeft\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022TokensFrozen\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amt\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022time\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022TokensUnfrozen\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"LockMyBSOV","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://11216e3da4e6310be0b1d780ecd6974528b25c4bab4c698f8b8f5bd87afd7067"}]