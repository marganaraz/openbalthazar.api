[{"SourceCode":"pragma solidity ^0.5.2;\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Unsigned math operations with safety checks that revert on error\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Multiplies two unsigned integers, reverts on overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Adds two unsigned integers, reverts on overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),\r\n     * reverts when dividing by zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n// File: contracts/managers/triggers/ITrigger.sol\r\n\r\n/*\r\n    Copyright 2019 Set Labs Inc.\r\n\r\n    Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n    you may not use this file except in compliance with the License.\r\n    You may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n    Unless required by applicable law or agreed to in writing, software\r\n    distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n    See the License for the specific language governing permissions and\r\n    limitations under the License.\r\n*/\r\n\r\npragma solidity 0.5.7;\r\n\r\n/**\r\n * @title IPriceTrigger\r\n * @author Set Protocol\r\n *\r\n * Interface for interacting with PriceTrigger contracts\r\n */\r\ninterface ITrigger {\r\n    /*\r\n     * Returns bool indicating whether the current market conditions are bullish.\r\n     *\r\n     * @return             Boolean whether condition is bullish\r\n     */\r\n    function isBullish()\r\n        external\r\n        view\r\n        returns (bool);\r\n}\r\n\r\n// File: contracts/meta-oracles/interfaces/IOracle.sol\r\n\r\n/*\r\n    Copyright 2019 Set Labs Inc.\r\n\r\n    Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n    you may not use this file except in compliance with the License.\r\n    You may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n    Unless required by applicable law or agreed to in writing, software\r\n    distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n    See the License for the specific language governing permissions and\r\n    limitations under the License.\r\n*/\r\n\r\npragma solidity 0.5.7;\r\n\r\n\r\n/**\r\n * @title IOracle\r\n * @author Set Protocol\r\n *\r\n * Interface for operating with any external Oracle that returns uint256 or\r\n * an adapting contract that converts oracle output to uint256\r\n */\r\ninterface IOracle {\r\n\r\n    /**\r\n     * Returns the queried data from an oracle returning uint256\r\n     *\r\n     * @return  Current price of asset represented in uint256\r\n     */\r\n    function read()\r\n        external\r\n        view\r\n        returns (uint256);\r\n}\r\n\r\n// File: contracts/meta-oracles/interfaces/IMetaOracleV2.sol\r\n\r\n/*\r\n    Copyright 2019 Set Labs Inc.\r\n\r\n    Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n    you may not use this file except in compliance with the License.\r\n    You may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n    Unless required by applicable law or agreed to in writing, software\r\n    distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n    See the License for the specific language governing permissions and\r\n    limitations under the License.\r\n*/\r\n\r\npragma solidity 0.5.7;\r\n\r\n\r\n/**\r\n * @title IMetaOracleV2\r\n * @author Set Protocol\r\n *\r\n * Interface for operating with any MetaOracleV2 (moving average, bollinger, etc.)\r\n *\r\n * CHANGELOG:\r\n *  - read returns uint256 instead of bytes\r\n */\r\ninterface IMetaOracleV2 {\r\n\r\n    /**\r\n     * Returns the queried data from a meta oracle.\r\n     *\r\n     * @return  Current price of asset in uint256\r\n     */\r\n    function read(\r\n        uint256 _dataDays\r\n    )\r\n        external\r\n        view\r\n        returns (uint256);\r\n}\r\n\r\n// File: contracts/managers/lib/Oscillator.sol\r\n\r\n/*\r\n    Copyright 2019 Set Labs Inc.\r\n\r\n    Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n    you may not use this file except in compliance with the License.\r\n    You may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n    Unless required by applicable law or agreed to in writing, software\r\n    distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n    See the License for the specific language governing permissions and\r\n    limitations under the License.\r\n*/\r\n\r\npragma solidity 0.5.7;\r\n\r\n\r\n/**\r\n * @title Oscillator\r\n * @author Set Protocol\r\n *\r\n * Library of utility functions to deal with oscillator-related functionality.\r\n */\r\nlibrary Oscillator {\r\n\r\n    enum State { NEUTRAL, UPPER, LOWER }\r\n\r\n    // Oscillator bounds typically between 0 and 100\r\n    struct Bounds {\r\n        uint256 lower;\r\n        uint256 upper;\r\n    }\r\n\r\n    /*\r\n     * Returns upper if value is greater or equal to upper bound.\r\n     * Returns lower if lower than lower bound, and neutral if in between.\r\n     * Asymmetric bounds are due to rounding in solidity and not wanting 40.1\r\n     * to register in LOWER state, for example.\r\n     */\r\n    function getState(\r\n        Bounds storage _bounds,\r\n        uint256 _value\r\n    )\r\n        internal\r\n        view\r\n        returns(State)\r\n    {\r\n        return _value \u003E= _bounds.upper ? State.UPPER :\r\n            _value \u003C _bounds.lower ? State.LOWER : State.NEUTRAL;\r\n    }\r\n}\r\n\r\n// File: contracts/managers/triggers/RSITrendingTrigger.sol\r\n\r\n/*\r\n    Copyright 2019 Set Labs Inc.\r\n\r\n    Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n    you may not use this file except in compliance with the License.\r\n    You may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n    Unless required by applicable law or agreed to in writing, software\r\n    distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n    See the License for the specific language governing permissions and\r\n    limitations under the License.\r\n*/\r\n\r\npragma solidity 0.5.7;\r\npragma experimental \u0022ABIEncoderV2\u0022;\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n/**\r\n * @title RSITrending\r\n * @author Set Protocol\r\n *\r\n * Implementing the ITrigger interface, this contract is queried by a\r\n * RebalancingSetToken Manager to determine the whether the current market state for\r\n * the RSI Trending trigger is bullish.\r\n *\r\n * This trigger is for trend trading strategies which sets upperBound as resistance\r\n * and lowerBound as support. When RSI level crosses above upperBound the indicator\r\n * is bullish. When RSI level crosses below lowerBound the indicator is bearish.\r\n *\r\n */\r\ncontract RSITrendingTrigger is\r\n    ITrigger\r\n{\r\n    using SafeMath for uint256;\r\n\r\n    /* ============ State Variables ============ */\r\n    IMetaOracleV2 public rsiOracle;\r\n    Oscillator.Bounds public bounds;\r\n    uint256 public rsiTimePeriod;\r\n\r\n    /*\r\n     * RSITrendingTrigger constructor.\r\n     *\r\n     * @param  _rsiOracle               The address of RSI oracle\r\n     * @param  _lowerBound              Lower bound of RSI to trigger a rebalance\r\n     * @param  _upperBound              Upper bound of RSI to trigger a rebalance\r\n     * @param  _rsiTimePeriod           The amount of days to use in RSI calculation\r\n     */\r\n    constructor(\r\n        IMetaOracleV2 _rsiOracle,\r\n        uint256 _lowerBound,\r\n        uint256 _upperBound,\r\n        uint256 _rsiTimePeriod\r\n    )\r\n        public\r\n    {\r\n        require(\r\n            _upperBound \u003E= _lowerBound,\r\n            \u0022RSITrendingTrigger.constructor: Upper bound must be greater than lower bound.\u0022\r\n        );\r\n\r\n        // If upper bound less than 100 and above inequality holds then lowerBound\r\n        // also guaranteed to be between 0 and 100.\r\n        require(\r\n            _upperBound \u003C 100,\r\n            \u0022RSITrendingTrigger.constructor: Bounds must be between 0 and 100.\u0022\r\n        );\r\n\r\n        // RSI time period must be greater than 0\r\n        require(\r\n            _rsiTimePeriod \u003E 0,\r\n            \u0022RSITrendingTrigger.constructor: RSI time period must be greater than 0.\u0022\r\n        );\r\n\r\n        rsiOracle = _rsiOracle;\r\n        rsiTimePeriod = _rsiTimePeriod;\r\n        bounds = Oscillator.Bounds({\r\n            lower: _lowerBound,\r\n            upper: _upperBound\r\n        });\r\n    }\r\n\r\n    /* ============ External ============ */\r\n\r\n    /*\r\n     * If RSI is above upper bound then should be true, if RSI is below lower bound\r\n     * then should be false. If in between bounds then revert.\r\n     */\r\n    function isBullish()\r\n        external\r\n        view\r\n        returns (bool)\r\n    {\r\n        uint256 rsiValue = rsiOracle.read(rsiTimePeriod);\r\n        Oscillator.State rsiState = Oscillator.getState(bounds, rsiValue);\r\n\r\n        require(\r\n            rsiState != Oscillator.State.NEUTRAL,\r\n            \u0022Oscillator: State must not be neutral\u0022\r\n        );\r\n\r\n        return rsiState == Oscillator.State.UPPER;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022rsiTimePeriod\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022bounds\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022lower\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022upper\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isBullish\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022rsiOracle\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_rsiOracle\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_lowerBound\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_upperBound\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_rsiTimePeriod\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"RSITrendingTrigger","CompilerVersion":"v0.5.7\u002Bcommit.6da8b019","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"00000000000000000000000079ecbfcee430c17a74891d4dde2e1d21d4b2882b0000000000000000000000000000000000000000000000000000000000000028000000000000000000000000000000000000000000000000000000000000003c000000000000000000000000000000000000000000000000000000000000000e","Library":"","SwarmSource":"bzzr://5fc3c59d0bb851d3aecdc2be86a6ced97dfe5f0de9a0b4e5ab7d722e9683c0a4"}]