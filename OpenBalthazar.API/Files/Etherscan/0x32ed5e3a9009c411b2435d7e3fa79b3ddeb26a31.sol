[{"SourceCode":"pragma solidity ^0.5.11;\r\n\r\ncontract IERC20 {\r\n  uint256 public totalSupply;\r\n  function balanceOf(address _owner) public view returns (uint256 balance);\r\n  function transfer(address _to, uint256 _value) public returns (bool success);\r\n  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);\r\n  function approve(address _spender, uint256 _value) public returns (bool success);\r\n  function allowance(address _owner, address _spender) public view returns (uint256 remaining);\r\n  event Transfer(address indexed _from, address indexed _to, uint256 _value);\r\n  event Approval(address indexed _owner, address indexed _spender, uint256 _value);\r\n}\r\n\r\nlibrary SafeMath {   \r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256){\r\n    uint256 c = a * b;\r\n    assert(a == 0 || c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003E 0);\r\n    uint256 c = a / b;\r\n    assert(a == b * c \u002B a % b);\r\n    return c;\r\n  }\r\n\r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }  \r\n}\r\n\r\nlibrary SafeERC20 {\r\n    using SafeMath for uint256;\r\n\r\n    function safeTransfer(IERC20 token, address to, uint256 value) internal {\r\n        require(token.transfer(to, value));\r\n    }   \r\n}\r\n\r\ncontract ReentrancyGuard {   \r\n    uint256 private _guardCounter;\r\n\r\n    constructor () internal {\r\n        _guardCounter = 1;\r\n    }\r\n\r\n    modifier nonReentrant() {\r\n        _guardCounter \u002B= 1;\r\n        uint256 localCounter = _guardCounter;\r\n        _;\r\n        require(localCounter == _guardCounter);\r\n    } \r\n}\r\n\r\ncontract Ownable {  \r\n  address payable public owner;\r\n  address payable public potentialNewOwner;\r\n  \r\n  event OwnershipTransferred(address payable indexed _from, address payable indexed _to);\r\n\r\n  constructor() public {\r\n    owner = msg.sender;\r\n  }\r\n\r\n  modifier onlyOwner() {\r\n    require(msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  function transferOwnership(address payable _newOwner) external onlyOwner {\r\n    potentialNewOwner = _newOwner;\r\n  }\r\n  \r\n  function acceptOwnership() external {\r\n    require(msg.sender == potentialNewOwner);\r\n    emit OwnershipTransferred(owner, potentialNewOwner);\r\n    owner = potentialNewOwner;\r\n  }\r\n}\r\n\r\ncontract Breaker is Ownable {\r\n    bool public inLockdown;\r\n\r\n    constructor () internal {\r\n        inLockdown = false;\r\n    }\r\n\r\n    modifier outOfLockdown() {\r\n        require(inLockdown == false);\r\n        _;\r\n    }\r\n    \r\n    function updateLockdownState(bool state) external onlyOwner{\r\n        inLockdown = state;\r\n    }\r\n}\r\n\r\ncontract Crowdsale is Breaker, ReentrancyGuard {\r\n    using SafeMath for uint256;\r\n    using SafeERC20 for IERC20;\r\n\r\n    IERC20 private _token;\r\n    address payable private _wallet;\r\n    uint256 private _rate;\r\n    uint256 private _weiRaised;\r\n    \r\n    string public name;\r\n    string public symbol;\r\n\r\n    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);\r\n    event RateUpdate(uint256 rate);\r\n\r\n    constructor (address payable wallet, uint256 rate, IERC20 token) public {\r\n        require(rate \u003E 0);\r\n        require(wallet != address(0));\r\n        require(address(token) != address(0));\r\n\r\n        _rate = rate;\r\n        _wallet = wallet;\r\n        _token = token;\r\n\t\r\n        name = \u0022Morality Crowdsale\u0022;\r\n\t    symbol = \u0022MO\u0022;\r\n    }\r\n\r\n    function () external payable {\r\n        buyTokens(msg.sender);\r\n    }\r\n\r\n    function token() external view returns (IERC20) {\r\n        return _token;\r\n    }\r\n\r\n    function wallet() external view returns (address) {\r\n        return _wallet;\r\n    }\r\n\r\n    function rate() external view returns (uint256) {\r\n        return _rate;\r\n    }\r\n\r\n    function weiRaised() external view returns (uint256) {\r\n        return _weiRaised;\r\n    }\r\n\r\n    function buyTokens(address beneficiary) public nonReentrant outOfLockdown payable {\r\n        uint256 weiAmount = msg.value;\r\n        _preValidatePurchase(beneficiary, weiAmount);\r\n        //Calculate token amount to sent\r\n        uint256 tokens = _getTokenAmount(weiAmount);\r\n        //Update total raised\r\n        _weiRaised = _weiRaised.add(weiAmount);\r\n        //Send tokens to beneficiary\r\n        _processPurchase(beneficiary, tokens);\r\n        //Update the event log\r\n        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);\r\n        //Forwad the funds to admin\r\n        _forwardFunds();\r\n    }\r\n    \r\n    function setRate(uint256 newRate) onlyOwner external{\r\n        _rate = newRate;\r\n        emit RateUpdate(newRate);\r\n    }\r\n\r\n    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal pure {\r\n        require(beneficiary != address(0));\r\n        require(weiAmount != 0);\r\n    }\r\n\r\n    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {\r\n        _token.safeTransfer(beneficiary, tokenAmount);\r\n    }\r\n\r\n    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {\r\n        _deliverTokens(beneficiary, tokenAmount);\r\n    }\r\n\r\n    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {\r\n        return weiAmount.mul(_rate);\r\n    }\r\n    \r\n    function _forwardFunds() internal {\r\n        _wallet.transfer(msg.value);\r\n    }\r\n\t\r\n    function deprecateContract() onlyOwner external{\r\n        selfdestruct(owner);\r\n    } \r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022inLockdown\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022rate\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022potentialNewOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022newRate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setRate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022weiRaised\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022wallet\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022state\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022updateLockdownState\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022acceptOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022deprecateContract\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022beneficiary\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022buyTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022token\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022contract IERC20\u0022,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022purchaser\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022TokensPurchased\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022RateUpdate\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Crowdsale","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000cde41fa0279e1d8e56eaeee9f7acdada11a1c58a0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000ebf7252e06e9e5cf81cb6ff6d07b46f126704c42","Library":"","SwarmSource":"bzzr://144b95a795b760977c9cbe33fa0f660380b332985d2294447265c56bffb51f10"}]