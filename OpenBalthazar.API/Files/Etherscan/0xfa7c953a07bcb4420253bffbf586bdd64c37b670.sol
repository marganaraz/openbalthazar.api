[{"SourceCode":"// File: contracts/commons/Ownable.sol\r\n\r\npragma solidity ^0.5.16;\r\n\r\n\r\ncontract Ownable {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor() internal {\r\n        _owner = msg.sender;\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        require(msg.sender == _owner, \u0022Ownable: caller is not the owner\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (\u0060newOwner\u0060).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) external onlyOwner {\r\n        require(newOwner != address(0), \u0022Ownable: new owner is the zero address\u0022);\r\n        emit OwnershipTransferred(_owner, newOwner);\r\n        _owner = newOwner;\r\n    }\r\n}\r\n\r\n// File: contracts/commons/Wallet.sol\r\n\r\npragma solidity ^0.5.16;\r\n\r\n\r\n\r\ncontract Wallet is Ownable {\r\n    function execute(\r\n        address payable _to,\r\n        uint256 _value,\r\n        bytes calldata _data\r\n    ) external onlyOwner returns (bool, bytes memory) {\r\n        return _to.call.value(_value)(_data);\r\n    }\r\n}\r\n\r\n// File: contracts/commons/Pausable.sol\r\n\r\npragma solidity ^0.5.16;\r\n\r\n\r\n\r\ncontract Pausable is Ownable {\r\n    bool public paused;\r\n\r\n    event SetPaused(bool _paused);\r\n\r\n    constructor() public {\r\n        emit SetPaused(false);\r\n    }\r\n\r\n    modifier notPaused() {\r\n        require(!paused, \u0022Contract is paused\u0022);\r\n        _;\r\n    }\r\n\r\n    function setPaused(bool _paused) external onlyOwner {\r\n        paused = _paused;\r\n        emit SetPaused(_paused);\r\n    }\r\n}\r\n\r\n// File: contracts/interfaces/ERC20.sol\r\n\r\npragma solidity ^0.5.16;\r\n\r\n\r\ninterface ERC20 {\r\n    function transfer(address _to, uint _value) external returns (bool success);\r\n    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);\r\n    function allowance(address _owner, address _spender) external view returns (uint256 remaining);\r\n    function approve(address _spender, uint256 _value) external returns (bool success);\r\n    function increaseApproval (address _spender, uint _addedValue) external returns (bool success);\r\n    function balanceOf(address _owner) external view returns (uint256 balance);\r\n}\r\n\r\n// File: contracts/interfaces/Model.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n/**\r\n    The abstract contract Model defines the whole lifecycle of a debt on the DebtEngine.\r\n\r\n    Models can be used without previous approbation, this is meant\r\n    to avoid centralization on the development of RCN; this implies that not all models are secure.\r\n    Models can have back-doors, bugs and they have not guarantee of being autonomous.\r\n\r\n    The DebtEngine is meant to be the User of this model,\r\n    so all the methods with the ability to perform state changes should only be callable by the DebtEngine.\r\n\r\n    All models should implement the 0xaf498c35 interface.\r\n\r\n    @author Agustin Aguilar\r\n*/\r\ncontract Model {\r\n    // ///\r\n    // Events\r\n    // ///\r\n\r\n    /**\r\n        @dev This emits when create a new debt.\r\n    */\r\n    event Created(bytes32 indexed _id);\r\n\r\n    /**\r\n        @dev This emits when the status of debt change.\r\n\r\n        @param _timestamp Timestamp of the registry\r\n        @param _status New status of the registry\r\n    */\r\n    event ChangedStatus(bytes32 indexed _id, uint256 _timestamp, uint256 _status);\r\n\r\n    /**\r\n        @dev This emits when the obligation of debt change.\r\n\r\n        @param _timestamp Timestamp of the registry\r\n        @param _debt New debt of the registry\r\n    */\r\n    event ChangedObligation(bytes32 indexed _id, uint256 _timestamp, uint256 _debt);\r\n\r\n    /**\r\n        @dev This emits when the frequency of debt change.\r\n\r\n        @param _timestamp Timestamp of the registry\r\n        @param _frequency New frequency of each installment\r\n    */\r\n    event ChangedFrequency(bytes32 indexed _id, uint256 _timestamp, uint256 _frequency);\r\n\r\n    /**\r\n        @param _timestamp Timestamp of the registry\r\n    */\r\n    event ChangedDueTime(bytes32 indexed _id, uint256 _timestamp, uint256 _status);\r\n\r\n    /**\r\n        @param _timestamp Timestamp of the registry\r\n        @param _dueTime New dueTime of each installment\r\n    */\r\n    event ChangedFinalTime(bytes32 indexed _id, uint256 _timestamp, uint64 _dueTime);\r\n\r\n    /**\r\n        @dev This emits when the call addDebt function.\r\n\r\n        @param _amount New amount of the debt, old amount plus added\r\n    */\r\n    event AddedDebt(bytes32 indexed _id, uint256 _amount);\r\n\r\n    /**\r\n        @dev This emits when the call addPaid function.\r\n\r\n        If the registry is fully paid on the call and the amount parameter exceeds the required\r\n            payment amount, the event emits the real amount paid on the payment.\r\n\r\n        @param _paid Real amount paid\r\n    */\r\n    event AddedPaid(bytes32 indexed _id, uint256 _paid);\r\n\r\n    // Model interface selector\r\n    bytes4 internal constant MODEL_INTERFACE = 0xaf498c35;\r\n\r\n    uint256 public constant STATUS_ONGOING = 1;\r\n    uint256 public constant STATUS_PAID = 2;\r\n    uint256 public constant STATUS_ERROR = 4;\r\n\r\n    // ///\r\n    // Meta\r\n    // ///\r\n\r\n    /**\r\n        @return Identifier of the model\r\n    */\r\n    function modelId() external view returns (bytes32);\r\n\r\n    /**\r\n        Returns the address of the contract used as Descriptor of the model\r\n\r\n        @dev The descriptor contract should follow the ModelDescriptor.sol scheme\r\n\r\n        @return Address of the descriptor\r\n    */\r\n    function descriptor() external view returns (address);\r\n\r\n    /**\r\n        If called for any address with the ability to modify the state of the model registries,\r\n            this method should return True.\r\n\r\n        @dev Some contracts may check if the DebtEngine is\r\n            an operator to know if the model is operative or not.\r\n\r\n        @param operator Address of the target request operator\r\n\r\n        @return True if operator is able to modify the state of the model\r\n    */\r\n    function isOperator(address operator) external view returns (bool canOperate);\r\n\r\n    /**\r\n        Validates the data for the creation of a new registry, if returns True the\r\n            same data should be compatible with the create method.\r\n\r\n        @dev This method can revert the call or return false, and both meant an invalid data.\r\n\r\n        @param data Data to validate\r\n\r\n        @return True if the data can be used to create a new registry\r\n    */\r\n    function validate(bytes calldata data) external view returns (bool isValid);\r\n\r\n    // ///\r\n    // Getters\r\n    // ///\r\n\r\n    /**\r\n        Exposes the current status of the registry. The possible values are:\r\n\r\n        1: Ongoing - The debt is still ongoing and waiting to be paid\r\n        2: Paid - The debt is already paid and\r\n        4: Error - There was an Error with the registry\r\n\r\n        @dev This method should always be called by the DebtEngine\r\n\r\n        @param id Id of the registry\r\n\r\n        @return The current status value\r\n    */\r\n    function getStatus(bytes32 id) external view returns (uint256 status);\r\n\r\n    /**\r\n        Returns the total paid amount on the registry.\r\n\r\n        @dev it should equal to the sum of all real addPaid\r\n\r\n        @param id Id of the registry\r\n\r\n        @return Total paid amount\r\n    */\r\n    function getPaid(bytes32 id) external view returns (uint256 paid);\r\n\r\n    /**\r\n        If the returned amount does not depend on any interactions and only on the model logic,\r\n            the defined flag will be True; if the amount is an estimation of the future debt,\r\n            the flag will be set to False.\r\n\r\n        If timestamp equals the current moment, the defined flag should always be True.\r\n\r\n        @dev This can be a gas-intensive method to call, consider calling the run method before.\r\n\r\n        @param id Id of the registry\r\n        @param timestamp Timestamp of the obligation query\r\n\r\n        @return amount Amount pending to pay on the given timestamp\r\n        @return defined True If the amount returned is fixed and can\u0027t change\r\n    */\r\n    function getObligation(bytes32 id, uint64 timestamp) external view returns (uint256 amount, bool defined);\r\n\r\n    /**\r\n        The amount required to fully paid a registry.\r\n\r\n        All registries should be payable in a single time, even when it has multiple installments.\r\n\r\n        If the registry discounts interest for early payment, those discounts should be\r\n            taken into account in the returned amount.\r\n\r\n        @dev This can be a gas-intensive method to call, consider calling the run method before.\r\n\r\n        @param id Id of the registry\r\n\r\n        @return amount Amount required to fully paid the loan on the current timestamp\r\n    */\r\n    function getClosingObligation(bytes32 id) external view returns (uint256 amount);\r\n\r\n    /**\r\n        The timestamp of the next required payment.\r\n\r\n        After this moment, if the payment goal is not met the debt will be considered overdue.\r\n\r\n            The getObligation method can be used to know the required payment on the future timestamp.\r\n\r\n        @param id Id of the registry\r\n\r\n        @return timestamp The timestamp of the next due time\r\n    */\r\n    function getDueTime(bytes32 id) external view returns (uint256 timestamp);\r\n\r\n    // ///\r\n    // Metadata\r\n    // ///\r\n\r\n    /**\r\n        If the loan has multiple installments returns the duration of each installment in seconds,\r\n            if the loan has not installments it should return 1.\r\n\r\n        @param id Id of the registry\r\n\r\n        @return frequency Frequency of each installment\r\n    */\r\n    function getFrequency(bytes32 id) external view returns (uint256 frequency);\r\n\r\n    /**\r\n        If the loan has multiple installments returns the total of installments,\r\n            if the loan has not installments it should return 1.\r\n\r\n        @param id Id of the registry\r\n\r\n        @return installments Total of installments\r\n    */\r\n    function getInstallments(bytes32 id) external view returns (uint256 installments);\r\n\r\n    /**\r\n        The registry could be paid before or after the date, but the debt will always be\r\n            considered overdue if paid after this timestamp.\r\n\r\n        This is the estimated final payment date of the debt if it\u0027s always paid on each exact dueTime.\r\n\r\n        @param id Id of the registry\r\n\r\n        @return timestamp Timestamp of the final due time\r\n    */\r\n    function getFinalTime(bytes32 id) external view returns (uint256 timestamp);\r\n\r\n    /**\r\n        Similar to getFinalTime returns the expected payment remaining if paid always on the exact dueTime.\r\n\r\n        If the model has no interest discounts for early payments,\r\n            this method should return the same value as getClosingObligation.\r\n\r\n        @param id Id of the registry\r\n\r\n        @return amount Expected payment amount\r\n    */\r\n    function getEstimateObligation(bytes32 id) external view returns (uint256 amount);\r\n\r\n    // ///\r\n    // State interface\r\n    // ///\r\n\r\n    /**\r\n        Creates a new registry using the provided data and id, it should fail if the id already exists\r\n            or if calling validate(data) returns false or throws.\r\n\r\n        @dev This method should only be callable by an operator\r\n\r\n        @param id Id of the registry to create\r\n        @param data Data to construct the new registry\r\n\r\n        @return success True if the registry was created\r\n    */\r\n    function create(bytes32 id, bytes calldata data) external returns (bool success);\r\n\r\n    /**\r\n        If the registry is fully paid on the call and the amount parameter exceeds the required\r\n            payment amount, the method returns the real amount used on the payment.\r\n\r\n        The payment taken should always be the same as the requested unless the registry\r\n            is fully paid on the process.\r\n\r\n        @dev This method should only be callable by an operator\r\n\r\n        @param id If of the registry\r\n        @param amount Amount to pay\r\n\r\n        @return real Real amount paid\r\n    */\r\n    function addPaid(bytes32 id, uint256 amount) external returns (uint256 real);\r\n\r\n    /**\r\n        Adds a new amount to be paid on the debt model,\r\n            each model can handle the addition of more debt freely.\r\n\r\n        @dev This method should only be callable by an operator\r\n\r\n        @param id Id of the registrya\r\n        @param amount Debt amount to add to the registry\r\n\r\n        @return added True if the debt was added\r\n    */\r\n    function addDebt(bytes32 id, uint256 amount) external returns (bool added);\r\n\r\n    // ///\r\n    // Utils\r\n    // ///\r\n\r\n    /**\r\n        Runs the internal clock of a registry, this is used to compute the last changes on the state.\r\n            It can make transactions cheaper by avoiding multiple calculations when calling views.\r\n\r\n        Not all models have internal clocks, a model without an internal clock should always return false.\r\n\r\n        Calls to this method should be possible from any address,\r\n            multiple calls to run shouldn\u0027t affect the internal calculations of the model.\r\n\r\n        @dev If the call had no effect the method would return False,\r\n            that is no sign of things going wrong, and the call shouldn\u0027t be wrapped on a require\r\n\r\n        @param id If of the registry\r\n\r\n        @return effect True if the run performed a change on the state\r\n    */\r\n    function run(bytes32 id) external returns (bool effect);\r\n}\r\n\r\n// File: contracts/interfaces/DebtEngine.sol\r\n\r\npragma solidity ^0.5.16;\r\n\r\n\r\ninterface DebtEngine {\r\n    function pay(\r\n        bytes32 _id,\r\n        uint256 _amount,\r\n        address _origin,\r\n        bytes calldata _oracleData\r\n    ) external returns (uint256 paid, uint256 paidToken);\r\n}\r\n\r\n// File: contracts/interfaces/LoanManager.sol\r\n\r\npragma solidity ^0.5.16;\r\n\r\n\r\n\r\n\r\ninterface LoanManager {\r\n    function token() external view returns (ERC20);\r\n    function debtEngine() external view returns (DebtEngine);\r\n    function getStatus(uint256 _id) external view returns (uint256);\r\n    function getModel(uint256 _id) external view returns (Model);\r\n    function cosign(uint256 _id, uint256 _cost) external returns (bool);\r\n    function getCreator(uint256 _id) external view returns (address);\r\n}\r\n\r\n// File: contracts/interfaces/Cosigner.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n\r\n/**\r\n    @dev Defines the interface of a standard RCN cosigner.\r\n\r\n    The cosigner is an agent that gives an insurance to the lender in the event of a defaulted loan, the confitions\r\n    of the insurance and the cost of the given are defined by the cosigner.\r\n\r\n    The lender will decide what cosigner to use, if any; the address of the cosigner and the valid data provided by the\r\n    agent should be passed as params when the lender calls the \u0022lend\u0022 method on the engine.\r\n\r\n    When the default conditions defined by the cosigner aligns with the status of the loan, the lender of the engine\r\n    should be able to call the \u0022claim\u0022 method to receive the benefit; the cosigner can define aditional requirements to\r\n    call this method, like the transfer of the ownership of the loan.\r\n*/\r\ncontract Cosigner {\r\n    uint256 public constant VERSION = 2;\r\n\r\n    /**\r\n        @return the url of the endpoint that exposes the insurance offers.\r\n    */\r\n    function url() external view returns (string memory);\r\n\r\n    /**\r\n        @dev Retrieves the cost of a given insurance, this amount should be exact.\r\n\r\n        @return the cost of the cosign, in RCN wei\r\n    */\r\n    function cost(\r\n        LoanManager manager,\r\n        uint256 index,\r\n        bytes calldata data,\r\n        bytes calldata oracleData\r\n    )\r\n        external view returns (uint256);\r\n\r\n    /**\r\n        @dev The engine calls this method for confirmation of the conditions, if the cosigner accepts the liability of\r\n        the insurance it must call the method \u0022cosign\u0022 of the engine. If the cosigner does not call that method, or\r\n        does not return true to this method, the operation fails.\r\n\r\n        @return true if the cosigner accepts the liability\r\n    */\r\n    function requestCosign(\r\n        LoanManager manager,\r\n        uint256 index,\r\n        bytes calldata data,\r\n        bytes calldata oracleData\r\n    )\r\n        external returns (bool);\r\n\r\n    /**\r\n        @dev Claims the benefit of the insurance if the loan is defaulted, this method should be only calleable by the\r\n        current lender of the loan.\r\n\r\n        @return true if the claim was done correctly.\r\n    */\r\n    function claim(LoanManager manager, uint256 index, bytes calldata oracleData) external returns (bool);\r\n}\r\n\r\n// File: contracts/RPCosignerV2.sol\r\n\r\npragma solidity ^0.5.16;\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\ncontract RPCosignerV2 is Cosigner, Ownable, Wallet, Pausable {\r\n    uint256 public deltaPayment = 1 days;\r\n    bool public legacyEnabled = true;\r\n\r\n    LoanManager public manager;\r\n    DebtEngine public engine;\r\n\r\n    mapping(address =\u003E bool) public originators;\r\n    mapping(uint256 =\u003E bool) public liability;\r\n\r\n    event SetOriginator(address _originator, bool _enabled);\r\n    event SetDeltaPayment(uint256 _prev, uint256 _val);\r\n    event SetLegacyEnabled(bool _enabled);\r\n    event Cosigned(uint256 _id);\r\n    event Paid(uint256 _id, uint256 _amount, uint256 _tokens);\r\n\r\n    string private constant ERROR_PREFIX = \u0022rpcosigner: \u0022;\r\n\r\n    string private constant ERROR_INVALID_MANAGER = string(abi.encodePacked(ERROR_PREFIX, \u0022invalid loan manager\u0022));\r\n    string private constant ERROR_INVALID_ORIGINATOR = string(abi.encodePacked(ERROR_PREFIX, \u0022invalid loan originator\u0022));\r\n    string private constant ERROR_DUPLICATED_LIABILITY = string(abi.encodePacked(ERROR_PREFIX, \u0022duplicated liability\u0022));\r\n    string private constant ERROR_COSIGN_FAILED = string(abi.encodePacked(ERROR_PREFIX, \u0022failed cosign\u0022));\r\n    string private constant ERROR_INVALID_LOAN_STATUS = string(abi.encodePacked(ERROR_PREFIX, \u0022invalid loan status\u0022));\r\n    string private constant ERROR_LOAN_NOT_OUTSTANDING = string(abi.encodePacked(ERROR_PREFIX, \u0022not outstanding loan\u0022));\r\n    string private constant ERROR_LEGACY_DISABLED = string(abi.encodePacked(ERROR_PREFIX, \u0022legacy claim is disabled\u0022));\r\n\r\n    uint256 private constant LOAN_STATUS_LENT = 1;\r\n\r\n    constructor(\r\n        LoanManager _manager\r\n    ) public {\r\n        // Load cre variables\r\n        ERC20 _token = _manager.token();\r\n        DebtEngine tengine = _manager.debtEngine();\r\n        // Approve token for payments\r\n        _token.approve(address(tengine), uint(-1));\r\n        // Save to storage\r\n        manager = _manager;\r\n        engine = tengine;\r\n        // Emit initial events\r\n        emit SetDeltaPayment(0, deltaPayment);\r\n        emit SetLegacyEnabled(legacyEnabled);\r\n    }\r\n\r\n    function setOriginator(address _originator, bool _enabled) external onlyOwner {\r\n        emit SetOriginator(_originator, _enabled);\r\n        originators[_originator] = _enabled;\r\n    }\r\n\r\n    function setDeltaPayment(uint256 _delta) external onlyOwner {\r\n        emit SetDeltaPayment(deltaPayment, _delta);\r\n        deltaPayment = _delta;\r\n    }\r\n\r\n    function setLegacyEnabled(bool _enabled) external onlyOwner {\r\n        emit SetLegacyEnabled(_enabled);\r\n        legacyEnabled = _enabled;\r\n    }\r\n\r\n    function url() external view returns (string memory) {\r\n        return \u0022\u0022;\r\n    }\r\n\r\n    function cost(\r\n        LoanManager,\r\n        uint256,\r\n        bytes calldata,\r\n        bytes calldata\r\n    ) external view returns (uint256) {\r\n        return 0;\r\n    }\r\n\r\n    function requestCosign(\r\n        LoanManager _manager,\r\n        uint256 _index,\r\n        bytes calldata,\r\n        bytes calldata\r\n    ) external notPaused returns (bool) {\r\n        require(_manager == manager, ERROR_INVALID_MANAGER);\r\n        require(originators[_manager.getCreator(_index)], ERROR_INVALID_ORIGINATOR);\r\n        require(!liability[_index], ERROR_DUPLICATED_LIABILITY);\r\n        liability[_index] = true;\r\n        require(_manager.cosign(_index, 0), ERROR_COSIGN_FAILED);\r\n        emit Cosigned(_index);\r\n        return true;\r\n    }\r\n\r\n    function claim(\r\n        LoanManager _manager,\r\n        uint256 _index,\r\n        bytes calldata _oracleData\r\n    ) external returns (bool) {\r\n        require(_manager == manager, ERROR_INVALID_MANAGER);\r\n        require(_manager.getStatus(_index) == LOAN_STATUS_LENT, ERROR_INVALID_LOAN_STATUS);\r\n\r\n        Model model = _manager.getModel(_index);\r\n\r\n        uint256 dueTime = model.getDueTime(bytes32(_index));\r\n        require(dueTime \u002B deltaPayment \u003C now, ERROR_LOAN_NOT_OUTSTANDING);\r\n\r\n        if (!liability[_index]) {\r\n            require(originators[_manager.getCreator(_index)], ERROR_INVALID_ORIGINATOR);\r\n            require(legacyEnabled, ERROR_LEGACY_DISABLED);\r\n        }\r\n\r\n        (uint256 paid, uint256 tokens) = engine.pay(bytes32(_index), uint(-1), address(this), _oracleData);\r\n        emit Paid(_index, paid, tokens);\r\n        return true;\r\n    }\r\n}","ABI":"[{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract LoanManager\u0022,\u0022name\u0022:\u0022_manager\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Cosigned\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022previousOwner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022OwnershipTransferred\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_id\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_tokens\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Paid\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_prev\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_val\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022SetDeltaPayment\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_enabled\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022SetLegacyEnabled\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_originator\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_enabled\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022SetOriginator\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_paused\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022SetPaused\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022VERSION\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract LoanManager\u0022,\u0022name\u0022:\u0022_manager\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_index\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022_oracleData\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022claim\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract LoanManager\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022cost\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022deltaPayment\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022engine\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract DebtEngine\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address payable\u0022,\u0022name\u0022:\u0022_to\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_value\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022_data\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022execute\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022legacyEnabled\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022liability\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022manager\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract LoanManager\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022originators\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022owner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022paused\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022contract LoanManager\u0022,\u0022name\u0022:\u0022_manager\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_index\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes\u0022},{\u0022internalType\u0022:\u0022bytes\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes\u0022}],\u0022name\u0022:\u0022requestCosign\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_delta\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setDeltaPayment\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_enabled\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setLegacyEnabled\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_originator\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_enabled\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setOriginator\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022_paused\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022name\u0022:\u0022setPaused\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newOwner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022transferOwnership\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022url\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"RPCosignerV2","CompilerVersion":"v0.5.16\u002Bcommit.9c3226ce","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000b55b0f33d6a2a03a275ca85d58e9357e1a141187","Library":"","SwarmSource":"bzzr://2673f9875409d97791923dcbc16b275f1553721c17790cbcbea0c3725025c302"}]