[{"SourceCode":"pragma solidity ^0.5.4;\r\n\r\n/**\r\n * ERC20 contract interface.\r\n */\r\ncontract ERC20 {\r\n    function totalSupply() public view returns (uint);\r\n    function decimals() public view returns (uint);\r\n    function balanceOf(address tokenOwner) public view returns (uint balance);\r\n    function allowance(address tokenOwner, address spender) public view returns (uint remaining);\r\n    function transfer(address to, uint tokens) public returns (bool success);\r\n    function approve(address spender, uint tokens) public returns (bool success);\r\n    function transferFrom(address from, address to, uint tokens) public returns (bool success);\r\n}\r\n\r\n/**\r\n * @title Module\r\n * @dev Interface for a module. \r\n * A module MUST implement the addModule() method to ensure that a wallet with at least one module\r\n * can never end up in a \u0022frozen\u0022 state.\r\n * @author Julien Niset - \u003Cjulien@argent.xyz\u003E\r\n */\r\ninterface Module {\r\n    function init(BaseWallet _wallet) external;\r\n    function addModule(BaseWallet _wallet, Module _module) external;\r\n    function recoverToken(address _token) external;\r\n}\r\n\r\n/**\r\n * @title BaseWallet\r\n * @dev Simple modular wallet that authorises modules to call its invoke() method.\r\n * Based on https://gist.github.com/Arachnid/a619d31f6d32757a4328a428286da186 by \r\n * @author Julien Niset - \u003Cjulien@argent.xyz\u003E\r\n */\r\ncontract BaseWallet {\r\n    address public implementation;\r\n    address public owner;\r\n    mapping (address =\u003E bool) public authorised;\r\n    mapping (bytes4 =\u003E address) public enabled;\r\n    uint public modules;\r\n    function init(address _owner, address[] calldata _modules) external;\r\n    function authoriseModule(address _module, bool _value) external;\r\n    function enableStaticCall(address _module, bytes4 _method) external;\r\n    function setOwner(address _newOwner) external;\r\n    function invoke(address _target, uint _value, bytes calldata _data) external returns (bytes memory _result);\r\n}\r\n\r\n/**\r\n * @title ModuleRegistry\r\n * @dev Registry of authorised modules. \r\n * Modules must be registered before they can be authorised on a wallet.\r\n * @author Julien Niset - \u003Cjulien@argent.xyz\u003E\r\n */\r\ncontract ModuleRegistry {\r\n    function registerModule(address _module, bytes32 _name) external;\r\n    function deregisterModule(address _module) external;\r\n    function registerUpgrader(address _upgrader, bytes32 _name) external;\r\n    function deregisterUpgrader(address _upgrader) external;\r\n    function recoverToken(address _token) external;\r\n    function moduleInfo(address _module) external view returns (bytes32);\r\n    function upgraderInfo(address _upgrader) external view returns (bytes32);\r\n    function isRegisteredModule(address _module) external view returns (bool);\r\n    function isRegisteredModule(address[] calldata _modules) external view returns (bool);\r\n    function isRegisteredUpgrader(address _upgrader) external view returns (bool);\r\n}\r\n\r\ncontract TokenPriceProvider {\r\n    mapping(address =\u003E uint256) public cachedPrices;\r\n    function setPrice(ERC20 _token, uint256 _price) public;\r\n    function setPriceForTokenList(ERC20[] calldata _tokens, uint256[] calldata _prices) external;\r\n    function getEtherValue(uint256 _amount, address _token) external view returns (uint256);\r\n}\r\n\r\n/**\r\n * @title GuardianStorage\r\n * @dev Contract storing the state of wallets related to guardians and lock.\r\n * The contract only defines basic setters and getters with no logic. Only modules authorised\r\n * for a wallet can modify its state.\r\n * @author Julien Niset - \u003Cjulien@argent.xyz\u003E\r\n * @author Olivier Van Den Biggelaar - \u003Colivier@argent.xyz\u003E\r\n */\r\ncontract GuardianStorage {\r\n    function addGuardian(BaseWallet _wallet, address _guardian) external;\r\n    function revokeGuardian(BaseWallet _wallet, address _guardian) external;\r\n    function guardianCount(BaseWallet _wallet) external view returns (uint256);\r\n    function getGuardians(BaseWallet _wallet) external view returns (address[] memory);\r\n    function isGuardian(BaseWallet _wallet, address _guardian) external view returns (bool);\r\n    function setLock(BaseWallet _wallet, uint256 _releaseAfter) external;\r\n    function isLocked(BaseWallet _wallet) external view returns (bool);\r\n    function getLock(BaseWallet _wallet) external view returns (uint256);\r\n    function getLocker(BaseWallet _wallet) external view returns (address);\r\n}\r\n\r\n/**\r\n * @title TransferStorage\r\n * @dev Contract storing the state of wallets related to transfers (limit and whitelist).\r\n * The contract only defines basic setters and getters with no logic. Only modules authorised\r\n * for a wallet can modify its state.\r\n * @author Julien Niset - \u003Cjulien@argent.xyz\u003E\r\n */\r\ncontract TransferStorage {\r\n    function setWhitelist(BaseWallet _wallet, address _target, uint256 _value) external;\r\n    function getWhitelist(BaseWallet _wallet, address _target) external view returns (uint256);\r\n}\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n\r\n    /**\r\n    * @dev Multiplies two numbers, reverts on overflow.\r\n    */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.\r\n    */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003E 0); // Solidity only automatically asserts when dividing by 0\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n    */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Adds two numbers, reverts on overflow.\r\n    */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),\r\n    * reverts when dividing by zero.\r\n    */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n\r\n    /**\r\n    * @dev Returns ceil(a / b).\r\n    */\r\n    function ceil(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a / b;\r\n        if(a % b == 0) {\r\n            return c;\r\n        }\r\n        else {\r\n            return c \u002B 1;\r\n        }\r\n    }\r\n}\r\n\r\nlibrary GuardianUtils {\r\n\r\n    /**\r\n    * @dev Checks if an address is an account guardian or an account authorised to sign on behalf of a smart-contract guardian\r\n    * given a list of guardians.\r\n    * @param _guardians the list of guardians\r\n    * @param _guardian the address to test\r\n    * @return true and the list of guardians minus the found guardian upon success, false and the original list of guardians if not found.\r\n    */\r\n    function isGuardian(address[] memory _guardians, address _guardian) internal view returns (bool, address[] memory) {\r\n        if(_guardians.length == 0 || _guardian == address(0)) {\r\n            return (false, _guardians);\r\n        }\r\n        bool isFound = false;\r\n        address[] memory updatedGuardians = new address[](_guardians.length - 1);\r\n        uint256 index = 0;\r\n        for (uint256 i = 0; i \u003C _guardians.length; i\u002B\u002B) {\r\n            if(!isFound) {\r\n                // check if _guardian is an account guardian\r\n                if(_guardian == _guardians[i]) {\r\n                    isFound = true;\r\n                    continue;\r\n                }\r\n                // check if _guardian is the owner of a smart contract guardian\r\n                if(isContract(_guardians[i]) \u0026\u0026 isGuardianOwner(_guardians[i], _guardian)) {\r\n                    isFound = true;\r\n                    continue;\r\n                }\r\n            }\r\n            if(index \u003C updatedGuardians.length) {\r\n                updatedGuardians[index] = _guardians[i];\r\n                index\u002B\u002B;\r\n            }\r\n        }\r\n        return isFound ? (true, updatedGuardians) : (false, _guardians);\r\n    }\r\n\r\n   /**\r\n    * @dev Checks if an address is a contract.\r\n    * @param _addr The address.\r\n    */\r\n    function isContract(address _addr) internal view returns (bool) {\r\n        uint32 size;\r\n        // solium-disable-next-line security/no-inline-assembly\r\n        assembly {\r\n            size := extcodesize(_addr)\r\n        }\r\n        return (size \u003E 0);\r\n    }\r\n\r\n    /**\r\n    * @dev Checks if an address is the owner of a guardian contract. \r\n    * The method does not revert if the call to the owner() method consumes more then 5000 gas. \r\n    * @param _guardian The guardian contract\r\n    * @param _owner The owner to verify.\r\n    */\r\n    function isGuardianOwner(address _guardian, address _owner) internal view returns (bool) {\r\n        address owner = address(0);\r\n        bytes4 sig = bytes4(keccak256(\u0022owner()\u0022));\r\n        // solium-disable-next-line security/no-inline-assembly\r\n        assembly {\r\n            let ptr := mload(0x40)\r\n            mstore(ptr,sig)\r\n            let result := staticcall(5000, _guardian, ptr, 0x20, ptr, 0x20)\r\n            if eq(result, 1) {\r\n                owner := mload(ptr)\r\n            }\r\n        }\r\n        return owner == _owner;\r\n    }\r\n} \r\n\r\n/**\r\n * @title BaseModule\r\n * @dev Basic module that contains some methods common to all modules.\r\n * @author Julien Niset - \u003Cjulien@argent.im\u003E\r\n */\r\ncontract BaseModule is Module {\r\n\r\n    // Empty calldata\r\n    bytes constant internal EMPTY_BYTES = \u0022\u0022;\r\n\r\n    // The adddress of the module registry.\r\n    ModuleRegistry internal registry;\r\n    // The address of the Guardian storage\r\n    GuardianStorage internal guardianStorage;\r\n\r\n    /**\r\n     * @dev Throws if the wallet is locked.\r\n     */\r\n    modifier onlyWhenUnlocked(BaseWallet _wallet) {\r\n        // solium-disable-next-line security/no-block-members\r\n        require(!guardianStorage.isLocked(_wallet), \u0022BM: wallet must be unlocked\u0022);\r\n        _;\r\n    }\r\n\r\n    event ModuleCreated(bytes32 name);\r\n    event ModuleInitialised(address wallet);\r\n\r\n    constructor(ModuleRegistry _registry, GuardianStorage _guardianStorage, bytes32 _name) public {\r\n        registry = _registry;\r\n        guardianStorage = _guardianStorage;\r\n        emit ModuleCreated(_name);\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if the sender is not the target wallet of the call.\r\n     */\r\n    modifier onlyWallet(BaseWallet _wallet) {\r\n        require(msg.sender == address(_wallet), \u0022BM: caller must be wallet\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if the sender is not the owner of the target wallet or the module itself.\r\n     */\r\n    modifier onlyWalletOwner(BaseWallet _wallet) {\r\n        require(msg.sender == address(this) || isOwner(_wallet, msg.sender), \u0022BM: must be an owner for the wallet\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if the sender is not the owner of the target wallet.\r\n     */\r\n    modifier strictOnlyWalletOwner(BaseWallet _wallet) {\r\n        require(isOwner(_wallet, msg.sender), \u0022BM: msg.sender must be an owner for the wallet\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Inits the module for a wallet by logging an event.\r\n     * The method can only be called by the wallet itself.\r\n     * @param _wallet The wallet.\r\n     */\r\n    function init(BaseWallet _wallet) public onlyWallet(_wallet) {\r\n        emit ModuleInitialised(address(_wallet));\r\n    }\r\n\r\n    /**\r\n     * @dev Adds a module to a wallet. First checks that the module is registered.\r\n     * @param _wallet The target wallet.\r\n     * @param _module The modules to authorise.\r\n     */\r\n    function addModule(BaseWallet _wallet, Module _module) external strictOnlyWalletOwner(_wallet) {\r\n        require(registry.isRegisteredModule(address(_module)), \u0022BM: module is not registered\u0022);\r\n        _wallet.authoriseModule(address(_module), true);\r\n    }\r\n\r\n    /**\r\n    * @dev Utility method enbaling anyone to recover ERC20 token sent to the\r\n    * module by mistake and transfer them to the Module Registry. \r\n    * @param _token The token to recover.\r\n    */\r\n    function recoverToken(address _token) external {\r\n        uint total = ERC20(_token).balanceOf(address(this));\r\n        ERC20(_token).transfer(address(registry), total);\r\n    }\r\n\r\n    /**\r\n     * @dev Helper method to check if an address is the owner of a target wallet.\r\n     * @param _wallet The target wallet.\r\n     * @param _addr The address.\r\n     */\r\n    function isOwner(BaseWallet _wallet, address _addr) internal view returns (bool) {\r\n        return _wallet.owner() == _addr;\r\n    }\r\n\r\n    /**\r\n     * @dev Helper method to invoke a wallet.\r\n     * @param _wallet The target wallet.\r\n     * @param _to The target address for the transaction.\r\n     * @param _value The value of the transaction.\r\n     * @param _data The data of the transaction.\r\n     */\r\n    function invokeWallet(address _wallet, address _to, uint256 _value, bytes memory _data) internal returns (bytes memory _res) {\r\n        bool success;\r\n        // solium-disable-next-line security/no-call-value\r\n        (success, _res) = _wallet.call(abi.encodeWithSignature(\u0022invoke(address,uint256,bytes)\u0022, _to, _value, _data));\r\n        if(success \u0026\u0026 _res.length \u003E 0) { //_res is empty if _wallet is an \u0022old\u0022 BaseWallet that can\u0027t return output values\r\n            (_res) = abi.decode(_res, (bytes));\r\n        } else if (_res.length \u003E 0) {\r\n            // solium-disable-next-line security/no-inline-assembly\r\n            assembly {\r\n                returndatacopy(0, 0, returndatasize)\r\n                revert(0, returndatasize)\r\n            }\r\n        } else if(!success) {\r\n            revert(\u0022BM: wallet invoke reverted\u0022);\r\n        }\r\n    }\r\n}\r\n\r\n/**\r\n * @title RelayerModule\r\n * @dev Base module containing logic to execute transactions signed by eth-less accounts and sent by a relayer.\r\n * @author Julien Niset - \u003Cjulien@argent.im\u003E\r\n */\r\ncontract RelayerModule is BaseModule {\r\n\r\n    uint256 constant internal BLOCKBOUND = 10000;\r\n\r\n    mapping (address =\u003E RelayerConfig) public relayer;\r\n\r\n    struct RelayerConfig {\r\n        uint256 nonce;\r\n        mapping (bytes32 =\u003E bool) executedTx;\r\n    }\r\n\r\n    event TransactionExecuted(address indexed wallet, bool indexed success, bytes32 signedHash);\r\n\r\n    /**\r\n     * @dev Throws if the call did not go through the execute() method.\r\n     */\r\n    modifier onlyExecute {\r\n        require(msg.sender == address(this), \u0022RM: must be called via execute()\u0022);\r\n        _;\r\n    }\r\n\r\n    /* ***************** Abstract method ************************* */\r\n\r\n    /**\r\n    * @dev Gets the number of valid signatures that must be provided to execute a\r\n    * specific relayed transaction.\r\n    * @param _wallet The target wallet.\r\n    * @param _data The data of the relayed transaction.\r\n    * @return The number of required signatures.\r\n    */\r\n    function getRequiredSignatures(BaseWallet _wallet, bytes memory _data) internal view returns (uint256);\r\n\r\n    /**\r\n    * @dev Validates the signatures provided with a relayed transaction.\r\n    * The method MUST throw if one or more signatures are not valid.\r\n    * @param _wallet The target wallet.\r\n    * @param _data The data of the relayed transaction.\r\n    * @param _signHash The signed hash representing the relayed transaction.\r\n    * @param _signatures The signatures as a concatenated byte array.\r\n    */\r\n    function validateSignatures(BaseWallet _wallet, bytes memory _data, bytes32 _signHash, bytes memory _signatures) internal view returns (bool);\r\n\r\n    /* ************************************************************ */\r\n\r\n    /**\r\n    * @dev Executes a relayed transaction.\r\n    * @param _wallet The target wallet.\r\n    * @param _data The data for the relayed transaction\r\n    * @param _nonce The nonce used to prevent replay attacks.\r\n    * @param _signatures The signatures as a concatenated byte array.\r\n    * @param _gasPrice The gas price to use for the gas refund.\r\n    * @param _gasLimit The gas limit to use for the gas refund.\r\n    */\r\n    function execute(\r\n        BaseWallet _wallet,\r\n        bytes calldata _data,\r\n        uint256 _nonce,\r\n        bytes calldata _signatures,\r\n        uint256 _gasPrice,\r\n        uint256 _gasLimit\r\n    )\r\n        external\r\n        returns (bool success)\r\n    {\r\n        uint startGas = gasleft();\r\n        bytes32 signHash = getSignHash(address(this), address(_wallet), 0, _data, _nonce, _gasPrice, _gasLimit);\r\n        require(checkAndUpdateUniqueness(_wallet, _nonce, signHash), \u0022RM: Duplicate request\u0022);\r\n        require(verifyData(address(_wallet), _data), \u0022RM: the wallet authorized is different then the target of the relayed data\u0022);\r\n        uint256 requiredSignatures = getRequiredSignatures(_wallet, _data);\r\n        if((requiredSignatures * 65) == _signatures.length) {\r\n            if(verifyRefund(_wallet, _gasLimit, _gasPrice, requiredSignatures)) {\r\n                if(requiredSignatures == 0 || validateSignatures(_wallet, _data, signHash, _signatures)) {\r\n                    // solium-disable-next-line security/no-call-value\r\n                    (success,) = address(this).call(_data);\r\n                    refund(_wallet, startGas - gasleft(), _gasPrice, _gasLimit, requiredSignatures, msg.sender);\r\n                }\r\n            }\r\n        }\r\n        emit TransactionExecuted(address(_wallet), success, signHash);\r\n    }\r\n\r\n    /**\r\n    * @dev Gets the current nonce for a wallet.\r\n    * @param _wallet The target wallet.\r\n    */\r\n    function getNonce(BaseWallet _wallet) external view returns (uint256 nonce) {\r\n        return relayer[address(_wallet)].nonce;\r\n    }\r\n\r\n    /**\r\n    * @dev Generates the signed hash of a relayed transaction according to ERC 1077.\r\n    * @param _from The starting address for the relayed transaction (should be the module)\r\n    * @param _to The destination address for the relayed transaction (should be the wallet)\r\n    * @param _value The value for the relayed transaction\r\n    * @param _data The data for the relayed transaction\r\n    * @param _nonce The nonce used to prevent replay attacks.\r\n    * @param _gasPrice The gas price to use for the gas refund.\r\n    * @param _gasLimit The gas limit to use for the gas refund.\r\n    */\r\n    function getSignHash(\r\n        address _from,\r\n        address _to,\r\n        uint256 _value,\r\n        bytes memory _data,\r\n        uint256 _nonce,\r\n        uint256 _gasPrice,\r\n        uint256 _gasLimit\r\n    )\r\n        internal\r\n        pure\r\n        returns (bytes32)\r\n    {\r\n        return keccak256(\r\n            abi.encodePacked(\r\n                \u0022\\x19Ethereum Signed Message:\\n32\u0022,\r\n                keccak256(abi.encodePacked(byte(0x19), byte(0), _from, _to, _value, _data, _nonce, _gasPrice, _gasLimit))\r\n        ));\r\n    }\r\n\r\n    /**\r\n    * @dev Checks if the relayed transaction is unique.\r\n    * @param _wallet The target wallet.\r\n    * @param _nonce The nonce\r\n    * @param _signHash The signed hash of the transaction\r\n    */\r\n    function checkAndUpdateUniqueness(BaseWallet _wallet, uint256 _nonce, bytes32 _signHash) internal returns (bool) {\r\n        if(relayer[address(_wallet)].executedTx[_signHash] == true) {\r\n            return false;\r\n        }\r\n        relayer[address(_wallet)].executedTx[_signHash] = true;\r\n        return true;\r\n    }\r\n\r\n    /**\r\n    * @dev Checks that a nonce has the correct format and is valid.\r\n    * It must be constructed as nonce = {block number}{timestamp} where each component is 16 bytes.\r\n    * @param _wallet The target wallet.\r\n    * @param _nonce The nonce\r\n    */\r\n    function checkAndUpdateNonce(BaseWallet _wallet, uint256 _nonce) internal returns (bool) {\r\n        if(_nonce \u003C= relayer[address(_wallet)].nonce) {\r\n            return false;\r\n        }\r\n        uint256 nonceBlock = (_nonce \u0026 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000) \u003E\u003E 128;\r\n        if(nonceBlock \u003E block.number \u002B BLOCKBOUND) {\r\n            return false;\r\n        }\r\n        relayer[address(_wallet)].nonce = _nonce;\r\n        return true;\r\n    }\r\n\r\n    /**\r\n    * @dev Recovers the signer at a given position from a list of concatenated signatures.\r\n    * @param _signedHash The signed hash\r\n    * @param _signatures The concatenated signatures.\r\n    * @param _index The index of the signature to recover.\r\n    */\r\n    function recoverSigner(bytes32 _signedHash, bytes memory _signatures, uint _index) internal pure returns (address) {\r\n        uint8 v;\r\n        bytes32 r;\r\n        bytes32 s;\r\n        // we jump 32 (0x20) as the first slot of bytes contains the length\r\n        // we jump 65 (0x41) per signature\r\n        // for v we load 32 bytes ending with v (the first 31 come from s) then apply a mask\r\n        // solium-disable-next-line security/no-inline-assembly\r\n        assembly {\r\n            r := mload(add(_signatures, add(0x20,mul(0x41,_index))))\r\n            s := mload(add(_signatures, add(0x40,mul(0x41,_index))))\r\n            v := and(mload(add(_signatures, add(0x41,mul(0x41,_index)))), 0xff)\r\n        }\r\n        require(v == 27 || v == 28);\r\n        return ecrecover(_signedHash, v, r, s);\r\n    }\r\n\r\n    /**\r\n    * @dev Refunds the gas used to the Relayer. \r\n    * For security reasons the default behavior is to not refund calls with 0 or 1 signatures. \r\n    * @param _wallet The target wallet.\r\n    * @param _gasUsed The gas used.\r\n    * @param _gasPrice The gas price for the refund.\r\n    * @param _gasLimit The gas limit for the refund.\r\n    * @param _signatures The number of signatures used in the call.\r\n    * @param _relayer The address of the Relayer.\r\n    */\r\n    function refund(BaseWallet _wallet, uint _gasUsed, uint _gasPrice, uint _gasLimit, uint _signatures, address _relayer) internal {\r\n        uint256 amount = 29292 \u002B _gasUsed; // 21000 (transaction) \u002B 7620 (execution of refund) \u002B 672 to log the event \u002B _gasUsed\r\n        // only refund if gas price not null, more than 1 signatures, gas less than gasLimit\r\n        if(_gasPrice \u003E 0 \u0026\u0026 _signatures \u003E 1 \u0026\u0026 amount \u003C= _gasLimit) {\r\n            if(_gasPrice \u003E tx.gasprice) {\r\n                amount = amount * tx.gasprice;\r\n            }\r\n            else {\r\n                amount = amount * _gasPrice;\r\n            }\r\n            invokeWallet(address(_wallet), _relayer, amount, EMPTY_BYTES);\r\n        }\r\n    }\r\n\r\n    /**\r\n    * @dev Returns false if the refund is expected to fail.\r\n    * @param _wallet The target wallet.\r\n    * @param _gasUsed The expected gas used.\r\n    * @param _gasPrice The expected gas price for the refund.\r\n    */\r\n    function verifyRefund(BaseWallet _wallet, uint _gasUsed, uint _gasPrice, uint _signatures) internal view returns (bool) {\r\n        if(_gasPrice \u003E 0\r\n            \u0026\u0026 _signatures \u003E 1\r\n            \u0026\u0026 (address(_wallet).balance \u003C _gasUsed * _gasPrice || _wallet.authorised(address(this)) == false)) {\r\n            return false;\r\n        }\r\n        return true;\r\n    }\r\n\r\n    /**\r\n    * @dev Checks that the wallet address provided as the first parameter of the relayed data is the same\r\n    * as the wallet passed as the input of the execute() method. \r\n    @return false if the addresses are different.\r\n    */\r\n    function verifyData(address _wallet, bytes memory _data) private pure returns (bool) {\r\n        require(_data.length \u003E= 36, \u0022RM: Invalid dataWallet\u0022);\r\n        address dataWallet;\r\n        // solium-disable-next-line security/no-inline-assembly\r\n        assembly {\r\n            //_data = {length:32}{sig:4}{_wallet:32}{...}\r\n            dataWallet := mload(add(_data, 0x24))\r\n        }\r\n        return dataWallet == _wallet;\r\n    }\r\n\r\n    /**\r\n    * @dev Parses the data to extract the method signature.\r\n    */\r\n    function functionPrefix(bytes memory _data) internal pure returns (bytes4 prefix) {\r\n        require(_data.length \u003E= 4, \u0022RM: Invalid functionPrefix\u0022);\r\n        // solium-disable-next-line security/no-inline-assembly\r\n        assembly {\r\n            prefix := mload(add(_data, 0x20))\r\n        }\r\n    }\r\n}\r\n\r\n/**\r\n * @title BaseTransfer\r\n * @dev Module containing internal methods to execute or approve transfers\r\n * @author Olivier VDB - \u003Colivier@argent.xyz\u003E\r\n */\r\ncontract BaseTransfer is BaseModule {\r\n\r\n    // Mock token address for ETH\r\n    address constant internal ETH_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\r\n\r\n    // *************** Events *************************** //\r\n\r\n    event Transfer(address indexed wallet, address indexed token, uint256 indexed amount, address to, bytes data);\r\n    event Approved(address indexed wallet, address indexed token, uint256 amount, address spender);\r\n    event CalledContract(address indexed wallet, address indexed to, uint256 amount, bytes data);\r\n\r\n    // *************** Internal Functions ********************* //\r\n\r\n    /**\r\n    * @dev Helper method to transfer ETH or ERC20 for a wallet.\r\n    * @param _wallet The target wallet.\r\n    * @param _token The ERC20 address.\r\n    * @param _to The recipient.\r\n    * @param _value The amount of ETH to transfer\r\n    * @param _data The data to *log* with the transfer.\r\n    */\r\n    function doTransfer(BaseWallet _wallet, address _token, address _to, uint256 _value, bytes memory _data) internal {\r\n        if(_token == ETH_TOKEN) {\r\n            invokeWallet(address(_wallet), _to, _value, EMPTY_BYTES);\r\n        }\r\n        else {\r\n            bytes memory methodData = abi.encodeWithSignature(\u0022transfer(address,uint256)\u0022, _to, _value);\r\n            invokeWallet(address(_wallet), _token, 0, methodData);\r\n        }\r\n        emit Transfer(address(_wallet), _token, _value, _to, _data);\r\n    }\r\n\r\n    /**\r\n    * @dev Helper method to approve spending the ERC20 of a wallet.\r\n    * @param _wallet The target wallet.\r\n    * @param _token The ERC20 address.\r\n    * @param _spender The spender address.\r\n    * @param _value The amount of token to transfer.\r\n    */\r\n    function doApproveToken(BaseWallet _wallet, address _token, address _spender, uint256 _value) internal {\r\n        bytes memory methodData = abi.encodeWithSignature(\u0022approve(address,uint256)\u0022, _spender, _value);\r\n        invokeWallet(address(_wallet), _token, 0, methodData);\r\n        emit Approved(address(_wallet), _token, _value, _spender);\r\n    }\r\n\r\n    /**\r\n    * @dev Helper method to call an external contract.\r\n    * @param _wallet The target wallet.\r\n    * @param _contract The contract address.\r\n    * @param _value The ETH value to transfer.\r\n    * @param _data The method data.\r\n    */\r\n    function doCallContract(BaseWallet _wallet, address _contract, uint256 _value, bytes memory _data) internal {\r\n        invokeWallet(address(_wallet), _contract, _value, _data);\r\n        emit CalledContract(address(_wallet), _contract, _value, _data);\r\n    }\r\n}\r\n\r\n/**\r\n * @title ApprovedTransfer\r\n * @dev Module to transfer tokens (ETH or ERC20) with the approval of guardians.\r\n * @author Julien Niset - \u003Cjulien@argent.im\u003E\r\n */\r\ncontract ApprovedTransfer is BaseModule, RelayerModule, BaseTransfer {\r\n\r\n    bytes32 constant NAME = \u0022ApprovedTransfer\u0022;\r\n\r\n    constructor(ModuleRegistry _registry, GuardianStorage _guardianStorage) BaseModule(_registry, _guardianStorage, NAME) public {\r\n\r\n    }\r\n\r\n    /**\r\n    * @dev transfers tokens (ETH or ERC20) from a wallet.\r\n    * @param _wallet The target wallet.\r\n    * @param _token The address of the token to transfer.\r\n    * @param _to The destination address\r\n    * @param _amount The amoutnof token to transfer\r\n    * @param _data  The data for the transaction (only for ETH transfers)\r\n    */\r\n    function transferToken(\r\n        BaseWallet _wallet,\r\n        address _token,\r\n        address _to,\r\n        uint256 _amount,\r\n        bytes calldata _data\r\n    )\r\n        external\r\n        onlyExecute\r\n        onlyWhenUnlocked(_wallet)\r\n    {\r\n        doTransfer(_wallet, _token, _to, _amount, _data);\r\n    }\r\n\r\n    /**\r\n    * @dev call a contract.\r\n    * @param _wallet The target wallet.\r\n    * @param _contract The address of the contract.\r\n    * @param _value The amount of ETH to transfer as part of call\r\n    * @param _data The encoded method data\r\n    */\r\n    function callContract(\r\n        BaseWallet _wallet,\r\n        address _contract,\r\n        uint256 _value,\r\n        bytes calldata _data\r\n    )\r\n        external\r\n        onlyExecute\r\n        onlyWhenUnlocked(_wallet)\r\n    {\r\n        require(!_wallet.authorised(_contract) \u0026\u0026 _contract != address(_wallet), \u0022AT: Forbidden contract\u0022);\r\n        doCallContract(_wallet, _contract, _value, _data);\r\n    }\r\n\r\n    // *************** Implementation of RelayerModule methods ********************* //\r\n\r\n    function validateSignatures(\r\n        BaseWallet _wallet,\r\n        bytes memory /* _data */,\r\n        bytes32 _signHash,\r\n        bytes memory _signatures\r\n    )\r\n        internal\r\n        view\r\n        returns (bool)\r\n    {\r\n        address lastSigner = address(0);\r\n        address[] memory guardians = guardianStorage.getGuardians(_wallet);\r\n        bool isGuardian = false;\r\n        for (uint8 i = 0; i \u003C _signatures.length / 65; i\u002B\u002B) {\r\n            address signer = recoverSigner(_signHash, _signatures, i);\r\n            if(i == 0) {\r\n                // AT: first signer must be owner\r\n                if(!isOwner(_wallet, signer)) {\r\n                    return false;\r\n                }\r\n            }\r\n            else {\r\n                // \u0022AT: signers must be different\u0022\r\n                if(signer \u003C= lastSigner) {\r\n                    return false;\r\n                }\r\n                lastSigner = signer;\r\n                (isGuardian, guardians) = GuardianUtils.isGuardian(guardians, signer);\r\n                // \u0022AT: signatures not valid\u0022\r\n                if(!isGuardian) {\r\n                    return false;\r\n                }\r\n            }\r\n        }\r\n        return true;\r\n    }\r\n\r\n    function getRequiredSignatures(BaseWallet _wallet, bytes memory /* _data */) internal view returns (uint256) {\r\n        // owner  \u002B [n/2] guardians\r\n        return  1 \u002B SafeMath.ceil(guardianStorage.guardianCount(_wallet), 2);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022init\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getNonce\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022transferToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_module\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addModule\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_token\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022recoverToken\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022name\u0022:\u0022_nonce\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_signatures\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022name\u0022:\u0022_gasPrice\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_gasLimit\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022execute\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022relayer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022nonce\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_contract\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022callContract\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_registry\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_guardianStorage\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022Transfer\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022token\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022spender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022Approved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022CalledContract\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022signedHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022TransactionExecuted\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022name\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022ModuleCreated\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022wallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022ModuleInitialised\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"ApprovedTransfer","CompilerVersion":"v0.5.4\u002Bcommit.9549d8ff","OptimizationUsed":"1","Runs":"999","ConstructorArguments":"000000000000000000000000c17d432bd8e8850fd7b32b0270f5afac65db010500000000000000000000000044da3a8051ba88eab0440db3779cab9d679ae76f","Library":"","SwarmSource":"bzzr://9943d0ee514d0d9bacea196bdcd09ebb8e636c1561c80dc0dfc986407799644c"}]