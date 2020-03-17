[{"SourceCode":"{\u0022Ownable.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.2;\\n\\n/**\\n * @title Ownable\\n * @dev The Ownable contract has an owner address, and provides basic authorization control\\n * functions, this simplifies the implementation of \\\u0022user permissions\\\u0022.\\n */\\ncontract Ownable {\\n    address private _owner;\\n\\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\\n\\n    /**\\n     * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\\n     * account.\\n     */\\n    constructor () internal {\\n        _owner = msg.sender;\\n        emit OwnershipTransferred(address(0), _owner);\\n    }\\n\\n    /**\\n     * @return the address of the owner.\\n     */\\n    function owner() public view returns (address) {\\n        return _owner;\\n    }\\n\\n    /**\\n     * @dev Throws if called by any account other than the owner.\\n     */\\n    modifier onlyOwner() {\\n        require(isOwner());\\n        _;\\n    }\\n\\n    /**\\n     * @return true if \u0060msg.sender\u0060 is the owner of the contract.\\n     */\\n    function isOwner() public view returns (bool) {\\n        return msg.sender == _owner;\\n    }\\n\\n    /**\\n     * @dev Allows the current owner to relinquish control of the contract.\\n     * It will not be possible to call the functions with the \u0060onlyOwner\u0060\\n     * modifier anymore.\\n     * @notice Renouncing ownership will leave the contract without an owner,\\n     * thereby removing any functionality that is only available to the owner.\\n     */\\n    function renounceOwnership() public onlyOwner {\\n        emit OwnershipTransferred(_owner, address(0));\\n        _owner = address(0);\\n    }\\n\\n    /**\\n     * @dev Allows the current owner to transfer control of the contract to a newOwner.\\n     * @param newOwner The address to transfer ownership to.\\n     */\\n    function transferOwnership(address newOwner) public onlyOwner {\\n        _transferOwnership(newOwner);\\n    }\\n\\n    /**\\n     * @dev Transfers control of the contract to a newOwner.\\n     * @param newOwner The address to transfer ownership to.\\n     */\\n    function _transferOwnership(address newOwner) internal {\\n        require(newOwner != address(0));\\n        emit OwnershipTransferred(_owner, newOwner);\\n        _owner = newOwner;\\n    }\\n}\\n\u0022},\u0022Roles.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.2;\\n\\n/**\\n * @title Roles\\n * @dev Library for managing addresses assigned to a Role.\\n */\\nlibrary Roles {\\n    struct Role {\\n        mapping (address =\\u003e bool) bearer;\\n    }\\n\\n    /**\\n     * @dev give an account access to this role\\n     */\\n    function add(Role storage role, address account) internal {\\n        require(account != address(0));\\n        require(!has(role, account));\\n\\n        role.bearer[account] = true;\\n    }\\n\\n    /**\\n     * @dev remove an account\\u0027s access to this role\\n     */\\n    function remove(Role storage role, address account) internal {\\n        require(account != address(0));\\n        require(has(role, account));\\n\\n        role.bearer[account] = false;\\n    }\\n\\n    /**\\n     * @dev check if an account has this role\\n     * @return bool\\n     */\\n    function has(Role storage role, address account) internal view returns (bool) {\\n        require(account != address(0));\\n        return role.bearer[account];\\n    }\\n}\\n\u0022},\u0022Whitelist.sol\u0022:{\u0022content\u0022:\u0022pragma solidity ^0.5.8;\\n\\nimport \\\u0022./Roles.sol\\\u0022;\\nimport \\\u0022./Ownable.sol\\\u0022;\\n\\ncontract Whitelist is Ownable {\\n  using Roles for Roles.Role;\\n\\n  Roles.Role private whitelist;\\n\\n  event WhitelistedAddressAdded(address indexed _address);\\n\\n  function isWhitelisted(address _address) public view returns (bool) {\\n    return whitelist.has(_address);\\n  }\\n\\n  function addAddressToWhitelist(address _address) external onlyOwner {\\n    _addAddressToWhitelist(_address);\\n  }\\n\\n  function addAddressesToWhitelist(address[] calldata _addresses) external onlyOwner {\\n    for (uint i = 0; i \\u003c _addresses.length; i\u002B\u002B) {\\n      _addAddressToWhitelist(_addresses[i]);\\n    }\\n  }\\n\\n  function _addAddressToWhitelist(address _address) internal {\\n    whitelist.add(_address);\\n    emit WhitelistedAddressAdded(_address);\\n  }\\n}\\n\u0022}}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isWhitelisted\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addAddressToWhitelist\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_addresses\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022addAddressesToWhitelist\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WhitelistedAddressAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Whitelist","CompilerVersion":"v0.5.9\u002Bcommit.e560f70d","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://012d4298aa7e9aa8252e410beb986a95ce11260fd2ce85855bd982988f872cd0"}]