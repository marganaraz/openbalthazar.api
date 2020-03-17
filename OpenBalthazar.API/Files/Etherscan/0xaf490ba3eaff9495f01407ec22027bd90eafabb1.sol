[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\n\r\n\r\n/*\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with GSN meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\ncontract Context {\r\n    // Empty internal constructor, to prevent people from mistakenly deploying\r\n    // an instance of this contract, which should be used via inheritance.\r\n    constructor () internal { }\r\n    // solhint-disable-previous-line no-empty-blocks\r\n\r\n    function _msgSender() internal view returns (address payable) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view returns (bytes memory) {\r\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\r\n        return msg.data;\r\n    }\r\n}\r\n\r\n\r\n/**\r\n * @title Roles\r\n * @dev Library for managing addresses assigned to a Role.\r\n */\r\nlibrary Roles {\r\n    struct Role {\r\n        mapping (address =\u003E bool) bearer;\r\n    }\r\n\r\n    /**\r\n     * @dev Give an account access to this role.\r\n     */\r\n    function add(Role storage role, address account) internal {\r\n        require(!has(role, account), \u0022Roles: account already has role\u0022);\r\n        role.bearer[account] = true;\r\n    }\r\n\r\n    /**\r\n     * @dev Remove an account\u0027s access to this role.\r\n     */\r\n    function remove(Role storage role, address account) internal {\r\n        require(has(role, account), \u0022Roles: account does not have role\u0022);\r\n        role.bearer[account] = false;\r\n    }\r\n\r\n    /**\r\n     * @dev Check if an account has this role.\r\n     * @return bool\r\n     */\r\n    function has(Role storage role, address account) internal view returns (bool) {\r\n        require(account != address(0), \u0022Roles: account is the zero address\u0022);\r\n        return role.bearer[account];\r\n    }\r\n}\r\n\r\ncontract PauserRole is Context {\r\n    using Roles for Roles.Role;\r\n\r\n    event PauserAdded(address indexed account);\r\n    event PauserRemoved(address indexed account);\r\n\r\n    Roles.Role private _pausers;\r\n\r\n    constructor () internal {\r\n        _addPauser(_msgSender());\r\n    }\r\n\r\n    modifier onlyPauser() {\r\n        require(isPauser(_msgSender()), \u0022PauserRole: caller does not have the Pauser role\u0022);\r\n        _;\r\n    }\r\n\r\n    function isPauser(address account) public view returns (bool) {\r\n        return _pausers.has(account);\r\n    }\r\n\r\n    function addPauser(address account) public onlyPauser {\r\n        _addPauser(account);\r\n    }\r\n\r\n    function renouncePauser() public {\r\n        _removePauser(_msgSender());\r\n    }\r\n\r\n    function _addPauser(address account) internal {\r\n        _pausers.add(account);\r\n        emit PauserAdded(account);\r\n    }\r\n\r\n    function _removePauser(address account) internal {\r\n        _pausers.remove(account);\r\n        emit PauserRemoved(account);\r\n    }\r\n}\r\n\r\n/**\r\n * @dev Contract module which allows children to implement an emergency stop\r\n * mechanism that can be triggered by an authorized account.\r\n *\r\n * This module is used through inheritance. It will make available the\r\n * modifiers \u0060whenNotPaused\u0060 and \u0060whenPaused\u0060, which can be applied to\r\n * the functions of your contract. Note that they will not be pausable by\r\n * simply including this module, only once the modifiers are put in place.\r\n */\r\ncontract Pausable is Context, PauserRole {\r\n    /**\r\n     * @dev Emitted when the pause is triggered by a pauser (\u0060account\u0060).\r\n     */\r\n    event Paused(address account);\r\n\r\n    /**\r\n     * @dev Emitted when the pause is lifted by a pauser (\u0060account\u0060).\r\n     */\r\n    event Unpaused(address account);\r\n\r\n    bool private _paused;\r\n\r\n    /**\r\n     * @dev Initializes the contract in unpaused state. Assigns the Pauser role\r\n     * to the deployer.\r\n     */\r\n    constructor () internal {\r\n        _paused = false;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the contract is paused, and false otherwise.\r\n     */\r\n    function paused() public view returns (bool) {\r\n        return _paused;\r\n    }\r\n\r\n    /**\r\n     * @dev Modifier to make a function callable only when the contract is not paused.\r\n     */\r\n    modifier whenNotPaused() {\r\n        require(!_paused, \u0022Pausable: paused\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Modifier to make a function callable only when the contract is paused.\r\n     */\r\n    modifier whenPaused() {\r\n        require(_paused, \u0022Pausable: not paused\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Called by a pauser to pause, triggers stopped state.\r\n     */\r\n    function pause() public onlyPauser whenNotPaused {\r\n        _paused = true;\r\n        emit Paused(_msgSender());\r\n    }\r\n\r\n    /**\r\n     * @dev Called by a pauser to unpause, returns to normal state.\r\n     */\r\n    function unpause() public onlyPauser whenPaused {\r\n        _paused = false;\r\n        emit Unpaused(_msgSender());\r\n    }\r\n}\r\n\r\n\r\ncontract Killable {\r\n\taddress payable public _owner;\r\n\r\n\tconstructor() internal {\r\n\t\t_owner = msg.sender;\r\n\t}\r\n\r\n\tfunction kill() public {\r\n\t\trequire(msg.sender == _owner, \u0022only owner method\u0022);\r\n\t\tselfdestruct(_owner);\r\n\t}\r\n}\r\n\r\n\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * \u0060onlyOwner\u0060, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\ncontract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor () internal {\r\n        _owner = _msgSender();\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(isOwner(), \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns true if the caller is the current owner.\r\n     */\r\n    function isOwner() public view returns (bool) {\r\n        return _msgSender() == _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * \u0060onlyOwner\u0060 functions anymore. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby removing any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public onlyOwner {\r\n        emit OwnershipTransferred(_owner, address(0));\r\n        _owner = address(0);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     */\r\n    function _transferOwnership(address newOwner) internal {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\n// prettier-ignore\r\n\r\n\r\n\r\ncontract IGroup {\r\n\tfunction isGroup(address _addr) public view returns (bool);\r\n\r\n\tfunction addGroup(address _addr) external;\r\n\r\n\tfunction getGroupKey(address _addr) internal pure returns (bytes32) {\r\n\t\treturn keccak256(abi.encodePacked(\u0022_group\u0022, _addr));\r\n\t}\r\n}\r\n\r\n\r\ncontract AddressValidator {\r\n\tstring constant errorMessage = \u0022this is illegal address\u0022;\r\n\r\n\tfunction validateIllegalAddress(address _addr) external pure {\r\n\t\trequire(_addr != address(0), errorMessage);\r\n\t}\r\n\r\n\tfunction validateGroup(address _addr, address _groupAddr) external view {\r\n\t\trequire(IGroup(_groupAddr).isGroup(_addr), errorMessage);\r\n\t}\r\n\r\n\tfunction validateGroups(\r\n\t\taddress _addr,\r\n\t\taddress _groupAddr1,\r\n\t\taddress _groupAddr2\r\n\t) external view {\r\n\t\tif (IGroup(_groupAddr1).isGroup(_addr)) {\r\n\t\t\treturn;\r\n\t\t}\r\n\t\trequire(IGroup(_groupAddr2).isGroup(_addr), errorMessage);\r\n\t}\r\n\r\n\tfunction validateAddress(address _addr, address _target) external pure {\r\n\t\trequire(_addr == _target, errorMessage);\r\n\t}\r\n\r\n\tfunction validateAddresses(\r\n\t\taddress _addr,\r\n\t\taddress _target1,\r\n\t\taddress _target2\r\n\t) external pure {\r\n\t\tif (_addr == _target1) {\r\n\t\t\treturn;\r\n\t\t}\r\n\t\trequire(_addr == _target2, errorMessage);\r\n\t}\r\n}\r\n\r\n\r\ncontract UsingValidator {\r\n\tAddressValidator private _validator;\r\n\r\n\tconstructor() public {\r\n\t\t_validator = new AddressValidator();\r\n\t}\r\n\r\n\tfunction addressValidator() internal view returns (AddressValidator) {\r\n\t\treturn _validator;\r\n\t}\r\n}\r\n\r\n\r\ncontract AddressConfig is Ownable, UsingValidator, Killable {\r\n\taddress public token = 0x98626E2C9231f03504273d55f397409deFD4a093;\r\n\taddress public allocator;\r\n\taddress public allocatorStorage;\r\n\taddress public withdraw;\r\n\taddress public withdrawStorage;\r\n\taddress public marketFactory;\r\n\taddress public marketGroup;\r\n\taddress public propertyFactory;\r\n\taddress public propertyGroup;\r\n\taddress public metricsGroup;\r\n\taddress public metricsFactory;\r\n\taddress public policy;\r\n\taddress public policyFactory;\r\n\taddress public policySet;\r\n\taddress public policyGroup;\r\n\taddress public lockup;\r\n\taddress public lockupStorage;\r\n\taddress public voteTimes;\r\n\taddress public voteTimesStorage;\r\n\taddress public voteCounter;\r\n\taddress public voteCounterStorage;\r\n\r\n\tfunction setAllocator(address _addr) external onlyOwner {\r\n\t\tallocator = _addr;\r\n\t}\r\n\r\n\tfunction setAllocatorStorage(address _addr) external onlyOwner {\r\n\t\tallocatorStorage = _addr;\r\n\t}\r\n\r\n\tfunction setWithdraw(address _addr) external onlyOwner {\r\n\t\twithdraw = _addr;\r\n\t}\r\n\r\n\tfunction setWithdrawStorage(address _addr) external onlyOwner {\r\n\t\twithdrawStorage = _addr;\r\n\t}\r\n\r\n\tfunction setMarketFactory(address _addr) external onlyOwner {\r\n\t\tmarketFactory = _addr;\r\n\t}\r\n\r\n\tfunction setMarketGroup(address _addr) external onlyOwner {\r\n\t\tmarketGroup = _addr;\r\n\t}\r\n\r\n\tfunction setPropertyFactory(address _addr) external onlyOwner {\r\n\t\tpropertyFactory = _addr;\r\n\t}\r\n\r\n\tfunction setPropertyGroup(address _addr) external onlyOwner {\r\n\t\tpropertyGroup = _addr;\r\n\t}\r\n\r\n\tfunction setMetricsFactory(address _addr) external onlyOwner {\r\n\t\tmetricsFactory = _addr;\r\n\t}\r\n\r\n\tfunction setMetricsGroup(address _addr) external onlyOwner {\r\n\t\tmetricsGroup = _addr;\r\n\t}\r\n\r\n\tfunction setPolicyFactory(address _addr) external onlyOwner {\r\n\t\tpolicyFactory = _addr;\r\n\t}\r\n\r\n\tfunction setPolicyGroup(address _addr) external onlyOwner {\r\n\t\tpolicyGroup = _addr;\r\n\t}\r\n\r\n\tfunction setPolicySet(address _addr) external onlyOwner {\r\n\t\tpolicySet = _addr;\r\n\t}\r\n\r\n\tfunction setPolicy(address _addr) external {\r\n\t\taddressValidator().validateAddress(msg.sender, policyFactory);\r\n\t\tpolicy = _addr;\r\n\t}\r\n\r\n\tfunction setToken(address _addr) external onlyOwner {\r\n\t\ttoken = _addr;\r\n\t}\r\n\r\n\tfunction setLockup(address _addr) external onlyOwner {\r\n\t\tlockup = _addr;\r\n\t}\r\n\r\n\tfunction setLockupStorage(address _addr) external onlyOwner {\r\n\t\tlockupStorage = _addr;\r\n\t}\r\n\r\n\tfunction setVoteTimes(address _addr) external onlyOwner {\r\n\t\tvoteTimes = _addr;\r\n\t}\r\n\r\n\tfunction setVoteTimesStorage(address _addr) external onlyOwner {\r\n\t\tvoteTimesStorage = _addr;\r\n\t}\r\n\r\n\tfunction setVoteCounter(address _addr) external onlyOwner {\r\n\t\tvoteCounter = _addr;\r\n\t}\r\n\r\n\tfunction setVoteCounterStorage(address _addr) external onlyOwner {\r\n\t\tvoteCounterStorage = _addr;\r\n\t}\r\n}\r\n\r\n\r\ncontract UsingConfig {\r\n\tAddressConfig private _config;\r\n\r\n\tconstructor(address _addressConfig) public {\r\n\t\t_config = AddressConfig(_addressConfig);\r\n\t}\r\n\r\n\tfunction config() internal view returns (AddressConfig) {\r\n\t\treturn _config;\r\n\t}\r\n\r\n\tfunction configAddress() external view returns (address) {\r\n\t\treturn address(_config);\r\n\t}\r\n}\r\n\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * \u0060SafeMath\u0060 restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060\u002B\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060*\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n//import {UsingStorage} from \u0022contracts/src/common/storage/UsingStorage.sol\u0022;\r\n\r\n\r\n\r\n\r\ncontract EternalStorage {\r\n\taddress private currentOwner = msg.sender;\r\n\r\n\tmapping(bytes32 =\u003E uint256) private uIntStorage;\r\n\tmapping(bytes32 =\u003E string) private stringStorage;\r\n\tmapping(bytes32 =\u003E address) private addressStorage;\r\n\tmapping(bytes32 =\u003E bytes32) private bytesStorage;\r\n\tmapping(bytes32 =\u003E bool) private boolStorage;\r\n\tmapping(bytes32 =\u003E int256) private intStorage;\r\n\r\n\tmodifier onlyCurrentOwner() {\r\n\t\trequire(msg.sender == currentOwner, \u0022not current owner\u0022);\r\n\t\t_;\r\n\t}\r\n\r\n\tfunction changeOwner(address _newOwner) external {\r\n\t\trequire(msg.sender == currentOwner, \u0022not current owner\u0022);\r\n\t\tcurrentOwner = _newOwner;\r\n\t}\r\n\r\n\t// *** Getter Methods ***\r\n\tfunction getUint(bytes32 _key) external view returns (uint256) {\r\n\t\treturn uIntStorage[_key];\r\n\t}\r\n\r\n\tfunction getString(bytes32 _key) external view returns (string memory) {\r\n\t\treturn stringStorage[_key];\r\n\t}\r\n\r\n\tfunction getAddress(bytes32 _key) external view returns (address) {\r\n\t\treturn addressStorage[_key];\r\n\t}\r\n\r\n\tfunction getBytes(bytes32 _key) external view returns (bytes32) {\r\n\t\treturn bytesStorage[_key];\r\n\t}\r\n\r\n\tfunction getBool(bytes32 _key) external view returns (bool) {\r\n\t\treturn boolStorage[_key];\r\n\t}\r\n\r\n\tfunction getInt(bytes32 _key) external view returns (int256) {\r\n\t\treturn intStorage[_key];\r\n\t}\r\n\r\n\t// *** Setter Methods ***\r\n\tfunction setUint(bytes32 _key, uint256 _value) external onlyCurrentOwner {\r\n\t\tuIntStorage[_key] = _value;\r\n\t}\r\n\r\n\tfunction setString(bytes32 _key, string calldata _value)\r\n\t\texternal\r\n\t\tonlyCurrentOwner\r\n\t{\r\n\t\tstringStorage[_key] = _value;\r\n\t}\r\n\r\n\tfunction setAddress(bytes32 _key, address _value)\r\n\t\texternal\r\n\t\tonlyCurrentOwner\r\n\t{\r\n\t\taddressStorage[_key] = _value;\r\n\t}\r\n\r\n\tfunction setBytes(bytes32 _key, bytes32 _value) external onlyCurrentOwner {\r\n\t\tbytesStorage[_key] = _value;\r\n\t}\r\n\r\n\tfunction setBool(bytes32 _key, bool _value) external onlyCurrentOwner {\r\n\t\tboolStorage[_key] = _value;\r\n\t}\r\n\r\n\tfunction setInt(bytes32 _key, int256 _value) external onlyCurrentOwner {\r\n\t\tintStorage[_key] = _value;\r\n\t}\r\n\r\n\t// *** Delete Methods ***\r\n\tfunction deleteUint(bytes32 _key) external onlyCurrentOwner {\r\n\t\tdelete uIntStorage[_key];\r\n\t}\r\n\r\n\tfunction deleteString(bytes32 _key) external onlyCurrentOwner {\r\n\t\tdelete stringStorage[_key];\r\n\t}\r\n\r\n\tfunction deleteAddress(bytes32 _key) external onlyCurrentOwner {\r\n\t\tdelete addressStorage[_key];\r\n\t}\r\n\r\n\tfunction deleteBytes(bytes32 _key) external onlyCurrentOwner {\r\n\t\tdelete bytesStorage[_key];\r\n\t}\r\n\r\n\tfunction deleteBool(bytes32 _key) external onlyCurrentOwner {\r\n\t\tdelete boolStorage[_key];\r\n\t}\r\n\r\n\tfunction deleteInt(bytes32 _key) external onlyCurrentOwner {\r\n\t\tdelete intStorage[_key];\r\n\t}\r\n}\r\n\r\n\r\ncontract UsingStorage is Ownable {\r\n\taddress private _storage;\r\n\r\n\tmodifier hasStorage() {\r\n\t\trequire(_storage != address(0), \u0022storage is not setted\u0022);\r\n\t\t_;\r\n\t}\r\n\r\n\tfunction eternalStorage()\r\n\t\tinternal\r\n\t\tview\r\n\t\thasStorage\r\n\t\treturns (EternalStorage)\r\n\t{\r\n\t\treturn EternalStorage(_storage);\r\n\t}\r\n\r\n\tfunction getStorageAddress() external view hasStorage returns (address) {\r\n\t\treturn _storage;\r\n\t}\r\n\r\n\tfunction createStorage() external onlyOwner {\r\n\t\trequire(_storage == address(0), \u0022storage is setted\u0022);\r\n\t\tEternalStorage tmp = new EternalStorage();\r\n\t\t_storage = address(tmp);\r\n\t}\r\n\r\n\tfunction setStorage(address _storageAddress) external onlyOwner {\r\n\t\t_storage = _storageAddress;\r\n\t}\r\n\r\n\tfunction changeOwner(address newOwner) external onlyOwner {\r\n\t\tEternalStorage(_storage).changeOwner(newOwner);\r\n\t}\r\n}\r\n\r\n\r\ncontract VoteTimesStorage is\r\n\tUsingStorage,\r\n\tUsingConfig,\r\n\tUsingValidator,\r\n\tKillable\r\n{\r\n\t// solium-disable-next-line no-empty-blocks\r\n\tconstructor(address _config) public UsingConfig(_config) {}\r\n\r\n\t// Vote Times\r\n\tfunction getVoteTimes() external view returns (uint256) {\r\n\t\treturn eternalStorage().getUint(getVoteTimesKey());\r\n\t}\r\n\r\n\tfunction setVoteTimes(uint256 times) external {\r\n\t\taddressValidator().validateAddress(msg.sender, config().voteTimes());\r\n\r\n\t\treturn eternalStorage().setUint(getVoteTimesKey(), times);\r\n\t}\r\n\r\n\tfunction getVoteTimesKey() private pure returns (bytes32) {\r\n\t\treturn keccak256(abi.encodePacked(\u0022_voteTimes\u0022));\r\n\t}\r\n\r\n\t//Vote Times By Property\r\n\tfunction getVoteTimesByProperty(address _property)\r\n\t\texternal\r\n\t\tview\r\n\t\treturns (uint256)\r\n\t{\r\n\t\treturn eternalStorage().getUint(getVoteTimesByPropertyKey(_property));\r\n\t}\r\n\r\n\tfunction setVoteTimesByProperty(address _property, uint256 times) external {\r\n\t\taddressValidator().validateAddress(msg.sender, config().voteTimes());\r\n\r\n\t\treturn\r\n\t\t\teternalStorage().setUint(\r\n\t\t\t\tgetVoteTimesByPropertyKey(_property),\r\n\t\t\t\ttimes\r\n\t\t\t);\r\n\t}\r\n\r\n\tfunction getVoteTimesByPropertyKey(address _property)\r\n\t\tprivate\r\n\t\tpure\r\n\t\treturns (bytes32)\r\n\t{\r\n\t\treturn keccak256(abi.encodePacked(\u0022_voteTimesByProperty\u0022, _property));\r\n\t}\r\n}\r\n\r\n\r\ncontract VoteTimes is UsingConfig, UsingValidator, Killable {\r\n\tusing SafeMath for uint256;\r\n\r\n\t// solium-disable-next-line no-empty-blocks\r\n\tconstructor(address _config) public UsingConfig(_config) {}\r\n\r\n\tfunction addVoteTime() external {\r\n\t\taddressValidator().validateAddresses(\r\n\t\t\tmsg.sender,\r\n\t\t\tconfig().marketFactory(),\r\n\t\t\tconfig().policyFactory()\r\n\t\t);\r\n\r\n\t\tuint256 voteTimes = getStorage().getVoteTimes();\r\n\t\tvoteTimes = voteTimes.add(1);\r\n\t\tgetStorage().setVoteTimes(voteTimes);\r\n\t}\r\n\r\n\tfunction addVoteTimesByProperty(address _property) external {\r\n\t\taddressValidator().validateAddress(msg.sender, config().voteCounter());\r\n\r\n\t\tuint256 voteTimesByProperty = getStorage().getVoteTimesByProperty(\r\n\t\t\t_property\r\n\t\t);\r\n\t\tvoteTimesByProperty = voteTimesByProperty.add(1);\r\n\t\tgetStorage().setVoteTimesByProperty(_property, voteTimesByProperty);\r\n\t}\r\n\r\n\tfunction resetVoteTimesByProperty(address _property) external {\r\n\t\taddressValidator().validateAddresses(\r\n\t\t\tmsg.sender,\r\n\t\t\tconfig().allocator(),\r\n\t\t\tconfig().propertyFactory()\r\n\t\t);\r\n\r\n\t\tuint256 voteTimes = getStorage().getVoteTimes();\r\n\t\tgetStorage().setVoteTimesByProperty(_property, voteTimes);\r\n\t}\r\n\r\n\tfunction getAbstentionTimes(address _property)\r\n\t\texternal\r\n\t\tview\r\n\t\treturns (uint256)\r\n\t{\r\n\t\tuint256 voteTimes = getStorage().getVoteTimes();\r\n\t\tuint256 voteTimesByProperty = getStorage().getVoteTimesByProperty(\r\n\t\t\t_property\r\n\t\t);\r\n\t\treturn voteTimes.sub(voteTimesByProperty);\r\n\t}\r\n\r\n\tfunction getStorage() private view returns (VoteTimesStorage) {\r\n\t\treturn VoteTimesStorage(config().voteTimesStorage());\r\n\t}\r\n}\r\n\r\n\r\ncontract Metrics {\r\n\taddress public market;\r\n\taddress public property;\r\n\r\n\tconstructor(address _market, address _property) public {\r\n\t\t//Do not validate because there is no AddressConfig\r\n\t\tmarket = _market;\r\n\t\tproperty = _property;\r\n\t}\r\n}\r\n\r\n\r\n\r\ncontract MetricsGroup is\r\n\tUsingConfig,\r\n\tUsingStorage,\r\n\tUsingValidator,\r\n\tIGroup,\r\n\tKillable\r\n{\r\n\tusing SafeMath for uint256;\r\n\r\n\t// solium-disable-next-line no-empty-blocks\r\n\tconstructor(address _config) public UsingConfig(_config) {}\r\n\r\n\tfunction addGroup(address _addr) external {\r\n\t\taddressValidator().validateAddress(\r\n\t\t\tmsg.sender,\r\n\t\t\tconfig().metricsFactory()\r\n\t\t);\r\n\r\n\t\trequire(isGroup(_addr) == false, \u0022already enabled\u0022);\r\n\t\teternalStorage().setBool(getGroupKey(_addr), true);\r\n\t\tuint256 totalCount = eternalStorage().getUint(getTotalCountKey());\r\n\t\ttotalCount = totalCount.add(1);\r\n\t\teternalStorage().setUint(getTotalCountKey(), totalCount);\r\n\t}\r\n\r\n\tfunction isGroup(address _addr) public view returns (bool) {\r\n\t\treturn eternalStorage().getBool(getGroupKey(_addr));\r\n\t}\r\n\r\n\tfunction totalIssuedMetrics() external view returns (uint256) {\r\n\t\treturn eternalStorage().getUint(getTotalCountKey());\r\n\t}\r\n\r\n\tfunction getTotalCountKey() private pure returns (bytes32) {\r\n\t\treturn keccak256(abi.encodePacked(\u0022_totalCount\u0022));\r\n\t}\r\n}\r\n\r\n\r\ncontract MetricsFactory is Pausable, UsingConfig, UsingValidator, Killable {\r\n\tevent Create(address indexed _from, address _metrics);\r\n\r\n\t// solium-disable-next-line no-empty-blocks\r\n\tconstructor(address _config) public UsingConfig(_config) {}\r\n\r\n\tfunction create(address _property) external returns (address) {\r\n\t\trequire(paused() == false, \u0022You cannot use that\u0022);\r\n\t\taddressValidator().validateGroup(msg.sender, config().marketGroup());\r\n\r\n\t\tMetrics metrics = new Metrics(msg.sender, _property);\r\n\t\tMetricsGroup metricsGroup = MetricsGroup(config().metricsGroup());\r\n\t\taddress metricsAddress = address(metrics);\r\n\t\tmetricsGroup.addGroup(metricsAddress);\r\n\t\temit Create(msg.sender, metricsAddress);\r\n\t\treturn metricsAddress;\r\n\t}\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_config\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_metrics\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Create\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Paused\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022PauserAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022PauserRemoved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Unpaused\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022_owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addPauser\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022configAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_property\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022create\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isPauser\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022kill\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renouncePauser\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022unpause\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"MetricsFactory","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000001d415aa39d647834786eb9b5a333a50e9935b796","Library":"","SwarmSource":"bzzr://dffb01f2ba3c8bee6eb59608a87feb6af970340867d35d88ec02987eecc258ea"}]