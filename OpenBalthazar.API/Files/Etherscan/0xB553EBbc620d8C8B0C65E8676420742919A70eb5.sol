[{"SourceCode":"// File: openzeppelin-solidity/contracts/math/SafeMath.sol\r\n\r\npragma solidity ^0.5.2;\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Unsigned math operations with safety checks that revert on error\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Multiplies two unsigned integers, reverts on overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Adds two unsigned integers, reverts on overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),\r\n     * reverts when dividing by zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n// File: contracts/lib/CommonMath.sol\r\n\r\n/*\r\n    Copyright 2018 Set Labs Inc.\r\n\r\n    Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n    you may not use this file except in compliance with the License.\r\n    You may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n    Unless required by applicable law or agreed to in writing, software\r\n    distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n    See the License for the specific language governing permissions and\r\n    limitations under the License.\r\n*/\r\n\r\npragma solidity 0.5.7;\r\n\r\n\r\n\r\nlibrary CommonMath {\r\n    using SafeMath for uint256;\r\n\r\n    uint256 public constant SCALE_FACTOR = 10 ** 18;\r\n    uint256 public constant MAX_UINT_256 = 2 ** 256 - 1;\r\n\r\n    /**\r\n     * Returns scale factor equal to 10 ** 18\r\n     *\r\n     * @return  10 ** 18\r\n     */\r\n    function scaleFactor()\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        return SCALE_FACTOR;\r\n    }\r\n\r\n    /**\r\n     * Calculates and returns the maximum value for a uint256\r\n     *\r\n     * @return  The maximum value for uint256\r\n     */\r\n    function maxUInt256()\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        return MAX_UINT_256;\r\n    }\r\n\r\n    /**\r\n     * Increases a value by the scale factor to allow for additional precision\r\n     * during mathematical operations\r\n     */\r\n    function scale(\r\n        uint256 a\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        return a.mul(SCALE_FACTOR);\r\n    }\r\n\r\n    /**\r\n     * Divides a value by the scale factor to allow for additional precision\r\n     * during mathematical operations\r\n    */\r\n    function deScale(\r\n        uint256 a\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        return a.div(SCALE_FACTOR);\r\n    }\r\n\r\n    /**\r\n    * @dev Performs the power on a specified value, reverts on overflow.\r\n    */\r\n    function safePower(\r\n        uint256 a,\r\n        uint256 pow\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        require(a \u003E 0);\r\n\r\n        uint256 result = 1;\r\n        for (uint256 i = 0; i \u003C pow; i\u002B\u002B){\r\n            uint256 previousResult = result;\r\n\r\n            // Using safemath multiplication prevents overflows\r\n            result = previousResult.mul(a);\r\n        }\r\n\r\n        return result;\r\n    }\r\n\r\n    /**\r\n    * @dev Performs division where if there is a modulo, the value is rounded up\r\n    */\r\n    function divCeil(uint256 a, uint256 b)\r\n        internal\r\n        pure\r\n        returns(uint256)\r\n    {\r\n        return a.mod(b) \u003E 0 ? a.div(b).add(1) : a.div(b);\r\n    }\r\n\r\n    /**\r\n     * Checks for rounding errors and returns value of potential partial amounts of a principal\r\n     *\r\n     * @param  _principal       Number fractional amount is derived from\r\n     * @param  _numerator       Numerator of fraction\r\n     * @param  _denominator     Denominator of fraction\r\n     * @return uint256          Fractional amount of principal calculated\r\n     */\r\n    function getPartialAmount(\r\n        uint256 _principal,\r\n        uint256 _numerator,\r\n        uint256 _denominator\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        // Get remainder of partial amount (if 0 not a partial amount)\r\n        uint256 remainder = mulmod(_principal, _numerator, _denominator);\r\n\r\n        // Return if not a partial amount\r\n        if (remainder == 0) {\r\n            return _principal.mul(_numerator).div(_denominator);\r\n        }\r\n\r\n        // Calculate error percentage\r\n        uint256 errPercentageTimes1000000 = remainder.mul(1000000).div(_numerator.mul(_principal));\r\n\r\n        // Require error percentage is less than 0.1%.\r\n        require(\r\n            errPercentageTimes1000000 \u003C 1000,\r\n            \u0022CommonMath.getPartialAmount: Rounding error exceeds bounds\u0022\r\n        );\r\n\r\n        return _principal.mul(_numerator).div(_denominator);\r\n    }\r\n\r\n    /*\r\n     * Gets the rounded up log10 of passed value\r\n     *\r\n     * @param  _value         Value to calculate ceil(log()) on\r\n     * @return uint256        Output value\r\n     */\r\n    function ceilLog10(\r\n        uint256 _value\r\n    )\r\n        internal\r\n        pure\r\n        returns (uint256)\r\n    {\r\n        // Make sure passed value is greater than 0\r\n        require (\r\n            _value \u003E 0,\r\n            \u0022CommonMath.ceilLog10: Value must be greater than zero.\u0022\r\n        );\r\n\r\n        // Since log10(1) = 0, if _value = 1 return 0\r\n        if (_value == 1) return 0;\r\n\r\n        // Calcualte ceil(log10())\r\n        uint256 x = _value - 1;\r\n\r\n        uint256 result = 0;\r\n\r\n        if (x \u003E= 10 ** 64) {\r\n            x /= 10 ** 64;\r\n            result \u002B= 64;\r\n        }\r\n        if (x \u003E= 10 ** 32) {\r\n            x /= 10 ** 32;\r\n            result \u002B= 32;\r\n        }\r\n        if (x \u003E= 10 ** 16) {\r\n            x /= 10 ** 16;\r\n            result \u002B= 16;\r\n        }\r\n        if (x \u003E= 10 ** 8) {\r\n            x /= 10 ** 8;\r\n            result \u002B= 8;\r\n        }\r\n        if (x \u003E= 10 ** 4) {\r\n            x /= 10 ** 4;\r\n            result \u002B= 4;\r\n        }\r\n        if (x \u003E= 100) {\r\n            x /= 100;\r\n            result \u002B= 2;\r\n        }\r\n        if (x \u003E= 10) {\r\n            result \u002B= 1;\r\n        }\r\n\r\n        return result \u002B 1;\r\n    }\r\n}\r\n\r\n// File: contracts/lib/IERC20.sol\r\n\r\n/*\r\n    Copyright 2018 Set Labs Inc.\r\n\r\n    Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n    you may not use this file except in compliance with the License.\r\n    You may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n    Unless required by applicable law or agreed to in writing, software\r\n    distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n    See the License for the specific language governing permissions and\r\n    limitations under the License.\r\n*/\r\n\r\npragma solidity 0.5.7;\r\n\r\n\r\n/**\r\n * @title IERC20\r\n * @author Set Protocol\r\n *\r\n * Interface for using ERC20 Tokens. This interface is needed to interact with tokens that are not\r\n * fully ERC20 compliant and return something other than true on successful transfers.\r\n */\r\ninterface IERC20 {\r\n    function balanceOf(\r\n        address _owner\r\n    )\r\n        external\r\n        view\r\n        returns (uint256);\r\n\r\n    function allowance(\r\n        address _owner,\r\n        address _spender\r\n    )\r\n        external\r\n        view\r\n        returns (uint256);\r\n\r\n    function transfer(\r\n        address _to,\r\n        uint256 _quantity\r\n    )\r\n        external;\r\n\r\n    function transferFrom(\r\n        address _from,\r\n        address _to,\r\n        uint256 _quantity\r\n    )\r\n        external;\r\n\r\n    function approve(\r\n        address _spender,\r\n        uint256 _quantity\r\n    )\r\n        external\r\n        returns (bool);\r\n\r\n    function totalSupply()\r\n        external\r\n        returns (uint256);\r\n}\r\n\r\n// File: contracts/lib/ERC20Wrapper.sol\r\n\r\n/*\r\n    Copyright 2018 Set Labs Inc.\r\n\r\n    Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n    you may not use this file except in compliance with the License.\r\n    You may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n    Unless required by applicable law or agreed to in writing, software\r\n    distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n    See the License for the specific language governing permissions and\r\n    limitations under the License.\r\n*/\r\n\r\npragma solidity 0.5.7;\r\n\r\n\r\n\r\n\r\n/**\r\n * @title ERC20Wrapper\r\n * @author Set Protocol\r\n *\r\n * This library contains functions for interacting wtih ERC20 tokens, even those not fully compliant.\r\n * For all functions we will only accept tokens that return a null or true value, any other values will\r\n * cause the operation to revert.\r\n */\r\nlibrary ERC20Wrapper {\r\n\r\n    // ============ Internal Functions ============\r\n\r\n    /**\r\n     * Check balance owner\u0027s balance of ERC20 token\r\n     *\r\n     * @param  _token          The address of the ERC20 token\r\n     * @param  _owner          The owner who\u0027s balance is being checked\r\n     * @return  uint256        The _owner\u0027s amount of tokens\r\n     */\r\n    function balanceOf(\r\n        address _token,\r\n        address _owner\r\n    )\r\n        external\r\n        view\r\n        returns (uint256)\r\n    {\r\n        return IERC20(_token).balanceOf(_owner);\r\n    }\r\n\r\n    /**\r\n     * Checks spender\u0027s allowance to use token\u0027s on owner\u0027s behalf.\r\n     *\r\n     * @param  _token          The address of the ERC20 token\r\n     * @param  _owner          The token owner address\r\n     * @param  _spender        The address the allowance is being checked on\r\n     * @return  uint256        The spender\u0027s allowance on behalf of owner\r\n     */\r\n    function allowance(\r\n        address _token,\r\n        address _owner,\r\n        address _spender\r\n    )\r\n        internal\r\n        view\r\n        returns (uint256)\r\n    {\r\n        return IERC20(_token).allowance(_owner, _spender);\r\n    }\r\n\r\n    /**\r\n     * Transfers tokens from an address. Handle\u0027s tokens that return true or null.\r\n     * If other value returned, reverts.\r\n     *\r\n     * @param  _token          The address of the ERC20 token\r\n     * @param  _to             The address to transfer to\r\n     * @param  _quantity       The amount of tokens to transfer\r\n     */\r\n    function transfer(\r\n        address _token,\r\n        address _to,\r\n        uint256 _quantity\r\n    )\r\n        external\r\n    {\r\n        IERC20(_token).transfer(_to, _quantity);\r\n\r\n        // Check that transfer returns true or null\r\n        require(\r\n            checkSuccess(),\r\n            \u0022ERC20Wrapper.transfer: Bad return value\u0022\r\n        );\r\n    }\r\n\r\n    /**\r\n     * Transfers tokens from an address (that has set allowance on the proxy).\r\n     * Handle\u0027s tokens that return true or null. If other value returned, reverts.\r\n     *\r\n     * @param  _token          The address of the ERC20 token\r\n     * @param  _from           The address to transfer from\r\n     * @param  _to             The address to transfer to\r\n     * @param  _quantity       The number of tokens to transfer\r\n     */\r\n    function transferFrom(\r\n        address _token,\r\n        address _from,\r\n        address _to,\r\n        uint256 _quantity\r\n    )\r\n        external\r\n    {\r\n        IERC20(_token).transferFrom(_from, _to, _quantity);\r\n\r\n        // Check that transferFrom returns true or null\r\n        require(\r\n            checkSuccess(),\r\n            \u0022ERC20Wrapper.transferFrom: Bad return value\u0022\r\n        );\r\n    }\r\n\r\n    /**\r\n     * Grants spender ability to spend on owner\u0027s behalf.\r\n     * Handle\u0027s tokens that return true or null. If other value returned, reverts.\r\n     *\r\n     * @param  _token          The address of the ERC20 token\r\n     * @param  _spender        The address to approve for transfer\r\n     * @param  _quantity       The amount of tokens to approve spender for\r\n     */\r\n    function approve(\r\n        address _token,\r\n        address _spender,\r\n        uint256 _quantity\r\n    )\r\n        internal\r\n    {\r\n        IERC20(_token).approve(_spender, _quantity);\r\n\r\n        // Check that approve returns true or null\r\n        require(\r\n            checkSuccess(),\r\n            \u0022ERC20Wrapper.approve: Bad return value\u0022\r\n        );\r\n    }\r\n\r\n    /**\r\n     * Ensure\u0027s the owner has granted enough allowance for system to\r\n     * transfer tokens.\r\n     *\r\n     * @param  _token          The address of the ERC20 token\r\n     * @param  _owner          The address of the token owner\r\n     * @param  _spender        The address to grant/check allowance for\r\n     * @param  _quantity       The amount to see if allowed for\r\n     */\r\n    function ensureAllowance(\r\n        address _token,\r\n        address _owner,\r\n        address _spender,\r\n        uint256 _quantity\r\n    )\r\n        internal\r\n    {\r\n        uint256 currentAllowance = allowance(_token, _owner, _spender);\r\n        if (currentAllowance \u003C _quantity) {\r\n            approve(\r\n                _token,\r\n                _spender,\r\n                CommonMath.maxUInt256()\r\n            );\r\n        }\r\n    }\r\n\r\n    // ============ Private Functions ============\r\n\r\n    /**\r\n     * Checks the return value of the previous function up to 32 bytes. Returns true if the previous\r\n     * function returned 0 bytes or 1.\r\n     */\r\n    function checkSuccess(\r\n    )\r\n        private\r\n        pure\r\n        returns (bool)\r\n    {\r\n        // default to failure\r\n        uint256 returnValue = 0;\r\n\r\n        assembly {\r\n            // check number of bytes returned from last function call\r\n            switch returndatasize\r\n\r\n            // no bytes returned: assume success\r\n            case 0x0 {\r\n                returnValue := 1\r\n            }\r\n\r\n            // 32 bytes returned\r\n            case 0x20 {\r\n                // copy 32 bytes into scratch space\r\n                returndatacopy(0x0, 0x0, 0x20)\r\n\r\n                // load those bytes into returnValue\r\n                returnValue := mload(0x0)\r\n            }\r\n\r\n            // not sure what was returned: dont mark as success\r\n            default { }\r\n        }\r\n\r\n        // check if returned value is one or nothing\r\n        return returnValue == 1;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balanceOf\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"ERC20Wrapper","CompilerVersion":"v0.5.7\u002Bcommit.6da8b019","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://72c87c0c8691f08c762c35e595e738a1538daf1804a487ecddd86d7b3a650d13"}]