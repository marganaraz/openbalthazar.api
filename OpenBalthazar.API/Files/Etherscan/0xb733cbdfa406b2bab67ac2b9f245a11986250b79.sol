[{"SourceCode":"/**\r\n *Submitted for verification at Etherscan.io on 2019-08-23\r\n*/\r\n\r\n/*\r\n\r\n Copyright 2017-2019 RigoBlock, Rigo Investment Sagl.\r\n\r\n Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n you may not use this file except in compliance with the License.\r\n You may obtain a copy of the License at\r\n\r\n     http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n Unless required by applicable law or agreed to in writing, software\r\n distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n See the License for the specific language governing permissions and\r\n limitations under the License.\r\n\r\n*/\r\n\r\npragma solidity 0.5.4;\r\n\r\ncontract Pool {\r\n\r\n    address public owner;\r\n\r\n    /*\r\n     * CONSTANT PUBLIC FUNCTIONS\r\n     */\r\n    function balanceOf(address _who) external view returns (uint256);\r\n    function totalSupply() external view returns (uint256 totaSupply);\r\n    function getEventful() external view returns (address);\r\n    function getData() external view returns (string memory name, string memory symbol, uint256 sellPrice, uint256 buyPrice);\r\n    function calcSharePrice() external view returns (uint256);\r\n    function getAdminData() external view returns (address, address feeCollector, address dragodAO, uint256 ratio, uint256 transactionFee, uint32 minPeriod);\r\n}\r\n\r\ncontract ReentrancyGuard {\r\n\r\n    // Locked state of mutex\r\n    bool private locked = false;\r\n\r\n    /// @dev Functions with this modifer cannot be reentered. The mutex will be locked\r\n    ///      before function execution and unlocked after.\r\n    modifier nonReentrant() {\r\n        // Ensure mutex is unlocked\r\n        require(\r\n            !locked,\r\n            \u0022REENTRANCY_ILLEGAL\u0022\r\n        );\r\n\r\n        // Lock mutex before function call\r\n        locked = true;\r\n\r\n        // Perform function call\r\n        _;\r\n\r\n        // Unlock mutex after function call\r\n        locked = false;\r\n    }\r\n}\r\n\r\ncontract SafeMath {\r\n\r\n    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a * b;\r\n        assert(a == 0 || c / a == b);\r\n        return c;\r\n    }\r\n\r\n    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003E 0);\r\n        uint256 c = a / b;\r\n        assert(a == b * c \u002B a % b);\r\n        return c;\r\n    }\r\n\r\n    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        assert(b \u003C= a);\r\n        return a - b;\r\n    }\r\n\r\n    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        assert(c\u003E=a \u0026\u0026 c\u003E=b);\r\n        return c;\r\n    }\r\n\r\n    function max64(uint64 a, uint64 b) internal pure returns (uint64) {\r\n        return a \u003E= b ? a : b;\r\n    }\r\n\r\n    function min64(uint64 a, uint64 b) internal pure returns (uint64) {\r\n        return a \u003C b ? a : b;\r\n    }\r\n\r\n    function max256(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a \u003E= b ? a : b;\r\n    }\r\n\r\n    function min256(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a \u003C b ? a : b;\r\n    }\r\n}\r\n\r\ninterface ProofOfPerformanceFace {\r\n\r\n    /*\r\n     * CORE FUNCTIONS\r\n     */\r\n    /// @dev Allows anyone to allocate the pop reward to pool wizards.\r\n    /// @param _ofPool Number of pool id in registry.\r\n    function claimPop(uint256 _ofPool) external;\r\n    \r\n    /// @dev Allows RigoBlock Dao to update the pools registry.\r\n    /// @param _dragoRegistry Address of new registry.\r\n    function setRegistry(address _dragoRegistry) external;\r\n    \r\n    /// @dev Allows RigoBlock Dao to update its address.\r\n    /// @param _rigoblockDao Address of new dao.\r\n    function setRigoblockDao(address _rigoblockDao) external;\r\n    \r\n    /// @dev Allows RigoBlock Dao to set the ratio between assets and performance reward for a group.\r\n    /// @param _ofGroup Id of the pool.\r\n    /// @param _ratio Id of the pool.\r\n    /// @notice onlyRigoblockDao can set ratio.\r\n    function setRatio(address _ofGroup, uint256 _ratio) external;\r\n\r\n    /*\r\n     * CONSTANT PUBLIC FUNCTIONS\r\n     */\r\n    /// @dev Gets data of a pool.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Bool the pool is active.\r\n    /// @return address of the pool.\r\n    /// @return address of the pool factory.\r\n    /// @return price of the pool in wei.\r\n    /// @return total supply of the pool in units.\r\n    /// @return total value of the pool in wei.\r\n    /// @return value of the reward factor or said pool.\r\n    /// @return ratio of assets/performance reward (from 0 to 10000).\r\n    /// @return value of the pop reward to be claimed in GRGs.\r\n    function getPoolData(uint256 _ofPool)\r\n        external\r\n        view\r\n        returns (\r\n            bool active,\r\n            address thePoolAddress,\r\n            address thePoolGroup,\r\n            uint256 thePoolPrice,\r\n            uint256 thePoolSupply,\r\n            uint256 poolValue,\r\n            uint256 epochReward,\r\n            uint256 ratio,\r\n            uint256 pop\r\n        );\r\n\r\n    /// @dev Returns the highwatermark of a pool.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Value of the all-time-high pool nav.\r\n    function getHwm(uint256 _ofPool) external view returns (uint256);\r\n\r\n    /// @dev Returns the reward factor for a pool.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Value of the reward factor.\r\n    function getEpochReward(uint256 _ofPool)\r\n        external\r\n        view\r\n        returns (uint256);\r\n\r\n    /// @dev Returns the split ratio of asset and performance reward.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Value of the ratio from 1 to 100.\r\n    function getRatio(uint256 _ofPool)\r\n        external\r\n        view\r\n        returns (uint256);\r\n\r\n    /// @dev Returns the proof of performance reward for a pool.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return popReward Value of the pop reward in Rigo tokens.\r\n    /// @return performanceReward Split of the performance reward in Rigo tokens.\r\n    /// @notice epoch reward should be big enough that it.\r\n    /// @notice can be decreased if number of funds increases.\r\n    /// @notice should be at least 10^6 (just as pool base) to start with.\r\n    /// @notice rigo token has 10^18 decimals.\r\n    function proofOfPerformance(uint256 _ofPool)\r\n        external\r\n        view\r\n        returns (uint256 popReward, uint256 performanceReward);\r\n\r\n    /// @dev Checks whether a pool is registered and active.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Bool the pool is active.\r\n    function isActive(uint256 _ofPool)\r\n        external\r\n        view\r\n        returns (bool);\r\n\r\n    /// @dev Returns the address and the group of a pool from its id.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Address of the target pool.\r\n    /// @return Address of the pool\u0027s group.\r\n    function addressFromId(uint256 _ofPool)\r\n        external\r\n        view\r\n        returns (\r\n            address pool,\r\n            address group\r\n        );\r\n\r\n    /// @dev Returns the price a pool from its id.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Price of the pool in wei.\r\n    /// @return Number of tokens of a pool (totalSupply).\r\n    function getPoolPrice(uint256 _ofPool)\r\n        external\r\n        view\r\n        returns (\r\n            uint256 thePoolPrice,\r\n            uint256 totalTokens\r\n        );\r\n\r\n    /// @dev Returns the address and the group of a pool from its id.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Address of the target pool.\r\n    /// @return Address of the pool\u0027s group.\r\n    function calcPoolValue(uint256 _ofPool)\r\n        external\r\n        view\r\n        returns (\r\n            uint256 aum\r\n        );\r\n}\r\n\r\ncontract Inflation {\r\n\r\n    uint256 public period;\r\n\r\n    /*\r\n     * CORE FUNCTIONS\r\n     */\r\n    function mintInflation(address _thePool, uint256 _reward) external returns (bool);\r\n    function setInflationFactor(address _group, uint256 _inflationFactor) external;\r\n    function setMinimumRigo(uint256 _minimum) external;\r\n    function setRigoblock(address _newRigoblock) external;\r\n    function setAuthority(address _authority) external;\r\n    function setProofOfPerformance(address _pop) external;\r\n    function setPeriod(uint256 _newPeriod) external;\r\n\r\n    /*\r\n     * CONSTANT PUBLIC FUNCTIONS\r\n     */\r\n    function canWithdraw(address _thePool) external view returns (bool);\r\n    function timeUntilClaim(address _thePool) external view returns (uint256);\r\n    function getInflationFactor(address _group) external view returns (uint256);\r\n}\r\n\r\ncontract RigoToken {\r\n    address public minter;\r\n    uint256 public totalSupply;\r\n\r\n    function balanceOf(address _who) external view returns (uint256);\r\n}\r\n\r\ninterface DragoRegistry {\r\n\r\n    //EVENTS\r\n\r\n    event Registered(string name, string symbol, uint256 id, address indexed drago, address indexed owner, address indexed group);\r\n    event Unregistered(string indexed name, string indexed symbol, uint256 indexed id);\r\n    event MetaChanged(uint256 indexed id, bytes32 indexed key, bytes32 value);\r\n\r\n    /*\r\n     * CORE FUNCTIONS\r\n     */\r\n    function register(address _drago, string calldata _name, string calldata _symbol, uint256 _dragoId, address _owner) external payable returns (bool);\r\n    function unregister(uint256 _id) external;\r\n    function setMeta(uint256 _id, bytes32 _key, bytes32 _value) external;\r\n    function addGroup(address _group) external;\r\n    function setFee(uint256 _fee) external;\r\n    function updateOwner(uint256 _id) external;\r\n    function updateOwners(uint256[] calldata _id) external;\r\n    function upgrade(address _newAddress) external payable; //payable as there is a transfer of value, otherwise opcode might throw an error\r\n    function setUpgraded(uint256 _version) external;\r\n    function drain() external;\r\n\r\n    /*\r\n     * CONSTANT PUBLIC FUNCTIONS\r\n     */\r\n    function dragoCount() external view returns (uint256);\r\n    function fromId(uint256 _id) external view returns (address drago, string memory name, string memory symbol, uint256 dragoId, address owner, address group);\r\n    function fromAddress(address _drago) external view returns (uint256 id, string memory name, string memory symbol, uint256 dragoId, address owner, address group);\r\n    function fromName(string calldata _name) external view returns (uint256 id, address drago, string memory symbol, uint256 dragoId, address owner, address group);\r\n    function getNameFromAddress(address _pool) external view returns (string memory);\r\n    function getSymbolFromAddress(address _pool) external view returns (string memory);\r\n    function meta(uint256 _id, bytes32 _key) external view returns (bytes32);\r\n    function getGroups() external view returns (address[] memory);\r\n    function getFee() external view returns (uint256);\r\n}\r\n\r\n/// @title Proof of Performance - Controls parameters of inflation.\r\n/// @author Gabriele Rigo - \u003Cgab@rigoblock.com\u003E\r\n// solhint-disable-next-line\r\ncontract ProofOfPerformance is\r\n    SafeMath,\r\n    ReentrancyGuard,\r\n    ProofOfPerformanceFace\r\n{\r\n    address public RIGOTOKENADDRESS;\r\n\r\n    address public dragoRegistry;\r\n    address public rigoblockDao;\r\n\r\n    mapping (uint256 =\u003E PoolPrice) poolPrice;\r\n    mapping (address =\u003E Group) groups;\r\n\r\n    struct PoolPrice {\r\n        uint256 highwatermark;\r\n    }\r\n\r\n    struct Group {\r\n        uint256 rewardRatio;\r\n    }\r\n\r\n    modifier onlyRigoblockDao() {\r\n        require(\r\n            msg.sender == rigoblockDao,\r\n            \u0022ONLY_RIGOBLOCK_DAO\u0022\r\n        );\r\n        _;\r\n    }\r\n\r\n    constructor(\r\n        address _rigoTokenAddress,\r\n        address _rigoblockDao,\r\n        address _dragoRegistry)\r\n        public\r\n    {\r\n        RIGOTOKENADDRESS = _rigoTokenAddress;\r\n        rigoblockDao = _rigoblockDao;\r\n        dragoRegistry = _dragoRegistry;\r\n    }\r\n\r\n    /*\r\n     * CORE FUNCTIONS\r\n     */\r\n    /// @dev Allows anyone to allocate the pop reward to pool wizards.\r\n    /// @param _ofPool Number of pool id in registry.\r\n    function claimPop(uint256 _ofPool)\r\n        external\r\n        nonReentrant\r\n    {\r\n        DragoRegistry registry = DragoRegistry(dragoRegistry);\r\n        address poolAddress;\r\n        (poolAddress, , , , , ) = registry.fromId(_ofPool);\r\n        (uint256 pop, ) = proofOfPerformanceInternal(_ofPool);\r\n        require(\r\n            pop \u003E 0,\r\n            \u0022POP_REWARD_IS_NULL\u0022\r\n        );\r\n        uint256 price = Pool(poolAddress).calcSharePrice();\r\n        poolPrice[_ofPool].highwatermark = price;\r\n        require(\r\n            Inflation(getMinter()).mintInflation(poolAddress, pop),\r\n            \u0022MINT_INFLATION_ERROR\u0022\r\n        );\r\n    }\r\n\r\n    /// @dev Allows RigoBlock Dao to update the pools registry.\r\n    /// @param _dragoRegistry Address of new registry.\r\n    function setRegistry(address _dragoRegistry)\r\n        external\r\n        onlyRigoblockDao\r\n    {\r\n        dragoRegistry = _dragoRegistry;\r\n    }\r\n\r\n    /// @dev Allows RigoBlock Dao to update its address.\r\n    /// @param _rigoblockDao Address of new dao.\r\n    function setRigoblockDao(address _rigoblockDao)\r\n        external\r\n        onlyRigoblockDao\r\n    {\r\n        rigoblockDao = _rigoblockDao;\r\n    }\r\n\r\n    /// @dev Allows RigoBlock Dao to set the ratio between assets and performance reward for a group.\r\n    /// @param _ofGroup Id of the pool.\r\n    /// @param _ratio Id of the pool.\r\n    /// @notice onlyRigoblockDao can set ratio.\r\n    function setRatio(\r\n        address _ofGroup,\r\n        uint256 _ratio)\r\n        external\r\n        onlyRigoblockDao\r\n    {\r\n        require(\r\n            _ratio \u003C= 10000,\r\n            \u0022RATIO_BIGGER_THAN_10000\u0022\r\n        ); //(from 0 to 10000)\r\n        groups[_ofGroup].rewardRatio = _ratio;\r\n    }\r\n\r\n    /*\r\n     * CONSTANT PUBLIC FUNCTIONS\r\n     */\r\n    /// @dev Gets data of a pool.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Bool the pool is active.\r\n    /// @return address of the pool.\r\n    /// @return address of the pool factory.\r\n    /// @return price of the pool in wei.\r\n    /// @return total supply of the pool in units.\r\n    /// @return total value of the pool in wei.\r\n    /// @return value of the reward factor or said pool.\r\n    /// @return ratio of assets/performance reward (from 0 to 10000).\r\n    /// @return value of the pop reward to be claimed in GRGs.\r\n    function getPoolData(uint256 _ofPool)\r\n        external\r\n        view\r\n        returns (\r\n            bool active,\r\n            address thePoolAddress,\r\n            address thePoolGroup,\r\n            uint256 thePoolPrice,\r\n            uint256 thePoolSupply,\r\n            uint256 poolValue,\r\n            uint256 epochReward,\r\n            uint256 ratio,\r\n            uint256 pop\r\n        )\r\n    {\r\n        active = isActiveInternal(_ofPool);\r\n        (thePoolAddress, thePoolGroup) = addressFromIdInternal(_ofPool);\r\n        (thePoolPrice, thePoolSupply, poolValue) = getPoolPriceAndValueInternal(_ofPool);\r\n        (epochReward, , ratio) = getInflationParameters(_ofPool);\r\n        (pop, ) = proofOfPerformanceInternal(_ofPool);\r\n        return(\r\n            active,\r\n            thePoolAddress,\r\n            thePoolGroup,\r\n            thePoolPrice,\r\n            thePoolSupply,\r\n            poolValue,\r\n            epochReward,\r\n            ratio,\r\n            pop\r\n        );\r\n    }\r\n\r\n    /// @dev Returns the highwatermark of a pool.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Value of the all-time-high pool nav.\r\n    function getHwm(uint256 _ofPool)\r\n        external\r\n        view\r\n        returns (uint256)\r\n    {\r\n        return poolPrice[_ofPool].highwatermark;\r\n    }\r\n\r\n    /// @dev Returns the reward factor for a pool.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Value of the reward factor.\r\n    function getEpochReward(uint256 _ofPool)\r\n        external\r\n        view\r\n        returns (uint256)\r\n    {\r\n        (uint256 epochReward, , ) = getInflationParameters(_ofPool);\r\n        return epochReward;\r\n    }\r\n\r\n    /// @dev Returns the split ratio of asset and performance reward.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Value of the ratio from 1 to 100.\r\n    function getRatio(uint256 _ofPool)\r\n        external\r\n        view\r\n        returns (uint256)\r\n    {\r\n        ( , , uint256 ratio) = getInflationParameters(_ofPool);\r\n        return ratio;\r\n    }\r\n\r\n    /// @dev Returns the proof of performance reward for a pool.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return popReward Value of the pop reward in Rigo tokens.\r\n    /// @return performanceReward Split of the performance reward in Rigo tokens.\r\n    /// @notice epoch reward should be big enough that it.\r\n    /// @notice can be decreased if number of funds increases.\r\n    /// @notice should be at least 10^6 (just as pool base) to start with.\r\n    /// @notice rigo token has 10^18 decimals.\r\n    function proofOfPerformance(uint256 _ofPool)\r\n        external\r\n        view\r\n        returns (uint256 popReward, uint256 performanceReward)\r\n    {\r\n        return proofOfPerformanceInternal(_ofPool);\r\n    }\r\n\r\n    /// @dev Checks whether a pool is registered and active.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Bool the pool is active.\r\n    function isActive(uint256 _ofPool)\r\n        external\r\n        view\r\n        returns (bool)\r\n    {\r\n        return isActiveInternal(_ofPool);\r\n    }\r\n\r\n    /// @dev Returns the address and the group of a pool from its id.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Address of the target pool.\r\n    /// @return Address of the pool\u0027s group.\r\n    function addressFromId(uint256 _ofPool)\r\n        external\r\n        view\r\n        returns (\r\n            address pool,\r\n            address group\r\n        )\r\n    {\r\n        return (addressFromIdInternal(_ofPool));\r\n    }\r\n\r\n    /// @dev Returns the price a pool from its id.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Price of the pool in wei.\r\n    /// @return Number of tokens of a pool (totalSupply).\r\n    function getPoolPrice(uint256 _ofPool)\r\n        external\r\n        view\r\n        returns (\r\n            uint256 thePoolPrice,\r\n            uint256 totalTokens\r\n        )\r\n    {\r\n        (thePoolPrice, totalTokens, ) = getPoolPriceAndValueInternal(_ofPool);\r\n    }\r\n\r\n    /// @dev Returns the address and the group of a pool from its id.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Address of the target pool.\r\n    /// @return Address of the pool\u0027s group.\r\n    function calcPoolValue(uint256 _ofPool)\r\n        external\r\n        view\r\n        returns (\r\n            uint256 aum\r\n        )\r\n    {\r\n        ( , , aum) = getPoolPriceAndValueInternal(_ofPool);\r\n    }\r\n\r\n    /*\r\n     * INTERNAL FUNCTIONS\r\n     */\r\n    /// @dev Returns the split ratio of asset and performance reward.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Value of the reward factor.\r\n    /// @return Value of epoch time.\r\n    /// @return Value of the ratio from 1 to 100.\r\n    function getInflationParameters(uint256 _ofPool)\r\n        internal\r\n        view\r\n        returns (\r\n            uint256 epochReward,\r\n            uint256 epochTime,\r\n            uint256 ratio\r\n        )\r\n    {\r\n        ( , address group) = addressFromIdInternal(_ofPool);\r\n        epochReward = Inflation(getMinter()).getInflationFactor(group);\r\n        epochTime = Inflation(getMinter()).period();\r\n        ratio = groups[group].rewardRatio;\r\n    }\r\n\r\n    /// @dev Returns the address of the Inflation contract.\r\n    /// @return Address of the minter/inflation.\r\n    function getMinter()\r\n        internal\r\n        view\r\n        returns (address)\r\n    {\r\n        RigoToken token = RigoToken(RIGOTOKENADDRESS);\r\n        return token.minter();\r\n    }\r\n\r\n    /// @dev Returns the proof of performance reward for a pool.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return popReward Value of the pop reward in Rigo tokens.\r\n    /// @return performanceReward Split of the performance reward in Rigo tokens.\r\n    /// @notice epoch reward should be big enough that it  can be decreased when number of funds increases\r\n    /// @notice should be at least 10^6 (just as pool base) to start with.\r\n    function proofOfPerformanceInternal(uint256 _ofPool)\r\n        internal\r\n        view\r\n        returns (uint256 popReward, uint256 performanceReward)\r\n    {\r\n        uint256 highwatermark;\r\n\r\n        if (poolPrice[_ofPool].highwatermark == 0) {\r\n            highwatermark = 1 ether;\r\n\r\n        } else {\r\n            highwatermark = poolPrice[_ofPool].highwatermark;\r\n        }\r\n\r\n        (uint256 newPrice, uint256 tokenSupply, uint256 poolValue) = getPoolPriceAndValueInternal(_ofPool);\r\n        require (\r\n            newPrice \u003E= highwatermark,\r\n            \u0022PRICE_LOWER_THAN_HWM\u0022\r\n        );\r\n        (address thePoolAddress, ) = addressFromIdInternal(_ofPool);\r\n        require(\r\n            address(Pool(thePoolAddress)).balance \u003C= poolValue \r\n            \u0026\u0026 poolValue * 1 ether / address(Pool(thePoolAddress)).balance \u003C 100 * 1 ether,\r\n            \u0022ETH_HIGHER_THAN_AUM_OR_ETH_AUM_RATIO_BELOW_1PERCENT_ERROR\u0022\r\n        );\r\n\r\n        (uint256 epochReward, uint256 epochTime, uint256 rewardRatio) = getInflationParameters(_ofPool);\r\n\r\n        uint256 assetsComponent = safeMul(\r\n            poolValue,\r\n            epochReward\r\n        ) * epochTime / 1 days; // proportional to epoch time\r\n\r\n        uint256 performanceComponent = safeMul(\r\n            safeMul(\r\n                (newPrice - highwatermark),\r\n                tokenSupply\r\n            ) / 1000000, // Pool(thePoolAddress).BASE(),\r\n            epochReward\r\n        ) * 365 days / 1 days;\r\n\r\n        uint256 assetsReward = safeMul(\r\n            assetsComponent,\r\n            safeSub(10000, rewardRatio) // 100000 = 100%\r\n        ) / 10000 ether * address(Pool(thePoolAddress)).balance / poolValue; // reward inversly proportional to Eth in pool\r\n\r\n        performanceReward = safeDiv(\r\n            safeMul(performanceComponent, rewardRatio),\r\n            10000 ether * address(Pool(thePoolAddress)).balance / poolValue\r\n        ) * 10; // rationalization by 2-20 rule\r\n\r\n        popReward = safeAdd(performanceReward, assetsReward);\r\n\r\n        if (popReward \u003E RigoToken(RIGOTOKENADDRESS).totalSupply() / 10000) {\r\n            popReward = RigoToken(RIGOTOKENADDRESS).totalSupply() / 10000; // max single reward 0.01% of total supply\r\n        }\r\n    }\r\n\r\n    /// @dev Checks whether a pool is registered and active.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Bool the pool is active.\r\n    function isActiveInternal(uint256 _ofPool)\r\n        internal view\r\n        returns (bool)\r\n    {\r\n        DragoRegistry registry = DragoRegistry(dragoRegistry);\r\n        (address thePool, , , , , ) = registry.fromId(_ofPool);\r\n        if (thePool != address(0)) {\r\n            return true;\r\n        }\r\n    }\r\n\r\n    /// @dev Returns the address and the group of a pool from its id.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Address of the target pool.\r\n    /// @return Address of the pool\u0027s group.\r\n    function addressFromIdInternal(uint256 _ofPool)\r\n        internal\r\n        view\r\n        returns (\r\n            address pool,\r\n            address group\r\n        )\r\n    {\r\n        DragoRegistry registry = DragoRegistry(dragoRegistry);\r\n        (pool, , , , , group) = registry.fromId(_ofPool);\r\n        return (pool, group);\r\n    }\r\n\r\n    /// @dev Returns price, supply, aum and boolean of a pool from its id.\r\n    /// @param _ofPool Id of the pool.\r\n    /// @return Price of the pool in wei.\r\n    /// @return Number of tokens of a pool (totalSupply).\r\n    /// @return Address of the target pool.\r\n    /// @return Address of the pool\u0027s group.\r\n    function getPoolPriceAndValueInternal(uint256 _ofPool)\r\n        internal\r\n        view\r\n        returns (\r\n            uint256 thePoolPrice,\r\n            uint256 totalTokens,\r\n            uint256 aum\r\n        )\r\n    {\r\n        (address poolAddress, ) = addressFromIdInternal(_ofPool);\r\n        Pool pool = Pool(poolAddress);\r\n        thePoolPrice = pool.calcSharePrice();\r\n        totalTokens = pool.totalSupply();\r\n        require(\r\n            thePoolPrice != 0 \u0026\u0026 totalTokens !=0,\r\n            \u0022POOL_PRICE_OR_TOTAL_SUPPLY_NULL_ERROR\u0022\r\n        );\r\n        aum = thePoolPrice * totalTokens / 1000000; // pool.BASE();\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_ofGroup\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_ratio\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setRatio\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_ofPool\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getHwm\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_ofPool\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022addressFromId\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022pool\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022group\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022rigoblockDao\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_ofPool\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022calcPoolValue\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022aum\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_ofPool\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getRatio\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_ofPool\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022proofOfPerformance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022popReward\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022performanceReward\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_ofPool\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022isActive\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_ofPool\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getPoolPrice\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022thePoolPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022totalTokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022RIGOTOKENADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_dragoRegistry\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setRegistry\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_rigoblockDao\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setRigoblockDao\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022dragoRegistry\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_ofPool\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getPoolData\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022active\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022thePoolAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022thePoolGroup\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022thePoolPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022thePoolSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022poolValue\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022epochReward\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022ratio\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022pop\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_ofPool\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getEpochReward\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_ofPool\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022claimPop\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_rigoTokenAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_rigoblockDao\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_dragoRegistry\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"ProofOfPerformance","CompilerVersion":"v0.5.4\u002Bcommit.9549d8ff","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000004fbb350052bca5417566f188eb2ebce5b19bc964000000000000000000000000000f05552f24850e75793d38c2bd0cbd249a9ff4000000000000000000000000de6445484a8dcd9bf35fc95eb4e3990cc358822e","Library":"","SwarmSource":"bzzr://123e094918beb47e0e6b57ab886f04ab5b989488d281c5d84b317996a29238fa"}]