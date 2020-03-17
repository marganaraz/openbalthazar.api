[{"SourceCode":"{\u0022Context.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.0;\\n\\n/*\\n * @dev Provides information about the current execution context, including the\\n * sender of the transaction and its data. While these are generally available\\n * via msg.sender and msg.data, they should not be accessed in such a direct\\n * manner, since when dealing with GSN meta-transactions the account sending and\\n * paying for execution may not be the actual sender (as far as an application\\n * is concerned).\\n *\\n * This contract is only required for intermediate, library-like contracts.\\n */\\ncontract Context {\\n    // Empty internal constructor, to prevent people from mistakenly deploying\\n    // an instance of this contract, which should be used via inheritance.\\n    constructor () internal { }\\n    // solhint-disable-previous-line no-empty-blocks\\n\\n    function _msgSender() internal view returns (address payable) {\\n        return msg.sender;\\n    }\\n\\n    function _msgData() internal view returns (bytes memory) {\\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\\n        return msg.data;\\n    }\\n}\\n\u0022},\u0022CStore.sol\u0022:{\u0022content\u0022:\u0022pragma solidity 0.5.8;\\n\\nimport \\\u0022./ERC644Balances.sol\\\u0022;\\nimport { ERC1820Client } from \\\u0022./ERC1820Client.sol\\\u0022;\\n\\n\\n/**\\n * @title ERC644 Database Contract\\n * @author Panos\\n */\\ncontract CStore is ERC644Balances, ERC1820Client {\\n\\n    address[] internal mDefaultOperators;\\n    mapping(address =\\u003e bool) internal mIsDefaultOperator;\\n    mapping(address =\\u003e mapping(address =\\u003e bool)) internal mRevokedDefaultOperator;\\n    mapping(address =\\u003e mapping(address =\\u003e bool)) internal mAuthorizedOperators;\\n\\n    /**\\n     * @notice Database construction\\n     * @param _totalSupply The total supply of the token\\n     */\\n    constructor(uint256 _totalSupply, address _initialOwner, address[] memory _defaultOperators) public\\n    {\\n        balances[_initialOwner] = _totalSupply;\\n        totalSupply = _totalSupply;\\n        mDefaultOperators = _defaultOperators;\\n        for (uint256 i = 0; i \\u003c mDefaultOperators.length; i\u002B\u002B) { mIsDefaultOperator[mDefaultOperators[i]] = true; }\\n\\n        setInterfaceImplementation(\\\u0022ERC644Balances\\\u0022, address(this));\\n    }\\n\\n    /**\\n     * @notice Increase total supply by \u0060_val\u0060\\n     * @param _val Value to increase\\n     * @return Operation status\\n     */\\n    // solhint-disable-next-line no-unused-vars\\n    function incTotalSupply(uint _val) external onlyModule returns (bool) {\\n        return false;\\n    }\\n\\n    /**\\n     * @notice Decrease total supply by \u0060_val\u0060\\n     * @param _val Value to decrease\\n     * @return Operation status\\n     */\\n     // solhint-disable-next-line no-unused-vars\\n     function decTotalSupply(uint _val) external onlyModule returns (bool) {\\n         return false;\\n     }\\n\\n    /**\\n     * @notice moving \u0060_amount\u0060 from \u0060_from\u0060 to \u0060_to\u0060\\n     * @param _from The sender address\\n     * @param _to The receiving address\\n     * @param _amount The moving amount\\n     * @return bool The move result\\n     */\\n    function move(address _from, address _to, uint256 _amount) external\\n    onlyModule\\n    returns (bool) {\\n        balances[_from] = balances[_from].sub(_amount);\\n        emit BalanceAdj(msg.sender, _from, _amount, \\\u0022-\\\u0022);\\n        balances[_to] = balances[_to].add(_amount);\\n        emit BalanceAdj(msg.sender, _to, _amount, \\\u0022\u002B\\\u0022);\\n        return true;\\n    }\\n\\n    /**\\n     * @notice Setting operator \u0060_operator\u0060 for \u0060_tokenHolder\u0060\\n     * @param _operator The operator to set status\\n     * @param _tokenHolder The token holder to set operator\\n     * @param _status The operator status\\n     * @return bool Status of operation\\n     */\\n    function setAuthorizedOperator(address _operator, address _tokenHolder, bool _status) external\\n    onlyModule\\n    returns (bool) {\\n        mAuthorizedOperators[_operator][_tokenHolder] = _status;\\n        return true;\\n    }\\n\\n    /**\\n     * @notice Set revoke status for default operator \u0060_operator\u0060 for \u0060_tokenHolder\u0060\\n     * @param _operator The default operator to set status\\n     * @param _tokenHolder The token holder to set operator\\n     * @param _status The operator status\\n     * @return bool Status of operation\\n     */\\n    function setRevokedDefaultOperator(address _operator, address _tokenHolder, bool _status) external\\n    onlyModule\\n    returns (bool) {\\n    mRevokedDefaultOperator[_operator][_tokenHolder] = _status;\\n        return true;\\n    }\\n\\n    /**\\n     * @notice Getting operator \u0060_operator\u0060 for \u0060_tokenHolder\u0060\\n     * @param _operator The operator address to get status\\n     * @param _tokenHolder The token holder address\\n     * @return bool Operator status\\n     */\\n    function getAuthorizedOperator(address _operator, address _tokenHolder) external\\n    view\\n    returns (bool) {\\n        return mAuthorizedOperators[_operator][_tokenHolder];\\n    }\\n\\n    /**\\n     * @notice Getting default operator \u0060_operator\u0060\\n     * @param _operator The default operator address to get status\\n     * @return bool Default operator status\\n     */\\n    function getDefaultOperator(address _operator) external view returns (bool) {\\n        return mIsDefaultOperator[_operator];\\n    }\\n\\n    /**\\n     * @notice Getting default operators\\n     * @return address[] Default operator addresses\\n     */\\n    function getDefaultOperators() external view returns (address[] memory) {\\n        return mDefaultOperators;\\n    }\\n\\n    function getRevokedDefaultOperator(address _operator, address _tokenHolder) external view returns (bool) {\\n        return mRevokedDefaultOperator[_operator][_tokenHolder];\\n    }\\n\\n    /**\\n     * @notice Increment \u0060_acct\u0060 balance by \u0060_val\u0060\\n     * @param _acct Target account to increment balance.\\n     * @param _val Value to increment\\n     * @return Operation status\\n     */\\n    // solhint-disable-next-line no-unused-vars\\n    function incBalance(address _acct, uint _val) public onlyModule returns (bool) {\\n        return false;\\n    }\\n\\n    /**\\n     * @notice Decrement \u0060_acct\u0060 balance by \u0060_val\u0060\\n     * @param _acct Target account to decrement balance.\\n     * @param _val Value to decrement\\n     * @return Operation status\\n     */\\n     // solhint-disable-next-line no-unused-vars\\n     function decBalance(address _acct, uint _val) public onlyModule returns (bool) {\\n         return false;\\n     }\\n}\\n\\n\u0022},\u0022ERC1820Client.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.3;\\n\\n\\ncontract ERC1820Registry {\\n    function setInterfaceImplementer(address _addr, bytes32 _interfaceHash, address _implementer) external;\\n    function getInterfaceImplementer(address _addr, bytes32 _interfaceHash) external view returns (address);\\n    function setManager(address _addr, address _newManager) external;\\n    function getManager(address _addr) public view returns (address);\\n}\\n\\n\\n/// Base client to interact with the registry.\\ncontract ERC1820Client {\\n    ERC1820Registry constant ERC1820REGISTRY = ERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);\\n\\n    function setInterfaceImplementation(string memory _interfaceLabel, address _implementation) internal {\\n        bytes32 interfaceHash = keccak256(abi.encodePacked(_interfaceLabel));\\n        ERC1820REGISTRY.setInterfaceImplementer(address(this), interfaceHash, _implementation);\\n    }\\n\\n    function interfaceAddr(address addr, string memory _interfaceLabel) internal view returns(address) {\\n        bytes32 interfaceHash = keccak256(abi.encodePacked(_interfaceLabel));\\n        return ERC1820REGISTRY.getInterfaceImplementer(addr, interfaceHash);\\n    }\\n\\n    function delegateManagement(address _newManager) internal {\\n        ERC1820REGISTRY.setManager(address(this), _newManager);\\n    }\\n}\\n\u0022},\u0022ERC644Balances.sol\u0022:{\u0022content\u0022:\u0022pragma solidity 0.5.8;\\n\\nimport \\\u0022./SafeMath.sol\\\u0022;\\nimport \\\u0022./SafeGuard.sol\\\u0022;\\nimport \\\u0022./IERC644.sol\\\u0022;\\n\\n\\n/**\\n * @title ERC644 Standard Balances Contract\\n * @author chrisfranko\\n */\\ncontract ERC644Balances is IERC644, SafeGuard {\\n    using SafeMath for uint256;\\n\\n    uint256 public totalSupply;\\n\\n    event BalanceAdj(address indexed module, address indexed account, uint amount, string polarity);\\n    event ModuleSet(address indexed module, bool indexed set);\\n\\n    mapping(address =\\u003e bool) public modules;\\n    mapping(address =\\u003e uint256) public balances;\\n    mapping(address =\\u003e mapping(address =\\u003e uint256)) public allowed;\\n\\n    modifier onlyModule() {\\n        require(modules[msg.sender], \\\u0022ERC644Balances: caller is not a module\\\u0022);\\n        _;\\n    }\\n\\n    /**\\n     * @notice Set allowance of \u0060_spender\u0060 in behalf of \u0060_sender\u0060 at \u0060_value\u0060\\n     * @param _sender Owner account\\n     * @param _spender Spender account\\n     * @param _value Value to approve\\n     * @return Operation status\\n     */\\n    function setApprove(address _sender, address _spender, uint256 _value) external onlyModule returns (bool) {\\n        allowed[_sender][_spender] = _value;\\n        return true;\\n    }\\n\\n    /**\\n     * @notice Decrease allowance of \u0060_spender\u0060 in behalf of \u0060_from\u0060 at \u0060_value\u0060\\n     * @param _from Owner account\\n     * @param _spender Spender account\\n     * @param _value Value to decrease\\n     * @return Operation status\\n     */\\n    function decApprove(address _from, address _spender, uint _value) external onlyModule returns (bool) {\\n        allowed[_from][_spender] = allowed[_from][_spender].sub(_value);\\n        return true;\\n    }\\n\\n    /**\\n    * @notice Increase total supply by \u0060_val\u0060\\n    * @param _val Value to increase\\n    * @return Operation status\\n    */\\n    function incTotalSupply(uint _val) external onlyModule returns (bool) {\\n        totalSupply = totalSupply.add(_val);\\n        return true;\\n    }\\n\\n    /**\\n     * @notice Decrease total supply by \u0060_val\u0060\\n     * @param _val Value to decrease\\n     * @return Operation status\\n     */\\n    function decTotalSupply(uint _val) external onlyModule returns (bool) {\\n        totalSupply = totalSupply.sub(_val);\\n        return true;\\n    }\\n\\n    /**\\n     * @notice Set/Unset \u0060_acct\u0060 as an authorized module\\n     * @param _acct Module address\\n     * @param _set Module set status\\n     * @return Operation status\\n     */\\n    function setModule(address _acct, bool _set) external onlyOwner returns (bool) {\\n        modules[_acct] = _set;\\n        emit ModuleSet(_acct, _set);\\n        return true;\\n    }\\n\\n    /**\\n     * @notice Get \u0060_acct\u0060 balance\\n     * @param _acct Target account to get balance.\\n     * @return The account balance\\n     */\\n    function getBalance(address _acct) external view returns (uint256) {\\n        return balances[_acct];\\n    }\\n\\n    /**\\n     * @notice Get allowance of \u0060_spender\u0060 in behalf of \u0060_owner\u0060\\n     * @param _owner Owner account\\n     * @param _spender Spender account\\n     * @return Allowance\\n     */\\n    function getAllowance(address _owner, address _spender) external view returns (uint256) {\\n        return allowed[_owner][_spender];\\n    }\\n\\n    /**\\n     * @notice Get if \u0060_acct\u0060 is an authorized module\\n     * @param _acct Module address\\n     * @return Operation status\\n     */\\n    function getModule(address _acct) external view returns (bool) {\\n        return modules[_acct];\\n    }\\n\\n    /**\\n     * @notice Get total supply\\n     * @return Total supply\\n     */\\n    function getTotalSupply() external view returns (uint256) {\\n        return totalSupply;\\n    }\\n\\n    /**\\n     * @notice Increment \u0060_acct\u0060 balance by \u0060_val\u0060\\n     * @param _acct Target account to increment balance.\\n     * @param _val Value to increment\\n     * @return Operation status\\n     */\\n    function incBalance(address _acct, uint _val) public onlyModule returns (bool) {\\n        balances[_acct] = balances[_acct].add(_val);\\n        emit BalanceAdj(msg.sender, _acct, _val, \\\u0022\u002B\\\u0022);\\n        return true;\\n    }\\n\\n    /**\\n     * @notice Decrement \u0060_acct\u0060 balance by \u0060_val\u0060\\n     * @param _acct Target account to decrement balance.\\n     * @param _val Value to decrement\\n     * @return Operation status\\n     */\\n    function decBalance(address _acct, uint _val) public onlyModule returns (bool) {\\n        balances[_acct] = balances[_acct].sub(_val);\\n        emit BalanceAdj(msg.sender, _acct, _val, \\\u0022-\\\u0022);\\n        return true;\\n    }\\n\\n    function transferRoot(address _new) external returns (bool) {\\n        return false;\\n    }\\n}\\n\\n\u0022},\u0022IERC644.sol\u0022:{\u0022content\u0022:\u0022pragma solidity 0.5.8;\\n\\n\\ninterface IERC644 {\\n    function getBalance(address _acct) external view returns(uint);\\n    function incBalance(address _acct, uint _val) external returns(bool);\\n    function decBalance(address _acct, uint _val) external returns(bool);\\n    function getAllowance(address _owner, address _spender) external view returns(uint);\\n    function setApprove(address _sender, address _spender, uint256 _value) external returns(bool);\\n    function decApprove(address _from, address _spender, uint _value) external returns(bool);\\n    function getModule(address _acct) external view returns (bool);\\n    function setModule(address _acct, bool _set) external returns(bool);\\n    function getTotalSupply() external view returns(uint);\\n    function incTotalSupply(uint _val) external returns(bool);\\n    function decTotalSupply(uint _val) external returns(bool);\\n    function transferRoot(address _new) external returns(bool);\\n\\n    event BalanceAdj(address indexed Module, address indexed Account, uint Amount, string Polarity);\\n    event ModuleSet(address indexed Module, bool indexed Set);\\n}\\n\\n\u0022},\u0022Ownable.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.0;\\n\\nimport \\\u0022./Context.sol\\\u0022;\\n/**\\n * @dev Contract module which provides a basic access control mechanism, where\\n * there is an account (an owner) that can be granted exclusive access to\\n * specific functions.\\n *\\n * This module is used through inheritance. It will make available the modifier\\n * \u0060onlyOwner\u0060, which can be applied to your functions to restrict their use to\\n * the owner.\\n */\\ncontract Ownable is Context {\\n    address private _owner;\\n\\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\\n\\n    /**\\n     * @dev Initializes the contract setting the deployer as the initial owner.\\n     */\\n    constructor () internal {\\n        address msgSender = _msgSender();\\n        _owner = msgSender;\\n        emit OwnershipTransferred(address(0), msgSender);\\n    }\\n\\n    /**\\n     * @dev Returns the address of the current owner.\\n     */\\n    function owner() public view returns (address) {\\n        return _owner;\\n    }\\n\\n    /**\\n     * @dev Throws if called by any account other than the owner.\\n     */\\n    modifier onlyOwner() {\\n        require(isOwner(), \\\u0022Ownable: caller is not the owner\\\u0022);\\n        _;\\n    }\\n\\n    /**\\n     * @dev Returns true if the caller is the current owner.\\n     */\\n    function isOwner() public view returns (bool) {\\n        return _msgSender() == _owner;\\n    }\\n\\n    /**\\n     * @dev Leaves the contract without owner. It will not be possible to call\\n     * \u0060onlyOwner\u0060 functions anymore. Can only be called by the current owner.\\n     *\\n     * NOTE: Renouncing ownership will leave the contract without an owner,\\n     * thereby removing any functionality that is only available to the owner.\\n     */\\n    function renounceOwnership() public onlyOwner {\\n        emit OwnershipTransferred(_owner, address(0));\\n        _owner = address(0);\\n    }\\n\\n    /**\\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\\n     * Can only be called by the current owner.\\n     */\\n    function transferOwnership(address newOwner) public onlyOwner {\\n        _transferOwnership(newOwner);\\n    }\\n\\n    /**\\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\\n     */\\n    function _transferOwnership(address newOwner) internal {\\n        require(newOwner != address(0), \\\u0022Ownable: new owner is the zero address\\\u0022);\\n        emit OwnershipTransferred(_owner, newOwner);\\n        _owner = newOwner;\\n    }\\n}\\n\u0022},\u0022SafeGuard.sol\u0022:{\u0022content\u0022:\u0022pragma solidity 0.5.8;\\n\\nimport \\\u0022./Ownable.sol\\\u0022;\\n\\n\\n/**\\n * @title Safe Guard Contract\\n * @author Panos\\n */\\ncontract SafeGuard is Ownable {\\n\\n    event Transaction(address indexed destination, uint value, bytes data);\\n\\n    /**\\n     * @dev Allows owner to execute a transaction.\\n     */\\n    function executeTransaction(address destination, uint value, bytes memory data)\\n    public\\n    onlyOwner\\n    {\\n        require(externalCall(destination, value, data.length, data));\\n        emit Transaction(destination, value, data);\\n    }\\n\\n    /**\\n     * @dev call has been separated into its own function in order to take advantage\\n     *  of the Solidity\\u0027s code generator to produce a loop that copies tx.data into memory.\\n     */\\n    function externalCall(address destination, uint value, uint dataLength, bytes memory data)\\n    private\\n    returns (bool) {\\n        bool result;\\n        assembly { // solhint-disable-line no-inline-assembly\\n        let x := mload(0x40)   // \\\u0022Allocate\\\u0022 memory for output\\n            // (0x40 is where \\\u0022free memory\\\u0022 pointer is stored by convention)\\n            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that\\n            result := call(\\n            sub(gas, 34710), // 34710 is the value that solidity is currently emitting\\n            // It includes callGas (700) \u002B callVeryLow (3, to pay for SUB) \u002B callValueTransferGas (9000) \u002B\\n            // callNewAccountGas (25000, in case the destination address does not exist and needs creating)\\n            destination,\\n            value,\\n            d,\\n            dataLength, // Size of the input (in bytes) - this is what fixes the padding problem\\n            x,\\n            0                  // Output is ignored, therefore the output size is zero\\n            )\\n        }\\n        return result;\\n    }\\n}\\n\\n\u0022},\u0022SafeMath.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.0;\\n\\n/**\\n * @dev Wrappers over Solidity\\u0027s arithmetic operations with added overflow\\n * checks.\\n *\\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\\n * in bugs, because programmers usually assume that an overflow raises an\\n * error, which is the standard behavior in high level programming languages.\\n * \u0060SafeMath\u0060 restores this intuition by reverting the transaction when an\\n * operation overflows.\\n *\\n * Using this library instead of the unchecked operations eliminates an entire\\n * class of bugs, so it\\u0027s recommended to use it always.\\n */\\nlibrary SafeMath {\\n    /**\\n     * @dev Returns the addition of two unsigned integers, reverting on\\n     * overflow.\\n     *\\n     * Counterpart to Solidity\\u0027s \u0060\u002B\u0060 operator.\\n     *\\n     * Requirements:\\n     * - Addition cannot overflow.\\n     */\\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\\n        uint256 c = a \u002B b;\\n        require(c \\u003e= a, \\\u0022SafeMath: addition overflow\\\u0022);\\n\\n        return c;\\n    }\\n\\n    /**\\n     * @dev Returns the subtraction of two unsigned integers, reverting on\\n     * overflow (when the result is negative).\\n     *\\n     * Counterpart to Solidity\\u0027s \u0060-\u0060 operator.\\n     *\\n     * Requirements:\\n     * - Subtraction cannot overflow.\\n     */\\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\\n        return sub(a, b, \\\u0022SafeMath: subtraction overflow\\\u0022);\\n    }\\n\\n    /**\\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\\n     * overflow (when the result is negative).\\n     *\\n     * Counterpart to Solidity\\u0027s \u0060-\u0060 operator.\\n     *\\n     * Requirements:\\n     * - Subtraction cannot overflow.\\n     *\\n     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.\\n     * @dev Get it via \u0060npm install @openzeppelin/contracts@next\u0060.\\n     */\\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\\n        require(b \\u003c= a, errorMessage);\\n        uint256 c = a - b;\\n\\n        return c;\\n    }\\n\\n    /**\\n     * @dev Returns the multiplication of two unsigned integers, reverting on\\n     * overflow.\\n     *\\n     * Counterpart to Solidity\\u0027s \u0060*\u0060 operator.\\n     *\\n     * Requirements:\\n     * - Multiplication cannot overflow.\\n     */\\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\\n        // Gas optimization: this is cheaper than requiring \\u0027a\\u0027 not being zero, but the\\n        // benefit is lost if \\u0027b\\u0027 is also tested.\\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\\n        if (a == 0) {\\n            return 0;\\n        }\\n\\n        uint256 c = a * b;\\n        require(c / a == b, \\\u0022SafeMath: multiplication overflow\\\u0022);\\n\\n        return c;\\n    }\\n\\n    /**\\n     * @dev Returns the integer division of two unsigned integers. Reverts on\\n     * division by zero. The result is rounded towards zero.\\n     *\\n     * Counterpart to Solidity\\u0027s \u0060/\u0060 operator. Note: this function uses a\\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\\n     * uses an invalid opcode to revert (consuming all remaining gas).\\n     *\\n     * Requirements:\\n     * - The divisor cannot be zero.\\n     */\\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\\n        return div(a, b, \\\u0022SafeMath: division by zero\\\u0022);\\n    }\\n\\n    /**\\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\\n     * division by zero. The result is rounded towards zero.\\n     *\\n     * Counterpart to Solidity\\u0027s \u0060/\u0060 operator. Note: this function uses a\\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\\n     * uses an invalid opcode to revert (consuming all remaining gas).\\n     *\\n     * Requirements:\\n     * - The divisor cannot be zero.\\n\\n     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.\\n     * @dev Get it via \u0060npm install @openzeppelin/contracts@next\u0060.\\n     */\\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\\n        // Solidity only automatically asserts when dividing by 0\\n        require(b \\u003e 0, errorMessage);\\n        uint256 c = a / b;\\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\\u0027t hold\\n\\n        return c;\\n    }\\n\\n    /**\\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\\n     * Reverts when dividing by zero.\\n     *\\n     * Counterpart to Solidity\\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\\n     * invalid opcode to revert (consuming all remaining gas).\\n     *\\n     * Requirements:\\n     * - The divisor cannot be zero.\\n     */\\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\\n        return mod(a, b, \\\u0022SafeMath: modulo by zero\\\u0022);\\n    }\\n\\n    /**\\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\\n     * Reverts with custom message when dividing by zero.\\n     *\\n     * Counterpart to Solidity\\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\\n     * invalid opcode to revert (consuming all remaining gas).\\n     *\\n     * Requirements:\\n     * - The divisor cannot be zero.\\n     *\\n     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.\\n     * @dev Get it via \u0060npm install @openzeppelin/contracts@next\u0060.\\n     */\\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\\n        require(b != 0, errorMessage);\\n        return a % b;\\n    }\\n}\\n\u0022}}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getAllowance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_operator\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_tokenHolder\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getRevokedDefaultOperator\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022totalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022balances\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_val\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decTotalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022destination\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022executeTransaction\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_operator\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getDefaultOperator\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022allowed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_acct\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_val\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022incBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_operator\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_tokenHolder\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getAuthorizedOperator\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setApprove\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getDefaultOperators\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022modules\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_acct\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_val\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_acct\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_set\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setModule\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_acct\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getModule\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022move\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_new\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferRoot\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getTotalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_operator\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_tokenHolder\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_status\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setRevokedDefaultOperator\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_val\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022incTotalSupply\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_operator\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_tokenHolder\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_status\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setAuthorizedOperator\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_acct\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_from\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_spender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022decApprove\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_totalSupply\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_initialOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_defaultOperators\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022module\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022polarity\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022BalanceAdj\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022module\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022set\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022ModuleSet\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022destination\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022Transaction\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"CStore","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"00000000000000000000000000000000000000000282b82666abfd3da9000000000000000000000000000000c225251b8738f2ff5376991fa37b44744a07b19b00000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000","Library":"","SwarmSource":"bzzr://2dd35872a32d9bcd22eb8ce622b4bf0decff3fa23c8a712fa4829f82302d4fe0"}]