[{"SourceCode":"/**\r\n *Submitted for verification at Etherscan.io on 2019-06-26\r\n*/\r\n\r\npragma solidity ^0.4.20;\r\n\r\n/*\r\n* - \r\n*/\r\n\r\ncontract KingsDapp {\r\n    /*=================================\r\n    =            MODIFIERS            =\r\n    =================================*/\r\n    // only people with tokens\r\n    modifier onlyBagholders() {\r\n        require(myTokens() \u003E 0);\r\n        _;\r\n    }\r\n    \r\n    // only people with profits\r\n    modifier onlyStronghands() {\r\n        require(myDividends(true) \u003E 0);\r\n        _;\r\n    }\r\n    \r\n    // administrators can:\r\n    // -\u003E change the name of the contract\r\n    // -\u003E change the name of the token\r\n    // -\u003E change the PoS difficulty (How many tokens it costs to hold a masternode, in case it gets crazy high later)\r\n    // they CANNOT:\r\n    // -\u003E take funds\r\n    // -\u003E disable withdrawals\r\n    // -\u003E kill the contract\r\n    // -\u003E change the price of tokens\r\n    modifier onlyAdministrator(){\r\n        address _customerAddress = msg.sender;\r\n        require(administrators[keccak256(_customerAddress)]);\r\n        _;\r\n    }\r\n    \r\n    \r\n    // ensures that the first tokens in the contract will be equally distributed\r\n    // meaning, no divine dump will be ever possible\r\n    // result: healthy longevity.\r\n    modifier antiEarlyWhale(uint256 _amountOfEthereum){\r\n        address _customerAddress = msg.sender;\r\n        \r\n        // are we still in the vulnerable phase?\r\n        // if so, enact anti early whale protocol \r\n        if( onlyAmbassadors \u0026\u0026 ((totalEthereumBalance() - _amountOfEthereum) \u003C= ambassadorQuota_ )){\r\n            require(\r\n                // is the customer in the ambassador list?\r\n                ambassadors_[_customerAddress] == true \u0026\u0026\r\n                \r\n                // does the customer purchase exceed the max ambassador quota?\r\n                (ambassadorAccumulatedQuota_[_customerAddress] \u002B _amountOfEthereum) \u003C= ambassadorMaxPurchase_\r\n                \r\n            );\r\n            \r\n            // updated the accumulated quota    \r\n            ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfEthereum);\r\n        \r\n            // execute\r\n            _;\r\n        } else {\r\n            // in case the ether count drops low, the ambassador phase won\u0027t reinitiate\r\n            onlyAmbassadors = false;\r\n            _;    \r\n        }\r\n        \r\n    }\r\n    \r\n    \r\n    /*==============================\r\n    =            EVENTS            =\r\n    ==============================*/\r\n    event onTokenPurchase(\r\n        address indexed customerAddress,\r\n        uint256 incomingEthereum,\r\n        uint256 tokensMinted,\r\n        address indexed referredBy\r\n    );\r\n    \r\n    event onTokenSell(\r\n        address indexed customerAddress,\r\n        uint256 tokensBurned,\r\n        uint256 ethereumEarned\r\n    );\r\n    \r\n    event onReinvestment(\r\n        address indexed customerAddress,\r\n        uint256 ethereumReinvested,\r\n        uint256 tokensMinted\r\n    );\r\n    \r\n    event onWithdraw(\r\n        address indexed customerAddress,\r\n        uint256 ethereumWithdrawn\r\n    );\r\n    \r\n    // ERC20\r\n    event Transfer(\r\n        address indexed from,\r\n        address indexed to,\r\n        uint256 tokens\r\n    );\r\n    \r\n    \r\n    /*=====================================\r\n    =            CONFIGURABLES            =\r\n    =====================================*/\r\n    string public name = \u0022KingsDapp\u0022;\r\n    string public symbol = \u0022KING\u0022;\r\n    uint8 constant public decimals = 18;\r\n    uint8 constant internal dividendFee_ = 33;\r\n    uint256 constant internal tokenPriceInitial_ = 0.00000001 ether;\r\n    uint256 constant internal tokenPriceIncremental_ = 0.000000003 ether;\r\n    uint256 constant internal magnitude = 2**64;\r\n    \r\n    // proof of stake (defaults at 100 tokens)\r\n    uint256 public stakingRequirement = 100e18;\r\n    \r\n    // ambassador program\r\n    mapping(address =\u003E bool) internal ambassadors_;\r\n    uint256 constant internal ambassadorMaxPurchase_ = 3 ether;\r\n    uint256 constant internal ambassadorQuota_ = 3 ether;\r\n    \r\n    \r\n    \r\n   /*================================\r\n    =            DATASETS            =\r\n    ================================*/\r\n    // amount of shares for each address (scaled number)\r\n    mapping(address =\u003E uint256) internal tokenBalanceLedger_;\r\n    mapping(address =\u003E uint256) internal referralBalance_;\r\n    mapping(address =\u003E int256) internal payoutsTo_;\r\n    mapping(address =\u003E uint256) internal ambassadorAccumulatedQuota_;\r\n    uint256 internal tokenSupply_ = 0;\r\n    uint256 internal profitPerShare_;\r\n    \r\n    // administrator list (see above on what they can do)\r\n    mapping(bytes32 =\u003E bool) public administrators;\r\n    \r\n    // when this is set to true, only ambassadors can purchase tokens (this prevents a whale premine, it ensures a fairly distributed upper pyramid)\r\n    bool public onlyAmbassadors = true;\r\n    \r\n\r\n\r\n    /*=======================================\r\n    =            PUBLIC FUNCTIONS            =\r\n    =======================================*/\r\n    /*\r\n    * -- APPLICATION ENTRY POINTS --  \r\n    */\r\n    function KingsDapp()\r\n        public\r\n    {\r\n        // add administrators here\r\n        administrators[keccak256(0xC3502531f3555Ee6B283Cf1513B1C074900B144a)] = true;\r\n        \r\n        // add the ambassadors here.\r\n        // Gilgamesh \r\n        ambassadors_[0xC3502531f3555Ee6B283Cf1513B1C074900B144a] = true;\r\n        \r\n    }\r\n    \r\n     \r\n    /**\r\n     * Converts all incoming ethereum to tokens for the caller, and passes down the referral addy (if any)\r\n     */\r\n    function buy(address _referredBy)\r\n        public\r\n        payable\r\n        returns(uint256)\r\n    {\r\n        purchaseTokens(msg.value, _referredBy);\r\n    }\r\n    \r\n    /**\r\n     * Fallback function to handle ethereum that was send straight to the contract\r\n     * Unfortunately we cannot use a referral address this way.\r\n     */\r\n    function()\r\n        payable\r\n        public\r\n    {\r\n        purchaseTokens(msg.value, 0x0);\r\n    }\r\n    \r\n    /**\r\n     * Converts all of caller\u0027s dividends to tokens.\r\n     */\r\n    function reinvest()\r\n        onlyStronghands()\r\n        public\r\n    {\r\n        // fetch dividends\r\n        uint256 _dividends = myDividends(false); // retrieve ref. bonus later in the code\r\n        \r\n        // pay out the dividends virtually\r\n        address _customerAddress = msg.sender;\r\n        payoutsTo_[_customerAddress] \u002B=  (int256) (_dividends * magnitude);\r\n        \r\n        // retrieve ref. bonus\r\n        _dividends \u002B= referralBalance_[_customerAddress];\r\n        referralBalance_[_customerAddress] = 0;\r\n        \r\n        // dispatch a buy order with the virtualized \u0022withdrawn dividends\u0022\r\n        uint256 _tokens = purchaseTokens(_dividends, 0x0);\r\n        \r\n        // fire event\r\n        onReinvestment(_customerAddress, _dividends, _tokens);\r\n    }\r\n    \r\n    /**\r\n     * Alias of sell() and withdraw().\r\n     */\r\n    function exit()\r\n        public\r\n    {\r\n        // get token count for caller \u0026 sell them all\r\n        address _customerAddress = msg.sender;\r\n        uint256 _tokens = tokenBalanceLedger_[_customerAddress];\r\n        if(_tokens \u003E 0) sell(_tokens);\r\n        \r\n        // lambo delivery service\r\n        withdraw();\r\n    }\r\n\r\n    /**\r\n     * Withdraws all of the callers earnings.\r\n     */\r\n    function withdraw()\r\n        onlyStronghands()\r\n        public\r\n    {\r\n        // setup data\r\n        address _customerAddress = msg.sender;\r\n        uint256 _dividends = myDividends(false); // get ref. bonus later in the code\r\n        \r\n        // update dividend tracker\r\n        payoutsTo_[_customerAddress] \u002B=  (int256) (_dividends * magnitude);\r\n        \r\n        // add ref. bonus\r\n        _dividends \u002B= referralBalance_[_customerAddress];\r\n        referralBalance_[_customerAddress] = 0;\r\n        \r\n        // lambo delivery service\r\n        _customerAddress.transfer(_dividends);\r\n        \r\n        // fire event\r\n        onWithdraw(_customerAddress, _dividends);\r\n    }\r\n    \r\n    /**\r\n     * Liquifies tokens to ethereum.\r\n     */\r\n    function sell(uint256 _amountOfTokens)\r\n        onlyBagholders()\r\n        public\r\n    {\r\n        // setup data\r\n        address _customerAddress = msg.sender;\r\n        // russian hackers BTFO\r\n        require(_amountOfTokens \u003C= tokenBalanceLedger_[_customerAddress]);\r\n        uint256 _tokens = _amountOfTokens;\r\n        uint256 _ethereum = tokensToEthereum_(_tokens);\r\n        uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);\r\n        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);\r\n        \r\n        // burn the sold tokens\r\n        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);\r\n        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);\r\n        \r\n        // update dividends tracker\r\n        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens \u002B (_taxedEthereum * magnitude));\r\n        payoutsTo_[_customerAddress] -= _updatedPayouts;       \r\n        \r\n        // dividing by zero is a bad idea\r\n        if (tokenSupply_ \u003E 0) {\r\n            // update the amount of dividends per token\r\n            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);\r\n        }\r\n        \r\n        // fire event\r\n        onTokenSell(_customerAddress, _tokens, _taxedEthereum);\r\n    }\r\n    \r\n    \r\n    /**\r\n     * Transfer tokens from the caller to a new holder.\r\n     * Remember, there\u0027s a 10% fee here as well.\r\n     */\r\n    function transfer(address _toAddress, uint256 _amountOfTokens)\r\n        onlyBagholders()\r\n        public\r\n        returns(bool)\r\n    {\r\n        // setup\r\n        address _customerAddress = msg.sender;\r\n        \r\n        // make sure we have the requested tokens\r\n        // also disables transfers until ambassador phase is over\r\n        // ( we dont want whale premines )\r\n        require(!onlyAmbassadors \u0026\u0026 _amountOfTokens \u003C= tokenBalanceLedger_[_customerAddress]);\r\n        \r\n        // withdraw all outstanding dividends first\r\n        if(myDividends(true) \u003E 0) withdraw();\r\n        \r\n        // liquify 10% of the tokens that are transfered\r\n        // these are dispersed to shareholders\r\n        uint256 _tokenFee = SafeMath.div(_amountOfTokens, dividendFee_);\r\n        uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);\r\n        uint256 _dividends = tokensToEthereum_(_tokenFee);\r\n  \r\n        // burn the fee tokens\r\n        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);\r\n\r\n        // exchange tokens\r\n        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);\r\n        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);\r\n        \r\n        // update dividend trackers\r\n        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);\r\n        payoutsTo_[_toAddress] \u002B= (int256) (profitPerShare_ * _taxedTokens);\r\n        \r\n        // disperse dividends among holders\r\n        profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);\r\n        \r\n        // fire event\r\n        Transfer(_customerAddress, _toAddress, _taxedTokens);\r\n        \r\n        // ERC20\r\n        return true;\r\n       \r\n    }\r\n    \r\n    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/\r\n    /**\r\n     * In case the amassador quota is not met, the administrator can manually disable the ambassador phase.\r\n     */\r\n    function disableInitialStage()\r\n        onlyAdministrator()\r\n        public\r\n    {\r\n        onlyAmbassadors = false;\r\n    }\r\n    \r\n    /**\r\n     * In case one of us dies, we need to replace ourselves.\r\n     */\r\n    function setAdministrator(bytes32 _identifier, bool _status)\r\n        onlyAdministrator()\r\n        public\r\n    {\r\n        administrators[_identifier] = _status;\r\n    }\r\n    \r\n    /**\r\n     * Precautionary measures in case we need to adjust the masternode rate.\r\n     */\r\n    function setStakingRequirement(uint256 _amountOfTokens)\r\n        onlyAdministrator()\r\n        public\r\n    {\r\n        stakingRequirement = _amountOfTokens;\r\n    }\r\n    \r\n    /**\r\n     * If we want to rebrand, we can.\r\n     */\r\n    function setName(string _name)\r\n        onlyAdministrator()\r\n        public\r\n    {\r\n        name = _name;\r\n    }\r\n    \r\n    /**\r\n     * If we want to rebrand, we can.\r\n     */\r\n    function setSymbol(string _symbol)\r\n        onlyAdministrator()\r\n        public\r\n    {\r\n        symbol = _symbol;\r\n    }\r\n\r\n    \r\n    /*----------  HELPERS AND CALCULATORS  ----------*/\r\n    /**\r\n     * Method to view the current Ethereum stored in the contract\r\n     * Example: totalEthereumBalance()\r\n     */\r\n    function totalEthereumBalance()\r\n        public\r\n        view\r\n        returns(uint)\r\n    {\r\n        return this.balance;\r\n    }\r\n    \r\n    /**\r\n     * Retrieve the total token supply.\r\n     */\r\n    function totalSupply()\r\n        public\r\n        view\r\n        returns(uint256)\r\n    {\r\n        return tokenSupply_;\r\n    }\r\n    \r\n    /**\r\n     * Retrieve the tokens owned by the caller.\r\n     */\r\n    function myTokens()\r\n        public\r\n        view\r\n        returns(uint256)\r\n    {\r\n        address _customerAddress = msg.sender;\r\n        return balanceOf(_customerAddress);\r\n    }\r\n    \r\n    /**\r\n     * Retrieve the dividends owned by the caller.\r\n     * If \u0060_includeReferralBonus\u0060 is to to 1/true, the referral bonus will be included in the calculations.\r\n     * The reason for this, is that in the frontend, we will want to get the total divs (global \u002B ref)\r\n     * But in the internal calculations, we want them separate. \r\n     */ \r\n    function myDividends(bool _includeReferralBonus) \r\n        public \r\n        view \r\n        returns(uint256)\r\n    {\r\n        address _customerAddress = msg.sender;\r\n        return _includeReferralBonus ? dividendsOf(_customerAddress) \u002B referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;\r\n    }\r\n    \r\n    /**\r\n     * Retrieve the token balance of any single address.\r\n     */\r\n    function balanceOf(address _customerAddress)\r\n        view\r\n        public\r\n        returns(uint256)\r\n    {\r\n        return tokenBalanceLedger_[_customerAddress];\r\n    }\r\n    \r\n    /**\r\n     * Retrieve the dividend balance of any single address.\r\n     */\r\n    function dividendsOf(address _customerAddress)\r\n        view\r\n        public\r\n        returns(uint256)\r\n    {\r\n        return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;\r\n    }\r\n    \r\n    /**\r\n     * Return the buy price of 1 individual token.\r\n     */\r\n    function sellPrice() \r\n        public \r\n        view \r\n        returns(uint256)\r\n    {\r\n        // our calculation relies on the token supply, so we need supply. Doh.\r\n        if(tokenSupply_ == 0){\r\n            return tokenPriceInitial_ - tokenPriceIncremental_;\r\n        } else {\r\n            uint256 _ethereum = tokensToEthereum_(1e18);\r\n            uint256 _dividends = SafeMath.div(_ethereum, dividendFee_  );\r\n            uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);\r\n            return _taxedEthereum;\r\n        }\r\n    }\r\n    \r\n    /**\r\n     * Return the sell price of 1 individual token.\r\n     */\r\n    function buyPrice() \r\n        public \r\n        view \r\n        returns(uint256)\r\n    {\r\n        // our calculation relies on the token supply, so we need supply. Doh.\r\n        if(tokenSupply_ == 0){\r\n            return tokenPriceInitial_ \u002B tokenPriceIncremental_;\r\n        } else {\r\n            uint256 _ethereum = tokensToEthereum_(1e18);\r\n            uint256 _dividends = SafeMath.div(_ethereum, dividendFee_  );\r\n            uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);\r\n            return _taxedEthereum;\r\n        }\r\n    }\r\n    \r\n    /**\r\n     * Function for the frontend to dynamically retrieve the price scaling of buy orders.\r\n     */\r\n    function calculateTokensReceived(uint256 _ethereumToSpend) \r\n        public \r\n        view \r\n        returns(uint256)\r\n    {\r\n        uint256 _dividends = SafeMath.div(_ethereumToSpend, dividendFee_);\r\n        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);\r\n        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);\r\n        \r\n        return _amountOfTokens;\r\n    }\r\n    \r\n    /**\r\n     * Function for the frontend to dynamically retrieve the price scaling of sell orders.\r\n     */\r\n    function calculateEthereumReceived(uint256 _tokensToSell) \r\n        public \r\n        view \r\n        returns(uint256)\r\n    {\r\n        require(_tokensToSell \u003C= tokenSupply_);\r\n        uint256 _ethereum = tokensToEthereum_(_tokensToSell);\r\n        uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);\r\n        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);\r\n        return _taxedEthereum;\r\n    }\r\n    \r\n    \r\n    /*==========================================\r\n    =            INTERNAL FUNCTIONS            =\r\n    ==========================================*/\r\n    function purchaseTokens(uint256 _incomingEthereum, address _referredBy)\r\n        antiEarlyWhale(_incomingEthereum)\r\n        internal\r\n        returns(uint256)\r\n    {\r\n        // data setup\r\n        address _customerAddress = msg.sender;\r\n        uint256 _undividedDividends = SafeMath.div(_incomingEthereum, dividendFee_);\r\n        uint256 _referralBonus = SafeMath.div(_undividedDividends, 3);\r\n        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);\r\n        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);\r\n        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);\r\n        uint256 _fee = _dividends * magnitude;\r\n \r\n        // no point in continuing execution if OP is a  hacker\r\n        // prevents overflow in the case that the pyramid somehow magically starts being used by everyone in the world\r\n        // (or hackers)\r\n        // and yes we know that the safemath function automatically rules out the \u0022greater then\u0022 equasion.\r\n        require(_amountOfTokens \u003E 0 \u0026\u0026 (SafeMath.add(_amountOfTokens,tokenSupply_) \u003E tokenSupply_));\r\n        \r\n        // is the user referred by a masternode?\r\n        if(\r\n            // is this a referred purchase?\r\n            _referredBy != 0x0000000000000000000000000000000000000000 \u0026\u0026\r\n\r\n            // no cheating!\r\n            _referredBy != _customerAddress \u0026\u0026\r\n            \r\n            // does the referrer have at least X whole tokens?\r\n            // i.e is the referrer a godly chad masternode\r\n            tokenBalanceLedger_[_referredBy] \u003E= stakingRequirement\r\n        ){\r\n            // wealth redistribution\r\n            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);\r\n        } else {\r\n            // no ref purchase\r\n            // add the referral bonus back to the global dividends cake\r\n            _dividends = SafeMath.add(_dividends, _referralBonus);\r\n            _fee = _dividends * magnitude;\r\n        }\r\n        \r\n        // we can\u0027t give people infinite ethereum\r\n        if(tokenSupply_ \u003E 0){\r\n            \r\n            // add tokens to the pool\r\n            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);\r\n \r\n            // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder\r\n            profitPerShare_ \u002B= (_dividends * magnitude / (tokenSupply_));\r\n            \r\n            // calculate the amount of tokens the customer receives over his purchase \r\n            _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));\r\n        \r\n        } else {\r\n            // add tokens to the pool\r\n            tokenSupply_ = _amountOfTokens;\r\n        }\r\n        \r\n        // update circulating supply \u0026 the ledger address for the customer\r\n        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);\r\n        \r\n        // Tells the contract that the buyer doesn\u0027t deserve dividends for the tokens before they owned them;\r\n        //really i know you think you do but you don\u0027t\r\n        int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);\r\n        payoutsTo_[_customerAddress] \u002B= _updatedPayouts;\r\n        \r\n        // fire event\r\n        onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy);\r\n        \r\n        return _amountOfTokens;\r\n    }\r\n\r\n    /**\r\n     * Calculate Token price based on an amount of incoming ethereum\r\n     * It\u0027s an algorithm, hopefully we gave you the whitepaper with it in scientific notation;\r\n     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.\r\n     */\r\n    function ethereumToTokens_(uint256 _ethereum)\r\n        internal\r\n        view\r\n        returns(uint256)\r\n    {\r\n        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;\r\n        uint256 _tokensReceived = \r\n         (\r\n            (\r\n                // underflow attempts BTFO\r\n                SafeMath.sub(\r\n                    (sqrt\r\n                        (\r\n                            (_tokenPriceInitial**2)\r\n                            \u002B\r\n                            (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))\r\n                            \u002B\r\n                            (((tokenPriceIncremental_)**2)*(tokenSupply_**2))\r\n                            \u002B\r\n                            (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)\r\n                        )\r\n                    ), _tokenPriceInitial\r\n                )\r\n            )/(tokenPriceIncremental_)\r\n        )-(tokenSupply_)\r\n        ;\r\n  \r\n        return _tokensReceived;\r\n    }\r\n    \r\n    /**\r\n     * Calculate token sell value.\r\n     * It\u0027s an algorithm, hopefully we gave you the whitepaper with it in scientific notation;\r\n     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.\r\n     */\r\n     function tokensToEthereum_(uint256 _tokens)\r\n        internal\r\n        view\r\n        returns(uint256)\r\n    {\r\n\r\n        uint256 tokens_ = (_tokens \u002B 1e18);\r\n        uint256 _tokenSupply = (tokenSupply_ \u002B 1e18);\r\n        uint256 _etherReceived =\r\n        (\r\n            // underflow attempts BTFO\r\n            SafeMath.sub(\r\n                (\r\n                    (\r\n                        (\r\n                            tokenPriceInitial_ \u002B(tokenPriceIncremental_ * (_tokenSupply/1e18))\r\n                        )-tokenPriceIncremental_\r\n                    )*(tokens_ - 1e18)\r\n                ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2\r\n            )\r\n        /1e18);\r\n        return _etherReceived;\r\n    }\r\n    \r\n    \r\n    //This is where all your gas goes, sorry\r\n    //Not sorry, you probably only paid 1 gwei\r\n    function sqrt(uint x) internal pure returns (uint y) {\r\n        uint z = (x \u002B 1) / 2;\r\n        y = x;\r\n        while (z \u003C y) {\r\n            y = z;\r\n            z = (x / z \u002B z) / 2;\r\n        }\r\n    }\r\n}\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n\r\n    /**\r\n    * @dev Multiplies two numbers, throws on overflow.\r\n    */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n        uint256 c = a * b;\r\n        assert(c / a == b);\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Integer division of two numbers, truncating the quotient.\r\n    */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // assert(b \u003E 0); // Solidity automatically throws when dividing by 0\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n    */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    /**\r\n    * @dev Adds two numbers, throws on overflow.\r\n    */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        assert(c \u003E= a);\r\n        return c;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_customerAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022dividendsOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022name\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_ethereumToSpend\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022calculateTokensReceived\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_tokensToSell\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022calculateEthereumReceived\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022onlyAmbassadors\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022decimals\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022administrators\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022sellPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022stakingRequirement\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_includeReferralBonus\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022myDividends\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalEthereumBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_customerAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_amountOfTokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setStakingRequirement\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022buyPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_identifier\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_status\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setAdministrator\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022myTokens\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022symbol\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022disableInitialStage\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_toAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amountOfTokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_symbol\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022setSymbol\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022setName\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_amountOfTokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022sell\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022exit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_referredBy\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022buy\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022reinvest\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022customerAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022incomingEthereum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokensMinted\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022referredBy\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022onTokenPurchase\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022customerAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokensBurned\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ethereumEarned\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022onTokenSell\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022customerAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ethereumReinvested\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokensMinted\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022onReinvestment\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022customerAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022ethereumWithdrawn\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022onWithdraw\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"KingsDapp","CompilerVersion":"v0.4.20\u002Bcommit.3155dd80","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://249ca64d3a2060709338b84776fa6fb7662962ea345646f3750e15c9b16559a8"}]