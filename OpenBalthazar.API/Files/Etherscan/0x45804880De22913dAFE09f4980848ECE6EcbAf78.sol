[{"SourceCode":"// File: contracts/zeppelin/Proxy.sol\r\n\r\npragma solidity 0.4.24;\r\n\r\n/**\r\n * @title Proxy\r\n * @dev Implements delegation of calls to other contracts, with proper\r\n * forwarding of return values and bubbling of failures.\r\n * It defines a fallback function that delegates all calls to the address\r\n * returned by the abstract _implementation() internal function.\r\n */\r\ncontract Proxy {\r\n    /**\r\n     * @dev Fallback function.\r\n     * Implemented entirely in \u0060_fallback\u0060.\r\n     */\r\n    function () payable external {\r\n        _fallback();\r\n    }\r\n\r\n    /**\r\n     * @return The Address of the implementation.\r\n     */\r\n    function _implementation() internal view returns (address);\r\n\r\n    /**\r\n     * @dev Delegates execution to an implementation contract.\r\n     * This is a low level function that doesn\u0027t return to its internal call site.\r\n     * It will return to the external caller whatever the implementation returns.\r\n     * @param implementation Address to delegate.\r\n     */\r\n    function _delegate(address implementation) internal {\r\n        assembly {\r\n        // Copy msg.data. We take full control of memory in this inline assembly\r\n        // block because it will not return to Solidity code. We overwrite the\r\n        // Solidity scratch pad at memory position 0.\r\n            calldatacopy(0, 0, calldatasize)\r\n\r\n        // Call the implementation.\r\n        // out and outsize are 0 because we don\u0027t know the size yet.\r\n            let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)\r\n\r\n        // Copy the returned data.\r\n            returndatacopy(0, 0, returndatasize)\r\n\r\n            switch result\r\n            // delegatecall returns 0 on error.\r\n            case 0 { revert(0, returndatasize) }\r\n            default { return(0, returndatasize) }\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Function that is run as the first thing in the fallback function.\r\n     * Can be redefined in derived contracts to add functionality.\r\n     * Redefinitions must call super._willFallback().\r\n     */\r\n    function _willFallback() internal {\r\n    }\r\n\r\n    /**\r\n     * @dev fallback implementation.\r\n     * Extracted to enable manual triggering.\r\n     */\r\n    function _fallback() internal {\r\n        _willFallback();\r\n        _delegate(_implementation());\r\n    }\r\n}\r\n\r\n// File: contracts/zeppelin/AddressUtils.sol\r\n\r\npragma solidity 0.4.24;\r\n\r\n\r\n/**\r\n * Utility library of inline functions on addresses\r\n */\r\nlibrary AddressUtils {\r\n\r\n    /**\r\n     * Returns whether the target address is a contract\r\n     * @dev This function will return false if invoked during the constructor of a contract,\r\n     * as the code is not actually created until after the constructor finishes.\r\n     * @param addr address to check\r\n     * @return whether the target address is a contract\r\n     */\r\n    function isContract(address addr) internal view returns (bool) {\r\n        uint256 size;\r\n        // XXX Currently there is no better way to check if there is a contract in an address\r\n        // than to check the size of the code at that address.\r\n        // See https://ethereum.stackexchange.com/a/14016/36603\r\n        // for more details about how this works.\r\n        // TODO Check this again before the Serenity release, because all addresses will be\r\n        // contracts then.\r\n        // solium-disable-next-line security/no-inline-assembly\r\n        assembly { size := extcodesize(addr) }\r\n        return size \u003E 0;\r\n    }\r\n\r\n}\r\n\r\n// File: contracts/zeppelin/UpgradeabilityProxy.sol\r\n\r\npragma solidity 0.4.24;\r\n\r\n\r\n\r\n/**\r\n * @title UpgradeabilityProxy\r\n * @dev This contract implements a proxy that allows to change the\r\n * implementation address to which it will delegate.\r\n * Such a change is called an implementation upgrade.\r\n */\r\ncontract UpgradeabilityProxy is Proxy {\r\n    /**\r\n     * @dev Emitted when the implementation is upgraded.\r\n     * @param implementation Address of the new implementation.\r\n     */\r\n    event Upgraded(address implementation);\r\n\r\n    /**\r\n     * @dev Storage slot with the address of the current implementation.\r\n     * This is the keccak-256 hash of \u0022org.zeppelinos.proxy.implementation\u0022, and is\r\n     * validated in the constructor.\r\n     */\r\n    bytes32 private constant IMPLEMENTATION_SLOT = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;\r\n\r\n    /**\r\n     * @dev Contract constructor.\r\n     * @param _implementation Address of the initial implementation.\r\n     */\r\n    constructor(address _implementation) public {\r\n        assert(IMPLEMENTATION_SLOT == keccak256(\u0022org.zeppelinos.proxy.implementation\u0022));\r\n\r\n        _setImplementation(_implementation);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the current implementation.\r\n     * @return Address of the current implementation\r\n     */\r\n    function _implementation() internal view returns (address impl) {\r\n        bytes32 slot = IMPLEMENTATION_SLOT;\r\n        assembly {\r\n            impl := sload(slot)\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Upgrades the proxy to a new implementation.\r\n     * @param newImplementation Address of the new implementation.\r\n     */\r\n    function _upgradeTo(address newImplementation) internal {\r\n        _setImplementation(newImplementation);\r\n        emit Upgraded(newImplementation);\r\n    }\r\n\r\n    /**\r\n     * @dev Sets the implementation address of the proxy.\r\n     * @param newImplementation Address of the new implementation.\r\n     */\r\n    function _setImplementation(address newImplementation) private {\r\n        require(AddressUtils.isContract(newImplementation), \u0022Cannot set a proxy implementation to a non-contract address\u0022);\r\n\r\n        bytes32 slot = IMPLEMENTATION_SLOT;\r\n\r\n        assembly {\r\n            sstore(slot, newImplementation)\r\n        }\r\n    }\r\n}\r\n\r\n// File: contracts/zeppelin/AdminUpgradeabilityProxy.sol\r\n\r\npragma solidity 0.4.24;\r\n\r\n\r\n/**\r\n * @title AdminUpgradeabilityProxy\r\n * @dev This contract combines an upgradeability proxy with an authorization\r\n * mechanism for administrative tasks.\r\n * All external functions in this contract must be guarded by the\r\n * \u0060ifAdmin\u0060 modifier. See ethereum/solidity#3864 for a Solidity\r\n * feature proposal that would enable this to be done automatically.\r\n */\r\ncontract AdminUpgradeabilityProxy is UpgradeabilityProxy {\r\n    /**\r\n     * @dev Emitted when the administration has been transferred.\r\n     * @param previousAdmin Address of the previous admin.\r\n     * @param newAdmin Address of the new admin.\r\n     */\r\n    event AdminChanged(address previousAdmin, address newAdmin);\r\n\r\n    /**\r\n     * @dev Storage slot with the admin of the contract.\r\n     * This is the keccak-256 hash of \u0022org.zeppelinos.proxy.admin\u0022, and is\r\n     * validated in the constructor.\r\n     */\r\n    bytes32 private constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;\r\n\r\n    /**\r\n     * @dev Modifier to check whether the \u0060msg.sender\u0060 is the admin.\r\n     * If it is, it will run the function. Otherwise, it will delegate the call\r\n     * to the implementation.\r\n     */\r\n    modifier ifAdmin() {\r\n        if (msg.sender == _admin()) {\r\n            _;\r\n        } else {\r\n            _fallback();\r\n        }\r\n    }\r\n\r\n    /**\r\n     * Contract constructor.\r\n     * It sets the \u0060msg.sender\u0060 as the proxy administrator.\r\n     * @param _implementation address of the initial implementation.\r\n     */\r\n    constructor(address _implementation) UpgradeabilityProxy(_implementation) public {\r\n        assert(ADMIN_SLOT == keccak256(\u0022org.zeppelinos.proxy.admin\u0022));\r\n\r\n        _setAdmin(msg.sender);\r\n    }\r\n\r\n    /**\r\n     * @return The address of the proxy admin.\r\n     */\r\n    function admin() external view ifAdmin returns (address) {\r\n        return _admin();\r\n    }\r\n\r\n    /**\r\n     * @return The address of the implementation.\r\n     */\r\n    function implementation() external view ifAdmin returns (address) {\r\n        return _implementation();\r\n    }\r\n\r\n    /**\r\n     * @dev Changes the admin of the proxy.\r\n     * Only the current admin can call this function.\r\n     * @param newAdmin Address to transfer proxy administration to.\r\n     */\r\n    function changeAdmin(address newAdmin) external ifAdmin {\r\n        require(newAdmin != address(0), \u0022Cannot change the admin of a proxy to the zero address\u0022);\r\n        emit AdminChanged(_admin(), newAdmin);\r\n        _setAdmin(newAdmin);\r\n    }\r\n\r\n    /**\r\n     * @dev Upgrade the backing implementation of the proxy.\r\n     * Only the admin can call this function.\r\n     * @param newImplementation Address of the new implementation.\r\n     */\r\n    function upgradeTo(address newImplementation) external ifAdmin {\r\n        _upgradeTo(newImplementation);\r\n    }\r\n\r\n    /**\r\n     * @dev Upgrade the backing implementation of the proxy and call a function\r\n     * on the new implementation.\r\n     * This is useful to initialize the proxied contract.\r\n     * @param newImplementation Address of the new implementation.\r\n     * @param data Data to send as msg.data in the low level call.\r\n     * It should include the signature and the parameters of the function to be\r\n     * called, as described in\r\n     * https://solidity.readthedocs.io/en/develop/abi-spec.html#function-selector-and-argument-encoding.\r\n     */\r\n    function upgradeToAndCall(address newImplementation, bytes data) payable external ifAdmin {\r\n        _upgradeTo(newImplementation);\r\n        require(address(this).call.value(msg.value)(data));\r\n    }\r\n\r\n    /**\r\n     * @return The admin slot.\r\n     */\r\n    function _admin() internal view returns (address adm) {\r\n        bytes32 slot = ADMIN_SLOT;\r\n        assembly {\r\n            adm := sload(slot)\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Sets the address of the proxy admin.\r\n     * @param newAdmin Address of the new proxy admin.\r\n     */\r\n    function _setAdmin(address newAdmin) internal {\r\n        bytes32 slot = ADMIN_SLOT;\r\n\r\n        assembly {\r\n            sstore(slot, newAdmin)\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Only fall back when the sender is not the admin.\r\n     */\r\n    function _willFallback() internal {\r\n        require(msg.sender != _admin(), \u0022Cannot call fallback function from the proxy admin\u0022);\r\n        super._willFallback();\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newImplementation\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022upgradeTo\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newImplementation\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022upgradeToAndCall\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022implementation\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newAdmin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022changeAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022admin\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_implementation\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022previousAdmin\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022newAdmin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022AdminChanged\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022implementation\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Upgraded\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"AdminUpgradeabilityProxy","CompilerVersion":"v0.4.24\u002Bcommit.e67f0147","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"00000000000000000000000074271f2282ed7ee35c166122a60c9830354be42a","Library":"","SwarmSource":"bzzr://453a6dd044ef35f7fee24140bd151a3917d2e3d954dc2abf305cf1a592e8ebb9"}]