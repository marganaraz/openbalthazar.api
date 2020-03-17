[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\npragma experimental ABIEncoderV2;\r\n\r\n\r\nlibrary FixedPoint {\r\n\r\n    using SafeMath for uint;\r\n\r\n    // Supports 18 decimals. E.g., 1e18 represents \u00221\u0022, 5e17 represents \u00220.5\u0022.\r\n    // Can represent a value up to (2^256 - 1)/10^18 = ~10^59. 10^59 will be stored internally as uint 10^77.\r\n    uint private constant FP_SCALING_FACTOR = 10**18;\r\n\r\n    struct Unsigned {\r\n        uint rawValue;\r\n    }\r\n\r\n    /** @dev Constructs an \u0060Unsigned\u0060 from an unscaled uint, e.g., \u0060b=5\u0060 gets stored internally as \u00605**18\u0060. */\r\n    function fromUnscaledUint(uint a) internal pure returns (Unsigned memory) {\r\n        return Unsigned(a.mul(FP_SCALING_FACTOR));\r\n    }\r\n\r\n    /** @dev Whether \u0060a\u0060 is greater than \u0060b\u0060. */\r\n    function isGreaterThan(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {\r\n        return a.rawValue \u003E b.rawValue;\r\n    }\r\n\r\n    /** @dev Whether \u0060a\u0060 is greater than \u0060b\u0060. */\r\n    function isGreaterThan(Unsigned memory a, uint b) internal pure returns (bool) {\r\n        return a.rawValue \u003E fromUnscaledUint(b).rawValue;\r\n    }\r\n\r\n    /** @dev Whether \u0060a\u0060 is greater than \u0060b\u0060. */\r\n    function isGreaterThan(uint a, Unsigned memory b) internal pure returns (bool) {\r\n        return fromUnscaledUint(a).rawValue \u003E b.rawValue;\r\n    }\r\n\r\n    /** @dev Whether \u0060a\u0060 is less than \u0060b\u0060. */\r\n    function isLessThan(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {\r\n        return a.rawValue \u003C b.rawValue;\r\n    }\r\n\r\n    /** @dev Whether \u0060a\u0060 is less than \u0060b\u0060. */\r\n    function isLessThan(Unsigned memory a, uint b) internal pure returns (bool) {\r\n        return a.rawValue \u003C fromUnscaledUint(b).rawValue;\r\n    }\r\n\r\n    /** @dev Whether \u0060a\u0060 is less than \u0060b\u0060. */\r\n    function isLessThan(uint a, Unsigned memory b) internal pure returns (bool) {\r\n        return fromUnscaledUint(a).rawValue \u003C b.rawValue;\r\n    }\r\n\r\n    /** @dev Adds two \u0060Unsigned\u0060s, reverting on overflow. */\r\n    function add(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {\r\n        return Unsigned(a.rawValue.add(b.rawValue));\r\n    }\r\n\r\n    /** @dev Adds an \u0060Unsigned\u0060 to an unscaled uint, reverting on overflow. */\r\n    function add(Unsigned memory a, uint b) internal pure returns (Unsigned memory) {\r\n        return add(a, fromUnscaledUint(b));\r\n    }\r\n\r\n    /** @dev Subtracts two \u0060Unsigned\u0060s, reverting on underflow. */\r\n    function sub(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {\r\n        return Unsigned(a.rawValue.sub(b.rawValue));\r\n    }\r\n\r\n    /** @dev Subtracts an unscaled uint from an \u0060Unsigned\u0060, reverting on underflow. */\r\n    function sub(Unsigned memory a, uint b) internal pure returns (Unsigned memory) {\r\n        return sub(a, fromUnscaledUint(b));\r\n    }\r\n\r\n    /** @dev Subtracts an \u0060Unsigned\u0060 from an unscaled uint, reverting on underflow. */\r\n    function sub(uint a, Unsigned memory b) internal pure returns (Unsigned memory) {\r\n        return sub(fromUnscaledUint(a), b);\r\n    }\r\n\r\n    /** @dev Multiplies two \u0060Unsigned\u0060s, reverting on overflow. */\r\n    function mul(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {\r\n        // There are two caveats with this computation:\r\n        // 1. Max output for the represented number is ~10^41, otherwise an intermediate value overflows. 10^41 is\r\n        // stored internally as a uint ~10^59.\r\n        // 2. Results that can\u0027t be represented exactly are truncated not rounded. E.g., 1.4 * 2e-18 = 2.8e-18, which\r\n        // would round to 3, but this computation produces the result 2.\r\n        // No need to use SafeMath because FP_SCALING_FACTOR != 0.\r\n        return Unsigned(a.rawValue.mul(b.rawValue) / FP_SCALING_FACTOR);\r\n    }\r\n\r\n    /** @dev Multiplies an \u0060Unsigned\u0060 by an unscaled uint, reverting on overflow. */\r\n    function mul(Unsigned memory a, uint b) internal pure returns (Unsigned memory) {\r\n        return Unsigned(a.rawValue.mul(b));\r\n    }\r\n\r\n    /** @dev Divides with truncation two \u0060Unsigned\u0060s, reverting on overflow or division by 0. */\r\n    function div(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {\r\n        // There are two caveats with this computation:\r\n        // 1. Max value for the number dividend \u0060a\u0060 represents is ~10^41, otherwise an intermediate value overflows.\r\n        // 10^41 is stored internally as a uint 10^59.\r\n        // 2. Results that can\u0027t be represented exactly are truncated not rounded. E.g., 2 / 3 = 0.6 repeating, which\r\n        // would round to 0.666666666666666667, but this computation produces the result 0.666666666666666666.\r\n        return Unsigned(a.rawValue.mul(FP_SCALING_FACTOR).div(b.rawValue));\r\n    }\r\n\r\n    /** @dev Divides with truncation an \u0060Unsigned\u0060 by an unscaled uint, reverting on division by 0. */\r\n    function div(Unsigned memory a, uint b) internal pure returns (Unsigned memory) {\r\n        return Unsigned(a.rawValue.div(b));\r\n    }\r\n\r\n    /** @dev Divides with truncation an unscaled uint by an \u0060Unsigned\u0060, reverting on overflow or division by 0. */\r\n    function div(uint a, Unsigned memory b) internal pure returns (Unsigned memory) {\r\n        return div(fromUnscaledUint(a), b);\r\n    }\r\n\r\n    /** @dev Raises an \u0060Unsigned\u0060 to the power of an unscaled uint, reverting on overflow. E.g., \u0060b=2\u0060 squares \u0060a\u0060. */\r\n    function pow(Unsigned memory a, uint b) internal pure returns (Unsigned memory output) {\r\n        // TODO(ptare): Consider using the exponentiation by squaring technique instead:\r\n        // https://en.wikipedia.org/wiki/Exponentiation_by_squaring\r\n        output = fromUnscaledUint(1);\r\n        for (uint i = 0; i \u003C b; i = i.add(1)) {\r\n            output = mul(output, a);\r\n        }\r\n    }\r\n}\r\n\r\nlibrary Exclusive {\r\n    struct RoleMembership {\r\n        address member;\r\n    }\r\n\r\n    function isMember(RoleMembership storage roleMembership, address memberToCheck) internal view returns (bool) {\r\n        return roleMembership.member == memberToCheck;\r\n    }\r\n\r\n    function resetMember(RoleMembership storage roleMembership, address newMember) internal {\r\n        require(newMember != address(0x0), \u0022Cannot set an exclusive role to 0x0\u0022);\r\n        roleMembership.member = newMember;\r\n    }\r\n\r\n    function getMember(RoleMembership storage roleMembership) internal view returns (address) {\r\n        return roleMembership.member;\r\n    }\r\n\r\n    function init(RoleMembership storage roleMembership, address initialMember) internal {\r\n        resetMember(roleMembership, initialMember);\r\n    }\r\n}\r\n\r\nlibrary Shared {\r\n    struct RoleMembership {\r\n        mapping(address =\u003E bool) members;\r\n    }\r\n\r\n    function isMember(RoleMembership storage roleMembership, address memberToCheck) internal view returns (bool) {\r\n        return roleMembership.members[memberToCheck];\r\n    }\r\n\r\n    function addMember(RoleMembership storage roleMembership, address memberToAdd) internal {\r\n        roleMembership.members[memberToAdd] = true;\r\n    }\r\n\r\n    function removeMember(RoleMembership storage roleMembership, address memberToRemove) internal {\r\n        roleMembership.members[memberToRemove] = false;\r\n    }\r\n\r\n    function init(RoleMembership storage roleMembership, address[] memory initialMembers) internal {\r\n        for (uint i = 0; i \u003C initialMembers.length; i\u002B\u002B) {\r\n            addMember(roleMembership, initialMembers[i]);\r\n        }\r\n    }\r\n}\r\n\r\ncontract MultiRole {\r\n    using Exclusive for Exclusive.RoleMembership;\r\n    using Shared for Shared.RoleMembership;\r\n\r\n    enum RoleType { Invalid, Exclusive, Shared }\r\n\r\n    struct Role {\r\n        uint managingRole;\r\n        RoleType roleType;\r\n        Exclusive.RoleMembership exclusiveRoleMembership;\r\n        Shared.RoleMembership sharedRoleMembership;\r\n    }\r\n\r\n    mapping(uint =\u003E Role) private roles;\r\n\r\n    /**\r\n     * @notice Reverts unless the caller is a member of the specified roleId.\r\n     */\r\n    modifier onlyRoleHolder(uint roleId) {\r\n        require(holdsRole(roleId, msg.sender), \u0022Sender does not hold required role\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @notice Reverts unless the caller is a member of the manager role for the specified roleId.\r\n     */\r\n    modifier onlyRoleManager(uint roleId) {\r\n        require(holdsRole(roles[roleId].managingRole, msg.sender), \u0022Can only be called by a role manager\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @notice Reverts unless the roleId represents an initialized, exclusive roleId.\r\n     */\r\n    modifier onlyExclusive(uint roleId) {\r\n        require(roles[roleId].roleType == RoleType.Exclusive, \u0022Must be called on an initialized Exclusive role\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @notice Reverts unless the roleId represents an initialized, shared roleId.\r\n     */\r\n    modifier onlyShared(uint roleId) {\r\n        require(roles[roleId].roleType == RoleType.Shared, \u0022Must be called on an initialized Shared role\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @notice Whether \u0060memberToCheck\u0060 is a member of roleId.\r\n     * @dev Reverts if roleId does not correspond to an initialized role.\r\n     */\r\n    function holdsRole(uint roleId, address memberToCheck) public view returns (bool) {\r\n        Role storage role = roles[roleId];\r\n        if (role.roleType == RoleType.Exclusive) {\r\n            return role.exclusiveRoleMembership.isMember(memberToCheck);\r\n        } else if (role.roleType == RoleType.Shared) {\r\n            return role.sharedRoleMembership.isMember(memberToCheck);\r\n        }\r\n        require(false, \u0022Invalid roleId\u0022);\r\n    }\r\n\r\n    /**\r\n     * @notice Changes the exclusive role holder of \u0060roleId\u0060 to \u0060newMember\u0060.\r\n     * @dev Reverts if the caller is not a member of the managing role for \u0060roleId\u0060 or if \u0060roleId\u0060 is not an\r\n     * initialized, exclusive role.\r\n     */\r\n    function resetMember(uint roleId, address newMember) public onlyExclusive(roleId) onlyRoleManager(roleId) {\r\n        roles[roleId].exclusiveRoleMembership.resetMember(newMember);\r\n    }\r\n\r\n    /**\r\n     * @notice Gets the current holder of the exclusive role, \u0060roleId\u0060.\r\n     * @dev Reverts if \u0060roleId\u0060 does not represent an initialized, exclusive role.\r\n     */\r\n    function getMember(uint roleId) public view onlyExclusive(roleId) returns (address) {\r\n        return roles[roleId].exclusiveRoleMembership.getMember();\r\n    }\r\n\r\n    /**\r\n     * @notice Adds \u0060newMember\u0060 to the shared role, \u0060roleId\u0060.\r\n     * @dev Reverts if \u0060roleId\u0060 does not represent an initialized, shared role or if the caller is not a member of the\r\n     * managing role for \u0060roleId\u0060.\r\n     */\r\n    function addMember(uint roleId, address newMember) public onlyShared(roleId) onlyRoleManager(roleId) {\r\n        roles[roleId].sharedRoleMembership.addMember(newMember);\r\n    }\r\n\r\n    /**\r\n     * @notice Removes \u0060memberToRemove\u0060 from the shared role, \u0060roleId\u0060.\r\n     * @dev Reverts if \u0060roleId\u0060 does not represent an initialized, shared role or if the caller is not a member of the\r\n     * managing role for \u0060roleId\u0060.\r\n     */\r\n    function removeMember(uint roleId, address memberToRemove) public onlyShared(roleId) onlyRoleManager(roleId) {\r\n        roles[roleId].sharedRoleMembership.removeMember(memberToRemove);\r\n    }\r\n\r\n    /**\r\n     * @notice Reverts if \u0060roleId\u0060 is not initialized.\r\n     */\r\n    modifier onlyValidRole(uint roleId) {\r\n        require(roles[roleId].roleType != RoleType.Invalid, \u0022Attempted to use an invalid roleId\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @notice Reverts if \u0060roleId\u0060 is initialized.\r\n     */\r\n    modifier onlyInvalidRole(uint roleId) {\r\n        require(roles[roleId].roleType == RoleType.Invalid, \u0022Cannot use a pre-existing role\u0022);\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @notice Internal method to initialize a shared role, \u0060roleId\u0060, which will be managed by \u0060managingRoleId\u0060.\r\n     * \u0060initialMembers\u0060 will be immediately added to the role.\r\n     * @dev Should be called by derived contracts, usually at construction time. Will revert if the role is already\r\n     * initialized.\r\n     */\r\n    function _createSharedRole(uint roleId, uint managingRoleId, address[] memory initialMembers)\r\n        internal\r\n        onlyInvalidRole(roleId)\r\n    {\r\n        Role storage role = roles[roleId];\r\n        role.roleType = RoleType.Shared;\r\n        role.managingRole = managingRoleId;\r\n        role.sharedRoleMembership.init(initialMembers);\r\n        require(roles[managingRoleId].roleType != RoleType.Invalid,\r\n            \u0022Attempted to use an invalid role to manage a shared role\u0022);\r\n    }\r\n\r\n    /**\r\n     * @notice Internal method to initialize a exclusive role, \u0060roleId\u0060, which will be managed by \u0060managingRoleId\u0060.\r\n     * \u0060initialMembers\u0060 will be immediately added to the role.\r\n     * @dev Should be called by derived contracts, usually at construction time. Will revert if the role is already\r\n     * initialized.\r\n     */\r\n    function _createExclusiveRole(uint roleId, uint managingRoleId, address initialMember)\r\n        internal\r\n        onlyInvalidRole(roleId)\r\n    {\r\n        Role storage role = roles[roleId];\r\n        role.roleType = RoleType.Exclusive;\r\n        role.managingRole = managingRoleId;\r\n        role.exclusiveRoleMembership.init(initialMember);\r\n        require(roles[managingRoleId].roleType != RoleType.Invalid,\r\n            \u0022Attempted to use an invalid role to manage an exclusive role\u0022);\r\n    }\r\n}\r\n\r\ninterface StoreInterface {\r\n\r\n    /** \r\n     * @dev Pays Oracle fees in ETH to the store. To be used by contracts whose margin currency is ETH.\r\n     */\r\n    function payOracleFees() external payable;\r\n\r\n    /**\r\n     * @dev Pays oracle fees in the margin currency, erc20Address, to the store. To be used if the margin\r\n     * currency is an ERC20 token rather than ETH\u003E All approved tokens are transfered.\r\n     */\r\n    function payOracleFeesErc20(address erc20Address) external; \r\n\r\n    /**\r\n     * @dev Computes the regular oracle fees that a contract should pay for a period. \r\n     * pfc\u0060 is the \u0022profit from corruption\u0022, or the maximum amount of margin currency that a\r\n     * token sponsor could extract from the contract through corrupting the price feed\r\n     * in their favor.\r\n     */\r\n    function computeRegularFee(uint startTime, uint endTime, FixedPoint.Unsigned calldata pfc) \r\n    external view returns (FixedPoint.Unsigned memory regularFee, FixedPoint.Unsigned memory latePenalty);\r\n    \r\n    /**\r\n     * @dev Computes the final oracle fees that a contract should pay at settlement.\r\n     */\r\n    function computeFinalFee(address currency) external view returns (FixedPoint.Unsigned memory finalFee);\r\n}\r\n\r\ncontract Withdrawable is MultiRole {\r\n\r\n    uint private _roleId;\r\n\r\n    /**\r\n     * @notice Withdraws ETH from the contract.\r\n     */\r\n    function withdraw(uint amount) external onlyRoleHolder(_roleId) {\r\n        msg.sender.transfer(amount);\r\n    }\r\n\r\n    /**\r\n     * @notice Withdraws ERC20 tokens from the contract.\r\n     */\r\n    function withdrawErc20(address erc20Address, uint amount) external onlyRoleHolder(_roleId) {\r\n        IERC20 erc20 = IERC20(erc20Address);\r\n        require(erc20.transfer(msg.sender, amount));\r\n    }\r\n\r\n    /**\r\n     * @notice Internal method that allows derived contracts to create a role for withdrawal.\r\n     * @dev Either this method or \u0060setWithdrawRole\u0060 must be called by the derived class for this contract to function\r\n     * properly.\r\n     */\r\n    function createWithdrawRole(uint roleId, uint managingRoleId, address owner) internal {\r\n        _roleId = roleId;\r\n        _createExclusiveRole(roleId, managingRoleId, owner);\r\n    }\r\n\r\n    /**\r\n     * @notice Internal method that allows derived contracts to choose the role for withdrawal.\r\n     * @dev The role \u0060roleId\u0060 must exist. Either this method or \u0060createWithdrawRole\u0060 must be called by the derived class\r\n     * for this contract to function properly.\r\n     */\r\n    function setWithdrawRole(uint roleId) internal {\r\n        _roleId = roleId;\r\n    }\r\n}\r\n\r\ncontract Store is StoreInterface, MultiRole, Withdrawable {\r\n\r\n    using SafeMath for uint;\r\n    using FixedPoint for FixedPoint.Unsigned;\r\n    using FixedPoint for uint;\r\n\r\n    enum Roles {\r\n        Owner,\r\n        Withdrawer\r\n    }\r\n\r\n    FixedPoint.Unsigned private fixedOracleFeePerSecond; // Percentage of 1 E.g., .1 is 10% Oracle fee.\r\n\r\n    FixedPoint.Unsigned private weeklyDelayFee; // Percentage of 1 E.g., .1 is 10% weekly delay fee.\r\n    mapping(address =\u003E FixedPoint.Unsigned) private finalFees;\r\n    uint private constant SECONDS_PER_WEEK = 604800;\r\n\r\n    event NewFixedOracleFeePerSecond(FixedPoint.Unsigned newOracleFee);\r\n\r\n    constructor() public {\r\n        _createExclusiveRole(uint(Roles.Owner), uint(Roles.Owner), msg.sender);\r\n        createWithdrawRole(uint(Roles.Withdrawer), uint(Roles.Owner), msg.sender);\r\n    }\r\n\r\n    function payOracleFees() external payable {\r\n        require(msg.value \u003E 0);\r\n    }\r\n\r\n    function payOracleFeesErc20(address erc20Address) external {\r\n        IERC20 erc20 = IERC20(erc20Address);\r\n        uint authorizedAmount = erc20.allowance(msg.sender, address(this));\r\n        require(authorizedAmount \u003E 0);\r\n        require(erc20.transferFrom(msg.sender, address(this), authorizedAmount));\r\n    }\r\n\r\n    function computeRegularFee(uint startTime, uint endTime, FixedPoint.Unsigned calldata pfc) \r\n        external \r\n        view \r\n        returns (FixedPoint.Unsigned memory regularFee, FixedPoint.Unsigned memory latePenalty) \r\n    {\r\n        uint timeDiff = endTime.sub(startTime);\r\n\r\n        // Multiply by the unscaled \u0060timeDiff\u0060 first, to get more accurate results.\r\n        regularFee = pfc.mul(timeDiff).mul(fixedOracleFeePerSecond);\r\n        // \u0060weeklyDelayFee\u0060 is already scaled up.\r\n        latePenalty = pfc.mul(weeklyDelayFee.mul(timeDiff.div(SECONDS_PER_WEEK)));\r\n\r\n        return (regularFee, latePenalty);\r\n    }\r\n\r\n    function computeFinalFee(address currency) \r\n        external \r\n        view \r\n        returns (FixedPoint.Unsigned memory finalFee) \r\n    {\r\n        finalFee = finalFees[currency];\r\n    }\r\n\r\n    /**\r\n     * @dev Sets a new oracle fee per second\r\n     */ \r\n    function setFixedOracleFeePerSecond(FixedPoint.Unsigned memory newOracleFee) \r\n        public \r\n        onlyRoleHolder(uint(Roles.Owner)) \r\n    {\r\n        // Oracle fees at or over 100% don\u0027t make sense.\r\n        require(newOracleFee.isLessThan(1));\r\n        fixedOracleFeePerSecond = newOracleFee;\r\n        emit NewFixedOracleFeePerSecond(newOracleFee);\r\n    }\r\n\r\n    /**\r\n     * @dev Sets a new weekly delay fee\r\n     */ \r\n    function setWeeklyDelayFee(FixedPoint.Unsigned memory newWeeklyDelayFee) \r\n        public \r\n        onlyRoleHolder(uint(Roles.Owner)) \r\n    {\r\n        weeklyDelayFee = newWeeklyDelayFee;\r\n    }\r\n\r\n    /**\r\n     * @dev Sets a new final fee for a particular currency\r\n     */ \r\n    function setFinalFee(address currency, FixedPoint.Unsigned memory finalFee) \r\n        public \r\n        onlyRoleHolder(uint(Roles.Owner))\r\n    {\r\n        finalFees[currency] = finalFee;\r\n    }\r\n}\r\n\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060\u002B\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060*\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     *\r\n     * _Available since v2.4.0._\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by \u0060account\u0060.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from the caller\u0027s account to \u0060recipient\u0060.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that \u0060spender\u0060 will be\r\n     * allowed to spend on behalf of \u0060owner\u0060 through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets \u0060amount\u0060 as the allowance of \u0060spender\u0060 over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves \u0060amount\u0060 tokens from \u0060sender\u0060 to \u0060recipient\u0060 using the\r\n     * allowance mechanism. \u0060amount\u0060 is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Emitted when \u0060value\u0060 tokens are moved from one account (\u0060from\u0060) to\r\n     * another (\u0060to\u0060).\r\n     *\r\n     * Note that \u0060value\u0060 may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a \u0060spender\u0060 for an \u0060owner\u0060 is set by\r\n     * a call to {approve}. \u0060value\u0060 is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}","ABI":"[{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022components\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rawValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022struct FixedPoint.Unsigned\u0022,\u0022name\u0022:\u0022newOracleFee\u0022,\u0022type\u0022:\u0022tuple\u0022}],\u0022name\u0022:\u0022NewFixedOracleFeePerSecond\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022roleId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newMember\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addMember\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022currency\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022computeFinalFee\u0022,\u0022outputs\u0022:[{\u0022components\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rawValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022internalType\u0022:\u0022struct FixedPoint.Unsigned\u0022,\u0022name\u0022:\u0022finalFee\u0022,\u0022type\u0022:\u0022tuple\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022startTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022endTime\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022components\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rawValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022internalType\u0022:\u0022struct FixedPoint.Unsigned\u0022,\u0022name\u0022:\u0022pfc\u0022,\u0022type\u0022:\u0022tuple\u0022}],\u0022name\u0022:\u0022computeRegularFee\u0022,\u0022outputs\u0022:[{\u0022components\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rawValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022internalType\u0022:\u0022struct FixedPoint.Unsigned\u0022,\u0022name\u0022:\u0022regularFee\u0022,\u0022type\u0022:\u0022tuple\u0022},{\u0022components\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rawValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022internalType\u0022:\u0022struct FixedPoint.Unsigned\u0022,\u0022name\u0022:\u0022latePenalty\u0022,\u0022type\u0022:\u0022tuple\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022roleId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getMember\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022roleId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022memberToCheck\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022holdsRole\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022bool\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022payOracleFees\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022erc20Address\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022payOracleFeesErc20\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022roleId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022memberToRemove\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeMember\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022roleId\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022newMember\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022resetMember\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022currency\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022components\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rawValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022internalType\u0022:\u0022struct FixedPoint.Unsigned\u0022,\u0022name\u0022:\u0022finalFee\u0022,\u0022type\u0022:\u0022tuple\u0022}],\u0022name\u0022:\u0022setFinalFee\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022components\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rawValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022internalType\u0022:\u0022struct FixedPoint.Unsigned\u0022,\u0022name\u0022:\u0022newOracleFee\u0022,\u0022type\u0022:\u0022tuple\u0022}],\u0022name\u0022:\u0022setFixedOracleFeePerSecond\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022components\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022rawValue\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022internalType\u0022:\u0022struct FixedPoint.Unsigned\u0022,\u0022name\u0022:\u0022newWeeklyDelayFee\u0022,\u0022type\u0022:\u0022tuple\u0022}],\u0022name\u0022:\u0022setWeeklyDelayFee\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022erc20Address\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022withdrawErc20\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022}]","ContractName":"Store","CompilerVersion":"v0.5.13\u002Bcommit.5b0b510c","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://3eeebf19070b9ea0cb4b47b1cd1741eb473b5740c6545a00af77ee6e29c9318a"}]