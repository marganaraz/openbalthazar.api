[{"SourceCode":"pragma solidity ^0.4.24;\r\n\r\nlibrary SafeMath {\r\n\r\n  \r\n  function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    if (a == 0) {\r\n      return 0;\r\n    }\r\n    uint256 c = a * b;\r\n    assert(c / a == b);\r\n    return c;\r\n  }\r\n\r\n  function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    uint256 c = a / b;\r\n    // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n    return c;\r\n  }\r\n\r\n  \r\n  function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    assert(b \u003C= a);\r\n    return a - b;\r\n  }\r\n\r\n \r\n  function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n    uint256 c = a \u002B b;\r\n    assert(c \u003E= a);\r\n    return c;\r\n  }\r\n}\r\n\r\n// https://github.com/ethereum/EIPs/issues/20\r\ninterface ERC20 {\r\n    function totalSupply() external view returns (uint supply);\r\n    function balanceOf(address _owner) external view returns (uint balance);\r\n    function transfer(address _to, uint _value) external returns (bool success);\r\n    function transferFrom(address _from, address _to, uint _value) external returns (bool success);\r\n    function approve(address _spender, uint _value) external returns (bool success);\r\n    function allowance(address _owner, address _spender) external view returns (uint remaining);\r\n    function decimals() external view returns(uint digits);\r\n    event Approval(address indexed _owner, address indexed _spender, uint _value);\r\n}\r\n\r\ncontract Ownable {\r\n    address public owner;\r\n    \r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(owner, newOwner);\r\n        owner = newOwner;\r\n    }\r\n\r\n}\r\n/**\r\n * Author : Hamza Yasin\r\n * Linkedin: linkedin.com/in/hamzayasin\r\n * Github: HamzaYasin1\r\n */\r\n\r\ncontract ScarlettSale is Ownable {\r\n    \r\n    using SafeMath for uint256;\r\n\r\n    // The token being sold\r\n    ERC20 private _token;\r\n    \r\n    // Address where funds are collected\r\n    address internal _wallet;\r\n    \r\n    uint256 internal _tierOneRate = 1000;\r\n    \r\n    uint256 internal _tierTwoRate = 665; \r\n    \r\n    uint256 internal _tierThreeRate = 500;\r\n    \r\n    uint256 internal _tierFourRate = 400; \r\n    \r\n    uint256 internal _tierFiveRate = 200; \r\n    \r\n    // Amount of wei raised\r\n    uint256 internal _weiRaised;\r\n    \r\n    uint256 internal _monthOne;\r\n        \r\n    uint256 internal _monthTwo;\r\n    \r\n    uint256 internal _monthThree;\r\n    \r\n    uint256 internal _monthFour;\r\n        \r\n    uint256 internal _tokensSold;\r\n    \r\n    uint256 public _startTime =  1569888000; // Start date - 10/01/2019 @ 12:00am (UTC)\r\n    \r\n    uint256 public _endTime = _startTime \u002B 20 weeks; //15-Oct-2019 - 12 am\r\n    \r\n    uint256 public _saleSupply = SafeMath.mul(100500000, 1 ether); //\r\n    \r\n    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);\r\n    \r\n    constructor (address  wallet, ERC20 token) public {\r\n        require(wallet != address(0), \u0022Crowdsale: wallet is the zero address\u0022);\r\n        require(address(token) != address(0), \u0022Crowdsale: token is the zero address\u0022);\r\n\r\n        _wallet = wallet;\r\n        _token = token;\r\n        _tokensSold = 0;\r\n        \r\n        _monthOne = SafeMath.add(_startTime, 4 weeks);\r\n        _monthTwo = SafeMath.add(_monthOne, 4 weeks);\r\n        _monthThree = SafeMath.add(_monthTwo, 4 weeks);\r\n        _monthFour = SafeMath.add(_monthThree, 4 weeks);\r\n\r\n    }\r\n\r\n    function () external payable {\r\n        buyTokens(msg.sender);\r\n    }\r\n\r\n\r\n    function token() public view returns (ERC20) {\r\n        return _token;\r\n    }\r\n\r\n    function wallet() public view returns (address ) {\r\n        return _wallet;\r\n    }\r\n\r\n    function weiRaised() public view returns (uint256) {\r\n        return _weiRaised;\r\n    }\r\n\r\n    function buyTokens(address beneficiary) public  payable {\r\n        require(validPurchase());\r\n\r\n        uint256 weiAmount = msg.value;\r\n        uint256 accessTime = now;\r\n        \r\n        require(weiAmount \u003E= 10000000000000000, \u0022Wei amount should be greater than 0.01 ETH\u0022);\r\n        _preValidatePurchase(beneficiary, weiAmount);\r\n        \r\n        uint256 tokens = 0;\r\n        \r\n        tokens = _processPurchase(accessTime,weiAmount, tokens);\r\n      \r\n        _weiRaised = _weiRaised.add(weiAmount);\r\n        \r\n        _deliverTokens(beneficiary, tokens);  \r\n        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);\r\n        \r\n        _tokensSold = _tokensSold.add(tokens);\r\n        \r\n        _forwardFunds();\r\n     \r\n    }\r\n\r\n    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal pure {\r\n        require(beneficiary != address(0), \u0022Crowdsale: beneficiary is the zero address\u0022);\r\n        require(weiAmount != 0, \u0022Crowdsale: weiAmount is 0\u0022);\r\n    }\r\n\r\n    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {\r\n        _token.transfer(beneficiary, tokenAmount);\r\n    }\r\n\r\n    function _processPurchase(uint256 accessTime, uint256 weiAmount, uint256 tokenAmount)  internal returns (uint256) {\r\n       \r\n       if ( accessTime \u003C= _monthOne ) { \r\n     \r\n        tokenAmount = SafeMath.add(tokenAmount, weiAmount.mul(_tierOneRate));\r\n     \r\n      } else if (( accessTime \u003C= _monthTwo ) \u0026\u0026 (accessTime \u003E _monthOne)) { \r\n     \r\n        tokenAmount = SafeMath.add(tokenAmount, weiAmount.mul(_tierTwoRate));\r\n     \r\n      } else if (( accessTime \u003C= _monthThree ) \u0026\u0026 (accessTime \u003E _monthTwo)) { \r\n     \r\n        tokenAmount = SafeMath.add(tokenAmount, weiAmount.mul(_tierThreeRate));\r\n     \r\n      } else if (( accessTime \u003C= _monthFour ) \u0026\u0026 (accessTime \u003E _monthThree)) { \r\n     \r\n        tokenAmount = SafeMath.add(tokenAmount, weiAmount.mul(_tierFourRate));\r\n     \r\n      } else {\r\n          \r\n          tokenAmount = SafeMath.add(tokenAmount, weiAmount.mul(_tierFiveRate));\r\n          \r\n      }\r\n\r\n        require(_saleSupply \u003E= tokenAmount, \u0022sale supply should be greater or equals to tokenAmount\u0022);\r\n        \r\n        _saleSupply = _saleSupply.sub(tokenAmount);        \r\n\r\n        return tokenAmount;\r\n        \r\n    }\r\n    \r\n      // @return true if the transaction can buy tokens\r\n    function validPurchase() internal constant returns (bool) {\r\n        bool withinPeriod = now \u003E= _startTime \u0026\u0026 now \u003C= _endTime;\r\n        bool nonZeroPurchase = msg.value != 0;\r\n        return withinPeriod \u0026\u0026 nonZeroPurchase;\r\n  }\r\n\r\n  // @return true if crowdsale event has ended\r\n    function hasEnded() public constant returns (bool) {\r\n      return now \u003E _endTime;\r\n    }\r\n\r\n    function _forwardFunds() internal {\r\n        _wallet.transfer(msg.value);\r\n    }\r\n    function withdrawTokens(uint _amount) external onlyOwner {\r\n        require(_amount \u003E 0, \u0022token amount should be greater than 0\u0022);\r\n       _token.transfer(_wallet, _amount);\r\n   }\r\n      \r\n    function setWallet(address _newWallet) public onlyOwner  {\r\n        _wallet = _newWallet;\r\n    }\r\n    \r\n    function transferFunds(address[] recipients, uint256[] values) external onlyOwner {\r\n\r\n        for (uint i = 0; i \u003C recipients.length; i\u002B\u002B) {\r\n            uint x = values[i].mul(1 ether);\r\n            require(_saleSupply \u003E= values[i]);\r\n            _saleSupply = SafeMath.sub(_saleSupply,values[i]);\r\n            _token.transfer(recipients[i], x); \r\n        }\r\n    } \r\n\r\n\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_saleSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022weiRaised\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_endTime\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022recipients\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022values\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022name\u0022:\u0022transferFunds\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022wallet\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newWallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setWallet\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022beneficiary\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022buyTokens\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022hasEnded\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_startTime\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022token\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022purchaser\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022beneficiary\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022TokensPurchased\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"ScarlettSale","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000990d3d245b83bf43488f446b3950554536036165000000000000000000000000ebaec4d9623621a43fa46a5bb5ccdc4aab651160","Library":"","SwarmSource":"bzzr://066a29dc57541e37ea574566d69386cc1c70c9a1a3cc11703062098f0faa2769"}]