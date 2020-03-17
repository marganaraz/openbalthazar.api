[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * \u0060SafeMath\u0060 restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\n\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060\u002B\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a, \u0022SafeMath: subtraction overflow\u0022);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060*\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, \u0022SafeMath: division by zero\u0022);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0, \u0022SafeMath: modulo by zero\u0022);\r\n        return a % b;\r\n    }\r\n}\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @title Roles\r\n * @dev Library for managing addresses assigned to a Role.\r\n */\r\nlibrary Roles {\r\n    struct Role {\r\n        mapping (address =\u003E bool) bearer;\r\n    }\r\n\r\n    /**\r\n     * @dev Give an account access to this role.\r\n     */\r\n    function add(Role storage role, address account) internal {\r\n        require(!has(role, account), \u0022Roles: account already has role\u0022);\r\n        role.bearer[account] = true;\r\n    }\r\n\r\n    /**\r\n     * @dev Remove an account\u0027s access to this role.\r\n     */\r\n    function remove(Role storage role, address account) internal {\r\n        require(has(role, account), \u0022Roles: account does not have role\u0022);\r\n        role.bearer[account] = false;\r\n    }\r\n\r\n    /**\r\n     * @dev Check if an account has this role.\r\n     * @return bool\r\n     */\r\n    function has(Role storage role, address account) internal view returns (bool) {\r\n        require(account != address(0), \u0022Roles: account is the zero address\u0022);\r\n        return role.bearer[account];\r\n    }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/access/roles/WhitelistAdminRole.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\n/**\r\n * @title WhitelistAdminRole\r\n * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.\r\n */\r\ncontract WhitelistAdminRole {\r\n    using Roles for Roles.Role;\r\n\r\n    event WhitelistAdminAdded(address indexed account);\r\n    event WhitelistAdminRemoved(address indexed account);\r\n\r\n    Roles.Role private _whitelistAdmins;\r\n\r\n    constructor () internal {\r\n        _addWhitelistAdmin(msg.sender);\r\n    }\r\n\r\n    modifier onlyWhitelistAdmin() {\r\n        require(isWhitelistAdmin(msg.sender), \u0022WhitelistAdminRole: caller does not have the WhitelistAdmin role\u0022);\r\n        _;\r\n    }\r\n\r\n    function isWhitelistAdmin(address account) public view returns (bool) {\r\n        return _whitelistAdmins.has(account);\r\n    }\r\n\r\n    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {\r\n        _addWhitelistAdmin(account);\r\n    }\r\n\r\n    function renounceWhitelistAdmin() public {\r\n        _removeWhitelistAdmin(msg.sender);\r\n    }\r\n\r\n    function _addWhitelistAdmin(address account) internal {\r\n        _whitelistAdmins.add(account);\r\n        emit WhitelistAdminAdded(account);\r\n    }\r\n\r\n    function _removeWhitelistAdmin(address account) internal {\r\n        _whitelistAdmins.remove(account);\r\n        emit WhitelistAdminRemoved(account);\r\n    }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/access/roles/WhitelistedRole.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n\r\n\r\n/**\r\n * @title WhitelistedRole\r\n * @dev Whitelisted accounts have been approved by a WhitelistAdmin to perform certain actions (e.g. participate in a\r\n * crowdsale). This role is special in that the only accounts that can add it are WhitelistAdmins (who can also remove\r\n * it), and not Whitelisteds themselves.\r\n */\r\ncontract WhitelistedRole is WhitelistAdminRole {\r\n    using Roles for Roles.Role;\r\n\r\n    event WhitelistedAdded(address indexed account);\r\n    event WhitelistedRemoved(address indexed account);\r\n\r\n    Roles.Role private _whitelisteds;\r\n\r\n    modifier onlyWhitelisted() {\r\n        require(isWhitelisted(msg.sender), \u0022WhitelistedRole: caller does not have the Whitelisted role\u0022);\r\n        _;\r\n    }\r\n\r\n    function isWhitelisted(address account) public view returns (bool) {\r\n        return _whitelisteds.has(account);\r\n    }\r\n\r\n    function addWhitelisted(address account) public onlyWhitelistAdmin {\r\n        _addWhitelisted(account);\r\n    }\r\n\r\n    function removeWhitelisted(address account) public onlyWhitelistAdmin {\r\n        _removeWhitelisted(account);\r\n    }\r\n\r\n    function renounceWhitelisted() public {\r\n        _removeWhitelisted(msg.sender);\r\n    }\r\n\r\n    function _addWhitelisted(address account) internal {\r\n        _whitelisteds.add(account);\r\n        emit WhitelistedAdded(account);\r\n    }\r\n\r\n    function _removeWhitelisted(address account) internal {\r\n        _whitelisteds.remove(account);\r\n        emit WhitelistedRemoved(account);\r\n    }\r\n}\r\n\r\n// File: contracts/Strings.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n//https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol\r\nlibrary Strings {\r\n\r\n    function strConcat(string memory _a, string memory _b) internal pure returns (string memory _concatenatedString) {\r\n        return strConcat(_a, _b, \u0022\u0022, \u0022\u0022, \u0022\u0022);\r\n    }\r\n\r\n    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory _concatenatedString) {\r\n        return strConcat(_a, _b, _c, \u0022\u0022, \u0022\u0022);\r\n    }\r\n\r\n    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory _concatenatedString) {\r\n        return strConcat(_a, _b, _c, _d, \u0022\u0022);\r\n    }\r\n\r\n    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory _concatenatedString) {\r\n        bytes memory _ba = bytes(_a);\r\n        bytes memory _bb = bytes(_b);\r\n        bytes memory _bc = bytes(_c);\r\n        bytes memory _bd = bytes(_d);\r\n        bytes memory _be = bytes(_e);\r\n        string memory abcde = new string(_ba.length \u002B _bb.length \u002B _bc.length \u002B _bd.length \u002B _be.length);\r\n        bytes memory babcde = bytes(abcde);\r\n        uint k = 0;\r\n        uint i = 0;\r\n        for (i = 0; i \u003C _ba.length; i\u002B\u002B) {\r\n            babcde[k\u002B\u002B] = _ba[i];\r\n        }\r\n        for (i = 0; i \u003C _bb.length; i\u002B\u002B) {\r\n            babcde[k\u002B\u002B] = _bb[i];\r\n        }\r\n        for (i = 0; i \u003C _bc.length; i\u002B\u002B) {\r\n            babcde[k\u002B\u002B] = _bc[i];\r\n        }\r\n        for (i = 0; i \u003C _bd.length; i\u002B\u002B) {\r\n            babcde[k\u002B\u002B] = _bd[i];\r\n        }\r\n        for (i = 0; i \u003C _be.length; i\u002B\u002B) {\r\n            babcde[k\u002B\u002B] = _be[i];\r\n        }\r\n        return string(babcde);\r\n    }\r\n\r\n    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {\r\n        if (_i == 0) {\r\n            return \u00220\u0022;\r\n        }\r\n        uint j = _i;\r\n        uint len;\r\n        while (j != 0) {\r\n            len\u002B\u002B;\r\n            j /= 10;\r\n        }\r\n        bytes memory bstr = new bytes(len);\r\n        uint k = len - 1;\r\n        while (_i != 0) {\r\n            bstr[k--] = byte(uint8(48 \u002B _i % 10));\r\n            _i /= 10;\r\n        }\r\n        return string(bstr);\r\n    }\r\n}\r\n\r\npragma solidity ^0.5.0;\r\n\r\ninterface punkInterface {\r\n    \r\n    function punkIndexToAddress(uint256 _punkId) external view returns (address); \r\n}\r\n\r\npragma solidity ^0.5.0;\r\n\r\ncontract punkDetails is WhitelistedRole {\r\n    using SafeMath for uint256;\r\n\r\n    punkInterface public punkContract;\r\n    \r\n    uint256 constant internal MAX_UINT256 = ~uint256(0);\r\n    \r\n    string contractName = \u0022Punk Details\u0022;\r\n    string punksWebsite = \u0022https://www.larvalabs.com/cryptopunks\u0022;\r\n    \r\n    uint256 public serialNumbers = 0;\r\n    \r\n    mapping(uint256 =\u003E string) public punkIdToPunkName;\r\n    mapping(uint256 =\u003E uint256) public punkIdToPunkAge;\r\n    mapping(uint256 =\u003E string) public punkIdToPunkJob;\r\n    mapping(uint256 =\u003E string) public punkIdToPunkLocation;\r\n    mapping(uint256 =\u003E string) public punkIdToPunkBio;\r\n    mapping(uint256 =\u003E bytes32) public punkIdToSerialNumber;\r\n    \r\n    \r\n    constructor() public {\r\n        super.addWhitelisted(msg.sender);\r\n        super.addWhitelisted(0xC352B534e8b987e036A93539Fd6897F53488e56a);\r\n\r\n        punkContract = punkInterface(0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB);\r\n    }\r\n\r\n    function updatePunkName(string memory _name, uint256 _punkId) public returns (bool){\r\n        require(msg.sender == punkContract.punkIndexToAddress(_punkId) || isWhitelisted(msg.sender), \u0022You must have permission.\u0022);\r\n        punkIdToPunkName[_punkId] = _name;\r\n        return true;\r\n    }\r\n    \r\n    function updatePunkAge(uint256 _age, uint256 _punkId) public returns (bool){\r\n        require(msg.sender == punkContract.punkIndexToAddress(_punkId) || isWhitelisted(msg.sender), \u0022You must have permission.\u0022);\r\n        punkIdToPunkAge[_punkId] = _age;\r\n        return true;\r\n    }\r\n    \r\n    function updatePunkJob(string memory _job, uint256 _punkId) public returns (bool){\r\n        require(msg.sender == punkContract.punkIndexToAddress(_punkId) || isWhitelisted(msg.sender), \u0022You must have permission.\u0022);\r\n        punkIdToPunkJob[_punkId] = _job;\r\n        return true;\r\n    }\r\n    \r\n    function updatePunkLocation(string memory _location, uint256 _punkId) public returns (bool){\r\n        require(msg.sender == punkContract.punkIndexToAddress(_punkId) || isWhitelisted(msg.sender), \u0022You must have permission.\u0022);\r\n        punkIdToPunkLocation[_punkId] = _location;\r\n        return true;\r\n    }\r\n    \r\n    function updatePunkBio(string memory _bio, uint256 _punkId) public returns (bool){\r\n        require(msg.sender == punkContract.punkIndexToAddress(_punkId) || isWhitelisted(msg.sender), \u0022You must have permission.\u0022);\r\n        punkIdToPunkBio[_punkId] = _bio;\r\n        return true;\r\n    }\r\n    \r\n    function assignSerialNumber(uint256 _punkId) public returns (bool){\r\n        require(msg.sender == punkContract.punkIndexToAddress(_punkId), \u0022You must have permission.\u0022);\r\n        require(punkIdToSerialNumber[_punkId]==\u0022\u0022, \u0022Can only assign a serial number once.\u0022);\r\n        \r\n        serialNumbers = serialNumbers.add(1); \r\n        bytes32 serialNumber = keccak256(abi.encodePacked(serialNumbers, block.number, msg.sender));\r\n        punkIdToSerialNumber[_punkId] = serialNumber;\r\n    }\r\n    \r\n    function updatePunksWebsite(string memory _website) public onlyWhitelisted returns (bool){\r\n        punksWebsite = _website;\r\n        return true;\r\n    }\r\n    \r\n    \r\n    \r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addWhitelisted\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022punkIdToPunkAge\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeWhitelisted\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isWhitelisted\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022punkIdToPunkJob\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceWhitelistAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_name\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_punkId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022updatePunkName\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022serialNumbers\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_website\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022updatePunksWebsite\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addWhitelistAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_job\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_punkId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022updatePunkJob\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022punkIdToSerialNumber\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022punkIdToPunkName\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022punkIdToPunkBio\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022punkIdToPunkLocation\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isWhitelistAdmin\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_punkId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022assignSerialNumber\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceWhitelisted\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_bio\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_punkId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022updatePunkBio\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_location\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_punkId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022updatePunkLocation\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_age\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_punkId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022updatePunkAge\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022punkContract\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WhitelistedAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WhitelistedRemoved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WhitelistAdminAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WhitelistAdminRemoved\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"punkDetails","CompilerVersion":"v0.5.0\u002Bcommit.1d4f565a","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://ba7ac3211042d53ada05cf72e49e73d19d35d9232c85ef6d8e23ab8e50554edb"}]