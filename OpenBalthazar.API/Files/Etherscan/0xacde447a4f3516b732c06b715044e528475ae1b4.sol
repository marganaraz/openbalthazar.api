[{"SourceCode":"pragma solidity 0.4.25;\n\n// File: openzeppelin-solidity-v1.12.0/contracts/ownership/Ownable.sol\n\n/**\n * @title Ownable\n * @dev The Ownable contract has an owner address, and provides basic authorization control\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\n */\ncontract Ownable {\n  address public owner;\n\n\n  event OwnershipRenounced(address indexed previousOwner);\n  event OwnershipTransferred(\n    address indexed previousOwner,\n    address indexed newOwner\n  );\n\n\n  /**\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\n   * account.\n   */\n  constructor() public {\n    owner = msg.sender;\n  }\n\n  /**\n   * @dev Throws if called by any account other than the owner.\n   */\n  modifier onlyOwner() {\n    require(msg.sender == owner);\n    _;\n  }\n\n  /**\n   * @dev Allows the current owner to relinquish control of the contract.\n   * @notice Renouncing to ownership will leave the contract without an owner.\n   * It will not be possible to call the functions with the \u0060onlyOwner\u0060\n   * modifier anymore.\n   */\n  function renounceOwnership() public onlyOwner {\n    emit OwnershipRenounced(owner);\n    owner = address(0);\n  }\n\n  /**\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\n   * @param _newOwner The address to transfer ownership to.\n   */\n  function transferOwnership(address _newOwner) public onlyOwner {\n    _transferOwnership(_newOwner);\n  }\n\n  /**\n   * @dev Transfers control of the contract to a newOwner.\n   * @param _newOwner The address to transfer ownership to.\n   */\n  function _transferOwnership(address _newOwner) internal {\n    require(_newOwner != address(0));\n    emit OwnershipTransferred(owner, _newOwner);\n    owner = _newOwner;\n  }\n}\n\n// File: openzeppelin-solidity-v1.12.0/contracts/ownership/Claimable.sol\n\n/**\n * @title Claimable\n * @dev Extension for the Ownable contract, where the ownership needs to be claimed.\n * This allows the new owner to accept the transfer.\n */\ncontract Claimable is Ownable {\n  address public pendingOwner;\n\n  /**\n   * @dev Modifier throws if called by any account other than the pendingOwner.\n   */\n  modifier onlyPendingOwner() {\n    require(msg.sender == pendingOwner);\n    _;\n  }\n\n  /**\n   * @dev Allows the current owner to set the pendingOwner address.\n   * @param newOwner The address to transfer ownership to.\n   */\n  function transferOwnership(address newOwner) public onlyOwner {\n    pendingOwner = newOwner;\n  }\n\n  /**\n   * @dev Allows the pendingOwner address to finalize the transfer.\n   */\n  function claimOwnership() public onlyPendingOwner {\n    emit OwnershipTransferred(owner, pendingOwner);\n    owner = pendingOwner;\n    pendingOwner = address(0);\n  }\n}\n\n// File: contracts/utils/Adminable.sol\n\n/**\n * @title Adminable.\n */\ncontract Adminable is Claimable {\n    address[] public adminArray;\n\n    struct AdminInfo {\n        bool valid;\n        uint256 index;\n    }\n\n    mapping(address =\u003E AdminInfo) public adminTable;\n\n    event AdminAccepted(address indexed _admin);\n    event AdminRejected(address indexed _admin);\n\n    /**\n     * @dev Reverts if called by any account other than one of the administrators.\n     */\n    modifier onlyAdmin() {\n        require(adminTable[msg.sender].valid, \u0022caller is illegal\u0022);\n        _;\n    }\n\n    /**\n     * @dev Accept a new administrator.\n     * @param _admin The administrator\u0027s address.\n     */\n    function accept(address _admin) external onlyOwner {\n        require(_admin != address(0), \u0022administrator is illegal\u0022);\n        AdminInfo storage adminInfo = adminTable[_admin];\n        require(!adminInfo.valid, \u0022administrator is already accepted\u0022);\n        adminInfo.valid = true;\n        adminInfo.index = adminArray.length;\n        adminArray.push(_admin);\n        emit AdminAccepted(_admin);\n    }\n\n    /**\n     * @dev Reject an existing administrator.\n     * @param _admin The administrator\u0027s address.\n     */\n    function reject(address _admin) external onlyOwner {\n        AdminInfo storage adminInfo = adminTable[_admin];\n        require(adminArray.length \u003E adminInfo.index, \u0022administrator is already rejected\u0022);\n        require(_admin == adminArray[adminInfo.index], \u0022administrator is already rejected\u0022);\n        // at this point we know that adminArray.length \u003E adminInfo.index \u003E= 0\n        address lastAdmin = adminArray[adminArray.length - 1]; // will never underflow\n        adminTable[lastAdmin].index = adminInfo.index;\n        adminArray[adminInfo.index] = lastAdmin;\n        adminArray.length -= 1; // will never underflow\n        delete adminTable[_admin];\n        emit AdminRejected(_admin);\n    }\n\n    /**\n     * @dev Get an array of all the administrators.\n     * @return An array of all the administrators.\n     */\n    function getAdminArray() external view returns (address[] memory) {\n        return adminArray;\n    }\n\n    /**\n     * @dev Get the total number of administrators.\n     * @return The total number of administrators.\n     */\n    function getAdminCount() external view returns (uint256) {\n        return adminArray.length;\n    }\n}\n\n// File: contracts/authorization/interfaces/IAuthorizationDataSource.sol\n\n/**\n * @title Authorization Data Source Interface.\n */\ninterface IAuthorizationDataSource {\n    /**\n     * @dev Get the authorized action-role of a wallet.\n     * @param _wallet The address of the wallet.\n     * @return The authorized action-role of the wallet.\n     */\n    function getAuthorizedActionRole(address _wallet) external view returns (bool, uint256);\n\n    /**\n     * @dev Get the authorized action-role and trade-class of a wallet.\n     * @param _wallet The address of the wallet.\n     * @return The authorized action-role and class of the wallet.\n     */\n    function getAuthorizedActionRoleAndClass(address _wallet) external view returns (bool, uint256, uint256);\n\n    /**\n     * @dev Get all the trade-limits and trade-class of a wallet.\n     * @param _wallet The address of the wallet.\n     * @return The trade-limits and trade-class of the wallet.\n     */\n    function getTradeLimitsAndClass(address _wallet) external view returns (uint256, uint256, uint256);\n\n\n    /**\n     * @dev Get the buy trade-limit and trade-class of a wallet.\n     * @param _wallet The address of the wallet.\n     * @return The buy trade-limit and trade-class of the wallet.\n     */\n    function getBuyTradeLimitAndClass(address _wallet) external view returns (uint256, uint256);\n\n    /**\n     * @dev Get the sell trade-limit and trade-class of a wallet.\n     * @param _wallet The address of the wallet.\n     * @return The sell trade-limit and trade-class of the wallet.\n     */\n    function getSellTradeLimitAndClass(address _wallet) external view returns (uint256, uint256);\n}\n\n// File: contracts/authorization/AuthorizationDataSource.sol\n\n/**\n * Details of usage of licenced software see here: https://www.saga.org/software/readme_v1\n */\n\n/**\n * @title Authorization Data Source.\n */\ncontract AuthorizationDataSource is IAuthorizationDataSource, Adminable {\n    string public constant VERSION = \u00222.0.0\u0022;\n\n    uint256 public walletCount;\n\n    struct WalletInfo {\n        uint256 sequenceNum;\n        bool isWhitelisted;\n        uint256 actionRole;\n        uint256 buyLimit;\n        uint256 sellLimit;\n        uint256 tradeClass;\n    }\n\n    mapping(address =\u003E WalletInfo) public walletTable;\n\n    event WalletSaved(address indexed _wallet);\n    event WalletDeleted(address indexed _wallet);\n    event WalletNotSaved(address indexed _wallet);\n    event WalletNotDeleted(address indexed _wallet);\n\n    /**\n     * @dev Get the authorized action-role of a wallet.\n     * @param _wallet The address of the wallet.\n     * @return The authorized action-role of the wallet.\n     */\n    function getAuthorizedActionRole(address _wallet) external view returns (bool, uint256) {\n        WalletInfo storage walletInfo = walletTable[_wallet];\n        return (walletInfo.isWhitelisted, walletInfo.actionRole);\n    }\n\n    /**\n     * @dev Get the authorized action-role and trade-class of a wallet.\n     * @param _wallet The address of the wallet.\n     * @return The authorized action-role and class of the wallet.\n     */\n    function getAuthorizedActionRoleAndClass(address _wallet) external view returns (bool, uint256, uint256) {\n        WalletInfo storage walletInfo = walletTable[_wallet];\n        return (walletInfo.isWhitelisted, walletInfo.actionRole, walletInfo.tradeClass);\n    }\n\n    /**\n     * @dev Get all the trade-limits and trade-class of a wallet.\n     * @param _wallet The address of the wallet.\n     * @return The trade-limits and trade-class of the wallet.\n     */\n    function getTradeLimitsAndClass(address _wallet) external view returns (uint256, uint256, uint256) {\n        WalletInfo storage walletInfo = walletTable[_wallet];\n        return (walletInfo.buyLimit, walletInfo.sellLimit, walletInfo.tradeClass);\n    }\n\n    /**\n     * @dev Get the buy trade-limit and trade-class of a wallet.\n     * @param _wallet The address of the wallet.\n     * @return The buy trade-limit and trade-class of the wallet.\n     */\n    function getBuyTradeLimitAndClass(address _wallet) external view returns (uint256, uint256) {\n        WalletInfo storage walletInfo = walletTable[_wallet];\n        return (walletInfo.buyLimit, walletInfo.tradeClass);\n    }\n\n    /**\n     * @dev Get the sell trade-limit and trade-class of a wallet.\n     * @param _wallet The address of the wallet.\n     * @return The sell trade-limit and trade-class of the wallet.\n     */\n    function getSellTradeLimitAndClass(address _wallet) external view returns (uint256, uint256) {\n        WalletInfo storage walletInfo = walletTable[_wallet];\n        return (walletInfo.sellLimit, walletInfo.tradeClass);\n    }\n\n    /**\n     * @dev Insert or update a wallet.\n     * @param _wallet The address of the wallet.\n     * @param _sequenceNum The sequence-number of the operation.\n     * @param _isWhitelisted The authorization of the wallet.\n     * @param _actionRole The action-role of the wallet.\n     * @param _buyLimit The buy trade-limit of the wallet.\n     * @param _sellLimit The sell trade-limit of the wallet.\n     * @param _tradeClass The trade-class of the wallet.\n     */\n    function upsertOne(address _wallet, uint256 _sequenceNum, bool _isWhitelisted, uint256 _actionRole, uint256 _buyLimit, uint256 _sellLimit, uint256 _tradeClass) external onlyAdmin {\n        _upsert(_wallet, _sequenceNum, _isWhitelisted, _actionRole, _buyLimit, _sellLimit, _tradeClass);\n    }\n\n    /**\n     * @dev Remove a wallet.\n     * @param _wallet The address of the wallet.\n     */\n    function removeOne(address _wallet) external onlyAdmin {\n        _remove(_wallet);\n    }\n\n    /**\n     * @dev Insert or update a list of wallets with the same params.\n     * @param _wallets The addresses of the wallets.\n     * @param _sequenceNum The sequence-number of the operation.\n     * @param _isWhitelisted The authorization of all the wallets.\n     * @param _actionRole The action-role of all the the wallets.\n     * @param _buyLimit The buy trade-limit of all the wallets.\n     * @param _sellLimit The sell trade-limit of all the wallets.\n     * @param _tradeClass The trade-class of all the wallets.\n     */\n    function upsertAll(address[] _wallets, uint256 _sequenceNum, bool _isWhitelisted, uint256 _actionRole, uint256 _buyLimit, uint256 _sellLimit, uint256 _tradeClass) external onlyAdmin {\n        for (uint256 i = 0; i \u003C _wallets.length; i\u002B\u002B)\n            _upsert(_wallets[i], _sequenceNum, _isWhitelisted, _actionRole, _buyLimit, _sellLimit, _tradeClass);\n    }\n\n    /**\n     * @dev Remove a list of wallets.\n     * @param _wallets The addresses of the wallets.\n     */\n    function removeAll(address[] _wallets) external onlyAdmin {\n        for (uint256 i = 0; i \u003C _wallets.length; i\u002B\u002B)\n            _remove(_wallets[i]);\n    }\n\n    /**\n     * @dev Insert or update a wallet.\n     * @param _wallet The address of the wallet.\n     * @param _sequenceNum The sequence-number of the operation.\n     * @param _isWhitelisted The authorization of the wallet.\n     * @param _actionRole The action-role of the wallet.\n     * @param _buyLimit The buy trade-limit of the wallet.\n     * @param _sellLimit The sell trade-limit of the wallet.\n     * @param _tradeClass The trade-class of the wallet.\n     */\n    function _upsert(address _wallet, uint256 _sequenceNum, bool _isWhitelisted, uint256 _actionRole, uint256 _buyLimit, uint256 _sellLimit, uint256 _tradeClass) private {\n        require(_wallet != address(0), \u0022wallet is illegal\u0022);\n        WalletInfo storage walletInfo = walletTable[_wallet];\n        if (walletInfo.sequenceNum \u003C _sequenceNum) {\n            if (walletInfo.sequenceNum == 0) // increment the wallet-count only when a new wallet is inserted\n                walletCount \u002B= 1; // will never overflow because the number of different wallets = 2^160 \u003C 2^256\n            walletInfo.sequenceNum = _sequenceNum;\n            walletInfo.isWhitelisted = _isWhitelisted;\n            walletInfo.actionRole = _actionRole;\n            walletInfo.buyLimit = _buyLimit;\n            walletInfo.sellLimit = _sellLimit;\n            walletInfo.tradeClass = _tradeClass;\n            emit WalletSaved(_wallet);\n        }\n        else {\n            emit WalletNotSaved(_wallet);\n        }\n    }\n\n    /**\n     * @dev Remove a wallet.\n     * @param _wallet The address of the wallet.\n     */\n    function _remove(address _wallet) private {\n        require(_wallet != address(0), \u0022wallet is illegal\u0022);\n        WalletInfo storage walletInfo = walletTable[_wallet];\n        if (walletInfo.sequenceNum \u003E 0) { // decrement the wallet-count only when an existing wallet is removed\n            walletCount -= 1; // will never underflow because every decrement follows a corresponding increment\n            delete walletTable[_wallet];\n            emit WalletDeleted(_wallet);\n        }\n        else {\n            emit WalletNotDeleted(_wallet);\n        }\n    }\n}\n","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getAuthorizedActionRole\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022walletCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022adminTable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022valid\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_wallets\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022name\u0022:\u0022removeAll\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022claimOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_wallets\u0022,\u0022type\u0022:\u0022address[]\u0022},{\u0022name\u0022:\u0022_sequenceNum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_isWhitelisted\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022_actionRole\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_buyLimit\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_sellLimit\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_tradeClass\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022upsertAll\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAdminArray\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address[]\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAdminCount\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_sequenceNum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_isWhitelisted\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022_actionRole\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_buyLimit\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_sellLimit\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_tradeClass\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022upsertOne\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022adminArray\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_admin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022accept\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_admin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022reject\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getTradeLimitsAndClass\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getSellTradeLimitAndClass\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022walletTable\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022sequenceNum\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022isWhitelisted\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022actionRole\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022buyLimit\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022sellLimit\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022tradeClass\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeOne\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pendingOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getBuyTradeLimitAndClass\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getAuthorizedActionRoleAndClass\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022VERSION\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WalletSaved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WalletDeleted\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WalletNotSaved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WalletNotDeleted\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_admin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022AdminAccepted\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022_admin\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022AdminRejected\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipRenounced\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"AuthorizationDataSource","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"1","Runs":"6000","ConstructorArguments":"","Library":"","SwarmSource":""}]