[{"SourceCode":"// File: contracts/IManager.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\ncontract IManager {\r\n    event SetController(address controller);\r\n    event ParameterUpdate(string param);\r\n\r\n    function setController(address _controller) external;\r\n}\r\n\r\n// File: contracts/zeppelin/Ownable.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n/**\r\n * @title Ownable\r\n * @dev The Ownable contract has an owner address, and provides basic authorization control\r\n * functions, this simplifies the implementation of \u0022user permissions\u0022.\r\n */\r\ncontract Ownable {\r\n    address public owner;\r\n\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n\r\n    /**\r\n    * @dev The Ownable constructor sets the original \u0060owner\u0060 of the contract to the sender\r\n    * account.\r\n    */\r\n    constructor() public {\r\n        owner = msg.sender;\r\n    }\r\n\r\n  /**\r\n   * @dev Throws if called by any account other than the owner.\r\n   */\r\n    modifier onlyOwner() {\r\n        require(msg.sender == owner);\r\n        _;\r\n    }\r\n\r\n\r\n    /**\r\n    * @dev Allows the current owner to transfer control of the contract to a newOwner.\r\n    * @param newOwner The address to transfer ownership to.\r\n    */\r\n    function transferOwnership(address newOwner) public onlyOwner {\r\n        require(newOwner != address(0));\r\n        emit OwnershipTransferred(owner, newOwner);\r\n        owner = newOwner;\r\n    }\r\n}\r\n\r\n// File: contracts/zeppelin/Pausable.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n\r\n/**\r\n * @title Pausable\r\n * @dev Base contract which allows children to implement an emergency stop mechanism.\r\n */\r\ncontract Pausable is Ownable {\r\n    event Pause();\r\n    event Unpause();\r\n\r\n    bool public paused = false;\r\n\r\n\r\n    /**\r\n    * @dev Modifier to make a function callable only when the contract is not paused.\r\n    */\r\n    modifier whenNotPaused() {\r\n        require(!paused);\r\n        _;\r\n    }\r\n\r\n    /**\r\n    * @dev Modifier to make a function callable only when the contract is paused.\r\n    */\r\n    modifier whenPaused() {\r\n        require(paused);\r\n        _;\r\n    }\r\n\r\n    /**\r\n    * @dev called by the owner to pause, triggers stopped state\r\n    */\r\n    function pause() public onlyOwner whenNotPaused {\r\n        paused = true;\r\n        emit Pause();\r\n    }\r\n\r\n    /**\r\n    * @dev called by the owner to unpause, returns to normal state\r\n    */\r\n    function unpause() public onlyOwner whenPaused {\r\n        paused = false;\r\n        emit Unpause();\r\n    }\r\n}\r\n\r\n// File: contracts/IController.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n\r\ncontract IController is Pausable {\r\n    event SetContractInfo(bytes32 id, address contractAddress, bytes20 gitCommitHash);\r\n\r\n    function setContractInfo(bytes32 _id, address _contractAddress, bytes20 _gitCommitHash) external;\r\n    function updateController(bytes32 _id, address _controller) external;\r\n    function getContract(bytes32 _id) public view returns (address);\r\n}\r\n\r\n// File: contracts/Manager.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n\r\n\r\ncontract Manager is IManager {\r\n    // Controller that contract is registered with\r\n    IController public controller;\r\n\r\n    // Check if sender is controller\r\n    modifier onlyController() {\r\n        require(msg.sender == address(controller), \u0022caller must be Controller\u0022);\r\n        _;\r\n    }\r\n\r\n    // Check if sender is controller owner\r\n    modifier onlyControllerOwner() {\r\n        require(msg.sender == controller.owner(), \u0022caller must be Controller owner\u0022);\r\n        _;\r\n    }\r\n\r\n    // Check if controller is not paused\r\n    modifier whenSystemNotPaused() {\r\n        require(!controller.paused(), \u0022system is paused\u0022);\r\n        _;\r\n    }\r\n\r\n    // Check if controller is paused\r\n    modifier whenSystemPaused() {\r\n        require(controller.paused(), \u0022system is not paused\u0022);\r\n        _;\r\n    }\r\n\r\n    constructor(address _controller) public {\r\n        controller = IController(_controller);\r\n    }\r\n\r\n    /**\r\n     * @notice Set controller. Only callable by current controller\r\n     * @param _controller Controller contract address\r\n     */\r\n    function setController(address _controller) external onlyController {\r\n        controller = IController(_controller);\r\n\r\n        emit SetController(_controller);\r\n    }\r\n}\r\n\r\n// File: contracts/ManagerProxyTarget.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n\r\n/**\r\n * @title ManagerProxyTarget\r\n * @notice The base contract that target contracts used by a proxy contract should inherit from\r\n * @dev Both the target contract and the proxy contract (implemented as ManagerProxy) MUST inherit from ManagerProxyTarget in order to guarantee\r\n that both contracts have the same storage layout. Differing storage layouts in a proxy contract and target contract can\r\n potentially break the delegate proxy upgradeability mechanism\r\n */\r\ncontract ManagerProxyTarget is Manager {\r\n    // Used to look up target contract address in controller\u0027s registry\r\n    bytes32 public targetContractId;\r\n}\r\n\r\n// File: contracts/rounds/IRoundsManager.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n/**\r\n * @title RoundsManager interface\r\n */\r\ncontract IRoundsManager {\r\n    // Events\r\n    event NewRound(uint256 indexed round, bytes32 blockHash);\r\n\r\n    // Deprecated events\r\n    // These event signatures can be used to construct the appropriate topic hashes to filter for past logs corresponding\r\n    // to these deprecated events.\r\n    // event NewRound(uint256 round)\r\n\r\n    // External functions\r\n    function initializeRound() external;\r\n\r\n    // Public functions\r\n    function blockNum() public view returns (uint256);\r\n    function blockHash(uint256 _block) public view returns (bytes32);\r\n    function blockHashForRound(uint256 _round) public view returns (bytes32);\r\n    function currentRound() public view returns (uint256);\r\n    function currentRoundStartBlock() public view returns (uint256);\r\n    function currentRoundInitialized() public view returns (bool);\r\n    function currentRoundLocked() public view returns (bool);\r\n}\r\n\r\n// File: contracts/bonding/IBondingManager.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n/**\r\n * @title Interface for BondingManager\r\n * TODO: switch to interface type\r\n */\r\ncontract IBondingManager {\r\n    event TranscoderUpdate(address indexed transcoder, uint256 rewardCut, uint256 feeShare);\r\n    event TranscoderActivated(address indexed transcoder, uint256 activationRound);\r\n    event TranscoderDeactivated(address indexed transcoder, uint256 deactivationRound);\r\n    event TranscoderSlashed(address indexed transcoder, address finder, uint256 penalty, uint256 finderReward);\r\n    event Reward(address indexed transcoder, uint256 amount);\r\n    event Bond(address indexed newDelegate, address indexed oldDelegate, address indexed delegator, uint256 additionalAmount, uint256 bondedAmount);\r\n    event Unbond(address indexed delegate, address indexed delegator, uint256 unbondingLockId, uint256 amount, uint256 withdrawRound);\r\n    event Rebond(address indexed delegate, address indexed delegator, uint256 unbondingLockId, uint256 amount);\r\n    event WithdrawStake(address indexed delegator, uint256 unbondingLockId, uint256 amount, uint256 withdrawRound);\r\n    event WithdrawFees(address indexed delegator);\r\n    event EarningsClaimed(address indexed delegate, address indexed delegator, uint256 rewards, uint256 fees, uint256 startRound, uint256 endRound);\r\n\r\n    // Deprecated events\r\n    // These event signatures can be used to construct the appropriate topic hashes to filter for past logs corresponding\r\n    // to these deprecated events.\r\n    // event Bond(address indexed delegate, address indexed delegator);\r\n    // event Unbond(address indexed delegate, address indexed delegator);\r\n    // event WithdrawStake(address indexed delegator);\r\n    // event TranscoderUpdate(address indexed transcoder, uint256 pendingRewardCut, uint256 pendingFeeShare, uint256 pendingPricePerSegment, bool registered);\r\n    // event TranscoderEvicted(address indexed transcoder);\r\n    // event TranscoderResigned(address indexed transcoder);\r\n\r\n    // External functions\r\n    function updateTranscoderWithFees(address _transcoder, uint256 _fees, uint256 _round) external;\r\n    function slashTranscoder(address _transcoder, address _finder, uint256 _slashAmount, uint256 _finderFee) external;\r\n    function setCurrentRoundTotalActiveStake() external;\r\n\r\n    // Public functions\r\n    function getTranscoderPoolSize() public view returns (uint256);\r\n    function transcoderTotalStake(address _transcoder) public view returns (uint256);\r\n    function isActiveTranscoder(address _transcoder) public view returns (bool);\r\n    function getTotalBonded() public view returns (uint256);\r\n}\r\n\r\n// File: contracts/token/IMinter.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n\r\n/**\r\n * @title Minter interface\r\n */\r\ncontract IMinter {\r\n    // Events\r\n    event SetCurrentRewardTokens(uint256 currentMintableTokens, uint256 currentInflation);\r\n\r\n    // External functions\r\n    function createReward(uint256 _fracNum, uint256 _fracDenom) external returns (uint256);\r\n    function trustedTransferTokens(address _to, uint256 _amount) external;\r\n    function trustedBurnTokens(uint256 _amount) external;\r\n    function trustedWithdrawETH(address payable _to, uint256 _amount) external;\r\n    function depositETH() external payable returns (bool);\r\n    function setCurrentRewardTokens() external;\r\n\r\n    // Public functions\r\n    function getController() public view returns (IController);\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/math/SafeMath.sol\r\n\r\npragma solidity ^0.5.0;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * \u0060SafeMath\u0060 restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060\u002B\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b \u003C= a, \u0022SafeMath: subtraction overflow\u0022);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060*\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, \u0022SafeMath: division by zero\u0022);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        require(b != 0, \u0022SafeMath: modulo by zero\u0022);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n// File: contracts/libraries/MathUtils.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n\r\nlibrary MathUtils {\r\n    using SafeMath for uint256;\r\n\r\n    // Divisor used for representing percentages\r\n    uint256 public constant PERC_DIVISOR = 1000000;\r\n\r\n    /**\r\n     * @dev Returns whether an amount is a valid percentage out of PERC_DIVISOR\r\n     * @param _amount Amount that is supposed to be a percentage\r\n     */\r\n    function validPerc(uint256 _amount) internal pure returns (bool) {\r\n        return _amount \u003C= PERC_DIVISOR;\r\n    }\r\n\r\n    /**\r\n     * @dev Compute percentage of a value with the percentage represented by a fraction\r\n     * @param _amount Amount to take the percentage of\r\n     * @param _fracNum Numerator of fraction representing the percentage\r\n     * @param _fracDenom Denominator of fraction representing the percentage\r\n     */\r\n    function percOf(uint256 _amount, uint256 _fracNum, uint256 _fracDenom) internal pure returns (uint256) {\r\n        return _amount.mul(percPoints(_fracNum, _fracDenom)).div(PERC_DIVISOR);\r\n    }\r\n\r\n    /**\r\n     * @dev Compute percentage of a value with the percentage represented by a fraction over PERC_DIVISOR\r\n     * @param _amount Amount to take the percentage of\r\n     * @param _fracNum Numerator of fraction representing the percentage with PERC_DIVISOR as the denominator\r\n     */\r\n    function percOf(uint256 _amount, uint256 _fracNum) internal pure returns (uint256) {\r\n        return _amount.mul(_fracNum).div(PERC_DIVISOR);\r\n    }\r\n\r\n    /**\r\n     * @dev Compute percentage representation of a fraction\r\n     * @param _fracNum Numerator of fraction represeting the percentage\r\n     * @param _fracDenom Denominator of fraction represeting the percentage\r\n     */\r\n    function percPoints(uint256 _fracNum, uint256 _fracDenom) internal pure returns (uint256) {\r\n        return _fracNum.mul(PERC_DIVISOR).div(_fracDenom);\r\n    }\r\n}\r\n\r\n// File: contracts/rounds/RoundsManager.sol\r\n\r\npragma solidity ^0.5.11;\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n/**\r\n * @title RoundsManager\r\n * @notice Manages round progression and other blockchain time related operations of the Livepeer protocol\r\n */\r\ncontract RoundsManager is ManagerProxyTarget, IRoundsManager {\r\n    using SafeMath for uint256;\r\n\r\n    // Round length in blocks\r\n    uint256 public roundLength;\r\n    // Lock period of a round as a % of round length\r\n    // Transcoders cannot join the transcoder pool or change their rates during the lock period at the end of a round\r\n    // The lock period provides delegators time to review transcoder information without changes\r\n    // # of blocks in the lock period = (roundLength * roundLockAmount) / PERC_DIVISOR\r\n    uint256 public roundLockAmount;\r\n    // Last initialized round. After first round, this is the last round during which initializeRound() was called\r\n    uint256 public lastInitializedRound;\r\n    // Round in which roundLength was last updated\r\n    uint256 public lastRoundLengthUpdateRound;\r\n    // Start block of the round in which roundLength was last updated\r\n    uint256 public lastRoundLengthUpdateStartBlock;\r\n\r\n    // Mapping round number =\u003E block hash for the round\r\n    mapping (uint256 =\u003E bytes32) internal _blockHashForRound;\r\n\r\n    /**\r\n     * @notice RoundsManager constructor. Only invokes constructor of base Manager contract with provided Controller address\r\n     * @dev This constructor will not initialize any state variables besides \u0060controller\u0060. The following setter functions\r\n     * should be used to initialize state variables post-deployment:\r\n     * - setRoundLength()\r\n     * - setRoundLockAmount()\r\n     * @param _controller Address of Controller that this contract will be registered with\r\n     */\r\n    constructor(address _controller) public Manager(_controller) {}\r\n\r\n    /**\r\n     * @notice Set round length. Only callable by the controller owner\r\n     * @param _roundLength Round length in blocks\r\n     */\r\n    function setRoundLength(uint256 _roundLength) external onlyControllerOwner {\r\n        require(_roundLength \u003E 0, \u0022round length cannot be 0\u0022);\r\n\r\n        if (roundLength == 0) {\r\n            // If first time initializing roundLength, set roundLength before\r\n            // lastRoundLengthUpdateRound and lastRoundLengthUpdateStartBlock\r\n            roundLength = _roundLength;\r\n            lastRoundLengthUpdateRound = currentRound();\r\n            lastRoundLengthUpdateStartBlock = currentRoundStartBlock();\r\n        } else {\r\n            // If updating roundLength, set roundLength after\r\n            // lastRoundLengthUpdateRound and lastRoundLengthUpdateStartBlock\r\n            lastRoundLengthUpdateRound = currentRound();\r\n            lastRoundLengthUpdateStartBlock = currentRoundStartBlock();\r\n            roundLength = _roundLength;\r\n        }\r\n\r\n        emit ParameterUpdate(\u0022roundLength\u0022);\r\n    }\r\n\r\n    /**\r\n     * @notice Set round lock amount. Only callable by the controller owner\r\n     * @param _roundLockAmount Round lock amount as a % of the number of blocks in a round\r\n     */\r\n    function setRoundLockAmount(uint256 _roundLockAmount) external onlyControllerOwner {\r\n        require(MathUtils.validPerc(_roundLockAmount), \u0022round lock amount must be a valid percentage\u0022);\r\n\r\n        roundLockAmount = _roundLockAmount;\r\n\r\n        emit ParameterUpdate(\u0022roundLockAmount\u0022);\r\n    }\r\n\r\n    /**\r\n     * @notice Initialize the current round. Called once at the start of any round\r\n     */\r\n    function initializeRound() external whenSystemNotPaused {\r\n        uint256 currRound = currentRound();\r\n\r\n        // Check if already called for the current round\r\n        require(lastInitializedRound \u003C currRound, \u0022round already initialized\u0022);\r\n\r\n        // Set current round as initialized\r\n        lastInitializedRound = currRound;\r\n        // Store block hash for round\r\n        bytes32 roundBlockHash = blockHash(blockNum().sub(1));\r\n        _blockHashForRound[currRound] = roundBlockHash;\r\n        // Set total active stake for the round\r\n        bondingManager().setCurrentRoundTotalActiveStake();\r\n        // Set mintable rewards for the round\r\n        minter().setCurrentRewardTokens();\r\n\r\n        emit NewRound(currRound, roundBlockHash);\r\n    }\r\n\r\n    /**\r\n     * @notice Return current block number\r\n     */\r\n    function blockNum() public view returns (uint256) {\r\n        return block.number;\r\n    }\r\n\r\n    /**\r\n     * @notice Return blockhash for a block\r\n     */\r\n    function blockHash(uint256 _block) public view returns (bytes32) {\r\n        uint256 currentBlock = blockNum();\r\n        require(_block \u003C currentBlock, \u0022can only retrieve past block hashes\u0022);\r\n        require(currentBlock \u003C 256 || _block \u003E= currentBlock - 256, \u0022can only retrieve hashes for last 256 blocks\u0022);\r\n\r\n        return blockhash(_block);\r\n    }\r\n\r\n    /**\r\n     * @notice Return blockhash for a round\r\n     * @param _round Round number\r\n     * @return Blockhash for \u0060_round\u0060\r\n     */\r\n    function blockHashForRound(uint256 _round) public view returns (bytes32) {\r\n        return _blockHashForRound[_round];\r\n    }\r\n\r\n    /**\r\n     * @notice Return current round\r\n     */\r\n    function currentRound() public view returns (uint256) {\r\n        // Compute # of rounds since roundLength was last updated\r\n        uint256 roundsSinceUpdate = blockNum().sub(lastRoundLengthUpdateStartBlock).div(roundLength);\r\n        // Current round = round that roundLength was last updated \u002B # of rounds since roundLength was last updated\r\n        return lastRoundLengthUpdateRound.add(roundsSinceUpdate);\r\n    }\r\n\r\n    /**\r\n     * @notice Return start block of current round\r\n     */\r\n    function currentRoundStartBlock() public view returns (uint256) {\r\n        // Compute # of rounds since roundLength was last updated\r\n        uint256 roundsSinceUpdate = blockNum().sub(lastRoundLengthUpdateStartBlock).div(roundLength);\r\n        // Current round start block = start block of round that roundLength was last updated \u002B (# of rounds since roundLenght was last updated * roundLength)\r\n        return lastRoundLengthUpdateStartBlock.add(roundsSinceUpdate.mul(roundLength));\r\n    }\r\n\r\n    /**\r\n     * @notice Check if current round is initialized\r\n     */\r\n    function currentRoundInitialized() public view returns (bool) {\r\n        return lastInitializedRound == currentRound();\r\n    }\r\n\r\n    /**\r\n     * @notice Check if we are in the lock period of the current round\r\n     */\r\n    function currentRoundLocked() public view returns (bool) {\r\n        uint256 lockedBlocks = MathUtils.percOf(roundLength, roundLockAmount);\r\n        return blockNum().sub(currentRoundStartBlock()) \u003E= roundLength.sub(lockedBlocks);\r\n    }\r\n\r\n    /**\r\n     * @dev Return BondingManager interface\r\n     */\r\n    function bondingManager() internal view returns (IBondingManager) {\r\n        return IBondingManager(controller.getContract(keccak256(\u0022BondingManager\u0022)));\r\n    }\r\n\r\n    /**\r\n     * @dev Return Minter interface\r\n     */\r\n    function minter() internal view returns (IMinter) {\r\n        return IMinter(controller.getContract(keccak256(\u0022Minter\u0022)));\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_roundLockAmount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setRoundLockAmount\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022lastRoundLengthUpdateRound\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022currentRoundInitialized\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_round\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022blockHashForRound\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022targetContractId\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022lastRoundLengthUpdateStartBlock\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_roundLength\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022setRoundLength\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022currentRoundLocked\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022_block\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022blockHash\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022lastInitializedRound\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022currentRound\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022blockNum\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022roundLength\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022currentRoundStartBlock\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_controller\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022setController\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022initializeRound\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022roundLockAmount\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022controller\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract IController\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022_controller\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022round\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022bytes32\u0022,\u0022name\u0022:\u0022blockHash\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022NewRound\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022controller\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022SetController\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022param\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022ParameterUpdate\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"RoundsManager","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000f96d54e490317c557a967abfa5d6e33006be69b3","Library":"","SwarmSource":"bzzr://b01fb08062e1021c895dd41e82e13e906f3789d34d46b9036c6d2fd506d403aa"}]