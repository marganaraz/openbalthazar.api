[{"SourceCode":"pragma solidity 0.4.25;\n\n// File: contracts/wallet_trading_limiter/interfaces/IWalletsTradingLimiter.sol\n\n/**\n * @title Wallets Trading Limiter Interface.\n */\ninterface IWalletsTradingLimiter {\n    /**\n     * @dev Increment the limiter value of a wallet.\n     * @param _wallet The address of the wallet.\n     * @param _value The amount to be updated.\n     */\n    function updateWallet(address _wallet, uint256 _value) external;\n}\n\n// File: contracts/wallet_trading_limiter/interfaces/IWalletsTradingDataSource.sol\n\n/**\n * @title Wallets Trading Data Source Interface.\n */\ninterface IWalletsTradingDataSource {\n    /**\n     * @dev Increment the value of a given wallet.\n     * @param _wallet The address of the wallet.\n     * @param _value The value to increment by.\n     * @param _limit The limit of the wallet.\n     */\n    function updateWallet(address _wallet, uint256 _value, uint256 _limit) external;\n}\n\n// File: contracts/wallet_trading_limiter/interfaces/IWalletsTradingLimiterValueConverter.sol\n\n/**\n * @title Wallets Trading Limiter Value Converter Interface.\n */\ninterface IWalletsTradingLimiterValueConverter {\n    /**\n     * @dev Get the current limiter currency worth of a given SGA amount.\n     * @param _sgaAmount The amount of SGA to convert.\n     * @return The equivalent amount of the limiter currency.\n     */\n    function toLimiterValue(uint256 _sgaAmount) external view returns (uint256);\n}\n\n// File: contracts/wallet_trading_limiter/interfaces/ITradingClasses.sol\n\n/**\n * @title Trading Classes Interface.\n */\ninterface ITradingClasses {\n    /**\n     * @dev Get the limit of a class.\n     * @param _id The id of the class.\n     * @return The limit of the class.\n     */\n    function getLimit(uint256 _id) external view returns (uint256);\n}\n\n// File: contracts/contract_address_locator/interfaces/IContractAddressLocator.sol\n\n/**\n * @title Contract Address Locator Interface.\n */\ninterface IContractAddressLocator {\n    /**\n     * @dev Get the contract address mapped to a given identifier.\n     * @param _identifier The identifier.\n     * @return The contract address.\n     */\n    function getContractAddress(bytes32 _identifier) external view returns (address);\n\n    /**\n     * @dev Determine whether or not a contract address relates to one of the identifiers.\n     * @param _contractAddress The contract address to look for.\n     * @param _identifiers The identifiers.\n     * @return A boolean indicating if the contract address relates to one of the identifiers.\n     */\n    function isContractAddressRelates(address _contractAddress, bytes32[] _identifiers) external view returns (bool);\n}\n\n// File: contracts/contract_address_locator/ContractAddressLocatorHolder.sol\n\n/**\n * @title Contract Address Locator Holder.\n * @dev Hold a contract address locator, which maps a unique identifier to every contract address in the system.\n * @dev Any contract which inherits from this contract can retrieve the address of any contract in the system.\n * @dev Thus, any contract can remain \u0022oblivious\u0022 to the replacement of any other contract in the system.\n * @dev In addition to that, any function in any contract can be restricted to a specific caller.\n */\ncontract ContractAddressLocatorHolder {\n    bytes32 internal constant _IAuthorizationDataSource_ = \u0022IAuthorizationDataSource\u0022;\n    bytes32 internal constant _ISGNConversionManager_    = \u0022ISGNConversionManager\u0022      ;\n    bytes32 internal constant _IModelDataSource_         = \u0022IModelDataSource\u0022        ;\n    bytes32 internal constant _IPaymentHandler_          = \u0022IPaymentHandler\u0022            ;\n    bytes32 internal constant _IPaymentManager_          = \u0022IPaymentManager\u0022            ;\n    bytes32 internal constant _IPaymentQueue_            = \u0022IPaymentQueue\u0022              ;\n    bytes32 internal constant _IReconciliationAdjuster_  = \u0022IReconciliationAdjuster\u0022      ;\n    bytes32 internal constant _IIntervalIterator_        = \u0022IIntervalIterator\u0022       ;\n    bytes32 internal constant _IMintHandler_             = \u0022IMintHandler\u0022            ;\n    bytes32 internal constant _IMintListener_            = \u0022IMintListener\u0022           ;\n    bytes32 internal constant _IMintManager_             = \u0022IMintManager\u0022            ;\n    bytes32 internal constant _IPriceBandCalculator_     = \u0022IPriceBandCalculator\u0022       ;\n    bytes32 internal constant _IModelCalculator_         = \u0022IModelCalculator\u0022        ;\n    bytes32 internal constant _IRedButton_               = \u0022IRedButton\u0022              ;\n    bytes32 internal constant _IReserveManager_          = \u0022IReserveManager\u0022         ;\n    bytes32 internal constant _ISagaExchanger_           = \u0022ISagaExchanger\u0022          ;\n    bytes32 internal constant _IMonetaryModel_               = \u0022IMonetaryModel\u0022              ;\n    bytes32 internal constant _IMonetaryModelState_          = \u0022IMonetaryModelState\u0022         ;\n    bytes32 internal constant _ISGAAuthorizationManager_ = \u0022ISGAAuthorizationManager\u0022;\n    bytes32 internal constant _ISGAToken_                = \u0022ISGAToken\u0022               ;\n    bytes32 internal constant _ISGATokenManager_         = \u0022ISGATokenManager\u0022        ;\n    bytes32 internal constant _ISGNAuthorizationManager_ = \u0022ISGNAuthorizationManager\u0022;\n    bytes32 internal constant _ISGNToken_                = \u0022ISGNToken\u0022               ;\n    bytes32 internal constant _ISGNTokenManager_         = \u0022ISGNTokenManager\u0022        ;\n    bytes32 internal constant _IMintingPointTimersManager_             = \u0022IMintingPointTimersManager\u0022            ;\n    bytes32 internal constant _ITradingClasses_          = \u0022ITradingClasses\u0022         ;\n    bytes32 internal constant _IWalletsTradingLimiterValueConverter_        = \u0022IWalletsTLValueConverter\u0022       ;\n    bytes32 internal constant _IWalletsTradingDataSource_       = \u0022IWalletsTradingDataSource\u0022      ;\n    bytes32 internal constant _WalletsTradingLimiter_SGNTokenManager_          = \u0022WalletsTLSGNTokenManager\u0022         ;\n    bytes32 internal constant _WalletsTradingLimiter_SGATokenManager_          = \u0022WalletsTLSGATokenManager\u0022         ;\n    bytes32 internal constant _IETHConverter_             = \u0022IETHConverter\u0022   ;\n    bytes32 internal constant _ITransactionLimiter_      = \u0022ITransactionLimiter\u0022     ;\n    bytes32 internal constant _ITransactionManager_      = \u0022ITransactionManager\u0022     ;\n    bytes32 internal constant _IRateApprover_      = \u0022IRateApprover\u0022     ;\n\n    IContractAddressLocator private contractAddressLocator;\n\n    /**\n     * @dev Create the contract.\n     * @param _contractAddressLocator The contract address locator.\n     */\n    constructor(IContractAddressLocator _contractAddressLocator) internal {\n        require(_contractAddressLocator != address(0), \u0022locator is illegal\u0022);\n        contractAddressLocator = _contractAddressLocator;\n    }\n\n    /**\n     * @dev Get the contract address locator.\n     * @return The contract address locator.\n     */\n    function getContractAddressLocator() external view returns (IContractAddressLocator) {\n        return contractAddressLocator;\n    }\n\n    /**\n     * @dev Get the contract address mapped to a given identifier.\n     * @param _identifier The identifier.\n     * @return The contract address.\n     */\n    function getContractAddress(bytes32 _identifier) internal view returns (address) {\n        return contractAddressLocator.getContractAddress(_identifier);\n    }\n\n\n\n    /**\n     * @dev Determine whether or not the sender relates to one of the identifiers.\n     * @param _identifiers The identifiers.\n     * @return A boolean indicating if the sender relates to one of the identifiers.\n     */\n    function isSenderAddressRelates(bytes32[] _identifiers) internal view returns (bool) {\n        return contractAddressLocator.isContractAddressRelates(msg.sender, _identifiers);\n    }\n\n    /**\n     * @dev Verify that the caller is mapped to a given identifier.\n     * @param _identifier The identifier.\n     */\n    modifier only(bytes32 _identifier) {\n        require(msg.sender == getContractAddress(_identifier), \u0022caller is illegal\u0022);\n        _;\n    }\n\n}\n\n// File: contracts/authorization/interfaces/IAuthorizationDataSource.sol\n\n/**\n * @title Authorization Data Source Interface.\n */\ninterface IAuthorizationDataSource {\n    /**\n     * @dev Get the authorized action-role of a wallet.\n     * @param _wallet The address of the wallet.\n     * @return The authorized action-role of the wallet.\n     */\n    function getAuthorizedActionRole(address _wallet) external view returns (bool, uint256);\n\n    /**\n     * @dev Get the trade-limit and trade-class of a wallet.\n     * @param _wallet The address of the wallet.\n     * @return The trade-limit and trade-class of the wallet.\n     */\n    function getTradeLimitAndClass(address _wallet) external view returns (uint256, uint256);\n}\n\n// File: openzeppelin-solidity-v1.12.0/contracts/ownership/Ownable.sol\n\n/**\n * @title Ownable\n * @dev The Ownable contract has an owner address, and provides basic authorization control\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\n */\ncontract Ownable {\n  address public owner;\n\n\n  event OwnershipRenounced(address indexed previousOwner);\n  event OwnershipTransferred(\n    address indexed previousOwner,\n    address indexed newOwner\n  );\n\n\n  /**\n   * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\n   * account.\n   */\n  constructor() public {\n    owner = msg.sender;\n  }\n\n  /**\n   * @dev Throws if called by any account other than the owner.\n   */\n  modifier onlyOwner() {\n    require(msg.sender == owner);\n    _;\n  }\n\n  /**\n   * @dev Allows the current owner to relinquish control of the contract.\n   * @notice Renouncing to ownership will leave the contract without an owner.\n   * It will not be possible to call the functions with the \u0060onlyOwner\u0060\n   * modifier anymore.\n   */\n  function renounceOwnership() public onlyOwner {\n    emit OwnershipRenounced(owner);\n    owner = address(0);\n  }\n\n  /**\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\n   * @param _newOwner The address to transfer ownership to.\n   */\n  function transferOwnership(address _newOwner) public onlyOwner {\n    _transferOwnership(_newOwner);\n  }\n\n  /**\n   * @dev Transfers control of the contract to a newOwner.\n   * @param _newOwner The address to transfer ownership to.\n   */\n  function _transferOwnership(address _newOwner) internal {\n    require(_newOwner != address(0));\n    emit OwnershipTransferred(owner, _newOwner);\n    owner = _newOwner;\n  }\n}\n\n// File: openzeppelin-solidity-v1.12.0/contracts/ownership/Claimable.sol\n\n/**\n * @title Claimable\n * @dev Extension for the Ownable contract, where the ownership needs to be claimed.\n * This allows the new owner to accept the transfer.\n */\ncontract Claimable is Ownable {\n  address public pendingOwner;\n\n  /**\n   * @dev Modifier throws if called by any account other than the pendingOwner.\n   */\n  modifier onlyPendingOwner() {\n    require(msg.sender == pendingOwner);\n    _;\n  }\n\n  /**\n   * @dev Allows the current owner to set the pendingOwner address.\n   * @param newOwner The address to transfer ownership to.\n   */\n  function transferOwnership(address newOwner) public onlyOwner {\n    pendingOwner = newOwner;\n  }\n\n  /**\n   * @dev Allows the pendingOwner address to finalize the transfer.\n   */\n  function claimOwnership() public onlyPendingOwner {\n    emit OwnershipTransferred(owner, pendingOwner);\n    owner = pendingOwner;\n    pendingOwner = address(0);\n  }\n}\n\n// File: contracts/wallet_trading_limiter/WalletsTradingLimiterBase.sol\n\n/**\n * @title Wallets Trading Limiter Base.\n */\ncontract WalletsTradingLimiterBase is IWalletsTradingLimiter, ContractAddressLocatorHolder, Claimable {\n    string public constant VERSION = \u00221.0.0\u0022;\n\n    /**\n     * @dev Create the contract.\n     * @param _contractAddressLocator The contract address locator.\n     */\n    constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}\n\n    /**\n     * @dev Return the contract which implements the IAuthorizationDataSource interface.\n     */\n    function getAuthorizationDataSource() public view returns (IAuthorizationDataSource) {\n        return IAuthorizationDataSource(getContractAddress(_IAuthorizationDataSource_));\n    }\n\n    /**\n     * @dev Return the contract which implements the IWalletsTradingDataSource interface.\n     */\n    function getWalletsTradingDataSource() public view returns (IWalletsTradingDataSource) {\n        return IWalletsTradingDataSource(getContractAddress(_IWalletsTradingDataSource_));\n    }\n\n    /**\n     * @dev Return the contract which implements the IWalletsTradingLimiterValueConverter interface.\n     */\n    function getWalletsTradingLimiterValueConverter() public view returns (IWalletsTradingLimiterValueConverter) {\n        return IWalletsTradingLimiterValueConverter(getContractAddress(_IWalletsTradingLimiterValueConverter_));\n    }\n\n    /**\n     * @dev Return the contract which implements the ITradingClasses interface.\n     */\n    function getTradingClasses() public view returns (ITradingClasses) {\n        return ITradingClasses(getContractAddress(_ITradingClasses_));\n    }\n\n    /**\n     * @dev Get the limiter value.\n     * @param _value The amount to be converted to the limiter value.\n     * @return The limiter value worth of the given amount.\n     */\n    function getLimiterValue(uint256 _value) public view returns (uint256);\n\n    /**\n     * @dev Get the contract locator identifier that is permitted to perform update wallet.\n     * @return The contract locator identifier.\n     */\n    function getUpdateWalletPermittedContractLocatorIdentifier() public pure returns (bytes32);\n\n    /**\n     * @dev Increment the limiter value of a wallet.\n     * @param _wallet The address of the wallet.\n     * @param _value The amount to be updated.\n     */\n    function updateWallet(address _wallet, uint256 _value) external only(getUpdateWalletPermittedContractLocatorIdentifier()) {\n        uint256 limiterValue =  getLimiterValue(_value);\n        (uint256 tradeLimit, uint256 tradeClass) = getAuthorizationDataSource().getTradeLimitAndClass(_wallet);\n        uint256 actualLimit = tradeLimit \u003E 0 ? tradeLimit : getTradingClasses().getLimit(tradeClass);\n        getWalletsTradingDataSource().updateWallet(_wallet, limiterValue, actualLimit);\n    }\n}\n\n// File: contracts/saga/SGAWalletsTradingLimiter.sol\n\n/**\n * Details of usage of licenced software see here: https://www.saga.org/software/readme_v1\n */\n\n/**\n * @title SGA Wallets Trading Limiter.\n */\ncontract SGAWalletsTradingLimiter is WalletsTradingLimiterBase {\n    string public constant VERSION = \u00221.0.0\u0022;\n\n    /**\n     * @dev Create the contract.\n     * @param _contractAddressLocator The contract address locator.\n     */\n    constructor(IContractAddressLocator _contractAddressLocator) WalletsTradingLimiterBase(_contractAddressLocator) public {}\n\n\n    /**\n     * @dev Get the contract locator identifier that is permitted to perform update wallet.\n     * @return The contract locator identifier.\n     */\n    function getUpdateWalletPermittedContractLocatorIdentifier() public pure returns (bytes32){\n        return _ISGATokenManager_;\n    }\n\n    /**\n     * @dev Get the limiter value.\n     * @param _value The SGA amount to convert to limiter value.\n     * @return The limiter value worth of the given SGA amount.\n     */\n    function getLimiterValue(uint256 _value) public view returns (uint256){\n        return getWalletsTradingLimiterValueConverter().toLimiterValue(_value);\n    }\n}\n","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022claimOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getContractAddressLocator\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getUpdateWalletPermittedContractLocatorIdentifier\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getTradingClasses\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getWalletsTradingDataSource\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getWalletsTradingLimiterValueConverter\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getLimiterValue\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_wallet\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022updateWallet\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022pendingOwner\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getAuthorizationDataSource\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022VERSION\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_contractAddressLocator\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipRenounced\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"SGAWalletsTradingLimiter","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"1","Runs":"6000","ConstructorArguments":"000000000000000000000000aabcd54faf94925adbe0df117c62961acecbacdb","Library":"","SwarmSource":"bzzr://d3686cfc723b3b94265d10efec998a73ea973e9bf2ebc8786f6702e4905b9558"}]