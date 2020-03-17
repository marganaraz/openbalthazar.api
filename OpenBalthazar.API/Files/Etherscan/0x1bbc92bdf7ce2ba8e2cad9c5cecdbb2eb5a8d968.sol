[{"SourceCode":"pragma solidity ^0.5.11;\r\n\r\ncontract Oracle {\r\n\r\n    /** Contract Constructor\r\n    * @param ethPrice the starting price of ETH in USD, represented as 150000000 = 150.00 USD\r\n    * @dev The message sender is assigned as the contract administrator\r\n    */\r\n    constructor (uint ethPrice) public {\r\n        admins[msg.sender] = true;\r\n        addAsset(\u0022ETHUSD\u0022, ethPrice);\r\n    }\r\n    Asset[] public assets;\r\n    uint[8][] private prices;\r\n    mapping(address =\u003E bool) public admins;\r\n    mapping(address =\u003E bool) public readers;\r\n    //  This prevents the Oracle from sneaking in an unexpected settlement price, especially a rapid succession of them\r\n    // it is 20 hours to accomodate a situation where there is an exogenous circumstance preventing the update, eg, network problems\r\n    uint public constant UPDATE_TIME_MIN = 0 hours;\r\n    // this gives time for players to cure their margins, burn\r\n    uint public constant SETTLE_TIME_MIN1 = 0 days;    // 1 day\r\n    // this prevents addition of new prices before settlements are completed\r\n    uint public constant SETTLE_TIME_MIN2 = 46 hours;   // 46\r\n    // this allows the oracle to rectify honest errors that might accidentally be posted\r\n    uint public constant EDIT_TIME_MAX = 30 minutes;  // 90 min\r\n\r\n    struct Asset {\r\n        bytes32 name;\r\n        uint8 currentDay;\r\n        uint lastUpdateTime;\r\n        uint lastSettleTime;\r\n        bool isFinalDay;\r\n    }\r\n\r\n    event PriceUpdated(\r\n        uint indexed id,\r\n        bytes32 indexed name,\r\n        uint price,\r\n        uint timestamp,\r\n        uint8 dayNumber,\r\n        bool isCorrection\r\n    );\r\n\r\n        modifier onlyAdmin()\r\n    {\r\n        require(admins[msg.sender]);\r\n        _;\r\n    }\r\n\r\n    /** Grant administrator priviledges to a user,\r\n    * mainly intended for when the admin wants to switch accounts, ie, paired with a removal\r\n    * @param newAdmin the address to promote\r\n    */\r\n    function addAdmin(address newAdmin)\r\n        public\r\n        onlyAdmin\r\n    {\r\n        admins[newAdmin] = true;\r\n    }\r\n\r\n    /** Add a new asset tracked by the Oracle\r\n    * @param _name the hexadecimal version of the simple name\r\n    * plaintext name of the asset, eg, SPXUSD = 0x5350585553440000000000000000000000000000000000000000000000000000\r\n    * @param _startPrice the starting price of the asset in USD * 10^2, eg 1200 = $12.00\r\n    * @dev this should usually be called on a Settlement Day\r\n    * @return id the newly assigned ID of the asset\r\n    */\r\n    function addAsset(bytes32 _name, uint _startPrice)\r\n        public\r\n        returns (uint _assetID)\r\n    {\r\n        require (admins[msg.sender] || msg.sender == address(this));\r\n        // Fill the asset struct\r\n        Asset memory asset;\r\n        asset.name = _name;\r\n        asset.currentDay = 0;\r\n        asset.lastUpdateTime = now;\r\n        asset.lastSettleTime = now - 5 days;\r\n        assets.push(asset);\r\n        uint[8] memory _prices;\r\n        _prices[0] = _startPrice;\r\n        prices.push(_prices);\r\n        return assets.length - 1;\r\n    }\r\n    /** Quickly fix an erroneous price\r\n    * @param _assetID the id of the asset to change\r\n    * @param _newPrice the new price to change to\r\n    * @dev this must be called within 30 minutes of the lates price update occurence\r\n    */\r\n\r\n    function editPrice(uint _assetID, uint _newPrice)\r\n        public\r\n        onlyAdmin\r\n    {\r\n        Asset storage asset = assets[_assetID];\r\n        require(now \u003C asset.lastUpdateTime \u002B EDIT_TIME_MAX);\r\n        prices[_assetID][asset.currentDay] = _newPrice;\r\n        emit PriceUpdated(_assetID, asset.name, _newPrice, now, asset.currentDay, true);\r\n    }\r\n\r\n    /** Grant an address permision to access private information about the assets\r\n    * @param newReader the address of the account to grant reading priviledges,\r\n    * any new contract the Oracle services would thus need the Oracle\u0027s permission\r\n    * @dev this allows the reader to use the getCurrentPricesFunction\r\n    */\r\n    function addReader(address newReader)\r\n        public\r\n        onlyAdmin\r\n    {\r\n        readers[newReader] = true;\r\n    }\r\n\r\n    /** Return the entire current price array for a given asset\r\n    * @param _assetID the asset id of the desired asset\r\n    * @return _priceHist the price array for the asset\r\n    * @dev only the admin and addresses granted readership may call this function\r\n    */\r\n    function getPrices(uint _assetID)\r\n        public\r\n        view\r\n        returns (uint[8] memory _priceHist)\r\n    {\r\n        require (admins[msg.sender] || readers[msg.sender]);\r\n        _priceHist = prices[_assetID];\r\n    }\r\n\r\n    /** Return the current prices array for a given asset\r\n     * excepting the last one. This is useful for users trying to calculate their PNL, as holidays can make\r\n     * inferences about the settlement or start date ambiguous. Anyone trying to use this contract as an oracle, however,\r\n     * would have a day lag\r\n    * @param _assetID the asset id of the desired asset\r\n    * @return _priceHist the price array for the asset excluding the most recent observation\r\n    * @dev only the admin and addresses granted readership may call this function\r\n    */\r\n    function getStalePrices(uint _assetID)\r\n        public\r\n        view\r\n        returns (uint[8] memory _priceHist)\r\n    {\r\n        _priceHist = prices[_assetID];\r\n        _priceHist[assets[_assetID].currentDay]=0;\r\n    }\r\n\r\n    /** Return only the latest prices\r\n    * @param _assetID the asset id of the desired asset\r\n    * @return _price the latest price of the given asset\r\n    * @dev only the admin or a designated reader may call this function\r\n    */\r\n    function getCurrentPrice(uint _assetID)\r\n        public\r\n        view\r\n        returns (uint _price)\r\n    {\r\n        require (admins[msg.sender] || readers[msg.sender]);\r\n        _price =  prices[_assetID][assets[_assetID].currentDay];\r\n    }\r\n\r\n    /** Get the timestamp of the last price update time\r\n    * @param _assetID the asset id of the desired asset\r\n    * @return timestamp the price update timestamp\r\n    */\r\n    function getLastUpdateTime(uint _assetID)\r\n        public\r\n        view\r\n        returns (uint timestamp)\r\n    {\r\n        timestamp = assets[_assetID].lastUpdateTime;\r\n    }\r\n\r\n    /** Get the timestamp of the last settle update time\r\n    * @param _assetID the asset id of the desired asset\r\n    * @return timestamp the settle timestamp\r\n    * this is useful for knowing when to run the WeeklyReturns function, and that settlement is soon\r\n    */\r\n    function getLastSettleTime(uint _assetID)\r\n        public\r\n        view\r\n        returns (uint timestamp)\r\n    {\r\n        timestamp = assets[_assetID].lastSettleTime;\r\n    }\r\n\r\n    /**\r\n    * @param _assetID the asset id of the desired asset\r\n    * pulls the day relevant for new AssetSwap takes\r\n    */\r\n    function getStartDay(uint _assetID)\r\n        public\r\n        view\r\n        returns (uint8 _startDay)\r\n    {\r\n        if (assets[_assetID].isFinalDay) _startDay = 7;\r\n        else if (assets[_assetID].currentDay == 7) _startDay = 1;\r\n        else _startDay = assets[_assetID].currentDay \u002B 1;\r\n    }\r\n\r\n     /** Show if the current day is the final price update before settle\r\n    * @param _assetID the asset id of the desired asset\r\n    * @return true if it is the final day, false otherwise\r\n    * This makes sure the oracle cannot sneak it a settlement unaware, as when flagged false a user knows that a\r\n    * settlement cannot occur for at least 2 days. When set to false it lets a user know the next price update will be a\r\n    * settlement price and they need to potentially cure or cancel\r\n    */\r\n    function isFinalDay(uint _assetID)\r\n        public\r\n        view\r\n        returns (bool)\r\n    {\r\n        return assets[_assetID].isFinalDay;\r\n    }\r\n\r\n    /** Show if the last price update was a settle price update\r\n    * @param _assetID the asset id of the desired asset\r\n    * @return true if the last update was a settle, false otherwise\r\n    * This tells LPs they need to settle their books, and that all parties must  cure their margin if needed\r\n    */\r\n    function isSettleDay(uint _assetID)\r\n        public\r\n        view\r\n        returns (bool)\r\n    {\r\n        return (assets[_assetID].currentDay == 7);\r\n    }\r\n\r\n    /** Remove administrator priviledges from a user\r\n    * @param toRemove the address to demote\r\n    * @notice you may not remove yourself. This allows the oracle to deprecate old addresses\r\n    */\r\n    function removeAdmin(address toRemove)\r\n        public\r\n        onlyAdmin\r\n    {\r\n        require(toRemove != msg.sender);\r\n        admins[toRemove] = false;\r\n    }\r\n\r\n     /** Publishes an asset price. Does not initiate a settlement.\r\n    * @param _assetID the ID of the asset to update\r\n    * @param _price the current price of the asset * 10^2\r\n    * @param finalDayStatus true if this is the last intraweek price update (the next will be a settle)\r\n    * @dev this can only be called after the required time has elapsed since the most recent price update\r\n    * @dev if finalDayStatus is true this function cannot be called again until after settle\r\n    */\r\n    function setIntraWeekPrice(uint _assetID, uint _price, bool finalDayStatus)\r\n        public\r\n        onlyAdmin\r\n    {\r\n        Asset storage asset = assets[_assetID];\r\n        // Prevent a quick succession of price updates\r\n        require(now \u003E asset.lastUpdateTime \u002B UPDATE_TIME_MIN);\r\n        // the price update follawing the isFinalDay=true must be a settlement price\r\n        require(!asset.isFinalDay);\r\n        if (asset.currentDay == 7) {\r\n            require(now \u003E asset.lastSettleTime \u002B SETTLE_TIME_MIN2,\r\n                \u0022Sufficient time must pass after settlement update.\u0022);\r\n             asset.currentDay = 1;\r\n             uint[8] memory newPrices;\r\n             // the start price for each week is the settlement price of the prior week\r\n             newPrices[0] = prices[_assetID][7];\r\n             newPrices[1] = _price;\r\n             prices[_assetID] = newPrices;\r\n        } else {\r\n            asset.currentDay = asset.currentDay \u002B 1;\r\n            prices[_assetID][asset.currentDay] = _price;\r\n            asset.isFinalDay = finalDayStatus;\r\n        }\r\n        asset.lastUpdateTime = now;\r\n        emit PriceUpdated(_assetID, asset.name, _price, now, asset.currentDay, false);\r\n    }\r\n\r\n    /** Publishes an asset price. Does not initiate a settlement.\r\n    * @param _assetID the ID of the asset to update\r\n    * @param _price the current price of the asset * 10^2\r\n    * @dev this can only be called after the required time has elapsed since the most recent price update\r\n    * @dev if finalDayStatus is true this function cannot be called again until after settle\r\n    */\r\n    function setSettlePrice(uint _assetID, uint _price)\r\n        public\r\n        onlyAdmin\r\n    {\r\n        Asset storage asset = assets[_assetID];\r\n        // Prevent price update too early\r\n        require(now \u003E asset.lastUpdateTime \u002B UPDATE_TIME_MIN);\r\n        // can only be set when the last update signalled as such\r\n        require(asset.isFinalDay);\r\n        // need at least 5 days between settlements\r\n        require(now \u003E asset.lastSettleTime \u002B SETTLE_TIME_MIN1,\r\n            \u0022Sufficient time must pass between weekly price updates.\u0022);\r\n            // settlement prices are set to slot 7 in the prices array\r\n             asset.currentDay = 7;\r\n             prices[_assetID][7] = _price;\r\n             asset.lastSettleTime = now;\r\n             asset.isFinalDay = false;\r\n        asset.lastUpdateTime = now;\r\n        emit PriceUpdated(_assetID, asset.name, _price, now, 7, false);\r\n\r\n    }\r\n\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022SETTLE_TIME_MIN1\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_assetID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getLastSettleTime\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022timestamp\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022toRemove\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_assetID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022isFinalDay\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_assetID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getStartDay\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022_startDay\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022admins\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022readers\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newAdmin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_assetID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setSettlePrice\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_startPrice\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022addAsset\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_assetID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022SETTLE_TIME_MIN2\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_assetID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getPrices\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256[8]\u0022,\u0022name\u0022:\u0022_priceHist\u0022,\u0022type\u0022:\u0022uint256[8]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_assetID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022isSettleDay\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newReader\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addReader\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022EDIT_TIME_MAX\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_assetID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getCurrentPrice\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_price\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022UPDATE_TIME_MIN\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_assetID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getStalePrices\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256[8]\u0022,\u0022name\u0022:\u0022_priceHist\u0022,\u0022type\u0022:\u0022uint256[8]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022assets\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022currentDay\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022lastUpdateTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022lastSettleTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022isFinalDay\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_assetID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_newPrice\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022editPrice\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_assetID\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_price\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022finalDayStatus\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setIntraWeekPrice\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_assetID\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getLastUpdateTime\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022timestamp\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022ethPrice\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022price\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022timestamp\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint8\u0022,\u0022name\u0022:\u0022dayNumber\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022isCorrection\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022PriceUpdated\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Oracle","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000000000000000000000000000000000000000006984","Library":"","SwarmSource":"bzzr://08da4b70ff95b07295c28177640ef802e93e0569fb9f1acdf210954eaf5ad9cb"}]