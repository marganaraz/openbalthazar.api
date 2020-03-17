[{"SourceCode":"pragma solidity ^0.4.4;\r\n\r\n/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.\r\n/// @author Stefan George - \u003Cstefan.george@consensys.net\u003E\r\ncontract MultiSigWallet {\r\n\r\n    uint constant public MAX_OWNER_COUNT = 50;\r\n\r\n    event Confirmation(address indexed sender, uint indexed transactionId);\r\n    event Revocation(address indexed sender, uint indexed transactionId);\r\n    event Submission(uint indexed transactionId);\r\n    event Execution(uint indexed transactionId);\r\n    event ExecutionFailure(uint indexed transactionId);\r\n    event Deposit(address indexed sender, uint value);\r\n    event OwnerAddition(address indexed owner);\r\n    event OwnerRemoval(address indexed owner);\r\n    event RequirementChange(uint required);\r\n\r\n    mapping (uint =\u003E Transaction) public transactions;\r\n    mapping (uint =\u003E mapping (address =\u003E bool)) public confirmations;\r\n    mapping (address =\u003E bool) public isOwner;\r\n    address[] public owners;\r\n    uint public required;\r\n    uint public transactionCount;\r\n\r\n    struct Transaction {\r\n        address destination;\r\n        uint value;\r\n        bytes data;\r\n        bool executed;\r\n    }\r\n\r\n    modifier onlyWallet() {\r\n        if (msg.sender != address(this))\r\n            throw;\r\n        _;\r\n    }\r\n\r\n    modifier ownerDoesNotExist(address owner) {\r\n        if (isOwner[owner])\r\n            throw;\r\n        _;\r\n    }\r\n\r\n    modifier ownerExists(address owner) {\r\n        if (!isOwner[owner])\r\n            throw;\r\n        _;\r\n    }\r\n\r\n    modifier transactionExists(uint transactionId) {\r\n        if (transactions[transactionId].destination == 0)\r\n            throw;\r\n        _;\r\n    }\r\n\r\n    modifier confirmed(uint transactionId, address owner) {\r\n        if (!confirmations[transactionId][owner])\r\n            throw;\r\n        _;\r\n    }\r\n\r\n    modifier notConfirmed(uint transactionId, address owner) {\r\n        if (confirmations[transactionId][owner])\r\n            throw;\r\n        _;\r\n    }\r\n\r\n    modifier notExecuted(uint transactionId) {\r\n        if (transactions[transactionId].executed)\r\n            throw;\r\n        _;\r\n    }\r\n\r\n    modifier notNull(address _address) {\r\n        if (_address == 0)\r\n            throw;\r\n        _;\r\n    }\r\n\r\n    modifier validRequirement(uint ownerCount, uint _required) {\r\n        if (   ownerCount \u003E MAX_OWNER_COUNT\r\n            || _required \u003E ownerCount\r\n            || _required == 0\r\n            || ownerCount == 0)\r\n            throw;\r\n        _;\r\n    }\r\n\r\n    /// @dev Fallback function allows to deposit ether.\r\n    function()\r\n        payable\r\n    {\r\n        if (msg.value \u003E 0)\r\n            Deposit(msg.sender, msg.value);\r\n    }\r\n\r\n    /*\r\n     * Public functions\r\n     */\r\n    /// @dev Contract constructor sets initial owners and required number of confirmations.\r\n    /// @param _owners List of initial owners.\r\n    /// @param _required Number of required confirmations.\r\n    function MultiSigWallet(address[] _owners, uint _required)\r\n        public\r\n        validRequirement(_owners.length, _required)\r\n    {\r\n        for (uint i=0; i\u003C_owners.length; i\u002B\u002B) {\r\n            if (isOwner[_owners[i]] || _owners[i] == 0)\r\n                throw;\r\n            isOwner[_owners[i]] = true;\r\n        }\r\n        owners = _owners;\r\n        required = _required;\r\n    }\r\n\r\n    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.\r\n    /// @param owner Address of new owner.\r\n    function addOwner(address owner)\r\n        public\r\n        onlyWallet\r\n        ownerDoesNotExist(owner)\r\n        notNull(owner)\r\n        validRequirement(owners.length \u002B 1, required)\r\n    {\r\n        isOwner[owner] = true;\r\n        owners.push(owner);\r\n        OwnerAddition(owner);\r\n    }\r\n\r\n    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.\r\n    /// @param owner Address of owner.\r\n    function removeOwner(address owner)\r\n        public\r\n        onlyWallet\r\n        ownerExists(owner)\r\n    {\r\n        isOwner[owner] = false;\r\n        for (uint i=0; i\u003Cowners.length - 1; i\u002B\u002B)\r\n            if (owners[i] == owner) {\r\n                owners[i] = owners[owners.length - 1];\r\n                break;\r\n            }\r\n        owners.length -= 1;\r\n        if (required \u003E owners.length)\r\n            changeRequirement(owners.length);\r\n        OwnerRemoval(owner);\r\n    }\r\n\r\n    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.\r\n    /// @param owner Address of owner to be replaced.\r\n    /// @param owner Address of new owner.\r\n    function replaceOwner(address owner, address newOwner)\r\n        public\r\n        onlyWallet\r\n        ownerExists(owner)\r\n        ownerDoesNotExist(newOwner)\r\n    {\r\n        for (uint i=0; i\u003Cowners.length; i\u002B\u002B)\r\n            if (owners[i] == owner) {\r\n                owners[i] = newOwner;\r\n                break;\r\n            }\r\n        isOwner[owner] = false;\r\n        isOwner[newOwner] = true;\r\n        OwnerRemoval(owner);\r\n        OwnerAddition(newOwner);\r\n    }\r\n\r\n    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.\r\n    /// @param _required Number of required confirmations.\r\n    function changeRequirement(uint _required)\r\n        public\r\n        onlyWallet\r\n        validRequirement(owners.length, _required)\r\n    {\r\n        required = _required;\r\n        RequirementChange(_required);\r\n    }\r\n\r\n    /// @dev Allows an owner to submit and confirm a transaction.\r\n    /// @param destination Transaction target address.\r\n    /// @param value Transaction ether value.\r\n    /// @param data Transaction data payload.\r\n    /// @return Returns transaction ID.\r\n    function submitTransaction(address destination, uint value, bytes data)\r\n        public\r\n        returns (uint transactionId)\r\n    {\r\n        transactionId = addTransaction(destination, value, data);\r\n        confirmTransaction(transactionId);\r\n    }\r\n\r\n    /// @dev Allows an owner to confirm a transaction.\r\n    /// @param transactionId Transaction ID.\r\n    function confirmTransaction(uint transactionId)\r\n        public\r\n        ownerExists(msg.sender)\r\n        transactionExists(transactionId)\r\n        notConfirmed(transactionId, msg.sender)\r\n    {\r\n        confirmations[transactionId][msg.sender] = true;\r\n        Confirmation(msg.sender, transactionId);\r\n        executeTransaction(transactionId);\r\n    }\r\n\r\n    /// @dev Allows an owner to revoke a confirmation for a transaction.\r\n    /// @param transactionId Transaction ID.\r\n    function revokeConfirmation(uint transactionId)\r\n        public\r\n        ownerExists(msg.sender)\r\n        confirmed(transactionId, msg.sender)\r\n        notExecuted(transactionId)\r\n    {\r\n        confirmations[transactionId][msg.sender] = false;\r\n        Revocation(msg.sender, transactionId);\r\n    }\r\n\r\n    /// @dev Allows anyone to execute a confirmed transaction.\r\n    /// @param transactionId Transaction ID.\r\n    function executeTransaction(uint transactionId)\r\n        public\r\n        notExecuted(transactionId)\r\n    {\r\n        if (isConfirmed(transactionId)) {\r\n            Transaction tx = transactions[transactionId];\r\n            tx.executed = true;\r\n            if (tx.destination.call.value(tx.value)(tx.data))\r\n                Execution(transactionId);\r\n            else {\r\n                ExecutionFailure(transactionId);\r\n                tx.executed = false;\r\n            }\r\n        }\r\n    }\r\n\r\n    /// @dev Returns the confirmation status of a transaction.\r\n    /// @param transactionId Transaction ID.\r\n    /// @return Confirmation status.\r\n    function isConfirmed(uint transactionId)\r\n        public\r\n        constant\r\n        returns (bool)\r\n    {\r\n        uint count = 0;\r\n        for (uint i=0; i\u003Cowners.length; i\u002B\u002B) {\r\n            if (confirmations[transactionId][owners[i]])\r\n                count \u002B= 1;\r\n            if (count == required)\r\n                return true;\r\n        }\r\n    }\r\n\r\n    /*\r\n     * Internal functions\r\n     */\r\n    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.\r\n    /// @param destination Transaction target address.\r\n    /// @param value Transaction ether value.\r\n    /// @param data Transaction data payload.\r\n    /// @return Returns transaction ID.\r\n    function addTransaction(address destination, uint value, bytes data)\r\n        internal\r\n        notNull(destination)\r\n        returns (uint transactionId)\r\n    {\r\n        transactionId = transactionCount;\r\n        transactions[transactionId] = Transaction({\r\n            destination: destination,\r\n            value: value,\r\n            data: data,\r\n            executed: false\r\n        });\r\n        transactionCount \u002B= 1;\r\n        Submission(transactionId);\r\n    }\r\n\r\n    /*\r\n     * Web3 call functions\r\n     */\r\n    /// @dev Returns number of confirmations of a transaction.\r\n    /// @param transactionId Transaction ID.\r\n    /// @return Number of confirmations.\r\n    function getConfirmationCount(uint transactionId)\r\n        public\r\n        constant\r\n        returns (uint count)\r\n    {\r\n        for (uint i=0; i\u003Cowners.length; i\u002B\u002B)\r\n            if (confirmations[transactionId][owners[i]])\r\n                count \u002B= 1;\r\n    }\r\n\r\n    /// @dev Returns total number of transactions after filers are applied.\r\n    /// @param pending Include pending transactions.\r\n    /// @param executed Include executed transactions.\r\n    /// @return Total number of transactions after filters are applied.\r\n    function getTransactionCount(bool pending, bool executed)\r\n        public\r\n        constant\r\n        returns (uint count)\r\n    {\r\n        for (uint i=0; i\u003CtransactionCount; i\u002B\u002B)\r\n            if (   pending \u0026\u0026 !transactions[i].executed\r\n                || executed \u0026\u0026 transactions[i].executed)\r\n                count \u002B= 1;\r\n    }\r\n\r\n    /// @dev Returns list of owners.\r\n    /// @return List of owner addresses.\r\n    function getOwners()\r\n        public\r\n        constant\r\n        returns (address[])\r\n    {\r\n        return owners;\r\n    }\r\n\r\n    /// @dev Returns array with owner addresses, which confirmed transaction.\r\n    /// @param transactionId Transaction ID.\r\n    /// @return Returns array of owner addresses.\r\n    function getConfirmations(uint transactionId)\r\n        public\r\n        constant\r\n        returns (address[] _confirmations)\r\n    {\r\n        address[] memory confirmationsTemp = new address[](owners.length);\r\n        uint count = 0;\r\n        uint i;\r\n        for (i=0; i\u003Cowners.length; i\u002B\u002B)\r\n            if (confirmations[transactionId][owners[i]]) {\r\n                confirmationsTemp[count] = owners[i];\r\n                count \u002B= 1;\r\n            }\r\n        _confirmations = new address[](count);\r\n        for (i=0; i\u003Ccount; i\u002B\u002B)\r\n            _confirmations[i] = confirmationsTemp[i];\r\n    }\r\n\r\n    /// @dev Returns list of transaction IDs in defined range.\r\n    /// @param from Index start position of transaction array.\r\n    /// @param to Index end position of transaction array.\r\n    /// @param pending Include pending transactions.\r\n    /// @param executed Include executed transactions.\r\n    /// @return Returns array of transaction IDs.\r\n    function getTransactionIds(uint from, uint to, bool pending, bool executed)\r\n        public\r\n        constant\r\n        returns (uint[] _transactionIds)\r\n    {\r\n        uint[] memory transactionIdsTemp = new uint[](transactionCount);\r\n        uint count = 0;\r\n        uint i;\r\n        for (i=0; i\u003CtransactionCount; i\u002B\u002B)\r\n            if (   pending \u0026\u0026 !transactions[i].executed\r\n                || executed \u0026\u0026 transactions[i].executed)\r\n            {\r\n                transactionIdsTemp[count] = i;\r\n                count \u002B= 1;\r\n            }\r\n        _transactionIds = new uint[](to - from);\r\n        for (i=from; i\u003Cto; i\u002B\u002B)\r\n            _transactionIds[i - from] = transactionIdsTemp[i];\r\n    }\r\n}\r\n\r\n/// @title Multisignature wallet with daily limit - Allows an owner to withdraw a daily limit without multisig.\r\n/// @author Stefan George - \u003Cstefan.george@consensys.net\u003E\r\ncontract MultiSigWalletWithDailyLimit is MultiSigWallet {\r\n\r\n    event DailyLimitChange(uint dailyLimit);\r\n\r\n    uint public dailyLimit;\r\n    uint public lastDay;\r\n    uint public spentToday;\r\n\r\n    /*\r\n     * Public functions\r\n     */\r\n    /// @dev Contract constructor sets initial owners, required number of confirmations and daily withdraw limit.\r\n    /// @param _owners List of initial owners.\r\n    /// @param _required Number of required confirmations.\r\n    /// @param _dailyLimit Amount in wei, which can be withdrawn without confirmations on a daily basis.\r\n    function MultiSigWalletWithDailyLimit(address[] _owners, uint _required, uint _dailyLimit)\r\n        public\r\n        MultiSigWallet(_owners, _required)\r\n    {\r\n        dailyLimit = _dailyLimit;\r\n    }\r\n\r\n    /// @dev Allows to change the daily limit. Transaction has to be sent by wallet.\r\n    /// @param _dailyLimit Amount in wei.\r\n    function changeDailyLimit(uint _dailyLimit)\r\n        public\r\n        onlyWallet\r\n    {\r\n        dailyLimit = _dailyLimit;\r\n        DailyLimitChange(_dailyLimit);\r\n    }\r\n\r\n    /// @dev Allows anyone to execute a confirmed transaction or ether withdraws until daily limit is reached.\r\n    /// @param transactionId Transaction ID.\r\n    function executeTransaction(uint transactionId)\r\n        public\r\n        notExecuted(transactionId)\r\n    {\r\n        Transaction tx = transactions[transactionId];\r\n        bool confirmed = isConfirmed(transactionId);\r\n        if (confirmed || tx.data.length == 0 \u0026\u0026 isUnderLimit(tx.value)) {\r\n            tx.executed = true;\r\n            if (!confirmed)\r\n                spentToday \u002B= tx.value;\r\n            if (tx.destination.call.value(tx.value)(tx.data))\r\n                Execution(transactionId);\r\n            else {\r\n                ExecutionFailure(transactionId);\r\n                tx.executed = false;\r\n                if (!confirmed)\r\n                    spentToday -= tx.value;\r\n            }\r\n        }\r\n    }\r\n\r\n    /*\r\n     * Internal functions\r\n     */\r\n    /// @dev Returns if amount is within daily limit and resets spentToday after one day.\r\n    /// @param amount Amount to withdraw.\r\n    /// @return Returns if amount is under daily limit.\r\n    function isUnderLimit(uint amount)\r\n        internal\r\n        returns (bool)\r\n    {\r\n        if (now \u003E lastDay \u002B 24 hours) {\r\n            lastDay = now;\r\n            spentToday = 0;\r\n        }\r\n        if (spentToday \u002B amount \u003E dailyLimit || spentToday \u002B amount \u003C spentToday)\r\n            return false;\r\n        return true;\r\n    }\r\n\r\n    /*\r\n     * Web3 call functions\r\n     */\r\n    /// @dev Returns maximum withdraw amount.\r\n    /// @return Returns amount.\r\n    function calcMaxWithdraw()\r\n        public\r\n        constant\r\n        returns (uint)\r\n    {\r\n        if (now \u003E lastDay \u002B 24 hours)\r\n            return dailyLimit;\r\n        if (dailyLimit \u003C spentToday)\r\n            return 0;\r\n        return dailyLimit - spentToday;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022owners\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022transactionId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022revokeConfirmation\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022confirmations\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022calcMaxWithdraw\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022pending\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022executed\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022getTransactionCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022count\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022dailyLimit\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022lastDay\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022transactionId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022isConfirmed\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022transactionId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getConfirmationCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022count\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022transactions\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022destination\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022name\u0022:\u0022executed\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getOwners\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022from\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022to\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022pending\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022executed\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022getTransactionIds\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_transactionIds\u0022,\u0022type\u0022:\u0022uint256[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022transactionId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getConfirmations\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_confirmations\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022transactionCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_required\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022changeRequirement\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022transactionId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022confirmTransaction\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022destination\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022submitTransaction\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022transactionId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_dailyLimit\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022changeDailyLimit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022MAX_OWNER_COUNT\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022required\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022replaceOwner\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022transactionId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022executeTransaction\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022spentToday\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_owners\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_required\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_dailyLimit\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022fallback\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022dailyLimit\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022DailyLimitChange\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022transactionId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Confirmation\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022transactionId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Revocation\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022transactionId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Submission\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022transactionId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Execution\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022transactionId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022ExecutionFailure\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Deposit\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnerAddition\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnerRemoval\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022required\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022RequirementChange\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"MultiSigWalletWithDailyLimit","CompilerVersion":"v0.4.21\u002Bcommit.dfe3193c","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000f2d5c484e662d5aba856607756d622980acb11ce00000000000000000000000000cb02093b426d6ea221a670c65729dac9cd361c00000000000000000000000000f25de5c07121c7ecb6f458ea4a0c4f44928a37000000000000000000000000d08a079cb9c6c91e15875adaff8031a41cb8c0d6000000000000000000000000b055759410a7cb835f60c900bd44abd9d6cd5e520000000000000000000000001a7219e08bfd868979be92c7624d69ae6599e7a8","Library":"","SwarmSource":"bzzr://c36617ec2d97a3335a178fa77ec60e1f4db7e4b5a996d11f595bf27cdba18c85"}]