[{"SourceCode":"// File: @digix/cacp-contracts-dao/contracts/ACOwned.sol\r\n\r\npragma solidity ^0.4.25;\r\n\r\n/// @title Owner based access control\r\n/// @author DigixGlobal\r\n\r\ncontract ACOwned {\r\n\r\n  address public owner;\r\n  address public new_owner;\r\n  bool is_ac_owned_init;\r\n\r\n  /// @dev Modifier to check if msg.sender is the contract owner\r\n  modifier if_owner() {\r\n    require(is_owner());\r\n    _;\r\n  }\r\n\r\n  function init_ac_owned()\r\n           internal\r\n           returns (bool _success)\r\n  {\r\n    if (is_ac_owned_init == false) {\r\n      owner = msg.sender;\r\n      is_ac_owned_init = true;\r\n    }\r\n    _success = true;\r\n  }\r\n\r\n  function is_owner()\r\n           private\r\n           constant\r\n           returns (bool _is_owner)\r\n  {\r\n    _is_owner = (msg.sender == owner);\r\n  }\r\n\r\n  function change_owner(address _new_owner)\r\n           if_owner()\r\n           public\r\n           returns (bool _success)\r\n  {\r\n    new_owner = _new_owner;\r\n    _success = true;\r\n  }\r\n\r\n  function claim_ownership()\r\n           public\r\n           returns (bool _success)\r\n  {\r\n    require(msg.sender == new_owner);\r\n    owner = new_owner;\r\n    _success = true;\r\n  }\r\n\r\n}\r\n\r\n// File: @digix/cacp-contracts-dao/contracts/Constants.sol\r\n\r\npragma solidity ^0.4.25;\r\n\r\n/// @title Some useful constants\r\n/// @author DigixGlobal\r\n\r\ncontract Constants {\r\n  address constant NULL_ADDRESS = address(0x0);\r\n  uint256 constant ZERO = uint256(0);\r\n  bytes32 constant EMPTY = bytes32(0x0);\r\n}\r\n\r\n// File: @digix/cacp-contracts-dao/contracts/ContractResolver.sol\r\n\r\npragma solidity ^0.4.25;\r\n\r\n\r\n\r\n/// @title Contract Name Registry\r\n/// @author DigixGlobal\r\n\r\ncontract ContractResolver is ACOwned, Constants {\r\n\r\n  mapping (bytes32 =\u003E address) contracts;\r\n  bool public locked_forever;\r\n\r\n  modifier unless_registered(bytes32 _key) {\r\n    require(contracts[_key] == NULL_ADDRESS);\r\n    _;\r\n  }\r\n\r\n  modifier if_owner_origin() {\r\n    require(tx.origin == owner);\r\n    _;\r\n  }\r\n\r\n  /// Function modifier to check if msg.sender corresponds to the resolved address of a given key\r\n  /// @param _contract The resolver key\r\n  modifier if_sender_is(bytes32 _contract) {\r\n    require(msg.sender == get_contract(_contract));\r\n    _;\r\n  }\r\n\r\n  modifier if_not_locked() {\r\n    require(locked_forever == false);\r\n    _;\r\n  }\r\n\r\n  /// @dev ContractResolver constructor will perform the following: 1. Set msg.sender as the contract owner.\r\n  constructor() public\r\n  {\r\n    require(init_ac_owned());\r\n    locked_forever = false;\r\n  }\r\n\r\n  /// @dev Called at contract initialization\r\n  /// @param _key bytestring for CACP name\r\n  /// @param _contract_address The address of the contract to be registered\r\n  /// @return _success if the operation is successful\r\n  function init_register_contract(bytes32 _key, address _contract_address)\r\n           if_owner_origin()\r\n           if_not_locked()\r\n           unless_registered(_key)\r\n           public\r\n           returns (bool _success)\r\n  {\r\n    require(_contract_address != NULL_ADDRESS);\r\n    contracts[_key] = _contract_address;\r\n    _success = true;\r\n  }\r\n\r\n  /// @dev Lock the resolver from any further modifications.  This can only be called from the owner\r\n  /// @return _success if the operation is successful\r\n  function lock_resolver_forever()\r\n           if_owner\r\n           public\r\n           returns (bool _success)\r\n  {\r\n    locked_forever = true;\r\n    _success = true;\r\n  }\r\n\r\n  /// @dev Get address of a contract\r\n  /// @param _key the bytestring name of the contract to look up\r\n  /// @return _contract the address of the contract\r\n  function get_contract(bytes32 _key)\r\n           public\r\n           view\r\n           returns (address _contract)\r\n  {\r\n    require(contracts[_key] != NULL_ADDRESS);\r\n    _contract = contracts[_key];\r\n  }\r\n\r\n}\r\n\r\n// File: @digix/cacp-contracts-dao/contracts/ResolverClient.sol\r\n\r\npragma solidity ^0.4.25;\r\n\r\n\r\n\r\n/// @title Contract Resolver Interface\r\n/// @author DigixGlobal\r\n\r\ncontract ResolverClient {\r\n\r\n  /// The address of the resolver contract for this project\r\n  address public resolver;\r\n  bytes32 public key;\r\n\r\n  /// Make our own address available to us as a constant\r\n  address public CONTRACT_ADDRESS;\r\n\r\n  /// Function modifier to check if msg.sender corresponds to the resolved address of a given key\r\n  /// @param _contract The resolver key\r\n  modifier if_sender_is(bytes32 _contract) {\r\n    require(sender_is(_contract));\r\n    _;\r\n  }\r\n\r\n  function sender_is(bytes32 _contract) internal view returns (bool _isFrom) {\r\n    _isFrom = msg.sender == ContractResolver(resolver).get_contract(_contract);\r\n  }\r\n\r\n  modifier if_sender_is_from(bytes32[3] _contracts) {\r\n    require(sender_is_from(_contracts));\r\n    _;\r\n  }\r\n\r\n  function sender_is_from(bytes32[3] _contracts) internal view returns (bool _isFrom) {\r\n    uint256 _n = _contracts.length;\r\n    for (uint256 i = 0; i \u003C _n; i\u002B\u002B) {\r\n      if (_contracts[i] == bytes32(0x0)) continue;\r\n      if (msg.sender == ContractResolver(resolver).get_contract(_contracts[i])) {\r\n        _isFrom = true;\r\n        break;\r\n      }\r\n    }\r\n  }\r\n\r\n  /// Function modifier to check resolver\u0027s locking status.\r\n  modifier unless_resolver_is_locked() {\r\n    require(is_locked() == false);\r\n    _;\r\n  }\r\n\r\n  /// @dev Initialize new contract\r\n  /// @param _key the resolver key for this contract\r\n  /// @return _success if the initialization is successful\r\n  function init(bytes32 _key, address _resolver)\r\n           internal\r\n           returns (bool _success)\r\n  {\r\n    bool _is_locked = ContractResolver(_resolver).locked_forever();\r\n    if (_is_locked == false) {\r\n      CONTRACT_ADDRESS = address(this);\r\n      resolver = _resolver;\r\n      key = _key;\r\n      require(ContractResolver(resolver).init_register_contract(key, CONTRACT_ADDRESS));\r\n      _success = true;\r\n    }  else {\r\n      _success = false;\r\n    }\r\n  }\r\n\r\n  /// @dev Check if resolver is locked\r\n  /// @return _locked if the resolver is currently locked\r\n  function is_locked()\r\n           private\r\n           view\r\n           returns (bool _locked)\r\n  {\r\n    _locked = ContractResolver(resolver).locked_forever();\r\n  }\r\n\r\n  /// @dev Get the address of a contract\r\n  /// @param _key the resolver key to look up\r\n  /// @return _contract the address of the contract\r\n  function get_contract(bytes32 _key)\r\n           public\r\n           view\r\n           returns (address _contract)\r\n  {\r\n    _contract = ContractResolver(resolver).get_contract(_key);\r\n  }\r\n}\r\n\r\n// File: openzeppelin-solidity/contracts/math/SafeMath.sol\r\n\r\npragma solidity ^0.4.24;\r\n\r\n\r\n/**\r\n * @title SafeMath\r\n * @dev Math operations with safety checks that throw on error\r\n */\r\nlibrary SafeMath {\r\n\r\n  /**\r\n  * @dev Multiplies two numbers, throws on overflow.\r\n  */\r\n  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {\r\n    // Gas optimization: this is cheaper than asserting \u0027a\u0027 not being zero, but the\r\n    // benefit is lost if \u0027b\u0027 is also tested.\r\n    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\r\n    if (_a == 0) {\r\n      return 0;\r\n    }\r\n\r\n    c = _a * _b;\r\n    assert(c / _a == _b);\r\n    return c;\r\n  }\r\n\r\n  /**\r\n  * @dev Integer division of two numbers, truncating the quotient.\r\n  */\r\n  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n    // assert(_b \u003E 0); // Solidity automatically throws when dividing by 0\r\n    // uint256 c = _a / _b;\r\n    // assert(_a == _b * c \u002B _a % _b); // There is no case in which this doesn\u0027t hold\r\n    return _a / _b;\r\n  }\r\n\r\n  /**\r\n  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\r\n  */\r\n  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {\r\n    assert(_b \u003C= _a);\r\n    return _a - _b;\r\n  }\r\n\r\n  /**\r\n  * @dev Adds two numbers, throws on overflow.\r\n  */\r\n  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {\r\n    c = _a \u002B _b;\r\n    assert(c \u003E= _a);\r\n    return c;\r\n  }\r\n}\r\n\r\n// File: contracts/common/DaoConstants.sol\r\n\r\npragma solidity ^0.4.25;\r\n\r\n\r\ncontract DaoConstants {\r\n    using SafeMath for uint256;\r\n    bytes32 EMPTY_BYTES = bytes32(0x0);\r\n    address EMPTY_ADDRESS = address(0x0);\r\n\r\n\r\n    bytes32 PROPOSAL_STATE_PREPROPOSAL = \u0022proposal_state_preproposal\u0022;\r\n    bytes32 PROPOSAL_STATE_DRAFT = \u0022proposal_state_draft\u0022;\r\n    bytes32 PROPOSAL_STATE_MODERATED = \u0022proposal_state_moderated\u0022;\r\n    bytes32 PROPOSAL_STATE_ONGOING = \u0022proposal_state_ongoing\u0022;\r\n    bytes32 PROPOSAL_STATE_CLOSED = \u0022proposal_state_closed\u0022;\r\n    bytes32 PROPOSAL_STATE_ARCHIVED = \u0022proposal_state_archived\u0022;\r\n\r\n    uint256 PRL_ACTION_STOP = 1;\r\n    uint256 PRL_ACTION_PAUSE = 2;\r\n    uint256 PRL_ACTION_UNPAUSE = 3;\r\n\r\n    uint256 COLLATERAL_STATUS_UNLOCKED = 1;\r\n    uint256 COLLATERAL_STATUS_LOCKED = 2;\r\n    uint256 COLLATERAL_STATUS_CLAIMED = 3;\r\n\r\n    bytes32 INTERMEDIATE_DGD_IDENTIFIER = \u0022inter_dgd_id\u0022;\r\n    bytes32 INTERMEDIATE_MODERATOR_DGD_IDENTIFIER = \u0022inter_mod_dgd_id\u0022;\r\n    bytes32 INTERMEDIATE_BONUS_CALCULATION_IDENTIFIER = \u0022inter_bonus_calculation_id\u0022;\r\n\r\n    // interactive contracts\r\n    bytes32 CONTRACT_DAO = \u0022dao\u0022;\r\n    bytes32 CONTRACT_DAO_SPECIAL_PROPOSAL = \u0022dao:special:proposal\u0022;\r\n    bytes32 CONTRACT_DAO_STAKE_LOCKING = \u0022dao:stake-locking\u0022;\r\n    bytes32 CONTRACT_DAO_VOTING = \u0022dao:voting\u0022;\r\n    bytes32 CONTRACT_DAO_VOTING_CLAIMS = \u0022dao:voting:claims\u0022;\r\n    bytes32 CONTRACT_DAO_SPECIAL_VOTING_CLAIMS = \u0022dao:svoting:claims\u0022;\r\n    bytes32 CONTRACT_DAO_IDENTITY = \u0022dao:identity\u0022;\r\n    bytes32 CONTRACT_DAO_REWARDS_MANAGER = \u0022dao:rewards-manager\u0022;\r\n    bytes32 CONTRACT_DAO_REWARDS_MANAGER_EXTRAS = \u0022dao:rewards-extras\u0022;\r\n    bytes32 CONTRACT_DAO_ROLES = \u0022dao:roles\u0022;\r\n    bytes32 CONTRACT_DAO_FUNDING_MANAGER = \u0022dao:funding-manager\u0022;\r\n    bytes32 CONTRACT_DAO_WHITELISTING = \u0022dao:whitelisting\u0022;\r\n    bytes32 CONTRACT_DAO_INFORMATION = \u0022dao:information\u0022;\r\n\r\n    // service contracts\r\n    bytes32 CONTRACT_SERVICE_ROLE = \u0022service:role\u0022;\r\n    bytes32 CONTRACT_SERVICE_DAO_INFO = \u0022service:dao:info\u0022;\r\n    bytes32 CONTRACT_SERVICE_DAO_LISTING = \u0022service:dao:listing\u0022;\r\n    bytes32 CONTRACT_SERVICE_DAO_CALCULATOR = \u0022service:dao:calculator\u0022;\r\n\r\n    // storage contracts\r\n    bytes32 CONTRACT_STORAGE_DAO = \u0022storage:dao\u0022;\r\n    bytes32 CONTRACT_STORAGE_DAO_COUNTER = \u0022storage:dao:counter\u0022;\r\n    bytes32 CONTRACT_STORAGE_DAO_UPGRADE = \u0022storage:dao:upgrade\u0022;\r\n    bytes32 CONTRACT_STORAGE_DAO_IDENTITY = \u0022storage:dao:identity\u0022;\r\n    bytes32 CONTRACT_STORAGE_DAO_POINTS = \u0022storage:dao:points\u0022;\r\n    bytes32 CONTRACT_STORAGE_DAO_SPECIAL = \u0022storage:dao:special\u0022;\r\n    bytes32 CONTRACT_STORAGE_DAO_CONFIG = \u0022storage:dao:config\u0022;\r\n    bytes32 CONTRACT_STORAGE_DAO_STAKE = \u0022storage:dao:stake\u0022;\r\n    bytes32 CONTRACT_STORAGE_DAO_REWARDS = \u0022storage:dao:rewards\u0022;\r\n    bytes32 CONTRACT_STORAGE_DAO_WHITELISTING = \u0022storage:dao:whitelisting\u0022;\r\n    bytes32 CONTRACT_STORAGE_INTERMEDIATE_RESULTS = \u0022storage:intermediate:results\u0022;\r\n\r\n    bytes32 CONTRACT_DGD_TOKEN = \u0022t:dgd\u0022;\r\n    bytes32 CONTRACT_DGX_TOKEN = \u0022t:dgx\u0022;\r\n    bytes32 CONTRACT_BADGE_TOKEN = \u0022t:badge\u0022;\r\n\r\n    uint8 ROLES_ROOT = 1;\r\n    uint8 ROLES_FOUNDERS = 2;\r\n    uint8 ROLES_PRLS = 3;\r\n    uint8 ROLES_KYC_ADMINS = 4;\r\n\r\n    uint256 QUARTER_DURATION = 90 days;\r\n\r\n    bytes32 CONFIG_MINIMUM_LOCKED_DGD = \u0022min_dgd_participant\u0022;\r\n    bytes32 CONFIG_MINIMUM_DGD_FOR_MODERATOR = \u0022min_dgd_moderator\u0022;\r\n    bytes32 CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR = \u0022min_reputation_moderator\u0022;\r\n\r\n    bytes32 CONFIG_LOCKING_PHASE_DURATION = \u0022locking_phase_duration\u0022;\r\n    bytes32 CONFIG_QUARTER_DURATION = \u0022quarter_duration\u0022;\r\n    bytes32 CONFIG_VOTING_COMMIT_PHASE = \u0022voting_commit_phase\u0022;\r\n    bytes32 CONFIG_VOTING_PHASE_TOTAL = \u0022voting_phase_total\u0022;\r\n    bytes32 CONFIG_INTERIM_COMMIT_PHASE = \u0022interim_voting_commit_phase\u0022;\r\n    bytes32 CONFIG_INTERIM_PHASE_TOTAL = \u0022interim_voting_phase_total\u0022;\r\n\r\n    bytes32 CONFIG_DRAFT_QUORUM_FIXED_PORTION_NUMERATOR = \u0022draft_quorum_fixed_numerator\u0022;\r\n    bytes32 CONFIG_DRAFT_QUORUM_FIXED_PORTION_DENOMINATOR = \u0022draft_quorum_fixed_denominator\u0022;\r\n    bytes32 CONFIG_DRAFT_QUORUM_SCALING_FACTOR_NUMERATOR = \u0022draft_quorum_sfactor_numerator\u0022;\r\n    bytes32 CONFIG_DRAFT_QUORUM_SCALING_FACTOR_DENOMINATOR = \u0022draft_quorum_sfactor_denominator\u0022;\r\n    bytes32 CONFIG_VOTING_QUORUM_FIXED_PORTION_NUMERATOR = \u0022vote_quorum_fixed_numerator\u0022;\r\n    bytes32 CONFIG_VOTING_QUORUM_FIXED_PORTION_DENOMINATOR = \u0022vote_quorum_fixed_denominator\u0022;\r\n    bytes32 CONFIG_VOTING_QUORUM_SCALING_FACTOR_NUMERATOR = \u0022vote_quorum_sfactor_numerator\u0022;\r\n    bytes32 CONFIG_VOTING_QUORUM_SCALING_FACTOR_DENOMINATOR = \u0022vote_quorum_sfactor_denominator\u0022;\r\n    bytes32 CONFIG_FINAL_REWARD_SCALING_FACTOR_NUMERATOR = \u0022final_reward_sfactor_numerator\u0022;\r\n    bytes32 CONFIG_FINAL_REWARD_SCALING_FACTOR_DENOMINATOR = \u0022final_reward_sfactor_denominator\u0022;\r\n\r\n    bytes32 CONFIG_DRAFT_QUOTA_NUMERATOR = \u0022draft_quota_numerator\u0022;\r\n    bytes32 CONFIG_DRAFT_QUOTA_DENOMINATOR = \u0022draft_quota_denominator\u0022;\r\n    bytes32 CONFIG_VOTING_QUOTA_NUMERATOR = \u0022voting_quota_numerator\u0022;\r\n    bytes32 CONFIG_VOTING_QUOTA_DENOMINATOR = \u0022voting_quota_denominator\u0022;\r\n\r\n    bytes32 CONFIG_MINIMAL_QUARTER_POINT = \u0022minimal_qp\u0022;\r\n    bytes32 CONFIG_QUARTER_POINT_SCALING_FACTOR = \u0022quarter_point_scaling_factor\u0022;\r\n    bytes32 CONFIG_REPUTATION_POINT_SCALING_FACTOR = \u0022rep_point_scaling_factor\u0022;\r\n\r\n    bytes32 CONFIG_MODERATOR_MINIMAL_QUARTER_POINT = \u0022minimal_mod_qp\u0022;\r\n    bytes32 CONFIG_MODERATOR_QUARTER_POINT_SCALING_FACTOR = \u0022mod_qp_scaling_factor\u0022;\r\n    bytes32 CONFIG_MODERATOR_REPUTATION_POINT_SCALING_FACTOR = \u0022mod_rep_point_scaling_factor\u0022;\r\n\r\n    bytes32 CONFIG_QUARTER_POINT_DRAFT_VOTE = \u0022quarter_point_draft_vote\u0022;\r\n    bytes32 CONFIG_QUARTER_POINT_VOTE = \u0022quarter_point_vote\u0022;\r\n    bytes32 CONFIG_QUARTER_POINT_INTERIM_VOTE = \u0022quarter_point_interim_vote\u0022;\r\n\r\n    /// this is per 10000 ETHs\r\n    bytes32 CONFIG_QUARTER_POINT_MILESTONE_COMPLETION_PER_10000ETH = \u0022q_p_milestone_completion\u0022;\r\n\r\n    bytes32 CONFIG_BONUS_REPUTATION_NUMERATOR = \u0022bonus_reputation_numerator\u0022;\r\n    bytes32 CONFIG_BONUS_REPUTATION_DENOMINATOR = \u0022bonus_reputation_denominator\u0022;\r\n\r\n    bytes32 CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE = \u0022special_proposal_commit_phase\u0022;\r\n    bytes32 CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL = \u0022special_proposal_phase_total\u0022;\r\n\r\n    bytes32 CONFIG_SPECIAL_QUOTA_NUMERATOR = \u0022config_special_quota_numerator\u0022;\r\n    bytes32 CONFIG_SPECIAL_QUOTA_DENOMINATOR = \u0022config_special_quota_denominator\u0022;\r\n\r\n    bytes32 CONFIG_SPECIAL_PROPOSAL_QUORUM_NUMERATOR = \u0022special_quorum_numerator\u0022;\r\n    bytes32 CONFIG_SPECIAL_PROPOSAL_QUORUM_DENOMINATOR = \u0022special_quorum_denominator\u0022;\r\n\r\n    bytes32 CONFIG_MAXIMUM_REPUTATION_DEDUCTION = \u0022config_max_reputation_deduction\u0022;\r\n    bytes32 CONFIG_PUNISHMENT_FOR_NOT_LOCKING = \u0022config_punishment_not_locking\u0022;\r\n\r\n    bytes32 CONFIG_REPUTATION_PER_EXTRA_QP_NUM = \u0022config_rep_per_extra_qp_num\u0022;\r\n    bytes32 CONFIG_REPUTATION_PER_EXTRA_QP_DEN = \u0022config_rep_per_extra_qp_den\u0022;\r\n\r\n    bytes32 CONFIG_MAXIMUM_MODERATOR_REPUTATION_DEDUCTION = \u0022config_max_m_rp_deduction\u0022;\r\n    bytes32 CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_NUM = \u0022config_rep_per_extra_m_qp_num\u0022;\r\n    bytes32 CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_DEN = \u0022config_rep_per_extra_m_qp_den\u0022;\r\n\r\n    bytes32 CONFIG_PORTION_TO_MODERATORS_NUM = \u0022config_mod_portion_num\u0022;\r\n    bytes32 CONFIG_PORTION_TO_MODERATORS_DEN = \u0022config_mod_portion_den\u0022;\r\n\r\n    bytes32 CONFIG_DRAFT_VOTING_PHASE = \u0022config_draft_voting_phase\u0022;\r\n\r\n    bytes32 CONFIG_REPUTATION_POINT_BOOST_FOR_BADGE = \u0022config_rp_boost_per_badge\u0022;\r\n\r\n    bytes32 CONFIG_VOTE_CLAIMING_DEADLINE = \u0022config_claiming_deadline\u0022;\r\n\r\n    bytes32 CONFIG_PREPROPOSAL_COLLATERAL = \u0022config_preproposal_collateral\u0022;\r\n\r\n    bytes32 CONFIG_MAX_FUNDING_FOR_NON_DIGIX = \u0022config_max_funding_nonDigix\u0022;\r\n    bytes32 CONFIG_MAX_MILESTONES_FOR_NON_DIGIX = \u0022config_max_milestones_nonDigix\u0022;\r\n    bytes32 CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER = \u0022config_nonDigix_proposal_cap\u0022;\r\n\r\n    bytes32 CONFIG_PROPOSAL_DEAD_DURATION = \u0022config_dead_duration\u0022;\r\n    bytes32 CONFIG_CARBON_VOTE_REPUTATION_BONUS = \u0022config_cv_reputation\u0022;\r\n}\r\n\r\n// File: contracts/storage/DaoPointsStorage.sol\r\n\r\npragma solidity ^0.4.25;\r\n\r\n\r\n\r\ncontract DaoPointsStorage is ResolverClient, DaoConstants {\r\n\r\n    // struct for a non-transferrable token\r\n    struct Token {\r\n        uint256 totalSupply;\r\n        mapping (address =\u003E uint256) balance;\r\n    }\r\n\r\n    // the reputation point token\r\n    // since reputation is cumulative, we only need to store one value\r\n    Token reputationPoint;\r\n\r\n    // since quarter points are specific to quarters, we need a mapping from\r\n    // quarter number to the quarter point token for that quarter\r\n    mapping (uint256 =\u003E Token) quarterPoint;\r\n\r\n    // the same is the case with quarter moderator points\r\n    // these are specific to quarters\r\n    mapping (uint256 =\u003E Token) quarterModeratorPoint;\r\n\r\n    constructor(address _resolver)\r\n        public\r\n    {\r\n        require(init(CONTRACT_STORAGE_DAO_POINTS, _resolver));\r\n    }\r\n\r\n    /// @notice add quarter points for a _participant for a _quarterNumber\r\n    function addQuarterPoint(address _participant, uint256 _point, uint256 _quarterNumber)\r\n        public\r\n        returns (uint256 _newPoint, uint256 _newTotalPoint)\r\n    {\r\n        require(sender_is_from([CONTRACT_DAO_VOTING, CONTRACT_DAO_VOTING_CLAIMS, EMPTY_BYTES]));\r\n        quarterPoint[_quarterNumber].totalSupply = quarterPoint[_quarterNumber].totalSupply.add(_point);\r\n        quarterPoint[_quarterNumber].balance[_participant] = quarterPoint[_quarterNumber].balance[_participant].add(_point);\r\n\r\n        _newPoint = quarterPoint[_quarterNumber].balance[_participant];\r\n        _newTotalPoint = quarterPoint[_quarterNumber].totalSupply;\r\n    }\r\n\r\n    function addModeratorQuarterPoint(address _participant, uint256 _point, uint256 _quarterNumber)\r\n        public\r\n        returns (uint256 _newPoint, uint256 _newTotalPoint)\r\n    {\r\n        require(sender_is_from([CONTRACT_DAO_VOTING, CONTRACT_DAO_VOTING_CLAIMS, EMPTY_BYTES]));\r\n        quarterModeratorPoint[_quarterNumber].totalSupply = quarterModeratorPoint[_quarterNumber].totalSupply.add(_point);\r\n        quarterModeratorPoint[_quarterNumber].balance[_participant] = quarterModeratorPoint[_quarterNumber].balance[_participant].add(_point);\r\n\r\n        _newPoint = quarterModeratorPoint[_quarterNumber].balance[_participant];\r\n        _newTotalPoint = quarterModeratorPoint[_quarterNumber].totalSupply;\r\n    }\r\n\r\n    /// @notice get quarter points for a _participant in a _quarterNumber\r\n    function getQuarterPoint(address _participant, uint256 _quarterNumber)\r\n        public\r\n        view\r\n        returns (uint256 _point)\r\n    {\r\n        _point = quarterPoint[_quarterNumber].balance[_participant];\r\n    }\r\n\r\n    function getQuarterModeratorPoint(address _participant, uint256 _quarterNumber)\r\n        public\r\n        view\r\n        returns (uint256 _point)\r\n    {\r\n        _point = quarterModeratorPoint[_quarterNumber].balance[_participant];\r\n    }\r\n\r\n    /// @notice get total quarter points for a particular _quarterNumber\r\n    function getTotalQuarterPoint(uint256 _quarterNumber)\r\n        public\r\n        view\r\n        returns (uint256 _totalPoint)\r\n    {\r\n        _totalPoint = quarterPoint[_quarterNumber].totalSupply;\r\n    }\r\n\r\n    function getTotalQuarterModeratorPoint(uint256 _quarterNumber)\r\n        public\r\n        view\r\n        returns (uint256 _totalPoint)\r\n    {\r\n        _totalPoint = quarterModeratorPoint[_quarterNumber].totalSupply;\r\n    }\r\n\r\n    /// @notice add reputation points for a _participant\r\n    function increaseReputation(address _participant, uint256 _point)\r\n        public\r\n        returns (uint256 _newPoint, uint256 _totalPoint)\r\n    {\r\n        require(sender_is_from([CONTRACT_DAO_VOTING_CLAIMS, CONTRACT_DAO_REWARDS_MANAGER, CONTRACT_DAO_STAKE_LOCKING]));\r\n        reputationPoint.totalSupply = reputationPoint.totalSupply.add(_point);\r\n        reputationPoint.balance[_participant] = reputationPoint.balance[_participant].add(_point);\r\n\r\n        _newPoint = reputationPoint.balance[_participant];\r\n        _totalPoint = reputationPoint.totalSupply;\r\n    }\r\n\r\n    /// @notice subtract reputation points for a _participant\r\n    function reduceReputation(address _participant, uint256 _point)\r\n        public\r\n        returns (uint256 _newPoint, uint256 _totalPoint)\r\n    {\r\n        require(sender_is_from([CONTRACT_DAO_VOTING_CLAIMS, CONTRACT_DAO_REWARDS_MANAGER, EMPTY_BYTES]));\r\n        uint256 _toDeduct = _point;\r\n        if (reputationPoint.balance[_participant] \u003E _point) {\r\n            reputationPoint.balance[_participant] = reputationPoint.balance[_participant].sub(_point);\r\n        } else {\r\n            _toDeduct = reputationPoint.balance[_participant];\r\n            reputationPoint.balance[_participant] = 0;\r\n        }\r\n\r\n        reputationPoint.totalSupply = reputationPoint.totalSupply.sub(_toDeduct);\r\n\r\n        _newPoint = reputationPoint.balance[_participant];\r\n        _totalPoint = reputationPoint.totalSupply;\r\n    }\r\n\r\n  /// @notice get reputation points for a _participant\r\n  function getReputation(address _participant)\r\n      public\r\n      view\r\n      returns (uint256 _point)\r\n  {\r\n      _point = reputationPoint.balance[_participant];\r\n  }\r\n\r\n  /// @notice get total reputation points distributed in the dao\r\n  function getTotalReputation()\r\n      public\r\n      view\r\n      returns (uint256 _totalPoint)\r\n  {\r\n      _totalPoint = reputationPoint.totalSupply;\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022resolver\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getTotalReputation\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_totalPoint\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_participant\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_point\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_quarterNumber\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022addQuarterPoint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_newPoint\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_newTotalPoint\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_quarterNumber\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getTotalQuarterModeratorPoint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_totalPoint\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022key\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_key\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022get_contract\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_contract\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_participant\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_point\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022reduceReputation\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_newPoint\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_totalPoint\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_quarterNumber\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getTotalQuarterPoint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_totalPoint\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_participant\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_quarterNumber\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getQuarterPoint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_point\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_participant\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getReputation\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_point\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_participant\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_quarterNumber\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getQuarterModeratorPoint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_point\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022CONTRACT_ADDRESS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_participant\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_point\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022increaseReputation\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_newPoint\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_totalPoint\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_participant\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_point\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_quarterNumber\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022addModeratorQuarterPoint\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022_newPoint\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022_newTotalPoint\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_resolver\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"DaoPointsStorage","CompilerVersion":"v0.4.25\u002Bcommit.59dbf8f1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000005f60ef7e1443f82ca7de947711f0966ca6e3b5","Library":"","SwarmSource":"bzzr://ea8c956299ed5883ec123d2297dd6f62b2676a9008861da564410a27f19571aa"}]