[{"SourceCode":"pragma solidity ^0.4.25;\r\n \r\n/*\r\n* An ERC 20 Utility Token with an Inbuilt Exchange within the Smart Contract\r\n* Ace Tokens (ACE) by AceWins.io                                                                                                                    \r\n* 1% Affiliate Commission\r\n* Website: https://www.acetokens.io\r\n* Casino Website: https://www.acewins.io\r\n*/\r\n\r\n\r\ncontract Ownable {\r\n    \r\n    address public owner;\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n    \r\n\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n}\r\n\r\n\r\ncontract AceTokens is Ownable{\r\n    using SafeMath for uint256;\r\n    \r\n     modifier onlyBagholders {\r\n        require(myTokens() \u003E 0);\r\n        _;\r\n    }\r\n            \r\n    event onTokenPurchase(\r\n        address indexed customerAddress,\r\n        uint256 incomingEthereum,\r\n        uint256 tokensMinted,\r\n        address indexed referredBy,\r\n        uint timestamp,\r\n        uint256 price\r\n);\r\n\r\n    event onTokenSell(\r\n        address indexed customerAddress,\r\n        uint256 tokensBurned,\r\n        uint256 ethereumEarned,\r\n        uint timestamp,\r\n        uint256 price\r\n);\r\n    event onWithdraw(\r\n        address indexed customerAddress,\r\n        uint256 ethereumWithdrawn\r\n);\r\n\r\n    event Transfer(\r\n        address indexed from,\r\n        address indexed to,\r\n        uint256 tokens\r\n);\r\n\r\n    string public name = \u0022Ace Tokens\u0022;\r\n    string public symbol = \u0022ACE\u0022;\r\n    uint8 constant public decimals = 18;\r\n    uint8 constant internal refferalFee_ = 1;\r\n    uint8 constant internal AdmCh_ = 7; //It is actually 0.7%. This value will be divided by 10 and used. Since we cannot use a decimal here, a round number is used.\r\n    uint256 constant internal tokenPriceInitial_ = 0.00000001 ether;\r\n    uint256 constant internal tokenPriceIncremental_ = 0.000000001 ether;\r\n    uint256 public stakingRequirement = 10e18;\r\n    uint256 public launchtime = 1582205400;\r\n  \r\n    \r\n    mapping(address =\u003E uint256) internal tokenBalanceLedger_;\r\n    mapping(address =\u003E uint256) internal referralBalance_;\r\n    mapping(address =\u003E int256) internal payoutsTo_;\r\n    uint256 internal tokenSupply_;\r\n    address adm = 0xA4d05a1c22C8Abe6CCB2333C092EC80bd0955031;\r\n    \r\n\r\n        function buy(address _referredBy) public payable returns (uint256) {\r\n        require(now \u003E= launchtime);\r\n        uint256 AdmFee = msg.value.div(100).mul(AdmCh_);\r\n        uint256 ExFee = SafeMath.div(AdmFee, 10);  \r\n        adm.transfer(ExFee);\r\n        purchaseTokens(msg.value, _referredBy);\r\n    }\r\n    \r\n        function() payable public {\r\n        require(now \u003E= launchtime);\r\n        uint256 AdmFee = msg.value.div(100).mul(AdmCh_);\r\n        uint256 ExFee = SafeMath.div(AdmFee, 10); \r\n        adm.transfer(ExFee);\r\n        purchaseTokens(msg.value, 0x0);\r\n    }\r\n    \r\n function sell(uint256 _amountOfTokens) onlyBagholders public {\r\n        address _customerAddress = msg.sender;\r\n        require(_amountOfTokens \u003C= tokenBalanceLedger_[_customerAddress]);\r\n        uint256 _tokens = _amountOfTokens;\r\n        uint256 _ethereum = tokensToEthereum_(_tokens);\r\n        uint256 AdmFee = SafeMath.div(SafeMath.mul(_ethereum, AdmCh_), 100);\r\n        uint256 _admout = SafeMath.div(AdmFee, 10);\r\n        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _admout);\r\n        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);\r\n        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);\r\n        _customerAddress.transfer(_taxedEthereum);\r\n        adm.transfer(_admout); \r\n        emit onTokenSell(_customerAddress, _tokens, _taxedEthereum, now, buyPrice());\r\n    }\r\n\r\n    function transfer(address _toAddress, uint256 _amountOfTokens) onlyBagholders public returns (bool) {\r\n        address _customerAddress = msg.sender;\r\n        require(_amountOfTokens \u003C= tokenBalanceLedger_[_customerAddress]);\r\n        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);\r\n        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);\r\n        emit Transfer(_customerAddress, _toAddress, _amountOfTokens);\r\n        return true;\r\n    }\r\n\r\n\r\n    function totalEthereumBalance() public view returns (uint256) {\r\n        return this.balance;\r\n    }\r\n\r\n    function totalSupply() public view returns (uint256) {\r\n        return tokenSupply_;\r\n    }\r\n\r\n    function myTokens() public view returns (uint256) {\r\n        address _customerAddress = msg.sender;\r\n        return balanceOf(_customerAddress);\r\n    }\r\n\r\n\r\n    function balanceOf(address _customerAddress) public view returns (uint256) {\r\n        return tokenBalanceLedger_[_customerAddress];\r\n    }\r\n\r\n\r\n\r\n    function sellPrice() public view returns (uint256) {\r\n        // our calculation relies on the token supply, so we need supply. Doh.\r\n        if (tokenSupply_ == 0) {\r\n            return tokenPriceInitial_ - tokenPriceIncremental_;\r\n        } else {\r\n            uint256 _ethereum = tokensToEthereum_(1e18);\r\n            uint256 AdmFee = SafeMath.div(SafeMath.mul(_ethereum, AdmCh_), 100);\r\n            uint256 _admout = SafeMath.div(AdmFee, 10); \r\n            uint256 _taxedEthereum = SafeMath.sub(_ethereum, _admout);\r\n            return _taxedEthereum;\r\n        }\r\n    }\r\n\r\n    function buyPrice() public view returns (uint256) {\r\n        if (tokenSupply_ == 0) {\r\n            return tokenPriceInitial_ \u002B tokenPriceIncremental_;\r\n        } else {\r\n            uint256 _ethereum = tokensToEthereum_(1e18);\r\n            uint256 AdmFee = SafeMath.div(SafeMath.mul(_ethereum, AdmCh_), 100);\r\n            uint256 _admout = SafeMath.div(AdmFee, 10); \r\n            uint256 _referralBonus = SafeMath.div(SafeMath.mul(_ethereum, refferalFee_), 100);\r\n            uint256 _totalfees = SafeMath.add(_referralBonus, _admout);\r\n            uint256 _taxedEthereum = SafeMath.add(_ethereum, _totalfees);\r\n            return _taxedEthereum;\r\n        }\r\n    }\r\n\r\n    function calculateTokensReceived(uint256 _ethereumToSpend) public view returns (uint256) {\r\n        uint256 AdmFee = SafeMath.div(SafeMath.mul(_ethereumToSpend, AdmCh_), 100);\r\n        uint256 _admfees = SafeMath.div(AdmFee, 10); \r\n        uint256 _referralBonus = SafeMath.div(SafeMath.mul(_ethereumToSpend, refferalFee_), 100);\r\n        uint256 _totalfees = SafeMath.add(_referralBonus, _admfees);\r\n        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _totalfees);\r\n        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);\r\n        return _amountOfTokens;\r\n    }\r\n\r\n    function calculateEthereumReceived(uint256 _tokensToSell) public view returns (uint256) {\r\n        require(_tokensToSell \u003C= tokenSupply_);\r\n        uint256 _ethereum = tokensToEthereum_(_tokensToSell);\r\n        uint256 AdmFee = SafeMath.div(SafeMath.mul(_ethereum, AdmCh_), 100);\r\n        uint256 _admout = SafeMath.div(AdmFee, 10); \r\n        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _admout);\r\n        return _taxedEthereum;\r\n    }\r\n\r\n  function purchaseTokens(uint256 _incomingEthereum, address _referredBy) internal returns (uint256) {\r\n        address _customerAddress = msg.sender;\r\n        uint256 _referralBonus = SafeMath.div(SafeMath.mul(_incomingEthereum, refferalFee_), 100);\r\n        uint256 AdmFee = SafeMath.div(SafeMath.mul(_incomingEthereum, AdmCh_), 100);\r\n        uint256 _admfees = SafeMath.div(AdmFee, 10); \r\n        uint256 _totalfees = SafeMath.add(_referralBonus, _admfees);\r\n        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _totalfees);\r\n        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);\r\n       \r\n\r\n        require(_amountOfTokens \u003E 0 \u0026\u0026 SafeMath.add(_amountOfTokens, tokenSupply_) \u003E tokenSupply_);\r\n\r\n        if (\r\n            _referredBy != 0x0000000000000000000000000000000000000000 \u0026\u0026\r\n            _referredBy != _customerAddress \u0026\u0026\r\n            tokenBalanceLedger_[_referredBy] \u003E= stakingRequirement\r\n        ) {  \r\n        \r\n           _referredBy.transfer(_referralBonus);\r\n           \r\n        } else {\r\n        \r\n        adm.transfer(_referralBonus);\r\n        \r\n        }\r\n\r\n        if (tokenSupply_ \u003E 0) {\r\n            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);\r\n            \r\n        } else {\r\n            tokenSupply_ = _amountOfTokens;\r\n        }\r\n\r\n        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);\r\n        emit onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy, now, buyPrice());\r\n\r\n        return _amountOfTokens;\r\n    }\r\n\r\n\r\n    function ethereumToTokens_(uint256 _ethereum) internal view returns (uint256) {\r\n        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;\r\n        uint256 _tokensReceived =\r\n            (\r\n                (\r\n                    SafeMath.sub(\r\n                        (sqrt\r\n                            (\r\n                                (_tokenPriceInitial ** 2)\r\n                                \u002B\r\n                                (2 * (tokenPriceIncremental_ * 1e18) * (_ethereum * 1e18))\r\n                                \u002B\r\n                                ((tokenPriceIncremental_ ** 2) * (tokenSupply_ ** 2))\r\n                                \u002B\r\n                                (2 * tokenPriceIncremental_ * _tokenPriceInitial*tokenSupply_)\r\n                            )\r\n                        ), _tokenPriceInitial\r\n                    )\r\n                ) / (tokenPriceIncremental_)\r\n            ) - (tokenSupply_);\r\n\r\n        return _tokensReceived;\r\n    }\r\n\r\n    function tokensToEthereum_(uint256 _tokens) internal view returns (uint256) {\r\n        uint256 tokens_ = (_tokens \u002B 1e18);\r\n        uint256 _tokenSupply = (tokenSupply_ \u002B 1e18);\r\n        uint256 _etherReceived =\r\n            (\r\n                SafeMath.sub(\r\n                    (\r\n                        (\r\n                            (\r\n                                tokenPriceInitial_ \u002B (tokenPriceIncremental_ * (_tokenSupply / 1e18))\r\n                            ) - tokenPriceIncremental_\r\n                        ) * (tokens_ - 1e18)\r\n                    ), (tokenPriceIncremental_ * ((tokens_ ** 2 - tokens_) / 1e18)) / 2\r\n                )\r\n                / 1e18);\r\n\r\n        return _etherReceived;\r\n    }\r\n\r\n \r\n   function setLaunchTime(uint256 _LaunchTime) public {\r\n      require(msg.sender==owner);\r\n      launchtime = _LaunchTime;\r\n    }\r\n\r\n    function updateAdm(address _address)  {\r\n       require(msg.sender==owner);\r\n       adm = _address;\r\n    }\r\n    \r\n\r\n    function sqrt(uint256 x) internal pure returns (uint256 y) {\r\n        uint256 z = (x \u002B 1) / 2;\r\n        y = x;\r\n\r\n        while (z \u003C y) {\r\n            y = z;\r\n            z = (x / z \u002B z) / 2;\r\n        }\r\n    }\r\n\r\n\r\n}\r\n\r\nlibrary SafeMath {\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n        uint256 c = a * b;\r\n        assert(c / a == b);\r\n        return c;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a / b;\r\n        return c;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_ethereumToSpend\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022calculateTokensReceived\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokensToSell\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022calculateEthereumReceived\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sellPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022stakingRequirement\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalEthereumBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_customerAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022buyPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022myTokens\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_LaunchTime\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setLaunchTime\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_toAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amountOfTokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022updateAdm\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_amountOfTokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022sell\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_referredBy\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022buy\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022launchtime\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022customerAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022incomingEthereum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokensMinted\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022referredBy\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022timestamp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022onTokenPurchase\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022customerAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokensBurned\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ethereumEarned\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022timestamp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022onTokenSell\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022customerAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ethereumWithdrawn\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022onWithdraw\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"AceTokens","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://19be65b4d6497d1c3a49b3d007a1528ca1c06b658e634772b0c9a3455a8159ea"}]