[{"SourceCode":"// File: openzeppelin-solidity/contracts/math/SafeMath.sol\r\n\r\npragma solidity ^0.5.2;\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Unsigned math operations with safety checks that revert on error\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Multiplies two unsigned integers, reverts on overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Adds two unsigned integers, reverts on overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),\r\n     * reverts when dividing by zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n// File: contracts/meta-oracles/lib/LinkedListLibraryV2.sol\r\n\r\n/*\r\n    Copyright 2019 Set Labs Inc.\r\n\r\n    Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n    you may not use this file except in compliance with the License.\r\n    You may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n    Unless required by applicable law or agreed to in writing, software\r\n    distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n    See the License for the specific language governing permissions and\r\n    limitations under the License.\r\n*/\r\n\r\npragma solidity 0.5.7;\r\npragma experimental \u0022ABIEncoderV2\u0022;\r\n\r\n\r\n\r\n/**\r\n * @title LinkedListLibraryV2\r\n * @author Set Protocol\r\n *\r\n * Library for creating and altering uni-directional circularly linked lists, optimized for sequential updating\r\n * Version two of this contract is a library vs. a contract.\r\n *\r\n *\r\n * CHANGELOG\r\n * - LinkedListLibraryV2 is declared as library vs. contract\r\n */\r\nlibrary LinkedListLibraryV2 {\r\n\r\n    using SafeMath for uint256;\r\n\r\n    /* ============ Structs ============ */\r\n\r\n    struct LinkedList{\r\n        uint256 dataSizeLimit;\r\n        uint256 lastUpdatedIndex;\r\n        uint256[] dataArray;\r\n    }\r\n\r\n    /*\r\n     * Initialize LinkedList by setting limit on amount of nodes and inital value of node 0\r\n     *\r\n     * @param  _self                        LinkedList to operate on\r\n     * @param  _dataSizeLimit               Max amount of nodes allowed in LinkedList\r\n     * @param  _initialValue                Initial value of node 0 in LinkedList\r\n     */\r\n    function initialize(\r\n        LinkedList storage _self,\r\n        uint256 _dataSizeLimit,\r\n        uint256 _initialValue\r\n    )\r\n        internal\r\n    {\r\n        require(\r\n            _self.dataArray.length == 0,\r\n            \u0022LinkedListLibrary: Initialized LinkedList must be empty\u0022\r\n        );\r\n\r\n        // Initialize Linked list by defining upper limit of data points in the list and setting\r\n        // initial value\r\n        _self.dataSizeLimit = _dataSizeLimit;\r\n        _self.dataArray.push(_initialValue);\r\n        _self.lastUpdatedIndex = 0;\r\n    }\r\n\r\n    /*\r\n     * Add new value to list by either creating new node if node limit not reached or updating\r\n     * existing node value\r\n     *\r\n     * @param  _self                        LinkedList to operate on\r\n     * @param  _addedValue                  Value to add to list\r\n     */\r\n    function editList(\r\n        LinkedList storage _self,\r\n        uint256 _addedValue\r\n    )\r\n        internal\r\n    {\r\n        // Add node if data hasn\u0027t reached size limit, otherwise update next node\r\n        _self.dataArray.length \u003C _self.dataSizeLimit ? addNode(_self, _addedValue)\r\n            : updateNode(_self, _addedValue);\r\n    }\r\n\r\n    /*\r\n     * Add new value to list by either creating new node. Node limit must not be reached.\r\n     *\r\n     * @param  _self                        LinkedList to operate on\r\n     * @param  _addedValue                  Value to add to list\r\n     */\r\n    function addNode(\r\n        LinkedList storage _self,\r\n        uint256 _addedValue\r\n    )\r\n        internal\r\n    {\r\n        uint256 newNodeIndex = _self.lastUpdatedIndex.add(1);\r\n\r\n        require(\r\n            newNodeIndex == _self.dataArray.length,\r\n            \u0022LinkedListLibrary: Node must be added at next expected index in list\u0022\r\n        );\r\n\r\n        require(\r\n            newNodeIndex \u003C _self.dataSizeLimit,\r\n            \u0022LinkedListLibrary: Attempting to add node that exceeds data size limit\u0022\r\n        );\r\n\r\n        // Add node value\r\n        _self.dataArray.push(_addedValue);\r\n\r\n        // Update lastUpdatedIndex value\r\n        _self.lastUpdatedIndex = newNodeIndex;\r\n    }\r\n\r\n    /*\r\n     * Add new value to list by updating existing node. Updates only happen if node limit has been\r\n     * reached.\r\n     *\r\n     * @param  _self                        LinkedList to operate on\r\n     * @param  _addedValue                  Value to add to list\r\n     */\r\n    function updateNode(\r\n        LinkedList storage _self,\r\n        uint256 _addedValue\r\n    )\r\n        internal\r\n    {\r\n        // Determine the next node in list to be updated\r\n        uint256 updateNodeIndex = _self.lastUpdatedIndex.add(1) % _self.dataSizeLimit;\r\n\r\n        // Require that updated node has been previously added\r\n        require(\r\n            updateNodeIndex \u003C _self.dataArray.length,\r\n            \u0022LinkedListLibrary: Attempting to update non-existent node\u0022\r\n        );\r\n\r\n        // Update node value and last updated index\r\n        _self.dataArray[updateNodeIndex] = _addedValue;\r\n        _self.lastUpdatedIndex = updateNodeIndex;\r\n    }\r\n\r\n    /*\r\n     * Read list from the lastUpdatedIndex back the passed amount of data points.\r\n     *\r\n     * @param  _self                        LinkedList to operate on\r\n     * @param  _dataPoints                  Number of data points to return\r\n     */\r\n    function readList(\r\n        LinkedList storage _self,\r\n        uint256 _dataPoints\r\n    )\r\n        internal\r\n        view\r\n        returns (uint256[] memory)\r\n    {\r\n        LinkedList memory linkedListMemory = _self;\r\n\r\n        return readListMemory(\r\n            linkedListMemory,\r\n            _dataPoints\r\n        );\r\n    }\r\n\r\n    function readListMemory(\r\n        LinkedList memory _self,\r\n        uint256 _dataPoints\r\n    )\r\n        internal\r\n        view\r\n        returns (uint256[] memory)\r\n    {\r\n        // Make sure query isn\u0027t for more data than collected\r\n        require(\r\n            _dataPoints \u003C= _self.dataArray.length,\r\n            \u0022LinkedListLibrary: Querying more data than available\u0022\r\n        );\r\n\r\n        // Instantiate output array in memory\r\n        uint256[] memory outputArray = new uint256[](_dataPoints);\r\n\r\n        // Find head of list\r\n        uint256 linkedListIndex = _self.lastUpdatedIndex;\r\n        for (uint256 i = 0; i \u003C _dataPoints; i\u002B\u002B) {\r\n            // Get value at index in linkedList\r\n            outputArray[i] = _self.dataArray[linkedListIndex];\r\n\r\n            // Find next linked index\r\n            linkedListIndex = linkedListIndex == 0 ? _self.dataSizeLimit.sub(1) : linkedListIndex.sub(1);\r\n        }\r\n\r\n        return outputArray;\r\n    }\r\n\r\n}\r\n\r\n// File: contracts/meta-oracles/lib/TimeSeriesStateLibrary.sol\r\n\r\n/*\r\n    Copyright 2019 Set Labs Inc.\r\n\r\n    Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n    you may not use this file except in compliance with the License.\r\n    You may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n    Unless required by applicable law or agreed to in writing, software\r\n    distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n    See the License for the specific language governing permissions and\r\n    limitations under the License.\r\n*/\r\n\r\npragma solidity 0.5.7;\r\n\r\n\r\n/**\r\n * @title TimeSeriesStateLibrary\r\n * @author Set Protocol\r\n *\r\n * Library defining TimeSeries state struct\r\n */\r\nlibrary TimeSeriesStateLibrary {\r\n    struct State {\r\n        uint256 nextEarliestUpdate;\r\n        uint256 updateInterval;\r\n        LinkedListLibraryV2.LinkedList timeSeriesData;\r\n    }\r\n}\r\n\r\n// File: contracts/meta-oracles/interfaces/ITimeSeriesFeed.sol\r\n\r\n/*\r\n    Copyright 2019 Set Labs Inc.\r\n\r\n    Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n    you may not use this file except in compliance with the License.\r\n    You may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n    Unless required by applicable law or agreed to in writing, software\r\n    distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n    See the License for the specific language governing permissions and\r\n    limitations under the License.\r\n*/\r\n\r\npragma solidity 0.5.7;\r\n\r\n/**\r\n * @title ITimeSeriesFeed\r\n * @author Set Protocol\r\n *\r\n * Interface for interacting with TimeSeriesFeed contract\r\n */\r\ninterface ITimeSeriesFeed {\r\n\r\n    /*\r\n     * Query linked list for specified days of data. Will revert if number of days\r\n     * passed exceeds amount of days collected.\r\n     *\r\n     * @param  _dataDays            Number of dats of data being queried\r\n     */\r\n    function read(\r\n        uint256 _dataDays\r\n    )\r\n        external\r\n        view\r\n        returns (uint256[] memory);\r\n\r\n    function nextEarliestUpdate()\r\n        external\r\n        view\r\n        returns (uint256);\r\n\r\n    function updateInterval()\r\n        external\r\n        view\r\n        returns (uint256);\r\n\r\n    function getTimeSeriesFeedState()\r\n        external\r\n        view\r\n        returns (TimeSeriesStateLibrary.State memory);\r\n}\r\n\r\n// File: contracts/meta-oracles/lib/RSILibrary.sol\r\n\r\n/*\r\n    Copyright 2019 Set Labs Inc.\r\n\r\n    Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n    you may not use this file except in compliance with the License.\r\n    You may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n    Unless required by applicable law or agreed to in writing, software\r\n    distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n    See the License for the specific language governing permissions and\r\n    limitations under the License.\r\n*/\r\n\r\npragma solidity 0.5.7;\r\n\r\n\r\n\r\n/**\r\n * @title RSILibrary\r\n * @author Set Protocol\r\n *\r\n * Library for calculating the Relative Strength Index\r\n *\r\n */\r\nlibrary RSILibrary{\r\n\r\n    using SafeMath for uint256;\r\n\r\n    /* ============ Constants ============ */\r\n\r\n    uint256 public constant HUNDRED = 100;\r\n\r\n    /*\r\n     * Calculates the new relative strength index value using\r\n     * an array of prices.\r\n     *\r\n     * RSI = 100 \u2212 100 /\r\n     *       (1 \u002B (Gain / Loss))\r\n     *\r\n     * Price Difference = Price(N) - Price(N-1) where N is number of days\r\n     * Gain = Sum(Positive Price Difference)\r\n     * Loss = -1 * Sum(Negative Price Difference)\r\n     *\r\n     *\r\n     * Our implementation is simplified to the following for efficiency\r\n     * RSI = (100 * SUM(Gain)) / (SUM(Loss) \u002B SUM(Gain))\r\n     *\r\n     *\r\n     * @param  _dataArray               Array of prices used to calculate the RSI\r\n     * @returns                         The RSI value\r\n     */\r\n    function calculate(\r\n        uint256[] memory _dataArray\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        uint256 positiveDataSum = 0;\r\n        uint256 negativeDataSum = 0;\r\n\r\n        // Check that data points must be greater than 1\r\n        require(\r\n            _dataArray.length \u003E 1,\r\n            \u0022RSILibrary.calculate: Length of data array must be greater than 1\u0022\r\n        );\r\n\r\n        // Sum negative and positive price differences\r\n        for (uint256 i = 1; i \u003C _dataArray.length; i\u002B\u002B) {\r\n            uint256 currentPrice = _dataArray[i - 1];\r\n            uint256 previousPrice = _dataArray[i];\r\n            if (currentPrice \u003E previousPrice) {\r\n                positiveDataSum = currentPrice.sub(previousPrice).add(positiveDataSum);\r\n            } else {\r\n                negativeDataSum = previousPrice.sub(currentPrice).add(negativeDataSum);\r\n            }\r\n        }\r\n\r\n        // Check that there must be a positive or negative price change\r\n        require(\r\n            negativeDataSum \u003E 0 || positiveDataSum \u003E 0,\r\n            \u0022RSILibrary.calculate: Not valid RSI Value\u0022\r\n        );\r\n\r\n        // a = 100 * SUM(Gain)\r\n        uint256 a = HUNDRED.mul(positiveDataSum);\r\n        // b = SUM(Gain) \u002B SUM(Loss)\r\n        uint256 b = positiveDataSum.add(negativeDataSum);\r\n\r\n        return a.div(b);\r\n    }\r\n}\r\n\r\n// File: contracts/meta-oracles/RSIOracle.sol\r\n\r\n/*\r\n    Copyright 2019 Set Labs Inc.\r\n\r\n    Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n    you may not use this file except in compliance with the License.\r\n    You may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n    Unless required by applicable law or agreed to in writing, software\r\n    distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n    See the License for the specific language governing permissions and\r\n    limitations under the License.\r\n*/\r\n\r\npragma solidity 0.5.7;\r\n\r\n\r\n\r\n\r\n/**\r\n * @title RSIOracle\r\n * @author Set Protocol\r\n *\r\n * Contract used calculate RSI of data points provided by other on-chain\r\n * price feed and return to querying contract.\r\n */\r\ncontract RSIOracle {\r\n\r\n    using SafeMath for uint256;\r\n\r\n    /* ============ State Variables ============ */\r\n    string public dataDescription;\r\n    ITimeSeriesFeed public timeSeriesFeedInstance;\r\n\r\n    /* ============ Constructor ============ */\r\n\r\n    /*\r\n     * RSIOracle constructor.\r\n     * Contract used to calculate RSI of data points provided by other on-chain\r\n     * price feed and return to querying contract.\r\n     *\r\n     * @param  _timeSeriesFeed          TimeSeriesFeed to get list of data from\r\n     * @param  _dataDescription         Description of data\r\n     */\r\n    constructor(\r\n        ITimeSeriesFeed _timeSeriesFeed,\r\n        string memory _dataDescription\r\n    )\r\n        public\r\n    {\r\n        timeSeriesFeedInstance = _timeSeriesFeed;\r\n\r\n        dataDescription = _dataDescription;\r\n    }\r\n\r\n    /*\r\n     * Get RSI over defined amount of data points by querying price feed and\r\n     * calculating using RSILibrary. Returns uint256.\r\n     *\r\n     * @param  _rsiTimePeriod    RSI lookback period\r\n     * @returns                  RSI value for passed number of _rsiTimePeriod\r\n     */\r\n    function read(\r\n        uint256 _rsiTimePeriod\r\n    )\r\n        external\r\n        view\r\n        returns (uint256)\r\n    {\r\n        // RSI period must be at least 1\r\n        require(\r\n            _rsiTimePeriod \u003E= 1,\r\n            \u0022RSIOracle.read: RSI time period must be at least 1\u0022\r\n        );\r\n\r\n        // Get data from price feed. This will be \u002B1 the lookback period\r\n        uint256[] memory dataArray = timeSeriesFeedInstance.read(_rsiTimePeriod.add(1));\r\n\r\n        // Return RSI calculation\r\n        return RSILibrary.calculate(dataArray);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022dataDescription\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022timeSeriesFeedInstance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_rsiTimePeriod\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022read\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_timeSeriesFeed\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_dataDescription\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"RSIOracle","CompilerVersion":"v0.5.7\u002Bcommit.6da8b019","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000b7b2977f1f84629000bf572b466b43ba2b93483600000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000014455448204461696c7920525349204f7261636c65000000000000000000000000","Library":"","SwarmSource":"bzzr://a2276400266cd643d66fce3891be8e6944c2cdf76f9f27857638553a46e6fd9c"}]