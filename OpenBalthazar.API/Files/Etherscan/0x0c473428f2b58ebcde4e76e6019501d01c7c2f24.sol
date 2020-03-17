[{"SourceCode":"pragma solidity 0.4.25;\n\n// File: contracts/saga/interfaces/IModelDataSource.sol\n\n/**\n * @title Model Data Source Interface.\n */\ninterface IModelDataSource {\n    /**\n     * @dev Get interval parameters.\n     * @param _rowNum Interval row index.\n     * @param _colNum Interval column index.\n     * @return Interval minimum amount of SGA.\n     * @return Interval maximum amount of SGA.\n     * @return Interval minimum amount of SDR.\n     * @return Interval maximum amount of SDR.\n     * @return Interval alpha value (scaled up).\n     * @return Interval beta  value (scaled up).\n     */\n    function getInterval(uint256 _rowNum, uint256 _colNum) external view returns (uint256, uint256, uint256, uint256, uint256, uint256);\n\n    /**\n     * @dev Get interval alpha and beta.\n     * @param _rowNum Interval row index.\n     * @param _colNum Interval column index.\n     * @return Interval alpha value (scaled up).\n     * @return Interval beta  value (scaled up).\n     */\n    function getIntervalCoefs(uint256 _rowNum, uint256 _colNum) external view returns (uint256, uint256);\n\n    /**\n     * @dev Get the amount of SGA required for moving to the next minting-point.\n     * @param _rowNum Interval row index.\n     * @return Required amount of SGA.\n     */\n    function getRequiredMintAmount(uint256 _rowNum) external view returns (uint256);\n}\n\n// File: contracts/saga/interfaces/IMintingPointTimersManager.sol\n\n/**\n * @title Minting Point Timers Manager Interface.\n */\ninterface IMintingPointTimersManager {\n    /**\n     * @dev Start a given timestamp.\n     * @param _id The ID of the timestamp.\n     * @notice When tested, this timestamp will be either \u0027running\u0027 or \u0027expired\u0027.\n     */\n    function start(uint256 _id) external;\n\n    /**\n     * @dev Reset a given timestamp.\n     * @param _id The ID of the timestamp.\n     * @notice When tested, this timestamp will be neither \u0027running\u0027 nor \u0027expired\u0027.\n     */\n    function reset(uint256 _id) external;\n\n    /**\n     * @dev Get an indication of whether or not a given timestamp is \u0027running\u0027.\n     * @param _id The ID of the timestamp.\n     * @return An indication of whether or not a given timestamp is \u0027running\u0027.\n     * @notice Even if this timestamp is not \u0027running\u0027, it is not necessarily \u0027expired\u0027.\n     */\n    function running(uint256 _id) external view returns (bool);\n\n    /**\n     * @dev Get an indication of whether or not a given timestamp is \u0027expired\u0027.\n     * @param _id The ID of the timestamp.\n     * @return An indication of whether or not a given timestamp is \u0027expired\u0027.\n     * @notice Even if this timestamp is not \u0027expired\u0027, it is not necessarily \u0027running\u0027.\n     */\n    function expired(uint256 _id) external view returns (bool);\n}\n\n// File: contracts/saga/interfaces/IIntervalIterator.sol\n\n/**\n * @title Interval Iterator Interface.\n */\ninterface IIntervalIterator {\n    /**\n     * @dev Move to a higher interval and start a corresponding timer if necessary.\n     */\n    function grow() external;\n\n    /**\n     * @dev Reset the timer of the current interval if necessary and move to a lower interval.\n     */\n    function shrink() external;\n\n    /**\n     * @dev Return the current interval.\n     */\n    function getCurrentInterval() external view returns (uint256, uint256, uint256, uint256, uint256, uint256);\n\n    /**\n     * @dev Return the current interval coefficients.\n     */\n    function getCurrentIntervalCoefs() external view returns (uint256, uint256);\n}\n\n// File: contracts/contract_address_locator/interfaces/IContractAddressLocator.sol\n\n/**\n * @title Contract Address Locator Interface.\n */\ninterface IContractAddressLocator {\n    /**\n     * @dev Get the contract address mapped to a given identifier.\n     * @param _identifier The identifier.\n     * @return The contract address.\n     */\n    function getContractAddress(bytes32 _identifier) external view returns (address);\n\n    /**\n     * @dev Determine whether or not a contract address relates to one of the identifiers.\n     * @param _contractAddress The contract address to look for.\n     * @param _identifiers The identifiers.\n     * @return A boolean indicating if the contract address relates to one of the identifiers.\n     */\n    function isContractAddressRelates(address _contractAddress, bytes32[] _identifiers) external view returns (bool);\n}\n\n// File: contracts/contract_address_locator/ContractAddressLocatorHolder.sol\n\n/**\n * @title Contract Address Locator Holder.\n * @dev Hold a contract address locator, which maps a unique identifier to every contract address in the system.\n * @dev Any contract which inherits from this contract can retrieve the address of any contract in the system.\n * @dev Thus, any contract can remain \u0022oblivious\u0022 to the replacement of any other contract in the system.\n * @dev In addition to that, any function in any contract can be restricted to a specific caller.\n */\ncontract ContractAddressLocatorHolder {\n    bytes32 internal constant _IAuthorizationDataSource_ = \u0022IAuthorizationDataSource\u0022;\n    bytes32 internal constant _ISGNConversionManager_    = \u0022ISGNConversionManager\u0022      ;\n    bytes32 internal constant _IModelDataSource_         = \u0022IModelDataSource\u0022        ;\n    bytes32 internal constant _IPaymentHandler_          = \u0022IPaymentHandler\u0022            ;\n    bytes32 internal constant _IPaymentManager_          = \u0022IPaymentManager\u0022            ;\n    bytes32 internal constant _IPaymentQueue_            = \u0022IPaymentQueue\u0022              ;\n    bytes32 internal constant _IReconciliationAdjuster_  = \u0022IReconciliationAdjuster\u0022      ;\n    bytes32 internal constant _IIntervalIterator_        = \u0022IIntervalIterator\u0022       ;\n    bytes32 internal constant _IMintHandler_             = \u0022IMintHandler\u0022            ;\n    bytes32 internal constant _IMintListener_            = \u0022IMintListener\u0022           ;\n    bytes32 internal constant _IMintManager_             = \u0022IMintManager\u0022            ;\n    bytes32 internal constant _IPriceBandCalculator_     = \u0022IPriceBandCalculator\u0022       ;\n    bytes32 internal constant _IModelCalculator_         = \u0022IModelCalculator\u0022        ;\n    bytes32 internal constant _IRedButton_               = \u0022IRedButton\u0022              ;\n    bytes32 internal constant _IReserveManager_          = \u0022IReserveManager\u0022         ;\n    bytes32 internal constant _ISagaExchanger_           = \u0022ISagaExchanger\u0022          ;\n    bytes32 internal constant _IMonetaryModel_               = \u0022IMonetaryModel\u0022              ;\n    bytes32 internal constant _IMonetaryModelState_          = \u0022IMonetaryModelState\u0022         ;\n    bytes32 internal constant _ISGAAuthorizationManager_ = \u0022ISGAAuthorizationManager\u0022;\n    bytes32 internal constant _ISGAToken_                = \u0022ISGAToken\u0022               ;\n    bytes32 internal constant _ISGATokenManager_         = \u0022ISGATokenManager\u0022        ;\n    bytes32 internal constant _ISGNAuthorizationManager_ = \u0022ISGNAuthorizationManager\u0022;\n    bytes32 internal constant _ISGNToken_                = \u0022ISGNToken\u0022               ;\n    bytes32 internal constant _ISGNTokenManager_         = \u0022ISGNTokenManager\u0022        ;\n    bytes32 internal constant _IMintingPointTimersManager_             = \u0022IMintingPointTimersManager\u0022            ;\n    bytes32 internal constant _ITradingClasses_          = \u0022ITradingClasses\u0022         ;\n    bytes32 internal constant _IWalletsTradingLimiterValueConverter_        = \u0022IWalletsTLValueConverter\u0022       ;\n    bytes32 internal constant _IWalletsTradingDataSource_       = \u0022IWalletsTradingDataSource\u0022      ;\n    bytes32 internal constant _WalletsTradingLimiter_SGNTokenManager_          = \u0022WalletsTLSGNTokenManager\u0022         ;\n    bytes32 internal constant _WalletsTradingLimiter_SGATokenManager_          = \u0022WalletsTLSGATokenManager\u0022         ;\n    bytes32 internal constant _IETHConverter_             = \u0022IETHConverter\u0022   ;\n    bytes32 internal constant _ITransactionLimiter_      = \u0022ITransactionLimiter\u0022     ;\n    bytes32 internal constant _ITransactionManager_      = \u0022ITransactionManager\u0022     ;\n    bytes32 internal constant _IRateApprover_      = \u0022IRateApprover\u0022     ;\n\n    IContractAddressLocator private contractAddressLocator;\n\n    /**\n     * @dev Create the contract.\n     * @param _contractAddressLocator The contract address locator.\n     */\n    constructor(IContractAddressLocator _contractAddressLocator) internal {\n        require(_contractAddressLocator != address(0), \u0022locator is illegal\u0022);\n        contractAddressLocator = _contractAddressLocator;\n    }\n\n    /**\n     * @dev Get the contract address locator.\n     * @return The contract address locator.\n     */\n    function getContractAddressLocator() external view returns (IContractAddressLocator) {\n        return contractAddressLocator;\n    }\n\n    /**\n     * @dev Get the contract address mapped to a given identifier.\n     * @param _identifier The identifier.\n     * @return The contract address.\n     */\n    function getContractAddress(bytes32 _identifier) internal view returns (address) {\n        return contractAddressLocator.getContractAddress(_identifier);\n    }\n\n\n\n    /**\n     * @dev Determine whether or not the sender relates to one of the identifiers.\n     * @param _identifiers The identifiers.\n     * @return A boolean indicating if the sender relates to one of the identifiers.\n     */\n    function isSenderAddressRelates(bytes32[] _identifiers) internal view returns (bool) {\n        return contractAddressLocator.isContractAddressRelates(msg.sender, _identifiers);\n    }\n\n    /**\n     * @dev Verify that the caller is mapped to a given identifier.\n     * @param _identifier The identifier.\n     */\n    modifier only(bytes32 _identifier) {\n        require(msg.sender == getContractAddress(_identifier), \u0022caller is illegal\u0022);\n        _;\n    }\n\n}\n\n// File: contracts/saga/IntervalIterator.sol\n\n/**\n * Details of usage of licenced software see here: https://www.saga.org/software/readme_v1\n */\n\n/**\n * @title Interval Iterator.\n */\ncontract IntervalIterator is IIntervalIterator, ContractAddressLocatorHolder {\n    string public constant VERSION = \u00221.0.0\u0022;\n\n    uint256 public row;\n    uint256 public col;\n\n    /**\n     * @dev Create the contract.\n     * @param _contractAddressLocator The contract address locator.\n     */\n    constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}\n\n    /**\n     * @dev Return the contract which implements the IModelDataSource interface.\n     */\n    function getModelDataSource() public view returns (IModelDataSource) {\n        return IModelDataSource(getContractAddress(_IModelDataSource_));\n    }\n\n    /**\n     * @dev Return the contract which implements the IMintingPointTimersManager interface.\n     */\n    function getMintingPointTimersManager() public view returns (IMintingPointTimersManager) {\n        return IMintingPointTimersManager(getContractAddress(_IMintingPointTimersManager_));\n    }\n\n    /**\n     * @dev Move to a higher interval and start a corresponding timer if necessary.\n     */\n    function grow() external only(_IMonetaryModel_) {\n        if (col == 0) {\n            row \u002B= 1;\n            getMintingPointTimersManager().start(row);\n        }\n        else {\n            col -= 1;\n        }\n    }\n\n    /**\n     * @dev Reset the timer of the current interval if necessary and move to a lower interval.\n     */\n    function shrink() external only(_IMonetaryModel_) {\n        IMintingPointTimersManager mintingPointTimersManager = getMintingPointTimersManager();\n        if (mintingPointTimersManager.running(row)) {\n            mintingPointTimersManager.reset(row);\n            assert(row \u003E 0);\n            row -= 1;\n        }\n        else {\n            col \u002B= 1;\n        }\n    }\n\n    /**\n     * @dev Return the current interval.\n     */\n    function getCurrentInterval() external view returns (uint256, uint256, uint256, uint256, uint256, uint256) {\n        return getModelDataSource().getInterval(row, col);\n    }\n\n    /**\n     * @dev Return the current interval coefficients.\n     */\n    function getCurrentIntervalCoefs() external view returns (uint256, uint256) {\n        return getModelDataSource().getIntervalCoefs(row, col);\n    }\n}\n","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022shrink\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCurrentInterval\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022grow\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022row\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getModelDataSource\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getContractAddressLocator\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022col\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getMintingPointTimersManager\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getCurrentIntervalCoefs\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022VERSION\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_contractAddressLocator\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"IntervalIterator","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"1","Runs":"6000","ConstructorArguments":"000000000000000000000000aabcd54faf94925adbe0df117c62961acecbacdb","Library":"","SwarmSource":"bzzr://2b66772af77b42c9b16e0ed1e1df5cad412651688c0f1868ce0cf2d25020f0a8"}]