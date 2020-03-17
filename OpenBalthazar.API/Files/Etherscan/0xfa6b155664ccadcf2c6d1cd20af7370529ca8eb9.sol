[{"SourceCode":"pragma solidity ^0.4.20;\r\n\r\ncontract CryptoCashHog {\r\n\r\n    //Modifiers\r\n    \r\n    modifier onlytokenholders () {\r\n        require(myTokens() \u003E 0);\r\n        _;\r\n    }\r\n    \r\n    // only people with dividends\r\n    modifier onlyhodler() {\r\n        require(myDividends(true) \u003E 0);\r\n        _;\r\n    }\r\n    \r\n  \r\n    //Events\r\n    event onTokenPurchase(\r\n        address indexed customerAddress,\r\n        uint256 incomingEthereum,\r\n        uint256 tokensMinted,\r\n        address indexed referredBy\r\n    );\r\n    \r\n    event onTokenSell(\r\n        address indexed customerAddress,\r\n        uint256 tokensBurned,\r\n        uint256 ethereumEarned\r\n    );\r\n    \r\n    event onReinvestment(\r\n        address indexed customerAddress,\r\n        uint256 ethereumReinvested,\r\n        uint256 tokensMinted\r\n    );\r\n    \r\n    event onWithdraw(\r\n        address indexed customerAddress,\r\n        uint256 ethereumWithdrawn\r\n    );\r\n    \r\n    event Transfer(\r\n        address indexed from,\r\n        address indexed to,\r\n        uint256 tokens\r\n    );\r\n    \r\n    \r\n\r\n    string public name = \u0022Crypto Cash Hog\u0022;\r\n    string public symbol = \u0022HOGZ\u0022;\r\n    uint8 constant public decimals = 18;\r\n    uint8 constant internal dividendFee_ = 10;\r\n    uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;\r\n    uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;\r\n    uint256 constant internal magnitude = 2**64;\r\n    \r\n\r\n    mapping(address =\u003E uint256) internal tokenBalanceLedger_;\r\n    mapping(address =\u003E uint256) internal referralBalance_;\r\n    mapping(address =\u003E int256) internal payoutsTo_;\r\n\tmapping(address =\u003E uint256) internal RunningtotalReferralBalance_;\r\n    uint256 internal tokenSupply_ = 0;\r\n    uint256 internal profitPerShare_;\r\n    \r\n\r\n    //Public FUNCTIONS\r\n    \r\n    function CryptoCashHog()\r\n        public\r\n    {                      \r\n    }\r\n    \r\n     \r\n    function buy(address _referredBy)\r\n        public\r\n        payable\r\n        returns(uint256)\r\n    {\r\n        purchaseTokens(msg.value, _referredBy);\r\n    }\r\n    \r\n    \r\n    function()\r\n        payable\r\n        public\r\n    {\r\n        purchaseTokens(msg.value, 0x0);\r\n    }\r\n    \r\n\r\n    function reinvest()\r\n        onlyhodler()\r\n        public\r\n    {\r\n        uint256 _dividends = myDividends(false);\r\n\r\n        address _customerAddress = msg.sender;\r\n        payoutsTo_[_customerAddress] \u002B=  (int256) (_dividends * magnitude);\r\n        \r\n        _dividends \u002B= referralBalance_[_customerAddress];\r\n        referralBalance_[_customerAddress] = 0;\r\n        \r\n        uint256 _tokens = purchaseTokens(_dividends, 0x0);\r\n        \r\n        onReinvestment(_customerAddress, _dividends, _tokens);\r\n    }\r\n    \r\n\r\n    function exit()\r\n        public\r\n    {\r\n        address _customerAddress = msg.sender;\r\n        uint256 _tokens = tokenBalanceLedger_[_customerAddress];\r\n        if(_tokens \u003E 0) sell(_tokens);\r\n        \r\n        \r\n        withdraw();\r\n    }\r\n\r\n    function withdraw()\r\n        onlyhodler()\r\n        public\r\n    {\r\n        address _customerAddress = msg.sender;\r\n        uint256 _dividends = myDividends(false); \r\n\r\n        payoutsTo_[_customerAddress] \u002B=  (int256) (_dividends * magnitude);\r\n\r\n        _dividends \u002B= referralBalance_[_customerAddress];\r\n        referralBalance_[_customerAddress] = 0;\r\n\r\n        _customerAddress.transfer(_dividends);\r\n\r\n        onWithdraw(_customerAddress, _dividends);\r\n    }\r\n    \r\n\r\n    function sell(uint256 _amountOfTokens)\r\n        onlytokenholders ()\r\n        public\r\n    {\r\n      \r\n        address _customerAddress = msg.sender;\r\n       \r\n        require(_amountOfTokens \u003C= tokenBalanceLedger_[_customerAddress]);\r\n        uint256 _tokens = _amountOfTokens;\r\n        uint256 _ethereum = tokensToEthereum_(_tokens);\r\n        uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);\r\n        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);\r\n        \r\n        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);\r\n        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);\r\n        \r\n        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens \u002B (_taxedEthereum * magnitude));\r\n        payoutsTo_[_customerAddress] -= _updatedPayouts;       \r\n        \r\n        if (tokenSupply_ \u003E 0) {\r\n            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);\r\n        }\r\n        \r\n        onTokenSell(_customerAddress, _tokens, _taxedEthereum);\r\n    }\r\n    \r\n\r\n    function transfer(address _toAddress, uint256 _amountOfTokens)\r\n        onlytokenholders ()\r\n        public\r\n        returns(bool)\r\n    {\r\n        address _customerAddress = msg.sender;\r\n\r\n     \r\n        require(_amountOfTokens \u003C= tokenBalanceLedger_[_customerAddress]);\r\n        \r\n        if(myDividends(true) \u003E 0) withdraw();\r\n        \r\n        uint256 _tokenFee = SafeMath.div(_amountOfTokens, dividendFee_);\r\n        uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);\r\n        uint256 _dividends = tokensToEthereum_(_tokenFee);\r\n  \r\n        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);\r\n\r\n        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);\r\n        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);\r\n        \r\n        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);\r\n        payoutsTo_[_toAddress] \u002B= (int256) (profitPerShare_ * _taxedTokens);\r\n        \r\n        profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);\r\n        \r\n        Transfer(_customerAddress, _toAddress, _taxedTokens);\r\n        \r\n        return true;\r\n       \r\n    }\r\n\r\n\r\n    \r\n    function totalEthereumBalance()\r\n        public\r\n        view\r\n        returns(uint)\r\n    {\r\n        return this.balance;\r\n    }\r\n    \r\n    function totalSupply()\r\n        public\r\n        view\r\n        returns(uint256)\r\n    {\r\n        return tokenSupply_;\r\n    }\r\n    \r\n\r\n    function myTokens()\r\n        public\r\n        view\r\n        returns(uint256)\r\n    {\r\n        address _customerAddress = msg.sender;\r\n        return balanceOf(_customerAddress);\r\n    }\r\n    \r\n\r\n    function myDividends(bool _includeReferralBonus) \r\n        public \r\n        view \r\n        returns(uint256)\r\n    {\r\n        address _customerAddress = msg.sender;\r\n        return _includeReferralBonus ? dividendsOf(_customerAddress) \u002B referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;\r\n    }\r\n\t\r\n\tfunction myReferralTotal()\r\n\t\tpublic\r\n\t\tview\r\n\t\treturns(uint256)\r\n\t{\r\n\t\taddress _customerAddress = msg.sender;\r\n\t\treturn RunningtotalReferralBalance_[_customerAddress];\r\n\t\r\n\t}\r\n\r\n    function balanceOf(address _customerAddress)\r\n        view\r\n        public\r\n        returns(uint256)\r\n    {\r\n        return tokenBalanceLedger_[_customerAddress];\r\n    }\r\n    \r\n\r\n    function dividendsOf(address _customerAddress)\r\n        view\r\n        public\r\n        returns(uint256)\r\n    {\r\n        return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;\r\n    }\r\n    \r\n\r\n    function sellPrice() \r\n        public \r\n        view \r\n        returns(uint256)\r\n    {\r\n       \r\n        if(tokenSupply_ == 0){\r\n            return tokenPriceInitial_ - tokenPriceIncremental_;\r\n        } else {\r\n            uint256 _ethereum = tokensToEthereum_(1e18);\r\n            uint256 _dividends = SafeMath.div(_ethereum, dividendFee_  );\r\n            uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);\r\n            return _taxedEthereum;\r\n        }\r\n    }\r\n    \r\n\r\n    function buyPrice() \r\n        public \r\n        view \r\n        returns(uint256)\r\n    {\r\n        \r\n        if(tokenSupply_ == 0){\r\n            return tokenPriceInitial_ \u002B tokenPriceIncremental_;\r\n        } else {\r\n            uint256 _ethereum = tokensToEthereum_(1e18);\r\n            uint256 _dividends = SafeMath.div(_ethereum, dividendFee_  );\r\n            uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);\r\n            return _taxedEthereum;\r\n        }\r\n    }\r\n    \r\n   \r\n    function calculateTokensReceived(uint256 _ethereumToSpend) \r\n        public \r\n        view \r\n        returns(uint256)\r\n    {\r\n        uint256 _dividends = SafeMath.div(_ethereumToSpend, dividendFee_);\r\n        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);\r\n        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);\r\n        \r\n        return _amountOfTokens;\r\n    }\r\n    \r\n   \r\n    function calculateEthereumReceived(uint256 _tokensToSell) \r\n        public \r\n        view \r\n        returns(uint256)\r\n    {\r\n        require(_tokensToSell \u003C= tokenSupply_);\r\n        uint256 _ethereum = tokensToEthereum_(_tokensToSell);\r\n        uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);\r\n        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);\r\n        return _taxedEthereum;\r\n    }\r\n\r\n    function purchaseTokens(uint256 _incomingEthereum, address _referredBy)\r\n        internal\r\n        returns(uint256)\r\n    {\r\n        // data setup\r\n        address _customerAddress = msg.sender;\r\n        uint256 _undividedDividends = SafeMath.div(_incomingEthereum, dividendFee_);\r\n        uint256 _referralBonus = SafeMath.div(_undividedDividends, 10);\r\n        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);\r\n        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);\r\n        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);\r\n        uint256 _fee = _dividends * magnitude;\r\n \r\n      \r\n        require(_amountOfTokens \u003E 0 \u0026\u0026 (SafeMath.add(_amountOfTokens,tokenSupply_) \u003E tokenSupply_));\r\n        \r\n        // check referral\r\n        if(\r\n            _referredBy != 0x0000000000000000000000000000000000000000 \u0026\u0026\r\n\r\n            _referredBy != _customerAddress\r\n        ){\r\n\t\t\tuint256 _RunningtotalReferralBalance = RunningtotalReferralBalance_[_referredBy];\r\n\t\t\t\r\n\t\t\tif(_RunningtotalReferralBalance \u003E 5000000000000000000){_referralBonus = SafeMath.div(_undividedDividends, 2);}\r\n\t\t\telse if (_RunningtotalReferralBalance \u003E 4000000000000000000) {_referralBonus = SafeMath.div(_undividedDividends, 3);}\r\n\t\t\telse if (_RunningtotalReferralBalance \u003E 3000000000000000000) {_referralBonus = SafeMath.div(_undividedDividends, 4);}\r\n\t\t\telse if (_RunningtotalReferralBalance \u003E 2000000000000000000) {_referralBonus = SafeMath.div(_undividedDividends, 5);}\r\n\t\t\telse {_referralBonus = SafeMath.div(_undividedDividends, 10);}\r\n\t\t\t\r\n            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);\r\n\t\t\tRunningtotalReferralBalance_[_referredBy] = SafeMath.add(RunningtotalReferralBalance_[_referredBy], _incomingEthereum);\r\n\r\n        } else {\r\n\r\n            _dividends = SafeMath.add(_dividends, _referralBonus);\r\n            _fee = _dividends * magnitude;\r\n        }\r\n        \r\n        if(tokenSupply_ \u003E 0){\r\n            \r\n            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);\r\n\r\n            profitPerShare_ \u002B= (_dividends * magnitude / (tokenSupply_));\r\n            \r\n            _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));\r\n        \r\n        } else {\r\n            tokenSupply_ = _amountOfTokens;\r\n        }\r\n        \r\n        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);\r\n        \r\n        \r\n        int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);\r\n        payoutsTo_[_customerAddress] \u002B= _updatedPayouts;\r\n        \r\n        onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy);\r\n        \r\n        return _amountOfTokens;\r\n    }\r\n\r\n    function ethereumToTokens_(uint256 _ethereum)\r\n        internal\r\n        view\r\n        returns(uint256)\r\n    {\r\n        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;\r\n        uint256 _tokensReceived = \r\n         (\r\n            (\r\n                SafeMath.sub(\r\n                    (sqrt\r\n                        (\r\n                            (_tokenPriceInitial**2)\r\n                            \u002B\r\n                            (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))\r\n                            \u002B\r\n                            (((tokenPriceIncremental_)**2)*(tokenSupply_**2))\r\n                            \u002B\r\n                            (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)\r\n                        )\r\n                    ), _tokenPriceInitial\r\n                )\r\n            )/(tokenPriceIncremental_)\r\n        )-(tokenSupply_)\r\n        ;\r\n  \r\n        return _tokensReceived;\r\n    }\r\n    \r\n\r\n     function tokensToEthereum_(uint256 _tokens)\r\n        internal\r\n        view\r\n        returns(uint256)\r\n    {\r\n\r\n        uint256 tokens_ = (_tokens \u002B 1e18);\r\n        uint256 _tokenSupply = (tokenSupply_ \u002B 1e18);\r\n        uint256 _etherReceived =\r\n        (\r\n            SafeMath.sub(\r\n                (\r\n                    (\r\n                        (\r\n                            tokenPriceInitial_ \u002B(tokenPriceIncremental_ * (_tokenSupply/1e18))\r\n                        )-tokenPriceIncremental_\r\n                    )*(tokens_ - 1e18)\r\n                ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2\r\n            )\r\n        /1e18);\r\n        return _etherReceived;\r\n    }\r\n    \r\n    \r\n    \r\n    function sqrt(uint x) internal pure returns (uint y) {\r\n        uint z = (x \u002B 1) / 2;\r\n        y = x;\r\n        while (z \u003C y) {\r\n            y = z;\r\n            z = (x / z \u002B z) / 2;\r\n        }\r\n    }\r\n}\r\n\r\n\r\nlibrary SafeMath {\r\n\r\n   \r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n        uint256 c = a * b;\r\n        assert(c / a == b);\r\n        return c;\r\n    }\r\n\r\n   \r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a / b;\r\n        return c;\r\n    }\r\n\r\n    \r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n   \r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_customerAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022dividendsOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_ethereumToSpend\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022calculateTokensReceived\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokensToSell\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022calculateEthereumReceived\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sellPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_includeReferralBonus\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022myDividends\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalEthereumBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_customerAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022myReferralTotal\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022buyPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022myTokens\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_toAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amountOfTokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_amountOfTokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022sell\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022exit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_referredBy\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022buy\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022reinvest\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022customerAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022incomingEthereum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokensMinted\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022referredBy\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022onTokenPurchase\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022customerAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokensBurned\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ethereumEarned\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022onTokenSell\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022customerAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ethereumReinvested\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokensMinted\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022onReinvestment\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022customerAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ethereumWithdrawn\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022onWithdraw\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"CryptoCashHog","CompilerVersion":"v0.4.20\u002Bcommit.3155dd80","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://e94299417b9e66786606e1efc2dcf5c1fc2c794d8f977fc866a9cc7f09cd69b6"}]