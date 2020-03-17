[{"SourceCode":"// File: openzeppelin-solidity/contracts/ownership/Ownable.sol\r\n\r\npragma solidity ^0.5.2;\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n     * account.\r\n     */\r\n    constructor () internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @return the address of the owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner());\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @return true if \u0060msg.sender\u0060 is the owner of the contract.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return msg.sender == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to relinquish control of the contract.\r\n     * It will not be possible to call the functions with the \u0060onlyOwner\u0060\r\n     * modifier anymore.\r\n     * @notice Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers control of the contract to a newOwner.\r\n     * @param newOwner The address to transfer ownership to.\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/math/SafeMath.sol\r\n\r\npragma solidity ^0.5.2;\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Unsigned math operations with safety checks that revert on error\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Multiplies two unsigned integers, reverts on overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Adds two unsigned integers, reverts on overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),\r\n     * reverts when dividing by zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n// File: set-protocol-contracts/contracts/lib/AddressArrayUtils.sol\r\n\r\n// Pulled in from Cryptofin Solidity package in order to control Solidity compiler version\r\n// https://github.com/cryptofinlabs/cryptofin-solidity/blob/master/contracts/array-utils/AddressArrayUtils.sol\r\n\r\npragma solidity 0.5.7;\r\n\r\n\r\nlibrary AddressArrayUtils {\r\n\r\n    /**\r\n     * Finds the index of the first occurrence of the given element.\r\n     * @param A The input array to search\r\n     * @param a The value to find\r\n     * @return Returns (index and isIn) for the first occurrence starting from index 0\r\n     */\r\n    function indexOf(address[] memory A, address a) internal pure returns (uint256, bool) {\r\n        uint256 length = A.length;\r\n        for (uint256 i = 0; i \u003C length; i\u002B\u002B) {\r\n            if (A[i] == a) {\r\n                return (i, true);\r\n            }\r\n        }\r\n        return (0, false);\r\n    }\r\n\r\n    /**\r\n    * Returns true if the value is present in the list. Uses indexOf internally.\r\n    * @param A The input array to search\r\n    * @param a The value to find\r\n    * @return Returns isIn for the first occurrence starting from index 0\r\n    */\r\n    function contains(address[] memory A, address a) internal pure returns (bool) {\r\n        bool isIn;\r\n        (, isIn) = indexOf(A, a);\r\n        return isIn;\r\n    }\r\n\r\n    /// @return Returns index and isIn for the first occurrence starting from\r\n    /// end\r\n    function indexOfFromEnd(address[] memory A, address a) internal pure returns (uint256, bool) {\r\n        uint256 length = A.length;\r\n        for (uint256 i = length; i \u003E 0; i--) {\r\n            if (A[i - 1] == a) {\r\n                return (i, true);\r\n            }\r\n        }\r\n        return (0, false);\r\n    }\r\n\r\n    /**\r\n     * Returns the combination of the two arrays\r\n     * @param A The first array\r\n     * @param B The second array\r\n     * @return Returns A extended by B\r\n     */\r\n    function extend(address[] memory A, address[] memory B) internal pure returns (address[] memory) {\r\n        uint256 aLength = A.length;\r\n        uint256 bLength = B.length;\r\n        address[] memory newAddresses = new address[](aLength \u002B bLength);\r\n        for (uint256 i = 0; i \u003C aLength; i\u002B\u002B) {\r\n            newAddresses[i] = A[i];\r\n        }\r\n        for (uint256 j = 0; j \u003C bLength; j\u002B\u002B) {\r\n            newAddresses[aLength \u002B j] = B[j];\r\n        }\r\n        return newAddresses;\r\n    }\r\n\r\n    /**\r\n     * Returns the array with a appended to A.\r\n     * @param A The first array\r\n     * @param a The value to append\r\n     * @return Returns A appended by a\r\n     */\r\n    function append(address[] memory A, address a) internal pure returns (address[] memory) {\r\n        address[] memory newAddresses = new address[](A.length \u002B 1);\r\n        for (uint256 i = 0; i \u003C A.length; i\u002B\u002B) {\r\n            newAddresses[i] = A[i];\r\n        }\r\n        newAddresses[A.length] = a;\r\n        return newAddresses;\r\n    }\r\n\r\n    /**\r\n     * Returns the combination of two storage arrays.\r\n     * @param A The first array\r\n     * @param B The second array\r\n     * @return Returns A appended by a\r\n     */\r\n    function sExtend(address[] storage A, address[] storage B) internal {\r\n        uint256 length = B.length;\r\n        for (uint256 i = 0; i \u003C length; i\u002B\u002B) {\r\n            A.push(B[i]);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * Returns the intersection of two arrays. Arrays are treated as collections, so duplicates are kept.\r\n     * @param A The first array\r\n     * @param B The second array\r\n     * @return The intersection of the two arrays\r\n     */\r\n    function intersect(address[] memory A, address[] memory B) internal pure returns (address[] memory) {\r\n        uint256 length = A.length;\r\n        bool[] memory includeMap = new bool[](length);\r\n        uint256 newLength = 0;\r\n        for (uint256 i = 0; i \u003C length; i\u002B\u002B) {\r\n            if (contains(B, A[i])) {\r\n                includeMap[i] = true;\r\n                newLength\u002B\u002B;\r\n            }\r\n        }\r\n        address[] memory newAddresses = new address[](newLength);\r\n        uint256 j = 0;\r\n        for (uint256 k = 0; k \u003C length; k\u002B\u002B) {\r\n            if (includeMap[k]) {\r\n                newAddresses[j] = A[k];\r\n                j\u002B\u002B;\r\n            }\r\n        }\r\n        return newAddresses;\r\n    }\r\n\r\n    /**\r\n     * Returns the union of the two arrays. Order is not guaranteed.\r\n     * @param A The first array\r\n     * @param B The second array\r\n     * @return The union of the two arrays\r\n     */\r\n    function union(address[] memory A, address[] memory B) internal pure returns (address[] memory) {\r\n        address[] memory leftDifference = difference(A, B);\r\n        address[] memory rightDifference = difference(B, A);\r\n        address[] memory intersection = intersect(A, B);\r\n        return extend(leftDifference, extend(intersection, rightDifference));\r\n    }\r\n\r\n    /**\r\n     * Alternate implementation\r\n     * Assumes there are no duplicates\r\n     */\r\n    function unionB(address[] memory A, address[] memory B) internal pure returns (address[] memory) {\r\n        bool[] memory includeMap = new bool[](A.length \u002B B.length);\r\n        uint256 count = 0;\r\n        for (uint256 i = 0; i \u003C A.length; i\u002B\u002B) {\r\n            includeMap[i] = true;\r\n            count\u002B\u002B;\r\n        }\r\n        for (uint256 j = 0; j \u003C B.length; j\u002B\u002B) {\r\n            if (!contains(A, B[j])) {\r\n                includeMap[A.length \u002B j] = true;\r\n                count\u002B\u002B;\r\n            }\r\n        }\r\n        address[] memory newAddresses = new address[](count);\r\n        uint256 k = 0;\r\n        for (uint256 m = 0; m \u003C A.length; m\u002B\u002B) {\r\n            if (includeMap[m]) {\r\n                newAddresses[k] = A[m];\r\n                k\u002B\u002B;\r\n            }\r\n        }\r\n        for (uint256 n = 0; n \u003C B.length; n\u002B\u002B) {\r\n            if (includeMap[A.length \u002B n]) {\r\n                newAddresses[k] = B[n];\r\n                k\u002B\u002B;\r\n            }\r\n        }\r\n        return newAddresses;\r\n    }\r\n\r\n    /**\r\n     * Computes the difference of two arrays. Assumes there are no duplicates.\r\n     * @param A The first array\r\n     * @param B The second array\r\n     * @return The difference of the two arrays\r\n     */\r\n    function difference(address[] memory A, address[] memory B) internal pure returns (address[] memory) {\r\n        uint256 length = A.length;\r\n        bool[] memory includeMap = new bool[](length);\r\n        uint256 count = 0;\r\n        // First count the new length because can\u0027t push for in-memory arrays\r\n        for (uint256 i = 0; i \u003C length; i\u002B\u002B) {\r\n            address e = A[i];\r\n            if (!contains(B, e)) {\r\n                includeMap[i] = true;\r\n                count\u002B\u002B;\r\n            }\r\n        }\r\n        address[] memory newAddresses = new address[](count);\r\n        uint256 j = 0;\r\n        for (uint256 k = 0; k \u003C length; k\u002B\u002B) {\r\n            if (includeMap[k]) {\r\n                newAddresses[j] = A[k];\r\n                j\u002B\u002B;\r\n            }\r\n        }\r\n        return newAddresses;\r\n    }\r\n\r\n    /**\r\n    * @dev Reverses storage array in place\r\n    */\r\n    function sReverse(address[] storage A) internal {\r\n        address t;\r\n        uint256 length = A.length;\r\n        for (uint256 i = 0; i \u003C length / 2; i\u002B\u002B) {\r\n            t = A[i];\r\n            A[i] = A[A.length - i - 1];\r\n            A[A.length - i - 1] = t;\r\n        }\r\n    }\r\n\r\n    /**\r\n    * Removes specified index from array\r\n    * Resulting ordering is not guaranteed\r\n    * @return Returns the new array and the removed entry\r\n    */\r\n    function pop(address[] memory A, uint256 index)\r\n        internal\r\n        pure\r\n        returns (address[] memory, address)\r\n    {\r\n        uint256 length = A.length;\r\n        address[] memory newAddresses = new address[](length - 1);\r\n        for (uint256 i = 0; i \u003C index; i\u002B\u002B) {\r\n            newAddresses[i] = A[i];\r\n        }\r\n        for (uint256 j = index \u002B 1; j \u003C length; j\u002B\u002B) {\r\n            newAddresses[j - 1] = A[j];\r\n        }\r\n        return (newAddresses, A[index]);\r\n    }\r\n\r\n    /**\r\n     * @return Returns the new array\r\n     */\r\n    function remove(address[] memory A, address a)\r\n        internal\r\n        pure\r\n        returns (address[] memory)\r\n    {\r\n        (uint256 index, bool isIn) = indexOf(A, a);\r\n        if (!isIn) {\r\n            revert();\r\n        } else {\r\n            (address[] memory _A,) = pop(A, index);\r\n            return _A;\r\n        }\r\n    }\r\n\r\n    function sPop(address[] storage A, uint256 index) internal returns (address) {\r\n        uint256 length = A.length;\r\n        if (index \u003E= length) {\r\n            revert(\u0022Error: index out of bounds\u0022);\r\n        }\r\n        address entry = A[index];\r\n        for (uint256 i = index; i \u003C length - 1; i\u002B\u002B) {\r\n            A[i] = A[i \u002B 1];\r\n        }\r\n        A.length--;\r\n        return entry;\r\n    }\r\n\r\n    /**\r\n    * Deletes address at index and fills the spot with the last address.\r\n    * Order is not preserved.\r\n    * @return Returns the removed entry\r\n    */\r\n    function sPopCheap(address[] storage A, uint256 index) internal returns (address) {\r\n        uint256 length = A.length;\r\n        if (index \u003E= length) {\r\n            revert(\u0022Error: index out of bounds\u0022);\r\n        }\r\n        address entry = A[index];\r\n        if (index != length - 1) {\r\n            A[index] = A[length - 1];\r\n            delete A[length - 1];\r\n        }\r\n        A.length--;\r\n        return entry;\r\n    }\r\n\r\n    /**\r\n     * Deletes address at index. Works by swapping it with the last address, then deleting.\r\n     * Order is not preserved\r\n     * @param A Storage array to remove from\r\n     */\r\n    function sRemoveCheap(address[] storage A, address a) internal {\r\n        (uint256 index, bool isIn) = indexOf(A, a);\r\n        if (!isIn) {\r\n            revert(\u0022Error: entry not found\u0022);\r\n        } else {\r\n            sPopCheap(A, index);\r\n            return;\r\n        }\r\n    }\r\n\r\n    /**\r\n     * Returns whether or not there\u0027s a duplicate. Runs in O(n^2).\r\n     * @param A Array to search\r\n     * @return Returns true if duplicate, false otherwise\r\n     */\r\n    function hasDuplicate(address[] memory A) internal pure returns (bool) {\r\n        if (A.length == 0) {\r\n            return false;\r\n        }\r\n        for (uint256 i = 0; i \u003C A.length - 1; i\u002B\u002B) {\r\n            for (uint256 j = i \u002B 1; j \u003C A.length; j\u002B\u002B) {\r\n                if (A[i] == A[j]) {\r\n                    return true;\r\n                }\r\n            }\r\n        }\r\n        return false;\r\n    }\r\n\r\n    /**\r\n     * Returns whether the two arrays are equal.\r\n     * @param A The first array\r\n     * @param B The second array\r\n     * @return True is the arrays are equal, false if not.\r\n     */\r\n    function isEqual(address[] memory A, address[] memory B) internal pure returns (bool) {\r\n        if (A.length != B.length) {\r\n            return false;\r\n        }\r\n        for (uint256 i = 0; i \u003C A.length; i\u002B\u002B) {\r\n            if (A[i] != B[i]) {\r\n                return false;\r\n            }\r\n        }\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * Returns the elements indexed at indexArray.\r\n     * @param A The array to index\r\n     * @param indexArray The array to use to index\r\n     * @return Returns array containing elements indexed at indexArray\r\n     */\r\n    function argGet(address[] memory A, uint256[] memory indexArray)\r\n        internal\r\n        pure\r\n        returns (address[] memory)\r\n    {\r\n        address[] memory array = new address[](indexArray.length);\r\n        for (uint256 i = 0; i \u003C indexArray.length; i\u002B\u002B) {\r\n            array[i] = A[indexArray[i]];\r\n        }\r\n        return array;\r\n    }\r\n\r\n}\r\n\r\n// File: set-protocol-contracts/contracts/lib/TimeLockUpgrade.sol\r\n\r\n/*\r\n    Copyright 2018 Set Labs Inc.\r\n\r\n    Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n    you may not use this file except in compliance with the License.\r\n    You may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n    Unless required by applicable law or agreed to in writing, software\r\n    distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n    See the License for the specific language governing permissions and\r\n    limitations under the License.\r\n*/\r\n\r\npragma solidity 0.5.7;\r\n\r\n\r\n\r\n\r\n/**\r\n * @title TimeLockUpgrade\r\n * @author Set Protocol\r\n *\r\n * The TimeLockUpgrade contract contains a modifier for handling minimum time period updates\r\n */\r\ncontract TimeLockUpgrade is\r\n    Ownable\r\n{\r\n    using SafeMath for uint256;\r\n\r\n    /* ============ State Variables ============ */\r\n\r\n    // Timelock Upgrade Period in seconds\r\n    uint256 public timeLockPeriod;\r\n\r\n    // Mapping of upgradable units and initialized timelock\r\n    mapping(bytes32 =\u003E uint256) public timeLockedUpgrades;\r\n\r\n    /* ============ Events ============ */\r\n\r\n    event UpgradeRegistered(\r\n        bytes32 _upgradeHash,\r\n        uint256 _timestamp\r\n    );\r\n\r\n    /* ============ Modifiers ============ */\r\n\r\n    modifier timeLockUpgrade() {\r\n        // If the time lock period is 0, then allow non-timebound upgrades.\r\n        // This is useful for initialization of the protocol and for testing.\r\n        if (timeLockPeriod == 0) {\r\n            _;\r\n\r\n            return;\r\n        }\r\n\r\n        // The upgrade hash is defined by the hash of the transaction call data,\r\n        // which uniquely identifies the function as well as the passed in arguments.\r\n        bytes32 upgradeHash = keccak256(\r\n            abi.encodePacked(\r\n                msg.data\r\n            )\r\n        );\r\n\r\n        uint256 registrationTime = timeLockedUpgrades[upgradeHash];\r\n\r\n        // If the upgrade hasn\u0027t been registered, register with the current time.\r\n        if (registrationTime == 0) {\r\n            timeLockedUpgrades[upgradeHash] = block.timestamp;\r\n\r\n            emit UpgradeRegistered(\r\n                upgradeHash,\r\n                block.timestamp\r\n            );\r\n\r\n            return;\r\n        }\r\n\r\n        require(\r\n            block.timestamp \u003E= registrationTime.add(timeLockPeriod),\r\n            \u0022TimeLockUpgrade: Time lock period must have elapsed.\u0022\r\n        );\r\n\r\n        // Reset the timestamp to 0\r\n        timeLockedUpgrades[upgradeHash] = 0;\r\n\r\n        // Run the rest of the upgrades\r\n        _;\r\n    }\r\n\r\n    /* ============ Function ============ */\r\n\r\n    /**\r\n     * Change timeLockPeriod period. Generally called after initially settings have been set up.\r\n     *\r\n     * @param  _timeLockPeriod   Time in seconds that upgrades need to be evaluated before execution\r\n     */\r\n    function setTimeLockPeriod(\r\n        uint256 _timeLockPeriod\r\n    )\r\n        external\r\n        onlyOwner\r\n    {\r\n        // Only allow setting of the timeLockPeriod if the period is greater than the existing\r\n        require(\r\n            _timeLockPeriod \u003E timeLockPeriod,\r\n            \u0022TimeLockUpgrade: New period must be greater than existing\u0022\r\n        );\r\n\r\n        timeLockPeriod = _timeLockPeriod;\r\n    }\r\n}\r\n\r\n// File: set-protocol-contracts/contracts/lib/Authorizable.sol\r\n\r\n/*\r\n    Copyright 2018 Set Labs Inc.\r\n\r\n    Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n    you may not use this file except in compliance with the License.\r\n    You may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n    Unless required by applicable law or agreed to in writing, software\r\n    distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n    See the License for the specific language governing permissions and\r\n    limitations under the License.\r\n*/\r\n\r\npragma solidity 0.5.7;\r\n\r\n\r\n\r\n\r\n\r\n\r\n/**\r\n * @title Authorizable\r\n * @author Set Protocol\r\n *\r\n * The Authorizable contract is an inherited contract that sets permissions on certain function calls\r\n * through the onlyAuthorized modifier. Permissions can be managed only by the Owner of the contract.\r\n */\r\ncontract Authorizable is\r\n    Ownable,\r\n    TimeLockUpgrade\r\n{\r\n    using SafeMath for uint256;\r\n    using AddressArrayUtils for address[];\r\n\r\n    /* ============ State Variables ============ */\r\n\r\n    // Mapping of addresses to bool indicator of authorization\r\n    mapping (address =\u003E bool) public authorized;\r\n\r\n    // Array of authorized addresses\r\n    address[] public authorities;\r\n\r\n    /* ============ Modifiers ============ */\r\n\r\n    // Only authorized addresses can invoke functions with this modifier.\r\n    modifier onlyAuthorized {\r\n        require(\r\n            authorized[msg.sender],\r\n            \u0022Authorizable.onlyAuthorized: Sender not included in authorities\u0022\r\n        );\r\n        _;\r\n    }\r\n\r\n    /* ============ Events ============ */\r\n\r\n    // Event emitted when new address is authorized.\r\n    event AddressAuthorized (\r\n        address indexed authAddress,\r\n        address authorizedBy\r\n    );\r\n\r\n    // Event emitted when address is deauthorized.\r\n    event AuthorizedAddressRemoved (\r\n        address indexed addressRemoved,\r\n        address authorizedBy\r\n    );\r\n\r\n    /* ============ Setters ============ */\r\n\r\n    /**\r\n     * Add authorized address to contract. Can only be set by owner.\r\n     *\r\n     * @param  _authTarget   The address of the new authorized contract\r\n     */\r\n\r\n    function addAuthorizedAddress(address _authTarget)\r\n        external\r\n        onlyOwner\r\n        timeLockUpgrade\r\n    {\r\n        // Require that address is not already authorized\r\n        require(\r\n            !authorized[_authTarget],\r\n            \u0022Authorizable.addAuthorizedAddress: Address already registered\u0022\r\n        );\r\n\r\n        // Set address authority to true\r\n        authorized[_authTarget] = true;\r\n\r\n        // Add address to authorities array\r\n        authorities.push(_authTarget);\r\n\r\n        // Emit authorized address event\r\n        emit AddressAuthorized(\r\n            _authTarget,\r\n            msg.sender\r\n        );\r\n    }\r\n\r\n    /**\r\n     * Remove authorized address from contract. Can only be set by owner.\r\n     *\r\n     * @param  _authTarget   The address to be de-permissioned\r\n     */\r\n\r\n    function removeAuthorizedAddress(address _authTarget)\r\n        external\r\n        onlyOwner\r\n    {\r\n        // Require address is authorized\r\n        require(\r\n            authorized[_authTarget],\r\n            \u0022Authorizable.removeAuthorizedAddress: Address not authorized\u0022\r\n        );\r\n\r\n        // Delete address from authorized mapping\r\n        authorized[_authTarget] = false;\r\n\r\n        authorities = authorities.remove(_authTarget);\r\n\r\n        // Emit AuthorizedAddressRemoved event.\r\n        emit AuthorizedAddressRemoved(\r\n            _authTarget,\r\n            msg.sender\r\n        );\r\n    }\r\n\r\n    /* ============ Getters ============ */\r\n\r\n    /**\r\n     * Get array of authorized addresses.\r\n     *\r\n     * @return address[]   Array of authorized addresses\r\n     */\r\n    function getAuthorizedAddresses()\r\n        external\r\n        view\r\n        returns (address[] memory)\r\n    {\r\n        // Return array of authorized addresses\r\n        return authorities;\r\n    }\r\n}\r\n\r\n// File: contracts/meta-oracles/interfaces/IOracle.sol\r\n\r\n/*\r\n    Copyright 2019 Set Labs Inc.\r\n\r\n    Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n    you may not use this file except in compliance with the License.\r\n    You may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n    Unless required by applicable law or agreed to in writing, software\r\n    distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n    See the License for the specific language governing permissions and\r\n    limitations under the License.\r\n*/\r\n\r\npragma solidity 0.5.7;\r\n\r\n\r\n/**\r\n * @title IOracle\r\n * @author Set Protocol\r\n *\r\n * Interface for operating with any external Oracle that returns uint256 or\r\n * an adapting contract that converts oracle output to uint256\r\n */\r\ninterface IOracle {\r\n\r\n    /**\r\n     * Returns the queried data from an oracle returning uint256\r\n     *\r\n     * @return  Current price of asset represented in uint256\r\n     */\r\n    function read()\r\n        external\r\n        view\r\n        returns (uint256);\r\n}\r\n\r\n// File: contracts/meta-oracles/OracleProxy.sol\r\n\r\n/*\r\n    Copyright 2019 Set Labs Inc.\r\n\r\n    Licensed under the Apache License, Version 2.0 (the \u0022License\u0022);\r\n    you may not use this file except in compliance with the License.\r\n    You may obtain a copy of the License at\r\n\r\n    http://www.apache.org/licenses/LICENSE-2.0\r\n\r\n    Unless required by applicable law or agreed to in writing, software\r\n    distributed under the License is distributed on an \u0022AS IS\u0022 BASIS,\r\n    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\r\n    See the License for the specific language governing permissions and\r\n    limitations under the License.\r\n*/\r\n\r\npragma solidity 0.5.7;\r\n\r\n\r\n\r\n\r\n/**\r\n * @title OracleProxy\r\n * @author Set Protocol\r\n *\r\n * Permissioned contract that acts as a bridge between external Oracles and the whole Set system.\r\n * OracleProxies help enforce standardization of data types the Set system uses as well as allows\r\n * for Set to interact with external permissioned oracles through one contract instead of permiss-\r\n * ioning all contracts that need the external oracle\u0027s data. Because the OracleProxy is interacting\r\n * with permissioned oracles, the OracleProxy must also be permissioned so that only out contracts\r\n * use it and the oracle data isn\u0027t leaked on chain.\r\n */\r\ncontract OracleProxy is\r\n    Authorizable\r\n{\r\n\r\n    /* ============ State Variables ============ */\r\n    IOracle public oracleInstance;\r\n\r\n    /* ============ Events ============ */\r\n\r\n    event LogOracleUpdated(\r\n        address indexed newOracleAddress\r\n    );\r\n\r\n    /* ============ Constructor ============ */\r\n    /*\r\n     * Set address of oracle being proxied\r\n     *\r\n     * @param  _oracleAddress    The address of oracle being proxied\r\n     */\r\n    constructor(\r\n        IOracle _oracleAddress\r\n    )\r\n        public\r\n    {\r\n        oracleInstance = _oracleAddress;\r\n    }\r\n\r\n    /* ============ External ============ */\r\n\r\n    /*\r\n     * Reads value of external oracle and passed to Set system. Only authorized addresses are allowed\r\n     * to call read().\r\n     *\r\n     * @returns         Oracle\u0027s uint256 output\r\n     */\r\n    function read()\r\n        external\r\n        view\r\n        onlyAuthorized\r\n        returns (uint256)\r\n    {\r\n        // Read value of oracle\r\n        return oracleInstance.read();\r\n    }\r\n\r\n    /*\r\n     * Sets address of new oracle to be proxied. Only owner has ability to update oracleAddress.\r\n     *\r\n     * @param _newOracleAddress         Address of new oracle being proxied\r\n     */\r\n    function changeOracleAddress(\r\n        IOracle _newOracleAddress\r\n    )\r\n        external\r\n        onlyOwner\r\n        timeLockUpgrade\r\n    {\r\n        // Check to make sure new oracle address is passed\r\n        require(\r\n            address(_newOracleAddress) != address(oracleInstance),\r\n            \u0022OracleProxy.changeOracleAddress: Must give new oracle address.\u0022\r\n        );\r\n\r\n        // Set new Oracle instance\r\n        oracleInstance = _newOracleAddress;\r\n\r\n        emit LogOracleUpdated(address(_newOracleAddress));\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022timeLockedUpgrades\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_authTarget\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addAuthorizedAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022authorities\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022read\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_authTarget\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeAuthorizedAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022timeLockPeriod\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_timeLockPeriod\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setTimeLockPeriod\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022authorized\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022oracleInstance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAuthorizedAddresses\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_newOracleAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeOracleAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_oracleAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOracleAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022LogOracleUpdated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022authAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022authorizedBy\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022AddressAuthorized\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022addressRemoved\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022authorizedBy\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022AuthorizedAddressRemoved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_upgradeHash\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_timestamp\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022UpgradeRegistered\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"OracleProxy","CompilerVersion":"v0.5.7\u002Bcommit.6da8b019","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000005211febe5d129dfa871e004c39652e8254a73ef8","Library":"","SwarmSource":"bzzr://60049cbfc59bd1a85027bc218ebe27da6e225c99313992a6f2b02061c48229af"}]