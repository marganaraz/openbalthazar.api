[{"SourceCode":"pragma solidity ^0.5.4;\r\n\r\nlibrary SafeMath {\r\n\r\n    /**\r\n    * @dev Multiplies two numbers, reverts on overflow.\r\n    */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.\r\n    */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003E 0); // Solidity only automatically asserts when dividing by 0\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).\r\n    */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Adds two numbers, reverts on overflow.\r\n    */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),\r\n    * reverts when dividing by zero.\r\n    */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0);\r\n        return a % b;\r\n    }\r\n\r\n    /**\r\n    * @dev Returns ceil(a / b).\r\n    */\r\n    function ceil(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a / b;\r\n        if(a % b == 0) {\r\n            return c;\r\n        }\r\n        else {\r\n            return c \u002B 1;\r\n        }\r\n    }\r\n}\r\n\r\ncontract Owned {\r\n\r\n    // The owner\r\n    address public owner;\r\n\r\n    event OwnerChanged(address indexed _newOwner);\r\n\r\n    /**\r\n     * @dev Throws if the sender is not the owner.\r\n     */\r\n    modifier onlyOwner {\r\n        require(msg.sender == owner, \u0022Must be owner\u0022);\r\n        _;\r\n    }\r\n\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n    /**\r\n     * @dev Lets the owner transfer ownership of the contract to a new owner.\r\n     * @param _newOwner The new owner.\r\n     */\r\n    function changeOwner(address _newOwner) external onlyOwner {\r\n        require(_newOwner != address(0), \u0022Address must not be null\u0022);\r\n        owner = _newOwner;\r\n        emit OwnerChanged(_newOwner);\r\n    }\r\n}\r\n\r\ncontract LogicManager is Owned {\r\n\r\n    event UpdateLogicSubmitted(address indexed logic, bool value);\r\n    event UpdateLogicCancelled(address indexed logic);\r\n    event UpdateLogicDone(address indexed logic, bool value);\r\n\r\n    struct pending {\r\n        bool value;\r\n        uint dueTime;\r\n    }\r\n\r\n    // The authorized logic modules\r\n    mapping (address =\u003E bool) public authorized;\r\n\r\n    /*\r\n    array\r\n    index 0: AccountLogic address\r\n          1: TransferLogic address\r\n          2: DualsigsLogic address\r\n          3: DappLogic address\r\n          4: ...\r\n     */\r\n    address[] public authorizedLogics;\r\n\r\n    // updated logics and their due time of becoming effective\r\n    mapping (address =\u003E pending) public pendingLogics;\r\n\r\n    // pending time before updated logics take effect\r\n    uint public pendingTime;\r\n\r\n    // how many authorized logics\r\n    uint public logicCount;\r\n\r\n    constructor(address[] memory _initialLogics, uint256 _pendingTime) public\r\n    {\r\n        for (uint i = 0; i \u003C _initialLogics.length; i\u002B\u002B) {\r\n            address logic = _initialLogics[i];\r\n            authorized[logic] = true;\r\n            logicCount \u002B= 1;\r\n        }\r\n        authorizedLogics = _initialLogics;\r\n\r\n        // pendingTime: 4 days for mainnet, 4 minutes for ropsten testnet\r\n        pendingTime = _pendingTime;\r\n    }\r\n\r\n    function isAuthorized(address _logic) external view returns (bool) {\r\n        return authorized[_logic];\r\n    }\r\n\r\n    function getAuthorizedLogics() external view returns (address[] memory) {\r\n        return authorizedLogics;\r\n    }\r\n\r\n    function submitUpdate(address _logic, bool _value) external onlyOwner {\r\n        pending storage p = pendingLogics[_logic];\r\n        p.value = _value;\r\n        p.dueTime = now \u002B pendingTime;\r\n        emit UpdateLogicSubmitted(_logic, _value);\r\n    }\r\n\r\n    function cancelUpdate(address _logic) external onlyOwner {\r\n        delete pendingLogics[_logic];\r\n        emit UpdateLogicCancelled(_logic);\r\n    }\r\n\r\n    function triggerUpdateLogic(address _logic) external {\r\n        pending memory p = pendingLogics[_logic];\r\n        require(p.dueTime \u003E 0, \u0022pending logic not found\u0022);\r\n        require(p.dueTime \u003C= now, \u0022too early to trigger updateLogic\u0022);\r\n        updateLogic(_logic, p.value);\r\n        delete pendingLogics[_logic];\r\n    }\r\n\r\n    function updateLogic(address _logic, bool _value) internal {\r\n        if (authorized[_logic] != _value) {\r\n            if(_value) {\r\n                logicCount \u002B= 1;\r\n                authorized[_logic] = true;\r\n                authorizedLogics.push(_logic);\r\n            }\r\n            else {\r\n                logicCount -= 1;\r\n                require(logicCount \u003E 0, \u0022must have at least one logic module\u0022);\r\n                delete authorized[_logic];\r\n                removeLogic(_logic);\r\n            }\r\n            emit UpdateLogicDone(_logic, _value);\r\n        }\r\n    }\r\n\r\n    function removeLogic(address _logic) internal {\r\n        uint len = authorizedLogics.length;\r\n        address lastLogic = authorizedLogics[len - 1];\r\n        if (_logic != lastLogic) {\r\n            for (uint i = 0; i \u003C len; i\u002B\u002B) {\r\n                 if (_logic == authorizedLogics[i]) {\r\n                     authorizedLogics[i] = lastLogic;\r\n                     break;\r\n                 }\r\n            }\r\n        }\r\n        authorizedLogics.length--;\r\n    }\r\n}\r\n\r\ncontract BaseLogic {\r\n\r\n    bytes constant internal SIGN_HASH_PREFIX = \u0022\\x19Ethereum Signed Message:\\n32\u0022;\r\n\r\n    mapping (address =\u003E uint256) keyNonce;\r\n    AccountStorage public accountStorage;\r\n\r\n    modifier allowSelfCallsOnly() {\r\n        require (msg.sender == address(this), \u0022only internal call is allowed\u0022);\r\n        _;\r\n    }\r\n\r\n    modifier allowAccountCallsOnly(Account _account) {\r\n        require(msg.sender == address(_account), \u0022caller must be account\u0022);\r\n        _;\r\n    }\r\n\r\n    event LogicInitialised(address wallet);\r\n\r\n    // *************** Constructor ********************** //\r\n\r\n    constructor(AccountStorage _accountStorage) public {\r\n        accountStorage = _accountStorage;\r\n    }\r\n\r\n    // *************** Initialization ********************* //\r\n\r\n    function initAccount(Account _account) external allowAccountCallsOnly(_account){\r\n        emit LogicInitialised(address(_account));\r\n    }\r\n\r\n    // *************** Getter ********************** //\r\n\r\n    function getKeyNonce(address _key) external view returns(uint256) {\r\n        return keyNonce[_key];\r\n    }\r\n\r\n    // *************** Signature ********************** //\r\n\r\n    function getSignHash(bytes memory _data, uint256 _nonce) internal view returns(bytes32) {\r\n        // use EIP 191\r\n        // 0x1900 \u002B this logic address \u002B data \u002B nonce of signing key\r\n        bytes32 msgHash = keccak256(abi.encodePacked(byte(0x19), byte(0), address(this), _data, _nonce));\r\n        bytes32 prefixedHash = keccak256(abi.encodePacked(SIGN_HASH_PREFIX, msgHash));\r\n        return prefixedHash;\r\n    }\r\n\r\n    function verifySig(address _signingKey, bytes memory _signature, bytes32 _signHash) internal pure {\r\n        require(_signingKey != address(0), \u0022invalid signing key\u0022);\r\n        address recoveredAddr = recover(_signHash, _signature);\r\n        require(recoveredAddr == _signingKey, \u0022signature verification failed\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address that signed a hashed message (\u0060hash\u0060) with\r\n     * \u0060signature\u0060. This address can then be used for verification purposes.\r\n     *\r\n     * The \u0060ecrecover\u0060 EVM opcode allows for malleable (non-unique) signatures:\r\n     * this function rejects them by requiring the \u0060s\u0060 value to be in the lower\r\n     * half order, and the \u0060v\u0060 value to be either 27 or 28.\r\n     *\r\n     * NOTE: This call _does not revert_ if the signature is invalid, or\r\n     * if the signer is otherwise unable to be retrieved. In those scenarios,\r\n     * the zero address is returned.\r\n     *\r\n     * IMPORTANT: \u0060hash\u0060 _must_ be the result of a hash operation for the\r\n     * verification to be secure: it is possible to craft signatures that\r\n     * recover to arbitrary addresses for non-hashed data. A safe way to ensure\r\n     * this is by receiving a hash of the original message (which may otherwise)\r\n     * be too long), and then calling {toEthSignedMessageHash} on it.\r\n     */\r\n    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {\r\n        // Check the signature length\r\n        if (signature.length != 65) {\r\n            return (address(0));\r\n        }\r\n\r\n        // Divide the signature in r, s and v variables\r\n        bytes32 r;\r\n        bytes32 s;\r\n        uint8 v;\r\n\r\n        // ecrecover takes the signature parameters, and the only way to get them\r\n        // currently is to use assembly.\r\n        // solhint-disable-next-line no-inline-assembly\r\n        assembly {\r\n            r := mload(add(signature, 0x20))\r\n            s := mload(add(signature, 0x40))\r\n            v := byte(0, mload(add(signature, 0x60)))\r\n        }\r\n\r\n        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature\r\n        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines\r\n        // the valid range for s in (281): 0 \u003C s \u003C secp256k1n \u00F7 2 \u002B 1, and for v in (282): v \u2208 {27, 28}. Most\r\n        // signatures from current libraries generate a unique signature with an s-value in the lower half order.\r\n        //\r\n        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value\r\n        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or\r\n        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept\r\n        // these malleable signatures as well.\r\n        if (uint256(s) \u003E 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {\r\n            return address(0);\r\n        }\r\n\r\n        if (v != 27 \u0026\u0026 v != 28) {\r\n            return address(0);\r\n        }\r\n\r\n        // If the signature is valid (and not malleable), return the signer address\r\n        return ecrecover(hash, v, r, s);\r\n    }\r\n\r\n    /* get signer address from data\r\n    * @dev Gets an address encoded as the first argument in transaction data\r\n    * @param b The byte array that should have an address as first argument\r\n    * @returns a The address retrieved from the array\r\n    */\r\n    function getSignerAddress(bytes memory _b) internal pure returns (address _a) {\r\n        require(_b.length \u003E= 36, \u0022invalid bytes\u0022);\r\n        // solium-disable-next-line security/no-inline-assembly\r\n        assembly {\r\n            let mask := 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF\r\n            _a := and(mask, mload(add(_b, 36)))\r\n            // b = {length:32}{method sig:4}{address:32}{...}\r\n            // 36 is the offset of the first parameter of the data, if encoded properly.\r\n            // 32 bytes for the length of the bytes array, and the first 4 bytes for the function signature.\r\n            // 32 bytes is the length of the bytes array!!!!\r\n        }\r\n    }\r\n\r\n    // get method id, first 4 bytes of data\r\n    function getMethodId(bytes memory _b) internal pure returns (bytes4 _a) {\r\n        require(_b.length \u003E= 4, \u0022invalid data\u0022);\r\n        // solium-disable-next-line security/no-inline-assembly\r\n        assembly {\r\n            // 32 bytes is the length of the bytes array\r\n            _a := mload(add(_b, 32))\r\n        }\r\n    }\r\n\r\n    function checkKeyStatus(address _account, uint256 _index) internal {\r\n        // check operation key status\r\n        if (_index \u003E 0) {\r\n            require(accountStorage.getKeyStatus(_account, _index) != 1, \u0022frozen key\u0022);\r\n        }\r\n    }\r\n\r\n    // _nonce is timestamp in microsecond(1/1000000 second)\r\n    function checkAndUpdateNonce(address _key, uint256 _nonce) internal {\r\n        require(_nonce \u003E keyNonce[_key], \u0022nonce too small\u0022);\r\n        require(SafeMath.div(_nonce, 1000000) \u003C= now \u002B 86400, \u0022nonce too big\u0022); // 86400=24*3600 seconds\r\n\r\n        keyNonce[_key] = _nonce;\r\n    }\r\n}\r\n\r\ncontract Account {\r\n\r\n    // The implementation of the proxy\r\n    address public implementation;\r\n\r\n    // Logic manager\r\n    address public manager;\r\n    \r\n    // The enabled static calls\r\n    mapping (bytes4 =\u003E address) public enabled;\r\n\r\n    event EnabledStaticCall(address indexed module, bytes4 indexed method);\r\n    event Invoked(address indexed module, address indexed target, uint indexed value, bytes data);\r\n    event Received(uint indexed value, address indexed sender, bytes data);\r\n\r\n    event AccountInit(address indexed account);\r\n    event ManagerChanged(address indexed mgr);\r\n\r\n    modifier allowAuthorizedLogicContractsCallsOnly {\r\n        require(LogicManager(manager).isAuthorized(msg.sender), \u0022not an authorized logic\u0022);\r\n        _;\r\n    }\r\n\r\n    function init(address _manager, address _accountStorage, address[] calldata _logics, address[] calldata _keys, address[] calldata _backups)\r\n        external\r\n    {\r\n        require(manager == address(0), \u0022Account: account already initialized\u0022);\r\n        require(_manager != address(0) \u0026\u0026 _accountStorage != address(0), \u0022Account: address is null\u0022);\r\n        manager = _manager;\r\n\r\n        for (uint i = 0; i \u003C _logics.length; i\u002B\u002B) {\r\n            address logic = _logics[i];\r\n            require(LogicManager(manager).isAuthorized(logic), \u0022must be authorized logic\u0022);\r\n\r\n            BaseLogic(logic).initAccount(this);\r\n        }\r\n\r\n        AccountStorage(_accountStorage).initAccount(this, _keys, _backups);\r\n\r\n        emit AccountInit(address(this));\r\n    }\r\n\r\n    function invoke(address _target, uint _value, bytes calldata _data)\r\n        external\r\n        allowAuthorizedLogicContractsCallsOnly\r\n        returns (bytes memory _res)\r\n    {\r\n        bool success;\r\n        // solium-disable-next-line security/no-call-value\r\n        (success, _res) = _target.call.value(_value)(_data);\r\n        require(success, \u0022call to target failed\u0022);\r\n        emit Invoked(msg.sender, _target, _value, _data);\r\n    }\r\n\r\n    /**\r\n    * @dev Enables a static method by specifying the target module to which the call must be delegated.\r\n    * @param _module The target module.\r\n    * @param _method The static method signature.\r\n    */\r\n    function enableStaticCall(address _module, bytes4 _method) external allowAuthorizedLogicContractsCallsOnly {\r\n        enabled[_method] = _module;\r\n        emit EnabledStaticCall(_module, _method);\r\n    }\r\n\r\n    function changeManager(address _newMgr) external allowAuthorizedLogicContractsCallsOnly {\r\n        require(_newMgr != address(0), \u0022address cannot be null\u0022);\r\n        require(_newMgr != manager, \u0022already changed\u0022);\r\n        manager = _newMgr;\r\n        emit ManagerChanged(_newMgr);\r\n    }\r\n\r\n     /**\r\n     * @dev This method makes it possible for the wallet to comply to interfaces expecting the wallet to\r\n     * implement specific static methods. It delegates the static call to a target contract if the data corresponds\r\n     * to an enabled method, or logs the call otherwise.\r\n     */\r\n    function() external payable {\r\n        if(msg.data.length \u003E 0) {\r\n            address logic = enabled[msg.sig];\r\n            if(logic == address(0)) {\r\n                emit Received(msg.value, msg.sender, msg.data);\r\n            }\r\n            else {\r\n                require(LogicManager(manager).isAuthorized(logic), \u0022must be an authorized logic for static call\u0022);\r\n                // solium-disable-next-line security/no-inline-assembly\r\n                assembly {\r\n                    calldatacopy(0, 0, calldatasize())\r\n                    let result := staticcall(gas, logic, 0, calldatasize(), 0, 0)\r\n                    returndatacopy(0, 0, returndatasize())\r\n                    switch result\r\n                    case 0 {revert(0, returndatasize())}\r\n                    default {return (0, returndatasize())}\r\n                }\r\n            }\r\n        }\r\n    }\r\n}\r\n\r\n\r\ncontract AccountStorage {\r\n\r\n    modifier allowAccountCallsOnly(Account _account) {\r\n        require(msg.sender == address(_account), \u0022caller must be account\u0022);\r\n        _;\r\n    }\r\n\r\n    modifier allowAuthorizedLogicContractsCallsOnly(address payable _account) {\r\n        require(LogicManager(Account(_account).manager()).isAuthorized(msg.sender), \u0022not an authorized logic\u0022);\r\n        _;\r\n    }\r\n\r\n    struct KeyItem {\r\n        address pubKey;\r\n        uint256 status;\r\n    }\r\n\r\n    struct BackupAccount {\r\n        address backup;\r\n        uint256 effectiveDate;//means not effective until this timestamp\r\n        uint256 expiryDate;//means effective until this timestamp\r\n    }\r\n\r\n    struct DelayItem {\r\n        bytes32 hash;\r\n        uint256 dueTime;\r\n    }\r\n\r\n    struct Proposal {\r\n        bytes32 hash;\r\n        address[] approval;\r\n    }\r\n\r\n    // account =\u003E quantity of operation keys (index \u003E= 1)\r\n    mapping (address =\u003E uint256) operationKeyCount;\r\n\r\n    // account =\u003E index =\u003E KeyItem\r\n    mapping (address =\u003E mapping(uint256 =\u003E KeyItem)) keyData;\r\n\r\n    // account =\u003E index =\u003E backup account\r\n    mapping (address =\u003E mapping(uint256 =\u003E BackupAccount)) backupData;\r\n\r\n    /* account =\u003E actionId =\u003E DelayItem\r\n\r\n       delayData applies to these 4 actions:\r\n       changeAdminKey, changeAllOperationKeys, unfreeze, changeAdminKeyByBackup\r\n    */\r\n    mapping (address =\u003E mapping(bytes4 =\u003E DelayItem)) delayData;\r\n\r\n    // client account =\u003E proposer account =\u003E proposed actionId =\u003E Proposal\r\n    mapping (address =\u003E mapping(address =\u003E mapping(bytes4 =\u003E Proposal))) proposalData;\r\n\r\n    // *************** keyCount ********************** //\r\n\r\n    function getOperationKeyCount(address _account) external view returns(uint256) {\r\n        return operationKeyCount[_account];\r\n    }\r\n\r\n    function increaseKeyCount(address payable _account) external allowAuthorizedLogicContractsCallsOnly(_account) {\r\n        operationKeyCount[_account] = operationKeyCount[_account] \u002B 1;\r\n    }\r\n\r\n    // *************** keyData ********************** //\r\n\r\n    function getKeyData(address _account, uint256 _index) public view returns(address) {\r\n        KeyItem memory item = keyData[_account][_index];\r\n        return item.pubKey;\r\n    }\r\n\r\n    function setKeyData(address payable _account, uint256 _index, address _key) external allowAuthorizedLogicContractsCallsOnly(_account) {\r\n        require(_key != address(0), \u0022invalid _key value\u0022);\r\n        KeyItem storage item = keyData[_account][_index];\r\n        item.pubKey = _key;\r\n    }\r\n\r\n    // *************** keyStatus ********************** //\r\n\r\n    function getKeyStatus(address _account, uint256 _index) external view returns(uint256) {\r\n        KeyItem memory item = keyData[_account][_index];\r\n        return item.status;\r\n    }\r\n\r\n    function setKeyStatus(address payable _account, uint256 _index, uint256 _status) external allowAuthorizedLogicContractsCallsOnly(_account) {\r\n        KeyItem storage item = keyData[_account][_index];\r\n        item.status = _status;\r\n    }\r\n\r\n    // *************** backupData ********************** //\r\n\r\n    function getBackupAddress(address _account, uint256 _index) external view returns(address) {\r\n        BackupAccount memory b = backupData[_account][_index];\r\n        return b.backup;\r\n    }\r\n\r\n    function getBackupEffectiveDate(address _account, uint256 _index) external view returns(uint256) {\r\n        BackupAccount memory b = backupData[_account][_index];\r\n        return b.effectiveDate;\r\n    }\r\n\r\n    function getBackupExpiryDate(address _account, uint256 _index) external view returns(uint256) {\r\n        BackupAccount memory b = backupData[_account][_index];\r\n        return b.expiryDate;\r\n    }\r\n\r\n    function setBackup(address payable _account, uint256 _index, address _backup, uint256 _effective, uint256 _expiry)\r\n        external\r\n        allowAuthorizedLogicContractsCallsOnly(_account)\r\n    {\r\n        BackupAccount storage b = backupData[_account][_index];\r\n        b.backup = _backup;\r\n        b.effectiveDate = _effective;\r\n        b.expiryDate = _expiry;\r\n    }\r\n\r\n    function setBackupExpiryDate(address payable _account, uint256 _index, uint256 _expiry)\r\n        external\r\n        allowAuthorizedLogicContractsCallsOnly(_account)\r\n    {\r\n        BackupAccount storage b = backupData[_account][_index];\r\n        b.expiryDate = _expiry;\r\n    }\r\n\r\n    function clearBackupData(address payable _account, uint256 _index) external allowAuthorizedLogicContractsCallsOnly(_account) {\r\n        delete backupData[_account][_index];\r\n    }\r\n\r\n    // *************** delayData ********************** //\r\n\r\n    function getDelayDataHash(address payable _account, bytes4 _actionId) external view returns(bytes32) {\r\n        DelayItem memory item = delayData[_account][_actionId];\r\n        return item.hash;\r\n    }\r\n\r\n    function getDelayDataDueTime(address payable _account, bytes4 _actionId) external view returns(uint256) {\r\n        DelayItem memory item = delayData[_account][_actionId];\r\n        return item.dueTime;\r\n    }\r\n\r\n    function setDelayData(address payable _account, bytes4 _actionId, bytes32 _hash, uint256 _dueTime) external allowAuthorizedLogicContractsCallsOnly(_account) {\r\n        DelayItem storage item = delayData[_account][_actionId];\r\n        item.hash = _hash;\r\n        item.dueTime = _dueTime;\r\n    }\r\n\r\n    function clearDelayData(address payable _account, bytes4 _actionId) external allowAuthorizedLogicContractsCallsOnly(_account) {\r\n        delete delayData[_account][_actionId];\r\n    }\r\n\r\n    // *************** proposalData ********************** //\r\n\r\n    function getProposalDataHash(address _client, address _proposer, bytes4 _actionId) external view returns(bytes32) {\r\n        Proposal memory p = proposalData[_client][_proposer][_actionId];\r\n        return p.hash;\r\n    }\r\n\r\n    function getProposalDataApproval(address _client, address _proposer, bytes4 _actionId) external view returns(address[] memory) {\r\n        Proposal memory p = proposalData[_client][_proposer][_actionId];\r\n        return p.approval;\r\n    }\r\n\r\n    function setProposalData(address payable _client, address _proposer, bytes4 _actionId, bytes32 _hash, address _approvedBackup)\r\n        external\r\n        allowAuthorizedLogicContractsCallsOnly(_client)\r\n    {\r\n        Proposal storage p = proposalData[_client][_proposer][_actionId];\r\n        if (p.hash \u003E 0) {\r\n            if (p.hash == _hash) {\r\n                for (uint256 i = 0; i \u003C p.approval.length; i\u002B\u002B) {\r\n                    require(p.approval[i] != _approvedBackup, \u0022backup already exists\u0022);\r\n                }\r\n                p.approval.push(_approvedBackup);\r\n            } else {\r\n                p.hash = _hash;\r\n                p.approval.length = 0;\r\n            }\r\n        } else {\r\n            p.hash = _hash;\r\n            p.approval.push(_approvedBackup);\r\n        }\r\n    }\r\n\r\n    function clearProposalData(address payable _client, address _proposer, bytes4 _actionId) external allowAuthorizedLogicContractsCallsOnly(_client) {\r\n        delete proposalData[_client][_proposer][_actionId];\r\n    }\r\n\r\n\r\n    // *************** init ********************** //\r\n    function initAccount(Account _account, address[] calldata _keys, address[] calldata _backups)\r\n        external\r\n        allowAccountCallsOnly(_account)\r\n    {\r\n        require(getKeyData(address(_account), 0) == address(0), \u0022AccountStorage: account already initialized!\u0022);\r\n        require(_keys.length \u003E 0, \u0022empty keys array\u0022);\r\n\r\n        operationKeyCount[address(_account)] = _keys.length - 1;\r\n\r\n        for (uint256 index = 0; index \u003C _keys.length; index\u002B\u002B) {\r\n            address _key = _keys[index];\r\n            require(_key != address(0), \u0022_key cannot be 0x0\u0022);\r\n            KeyItem storage item = keyData[address(_account)][index];\r\n            item.pubKey = _key;\r\n            item.status = 0;\r\n        }\r\n\r\n        // avoid backup duplication if _backups.length \u003E 1\r\n        // normally won\u0027t check duplication, in most cases only one initial backup when initialization\r\n        if (_backups.length \u003E 1) {\r\n            address[] memory bkps = _backups;\r\n            for (uint256 i = 0; i \u003C _backups.length; i\u002B\u002B) {\r\n                for (uint256 j = 0; j \u003C i; j\u002B\u002B) {\r\n                    require(bkps[j] != _backups[i], \u0022duplicate backup\u0022);\r\n                }\r\n            }\r\n        }\r\n\r\n        for (uint256 index = 0; index \u003C _backups.length; index\u002B\u002B) {\r\n            address _backup = _backups[index];\r\n            require(_backup != address(0), \u0022backup cannot be 0x0\u0022);\r\n            require(_backup != address(_account), \u0022cannot be backup of oneself\u0022);\r\n\r\n            backupData[address(_account)][index] = BackupAccount(_backup, now, uint256(-1));\r\n        }\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_keys\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_backups\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022initAccount\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_client\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_proposer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_actionId\u0022,\u0022type\u0022:\u0022bytes4\u0022}],\u0022name\u0022:\u0022clearProposalData\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_actionId\u0022,\u0022type\u0022:\u0022bytes4\u0022}],\u0022name\u0022:\u0022getDelayDataDueTime\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getKeyStatus\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_index\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_key\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setKeyData\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_client\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_proposer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_actionId\u0022,\u0022type\u0022:\u0022bytes4\u0022}],\u0022name\u0022:\u0022getProposalDataHash\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_client\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_proposer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_actionId\u0022,\u0022type\u0022:\u0022bytes4\u0022},{\u0022name\u0022:\u0022_hash\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_approvedBackup\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setProposalData\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_client\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_proposer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_actionId\u0022,\u0022type\u0022:\u0022bytes4\u0022}],\u0022name\u0022:\u0022getProposalDataApproval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022increaseKeyCount\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getKeyData\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022clearBackupData\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getBackupExpiryDate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_actionId\u0022,\u0022type\u0022:\u0022bytes4\u0022}],\u0022name\u0022:\u0022clearDelayData\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_actionId\u0022,\u0022type\u0022:\u0022bytes4\u0022},{\u0022name\u0022:\u0022_hash\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_dueTime\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setDelayData\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getBackupAddress\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getOperationKeyCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getBackupEffectiveDate\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_actionId\u0022,\u0022type\u0022:\u0022bytes4\u0022}],\u0022name\u0022:\u0022getDelayDataHash\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_index\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_status\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setKeyStatus\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_index\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_backup\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_effective\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_expiry\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setBackup\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_account\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_index\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_expiry\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setBackupExpiryDate\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"AccountStorage","CompilerVersion":"v0.5.4\u002Bcommit.9549d8ff","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://7067c4d168412123b2bc7076270c4c1690e9a4be42c89c870bdfef4c75d91b36"}]