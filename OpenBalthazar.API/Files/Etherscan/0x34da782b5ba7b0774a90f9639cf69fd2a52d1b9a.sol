[{"SourceCode":"pragma solidity 0.4.25;\n\n// File: contracts/saga-genesis/interfaces/ISGNAuthorizationManager.sol\n\n/**\n * @title SGN Authorization Manager Interface.\n */\ninterface ISGNAuthorizationManager {\n    /**\n     * @dev Determine whether or not a user is authorized to sell SGN.\n     * @param _sender The address of the user.\n     * @return Authorization status.\n     */\n    function isAuthorizedToSell(address _sender) external view returns (bool);\n\n    /**\n     * @dev Determine whether or not a user is authorized to transfer SGN to another user.\n     * @param _sender The address of the source user.\n     * @param _target The address of the target user.\n     * @return Authorization status.\n     */\n    function isAuthorizedToTransfer(address _sender, address _target) external view returns (bool);\n\n    /**\n     * @dev Determine whether or not a user is authorized to transfer SGN from one user to another user.\n     * @param _sender The address of the custodian user.\n     * @param _source The address of the source user.\n     * @param _target The address of the target user.\n     * @return Authorization status.\n     */\n    function isAuthorizedToTransferFrom(address _sender, address _source, address _target) external view returns (bool);\n}\n\n// File: contracts/contract_address_locator/interfaces/IContractAddressLocator.sol\n\n/**\n * @title Contract Address Locator Interface.\n */\ninterface IContractAddressLocator {\n    /**\n     * @dev Get the contract address mapped to a given identifier.\n     * @param _identifier The identifier.\n     * @return The contract address.\n     */\n    function getContractAddress(bytes32 _identifier) external view returns (address);\n\n    /**\n     * @dev Determine whether or not a contract address relates to one of the identifiers.\n     * @param _contractAddress The contract address to look for.\n     * @param _identifiers The identifiers.\n     * @return A boolean indicating if the contract address relates to one of the identifiers.\n     */\n    function isContractAddressRelates(address _contractAddress, bytes32[] _identifiers) external view returns (bool);\n}\n\n// File: contracts/contract_address_locator/ContractAddressLocatorHolder.sol\n\n/**\n * @title Contract Address Locator Holder.\n * @dev Hold a contract address locator, which maps a unique identifier to every contract address in the system.\n * @dev Any contract which inherits from this contract can retrieve the address of any contract in the system.\n * @dev Thus, any contract can remain \u0022oblivious\u0022 to the replacement of any other contract in the system.\n * @dev In addition to that, any function in any contract can be restricted to a specific caller.\n */\ncontract ContractAddressLocatorHolder {\n    bytes32 internal constant _IAuthorizationDataSource_ = \u0022IAuthorizationDataSource\u0022;\n    bytes32 internal constant _ISGNConversionManager_    = \u0022ISGNConversionManager\u0022      ;\n    bytes32 internal constant _IModelDataSource_         = \u0022IModelDataSource\u0022        ;\n    bytes32 internal constant _IPaymentHandler_          = \u0022IPaymentHandler\u0022            ;\n    bytes32 internal constant _IPaymentManager_          = \u0022IPaymentManager\u0022            ;\n    bytes32 internal constant _IPaymentQueue_            = \u0022IPaymentQueue\u0022              ;\n    bytes32 internal constant _IReconciliationAdjuster_  = \u0022IReconciliationAdjuster\u0022      ;\n    bytes32 internal constant _IIntervalIterator_        = \u0022IIntervalIterator\u0022       ;\n    bytes32 internal constant _IMintHandler_             = \u0022IMintHandler\u0022            ;\n    bytes32 internal constant _IMintListener_            = \u0022IMintListener\u0022           ;\n    bytes32 internal constant _IMintManager_             = \u0022IMintManager\u0022            ;\n    bytes32 internal constant _IPriceBandCalculator_     = \u0022IPriceBandCalculator\u0022       ;\n    bytes32 internal constant _IModelCalculator_         = \u0022IModelCalculator\u0022        ;\n    bytes32 internal constant _IRedButton_               = \u0022IRedButton\u0022              ;\n    bytes32 internal constant _IReserveManager_          = \u0022IReserveManager\u0022         ;\n    bytes32 internal constant _ISagaExchanger_           = \u0022ISagaExchanger\u0022          ;\n    bytes32 internal constant _IMonetaryModel_               = \u0022IMonetaryModel\u0022              ;\n    bytes32 internal constant _IMonetaryModelState_          = \u0022IMonetaryModelState\u0022         ;\n    bytes32 internal constant _ISGAAuthorizationManager_ = \u0022ISGAAuthorizationManager\u0022;\n    bytes32 internal constant _ISGAToken_                = \u0022ISGAToken\u0022               ;\n    bytes32 internal constant _ISGATokenManager_         = \u0022ISGATokenManager\u0022        ;\n    bytes32 internal constant _ISGNAuthorizationManager_ = \u0022ISGNAuthorizationManager\u0022;\n    bytes32 internal constant _ISGNToken_                = \u0022ISGNToken\u0022               ;\n    bytes32 internal constant _ISGNTokenManager_         = \u0022ISGNTokenManager\u0022        ;\n    bytes32 internal constant _IMintingPointTimersManager_             = \u0022IMintingPointTimersManager\u0022            ;\n    bytes32 internal constant _ITradingClasses_          = \u0022ITradingClasses\u0022         ;\n    bytes32 internal constant _IWalletsTradingLimiterValueConverter_        = \u0022IWalletsTLValueConverter\u0022       ;\n    bytes32 internal constant _BuyWalletsTradingDataSource_       = \u0022BuyWalletsTradingDataSource\u0022      ;\n    bytes32 internal constant _SellWalletsTradingDataSource_       = \u0022SellWalletsTradingDataSource\u0022      ;\n    bytes32 internal constant _WalletsTradingLimiter_SGNTokenManager_          = \u0022WalletsTLSGNTokenManager\u0022         ;\n    bytes32 internal constant _BuyWalletsTradingLimiter_SGATokenManager_          = \u0022BuyWalletsTLSGATokenManager\u0022         ;\n    bytes32 internal constant _SellWalletsTradingLimiter_SGATokenManager_          = \u0022SellWalletsTLSGATokenManager\u0022         ;\n    bytes32 internal constant _IETHConverter_             = \u0022IETHConverter\u0022   ;\n    bytes32 internal constant _ITransactionLimiter_      = \u0022ITransactionLimiter\u0022     ;\n    bytes32 internal constant _ITransactionManager_      = \u0022ITransactionManager\u0022     ;\n    bytes32 internal constant _IRateApprover_      = \u0022IRateApprover\u0022     ;\n\n    IContractAddressLocator private contractAddressLocator;\n\n    /**\n     * @dev Create the contract.\n     * @param _contractAddressLocator The contract address locator.\n     */\n    constructor(IContractAddressLocator _contractAddressLocator) internal {\n        require(_contractAddressLocator != address(0), \u0022locator is illegal\u0022);\n        contractAddressLocator = _contractAddressLocator;\n    }\n\n    /**\n     * @dev Get the contract address locator.\n     * @return The contract address locator.\n     */\n    function getContractAddressLocator() external view returns (IContractAddressLocator) {\n        return contractAddressLocator;\n    }\n\n    /**\n     * @dev Get the contract address mapped to a given identifier.\n     * @param _identifier The identifier.\n     * @return The contract address.\n     */\n    function getContractAddress(bytes32 _identifier) internal view returns (address) {\n        return contractAddressLocator.getContractAddress(_identifier);\n    }\n\n\n\n    /**\n     * @dev Determine whether or not the sender relates to one of the identifiers.\n     * @param _identifiers The identifiers.\n     * @return A boolean indicating if the sender relates to one of the identifiers.\n     */\n    function isSenderAddressRelates(bytes32[] _identifiers) internal view returns (bool) {\n        return contractAddressLocator.isContractAddressRelates(msg.sender, _identifiers);\n    }\n\n    /**\n     * @dev Verify that the caller is mapped to a given identifier.\n     * @param _identifier The identifier.\n     */\n    modifier only(bytes32 _identifier) {\n        require(msg.sender == getContractAddress(_identifier), \u0022caller is illegal\u0022);\n        _;\n    }\n\n}\n\n// File: contracts/authorization/AuthorizationActionRoles.sol\n\n/**\n * @title Authorization Action Roles.\n */\nlibrary AuthorizationActionRoles {\n    string public constant VERSION = \u00221.1.0\u0022;\n\n    enum Flag {\n        BuySga         ,\n        SellSga        ,\n        SellSgn        ,\n        ReceiveSgn     ,\n        TransferSgn    ,\n        TransferFromSgn\n    }\n\n    function isAuthorizedToBuySga         (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.BuySga         );}\n    function isAuthorizedToSellSga        (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.SellSga        );}\n    function isAuthorizedToSellSgn        (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.SellSgn        );}\n    function isAuthorizedToReceiveSgn     (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.ReceiveSgn     );}\n    function isAuthorizedToTransferSgn    (uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.TransferSgn    );}\n    function isAuthorizedToTransferFromSgn(uint256 _flags) internal pure returns (bool) {return isAuthorized(_flags, Flag.TransferFromSgn);}\n    function isAuthorized(uint256 _flags, Flag _flag) private pure returns (bool) {return ((_flags \u003E\u003E uint256(_flag)) \u0026 1) == 1;}\n}\n\n// File: contracts/authorization/interfaces/IAuthorizationDataSource.sol\n\n/**\n * @title Authorization Data Source Interface.\n */\ninterface IAuthorizationDataSource {\n    /**\n     * @dev Get the authorized action-role of a wallet.\n     * @param _wallet The address of the wallet.\n     * @return The authorized action-role of the wallet.\n     */\n    function getAuthorizedActionRole(address _wallet) external view returns (bool, uint256);\n\n    /**\n     * @dev Get the authorized action-role and trade-class of a wallet.\n     * @param _wallet The address of the wallet.\n     * @return The authorized action-role and class of the wallet.\n     */\n    function getAuthorizedActionRoleAndClass(address _wallet) external view returns (bool, uint256, uint256);\n\n    /**\n     * @dev Get all the trade-limits and trade-class of a wallet.\n     * @param _wallet The address of the wallet.\n     * @return The trade-limits and trade-class of the wallet.\n     */\n    function getTradeLimitsAndClass(address _wallet) external view returns (uint256, uint256, uint256);\n\n\n    /**\n     * @dev Get the buy trade-limit and trade-class of a wallet.\n     * @param _wallet The address of the wallet.\n     * @return The buy trade-limit and trade-class of the wallet.\n     */\n    function getBuyTradeLimitAndClass(address _wallet) external view returns (uint256, uint256);\n\n    /**\n     * @dev Get the sell trade-limit and trade-class of a wallet.\n     * @param _wallet The address of the wallet.\n     * @return The sell trade-limit and trade-class of the wallet.\n     */\n    function getSellTradeLimitAndClass(address _wallet) external view returns (uint256, uint256);\n}\n\n// File: contracts/wallet_trading_limiter/interfaces/ITradingClasses.sol\n\n/**\n * @title Trading Classes Interface.\n */\ninterface ITradingClasses {\n    /**\n     * @dev Get the complete info of a class.\n     * @param _id The id of the class.\n     * @return complete info of a class.\n     */\n    function getInfo(uint256 _id) external view returns (uint256, uint256, uint256);\n\n    /**\n     * @dev Get the action-role of a class.\n     * @param _id The id of the class.\n     * @return The action-role of the class.\n     */\n    function getActionRole(uint256 _id) external view returns (uint256);\n\n    /**\n     * @dev Get the sell limit of a class.\n     * @param _id The id of the class.\n     * @return The sell limit of the class.\n     */\n    function getSellLimit(uint256 _id) external view returns (uint256);\n\n    /**\n     * @dev Get the buy limit of a class.\n     * @param _id The id of the class.\n     * @return The buy limit of the class.\n     */\n    function getBuyLimit(uint256 _id) external view returns (uint256);\n}\n\n// File: contracts/saga-genesis/SGNAuthorizationManager.sol\n\n/**\n * Details of usage of licenced software see here: https://www.saga.org/software/readme_v1\n */\n\n/**\n * @title SGN Authorization Manager.\n */\ncontract SGNAuthorizationManager is ISGNAuthorizationManager, ContractAddressLocatorHolder {\n    string public constant VERSION = \u00221.1.0\u0022;\n\n    using AuthorizationActionRoles for uint256;\n\n    /**\n     * @dev Create the contract.\n     * @param _contractAddressLocator The contract address locator.\n     */\n    constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}\n\n    /**\n     * @dev Return the contract which implements the IAuthorizationDataSource interface.\n     */\n    function getAuthorizationDataSource() public view returns (IAuthorizationDataSource) {\n        return IAuthorizationDataSource(getContractAddress(_IAuthorizationDataSource_));\n    }\n\n    /**\n    * @dev Return the contract which implements the ITradingClasses interface.\n    */\n    function getTradingClasses() public view returns (ITradingClasses) {\n        return ITradingClasses(getContractAddress(_ITradingClasses_));\n    }\n\n    /**\n     * @dev Determine whether or not a wallet is authorized to sell SGN.\n     * @param _sender The address of the wallet.\n     * @return Authorization status.\n     */\n    function isAuthorizedToSell(address _sender) external view returns (bool) {\n        (bool senderIsWhitelisted, uint256 senderActionRole, uint256 senderTradeClassId) = getAuthorizationDataSource().getAuthorizedActionRoleAndClass(_sender);\n\n        return senderIsWhitelisted \u0026\u0026 getActionRole(senderActionRole, senderTradeClassId).isAuthorizedToSellSgn();\n    }\n\n    /**\n     * @dev Determine whether or not a wallet is authorized to transfer SGN to another wallet.\n     * @param _sender The address of the source wallet.\n     * @param _target The address of the target wallet.\n     * @return Authorization status.\n     */\n    function isAuthorizedToTransfer(address _sender, address _target) external view returns (bool) {\n        IAuthorizationDataSource authorizationDataSource = getAuthorizationDataSource();\n        (bool senderIsWhitelisted, uint256 senderActionRole, uint256 senderTradeClassId) = authorizationDataSource.getAuthorizedActionRoleAndClass(_sender);\n        (bool targetIsWhitelisted, uint256 targetActionRole, uint256 targetTradeClassId) = authorizationDataSource.getAuthorizedActionRoleAndClass(_target);\n\n        return senderIsWhitelisted \u0026\u0026 targetIsWhitelisted \u0026\u0026\n        getActionRole(senderActionRole, senderTradeClassId).isAuthorizedToTransferSgn() \u0026\u0026\n        getActionRole(targetActionRole, targetTradeClassId).isAuthorizedToReceiveSgn();\n    }\n\n    /**\n     * @dev Determine whether or not a wallet is authorized to transfer SGN from one wallet to another wallet.\n     * @param _sender The address of the wallet initiating the transaction.\n     * @param _source The address of the source wallet.\n     * @param _target The address of the target wallet.\n     * @return Authorization status.\n     */\n    function isAuthorizedToTransferFrom(address _sender, address _source, address _target) external view returns (bool) {\n        IAuthorizationDataSource authorizationDataSource = getAuthorizationDataSource();\n        (bool senderIsWhitelisted, uint256 senderActionRole, uint256 senderTradeClassId) = authorizationDataSource.getAuthorizedActionRoleAndClass(_sender);\n        (bool sourceIsWhitelisted, uint256 sourceActionRole, uint256 sourceTradeClassId) = authorizationDataSource.getAuthorizedActionRoleAndClass(_source);\n        (bool targetIsWhitelisted, uint256 targetActionRole, uint256 targetTradeClassId) = authorizationDataSource.getAuthorizedActionRoleAndClass(_target);\n\n        return senderIsWhitelisted \u0026\u0026 sourceIsWhitelisted \u0026\u0026 targetIsWhitelisted \u0026\u0026\n        getActionRole(senderActionRole, senderTradeClassId).isAuthorizedToTransferFromSgn() \u0026\u0026\n        getActionRole(sourceActionRole, sourceTradeClassId).isAuthorizedToTransferSgn() \u0026\u0026\n        getActionRole(targetActionRole, targetTradeClassId).isAuthorizedToReceiveSgn();\n    }\n\n    /**\n     * @dev Get the relevant action-role.\n     * @return The relevant action-role.\n     */\n    function getActionRole(uint256 _actionRole, uint256 _tradeClassId) private view returns (uint256) {\n        return _actionRole \u003E 0 ? _actionRole : getTradingClasses().getActionRole(_tradeClassId);\n    }\n}\n","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isAuthorizedToTransfer\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_source\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_target\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isAuthorizedToTransferFrom\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getContractAddressLocator\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getTradingClasses\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_sender\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isAuthorizedToSell\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAuthorizationDataSource\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022VERSION\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_contractAddressLocator\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"SGNAuthorizationManager","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"1","Runs":"6000","ConstructorArguments":"000000000000000000000000aabcd54faf94925adbe0df117c62961acecbacdb","Library":"","SwarmSource":""}]