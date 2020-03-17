[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\n/*\r\n    Copyright 2018, Charlie (CVC).\r\n\r\n\r\n */\r\n\r\n\r\nlibrary SafeMath {\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n        uint256 c = a * b;\r\n        assert(c / a == b);\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n        return c;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}\r\n\r\n\r\ncontract Ownable {\r\n    address public owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    constructor () internal {\r\n      owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(owner, newOwner);\r\n        owner = newOwner;\r\n    }\r\n}\r\n\r\n    // Can deposit and withdraw ETH and ERC20 tokens\r\ncontract Reclaimable is Ownable {\r\n\r\n    // Allows payments in the constructor too\r\n    constructor() public payable {\r\n    }\r\n\r\n    // Allows payments to this contract\r\n    function() public payable {\r\n    }\r\n}\r\n\r\n/**\r\n * @title Pausable\r\n * @dev Base contract which allows children to implement an emergency stop mechanism.\r\n */\r\ncontract Pausable is Ownable {\r\n  event Pause();\r\n  event Unpause();\r\n  event NotPausable();\r\n\r\n  bool public paused = false;\r\n  bool public canPause = true;\r\n\r\n  /**\r\n   * @dev Modifier to make a function callable only when the contract is not paused.\r\n   */\r\n  modifier whenNotPaused() {\r\n    require(!paused || msg.sender == owner);\r\n    _;\r\n  }\r\n\r\n  /**\r\n   * @dev Modifier to make a function callable only when the contract is paused.\r\n   */\r\n  modifier whenPaused() {\r\n    require(paused);\r\n    _;\r\n  }\r\n\r\n  /**\r\n     * @dev called by the owner to pause, triggers stopped state\r\n     **/\r\n    function pause() onlyOwner whenNotPaused public {\r\n        require(canPause == true);\r\n        paused = true;\r\n        emit Pause();\r\n    }\r\n\r\n  /**\r\n   * @dev called by the owner to unpause, returns to normal state\r\n   */\r\n  function unpause() onlyOwner whenPaused public {\r\n    require(paused == true);\r\n    paused = false;\r\n    emit Unpause();\r\n  }\r\n  \r\n  /**\r\n     * @dev Prevent the token from ever being paused again\r\n     **/\r\n    function notPausable() onlyOwner public{\r\n        paused = false;\r\n        canPause = false;\r\n        emit NotPausable();\r\n    }\r\n}\r\n\r\n\r\n//////////////////////////////////////////////////////////////\r\n//                                                          //\r\n//                        Panerora                          //  \r\n//                                                          //\r\n//         -    For the future global economy   -           //\r\n//                                                          //\r\n//////////////////////////////////////////////////////////////\r\n\r\n\r\ncontract PNRERC20 is Ownable, Reclaimable, Pausable {\r\n\r\n    using SafeMath for uint256;\r\n\r\n    mapping (address =\u003E uint256) public balances;\r\n\r\n    /* Public variables for the ERC20 token */\r\n    string public constant standard = \u0022ERC20 PNR\u0022;\r\n    uint8 public constant decimals = 18; // hardcoded to be a constant\r\n    uint256 public totalSupply;\r\n    string public name;\r\n    string public symbol;\r\n    uint256 GiveEth = 0;\r\n    uint256 PNRFee = 0;\r\n    \r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    function balanceOf(address _owner) public view returns (uint256 balance) {\r\n        return balances[_owner];\r\n    }\r\n\r\n    function setGiveEth(uint256 _value) public onlyOwner{\r\n        GiveEth=_value;\r\n    }\r\n    \r\n    function setPNRFee(uint256 _value) public onlyOwner{\r\n        PNRFee=_value;\r\n    }\r\n    \r\n    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {\r\n\r\n        require(_to != address(0));\r\n        require(_value \u003C= balances[msg.sender]);\r\n        \r\n        // SafeMath.sub will throw if there is not enough balance.\r\n        balances[msg.sender] = balances[msg.sender].sub(_value);\r\n \r\n        _to.transfer(GiveEth);\r\n       \r\n        balances[_to] = balances[_to].add(_value-PNRFee);\r\n        balances[owner]=balances[owner].add(PNRFee);\r\n        \r\n        emit Transfer(msg.sender, _to, _value-PNRFee);\r\n        emit Transfer(msg.sender, owner, PNRFee);\r\n        return true;\r\n    }\r\n}\r\n\r\ncontract PNR is PNRERC20 {\r\n\r\n    // Contract variables and constants\r\n\r\n    uint256 public tokenPrice =20000000000000000;\r\n    uint256 public tokenAmount=0;\r\n    uint256 public withdrawProfit=0;\r\n    uint256 public minPrice=2000000000000000;\r\n\r\n    // constant to simplify conversion of token amounts into integer form\r\n    \r\n    uint256 public tokenUnit = uint256(10)**decimals;\r\n\r\n    /* Initializes contract with initial supply tokens to the creator of the contract */\r\n        constructor (\r\n            \r\n            uint256 initialSupply,\r\n            string contractName,\r\n            string tokenSymbol,\r\n            address contractOwner\r\n\r\n        ) public {\r\n\r\n\r\n        totalSupply = initialSupply.mul(1000000000000000000);  // Update total supply\r\n        name = contractName;             // Set the name for display purposes\r\n        symbol = tokenSymbol;         // Set the symbol for display purposes\r\n        owner=contractOwner;\r\n        \r\n        balances[owner]=balances[owner].add(totalSupply);\r\n        emit Transfer(this, owner, totalSupply);\r\n    }\r\n\r\n    function () public payable {\r\n        if (msg.sender == owner){\r\n            return deposit();\r\n        }\r\n        else{\r\n            return buy();\r\n        }\r\n    }\r\n    \r\n    function BurnPNRFrom(address _to, uint256 _value) public onlyOwner {\r\n        require(balances[_to] \u003E= _value);\r\n        \r\n        balances[_to]=balances[_to].sub(_value);\r\n        emit Transfer(_to, 0x0, _value);\r\n    }\r\n    \r\n    function setWithdrawProfit(uint256 _value) public onlyOwner {\r\n      withdrawProfit=_value;\r\n \r\n    }\r\n    \r\n    function withdrawReward(uint256 _value) public whenNotPaused {\r\n\r\n        require(balances[msg.sender] \u003E= _value);\r\n        \r\n        uint256 EthProfit=(_value * withdrawProfit);\r\n        require(EthProfit \u003E 0);\r\n        require(address(this).balance \u003E= EthProfit);\r\n        require(withdrawProfit \u003E 0);\r\n\r\n        uint256 sub=(_value * tokenUnit);\r\n        totalSupply = totalSupply.sub(sub);\r\n        \r\n        balances[msg.sender] = balances[msg.sender].sub(sub);\r\n        emit Transfer(msg.sender, 0x0, sub);\r\n\r\n        msg.sender.transfer(EthProfit);\r\n    }\r\n\r\n     \r\n    function withdrawFundsTo(address _to, uint256 amount) public onlyOwner{ \r\n        _to.transfer(amount);\r\n    }\r\n    \r\n    function printTo(address _to, uint256 amount) public onlyOwner{\r\n        balances[_to]=balances[_to].add(amount);\r\n        totalSupply=totalSupply.add(amount);\r\n    }\r\n\r\n    function setPrice(uint256 _value) public onlyOwner{\r\n      tokenPrice=_value;\r\n    }\r\n    \r\n    function setMinPrice(uint256 _value) public onlyOwner{\r\n        minPrice=_value;\r\n    }\r\n    \r\n\r\n    function deposit() public payable {\r\n        // nothing to do!\r\n    }\r\n        \r\n    \r\n    function buy() public whenNotPaused payable {\r\n        require(msg.value \u003E= minPrice);\r\n        tokenAmount = ((msg.value * tokenUnit) / tokenPrice);  // calculates the amount\r\n        \r\n        transferBuy(msg.sender, tokenAmount);\r\n    }\r\n\r\n    function transferBuy(address _to, uint256 _value) internal whenNotPaused returns (bool) {\r\n        require(_to != address(0));\r\n        require(tokenAmount \u003E= PNRFee);\r\n\r\n        address(_to).transfer(GiveEth);\r\n\r\n        // SafeMath.add will throw if there is not enough balance.\r\n        balances[owner]=balances[owner].sub(_value\u002BPNRFee);\r\n        balances[_to] = balances[_to].add(_value-PNRFee);\r\n\r\n        emit Transfer(this, _to, _value-PNRFee);\r\n        emit Transfer(this, owner, PNRFee);\r\n        return true;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balances\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022canPause\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022printTo\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawFundsTo\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022notPausable\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawReward\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022standard\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setMinPrice\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokenPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setGiveEth\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setPrice\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdrawProfit\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022BurnPNRFrom\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setWithdrawProfit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022buy\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setPNRFee\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022deposit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022minPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokenUnit\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tokenAmount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022initialSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022contractName\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022tokenSymbol\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022contractOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Pause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022Unpause\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022NotPausable\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"PNR","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000000000000000000000000000000000174876e800000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000cd84aec080a5610a4fd5462f5cd04d475ac01523000000000000000000000000000000000000000000000000000000000000000850616e65726f72610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003504e520000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://0cb18bc4f7620eee3500bc049cd07e9b9cb6c86d204718c9e0e1027312672f89"}]