[{"SourceCode":"// File: browser/SafeMath.sol\r\n\r\n// Taken from github.com/OpenZeppelin/openzeppelin-contracts/blob/5d34dbe/contracts/math/SafeMath.sol\r\n\r\npragma solidity ^0.5.0;\r\npragma experimental ABIEncoderV2;\r\n\r\n/**\r\n * @dev Wrappers over Solidity\u0027s arithmetic operations with added overflow\r\n * checks.\r\n *\r\n * Arithmetic operations in Solidity wrap on overflow. This can easily result\r\n * in bugs, because programmers usually assume that an overflow raises an\r\n * error, which is the standard behavior in high level programming languages.\r\n * \u0060SafeMath\u0060 restores this intuition by reverting the transaction when an\r\n * operation overflows.\r\n *\r\n * Using this library instead of the unchecked operations eliminates an entire\r\n * class of bugs, so it\u0027s recommended to use it always.\r\n */\r\nlibrary SafeMath {\r\n    /**\r\n     * @dev Returns the addition of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060\u002B\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Addition cannot overflow.\r\n     */\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        uint256 c = a \u002B b;\r\n        require(c \u003E= a, \u0022SafeMath: addition overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return sub(a, b, \u0022SafeMath: subtraction overflow\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on\r\n     * overflow (when the result is negative).\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060-\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Subtraction cannot overflow.\r\n     */\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b \u003C= a, errorMessage);\r\n        uint256 c = a - b;\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the multiplication of two unsigned integers, reverting on\r\n     * overflow.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060*\u0060 operator.\r\n     *\r\n     * Requirements:\r\n     * - Multiplication cannot overflow.\r\n     */\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        // Gas optimization: this is cheaper than requiring \u0027a\u0027 not being zero, but the\r\n        // benefit is lost if \u0027b\u0027 is also tested.\r\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\r\n        if (a == 0) {\r\n            return 0;\r\n        }\r\n\r\n        uint256 c = a * b;\r\n        require(c / a == b, \u0022SafeMath: multiplication overflow\u0022);\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return div(a, b, \u0022SafeMath: division by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on\r\n     * division by zero. The result is rounded towards zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060/\u0060 operator. Note: this function uses a\r\n     * \u0060revert\u0060 opcode (which leaves remaining gas untouched) while Solidity\r\n     * uses an invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        // Solidity only automatically asserts when dividing by 0\r\n        require(b \u003E 0, errorMessage);\r\n        uint256 c = a / b;\r\n        // assert(a == b * c \u002B a % b); // There is no case in which this doesn\u0027t hold\r\n\r\n        return c;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return mod(a, b, \u0022SafeMath: modulo by zero\u0022);\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),\r\n     * Reverts with custom message when dividing by zero.\r\n     *\r\n     * Counterpart to Solidity\u0027s \u0060%\u0060 operator. This function uses a \u0060revert\u0060\r\n     * opcode (which leaves remaining gas untouched) while Solidity uses an\r\n     * invalid opcode to revert (consuming all remaining gas).\r\n     *\r\n     * Requirements:\r\n     * - The divisor cannot be zero.\r\n     */\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        require(b != 0, errorMessage);\r\n        return a % b;\r\n    }\r\n}\r\n\r\n// File: browser/CryptoLegacyBaseAPI.sol\r\n\r\ninterface CryptoLegacyBaseAPI {\r\n  function getVersion() external view returns (uint);\r\n  function getOwner() external view returns (address);\r\n  function getContinuationContractAddress() external view returns (address);\r\n  function isAcceptingKeeperProposals() external view returns (bool);\r\n}\r\n\r\n// File: browser/CryptoLegacy.sol\r\n\r\ncontract CryptoLegacy is CryptoLegacyBaseAPI {\r\n\r\n  // Version of the contract API.\r\n  uint public constant VERSION = 3;\r\n\r\n  event KeysNeeded();\r\n  event ContinuationContractAnnounced(address continuationContractAddress);\r\n  event Cancelled();\r\n\r\n  enum States {\r\n    CallForKeepers,\r\n    Active,\r\n    CallForKeys,\r\n    Cancelled\r\n  }\r\n\r\n  modifier atState(States _state) {\r\n    require(state == _state, \u00220\u0022); // error: invalid contract state\r\n    _;\r\n  }\r\n\r\n  modifier atEitherOfStates(States state1, States state2) {\r\n    require(state == state1 || state == state2, \u00221\u0022); // error: invalid contract state\r\n    _;\r\n  }\r\n\r\n  modifier ownerOnly() {\r\n    require(msg.sender == owner, \u00222\u0022); // error: tx sender must be the owner\r\n    _;\r\n  }\r\n\r\n  modifier activeKeepersOnly() {\r\n    require(isActiveKeeper(msg.sender), \u00223\u0022); // error: tx sender must be an active keeper\r\n    _;\r\n  }\r\n\r\n  struct KeeperProposal {\r\n    address keeperAddress;\r\n    bytes publicKey; // 64-byte\r\n    uint keepingFee;\r\n  }\r\n\r\n  struct ActiveKeeper {\r\n    bytes publicKey; // 64-byte\r\n    bytes32 keyPartHash; // sha-3 hash\r\n    uint keepingFee;\r\n    uint balance;\r\n    uint lastCheckInAt;\r\n    bool keyPartSupplied;\r\n  }\r\n\r\n  struct EncryptedData {\r\n    bytes encryptedData;\r\n    bytes16 aesCounter;\r\n    bytes32 dataHash; // sha-3 hash\r\n    uint16 shareLength;\r\n    bytes[] suppliedKeyParts;\r\n  }\r\n\r\n  struct ActiveKeeperDescription {\r\n    address keeperAddress;\r\n    uint balance;\r\n    uint lastCheckInAt;\r\n    bool keyPartSupplied;\r\n  }\r\n\r\n  struct Description {\r\n    States state;\r\n    uint checkInInterval;\r\n    uint lastOwnerCheckInAt;\r\n    KeeperProposal[] proposals;\r\n    ActiveKeeperDescription[] keepers;\r\n    uint checkInPrice;\r\n  }\r\n\r\n  address public owner;\r\n\r\n  // When owner wants to elect new Keepers, she cancels the contract and starts a new one.\r\n  // This variable contains the address of the new continuation contract.\r\n  address public continuationContractAddress = address(0);\r\n\r\n  uint public checkInInterval;\r\n  uint public lastOwnerCheckInAt;\r\n\r\n  States public state = States.CallForKeepers;\r\n\r\n  bytes[] public encryptedKeyPartsChunks;\r\n  EncryptedData public encryptedData;\r\n\r\n  KeeperProposal[] public keeperProposals;\r\n  mapping(address =\u003E bool) public proposedKeeperFlags;\r\n  mapping(bytes32 =\u003E bool) private proposedPublicKeyHashes;\r\n\r\n  mapping(address =\u003E ActiveKeeper) public activeKeepers;\r\n  address[] public activeKeepersAddresses;\r\n\r\n  // Sum of keeping fees of all active Keepers.\r\n  uint public totalKeepingFee;\r\n\r\n  // We need this because current version of Solidity doesn\u0027t support non-integer numbers.\r\n  // We set it to be equal to number of wei in eth to make sure we transfer keeping fee with\r\n  // enough precision.\r\n  uint public constant KEEPING_FEE_ROUNDING_MULT = 1 ether;\r\n\r\n  // Don\u0027t allow owner to specify check-in interval less than this when creating a new contract.\r\n  uint public constant MINIMUM_CHECK_IN_INTERVAL = 1 minutes;\r\n\r\n\r\n  // Called by the person who possesses the data they wish to transfer.\r\n  // This person becomes the owner of the contract.\r\n  //\r\n  constructor(address _owner, uint _checkInInterval) public {\r\n    require(_checkInInterval \u003E= MINIMUM_CHECK_IN_INTERVAL, \u00224\u0022); // error: check-in interval is too small\r\n    require(_owner != address(0), \u00225\u0022); // error: owner must not be zero\r\n    owner = _owner;\r\n    checkInInterval = _checkInInterval;\r\n  }\r\n\r\n\r\n  function describe() external view returns (Description memory) {\r\n    ActiveKeeperDescription[] memory keepers = new ActiveKeeperDescription[](activeKeepersAddresses.length);\r\n\r\n    for (uint i = 0; i \u003C activeKeepersAddresses.length; i\u002B\u002B) {\r\n      address addr = activeKeepersAddresses[i];\r\n      ActiveKeeper storage keeper = activeKeepers[addr];\r\n      keepers[i] = ActiveKeeperDescription({\r\n        keeperAddress: addr,\r\n        balance: keeper.balance,\r\n        lastCheckInAt: keeper.lastCheckInAt,\r\n        keyPartSupplied: keeper.keyPartSupplied\r\n      });\r\n    }\r\n\r\n    return Description({\r\n      state: state,\r\n      checkInInterval: checkInInterval,\r\n      lastOwnerCheckInAt: lastOwnerCheckInAt,\r\n      proposals: keeperProposals,\r\n      keepers: keepers,\r\n      checkInPrice: canCheckIn() ? calculateApproximateCheckInPrice() : 0\r\n    });\r\n  }\r\n\r\n\r\n  function getVersion() public view returns (uint) {\r\n    return VERSION;\r\n  }\r\n\r\n\r\n  function getOwner() public view returns (address) {\r\n    return owner;\r\n  }\r\n\r\n\r\n  function getContinuationContractAddress() public view returns (address) {\r\n    return continuationContractAddress;\r\n  }\r\n\r\n\r\n  function canCheckIn() public view returns (bool) {\r\n    if (state != States.Active) {\r\n      return false;\r\n    }\r\n    uint timeSinceLastOwnerCheckIn = SafeMath.sub(getBlockTimestamp(), lastOwnerCheckInAt);\r\n    return timeSinceLastOwnerCheckIn \u003C= checkInInterval;\r\n  }\r\n\r\n\r\n  function isAcceptingKeeperProposals() public view returns (bool) {\r\n    return state == States.CallForKeepers;\r\n  }\r\n\r\n\r\n  function getNumProposals() external view returns (uint) {\r\n    return keeperProposals.length;\r\n  }\r\n\r\n\r\n  function getNumKeepers() external view returns (uint) {\r\n    return activeKeepersAddresses.length;\r\n  }\r\n\r\n\r\n  function getNumEncryptedKeyPartsChunks() external view returns (uint) {\r\n    return encryptedKeyPartsChunks.length;\r\n  }\r\n\r\n\r\n  function getEncryptedKeyPartsChunk(uint index) external view returns (bytes memory) {\r\n    return encryptedKeyPartsChunks[index];\r\n  }\r\n\r\n\r\n  function getNumSuppliedKeyParts() external view returns (uint) {\r\n    return encryptedData.suppliedKeyParts.length;\r\n  }\r\n\r\n\r\n  function getSuppliedKeyPart(uint index) external view returns (bytes memory) {\r\n    return encryptedData.suppliedKeyParts[index];\r\n  }\r\n\r\n  function isActiveKeeper(address addr) public view returns (bool) {\r\n    return activeKeepers[addr].lastCheckInAt \u003E 0;\r\n  }\r\n\r\n  function didSendProposal(address addr) public view returns (bool) {\r\n    return proposedKeeperFlags[addr];\r\n  }\r\n\r\n\r\n  // Called by a Keeper to submit their proposal.\r\n  //\r\n  function submitKeeperProposal(bytes calldata publicKey, uint keepingFee) external\r\n    atState(States.CallForKeepers)\r\n  {\r\n    require(msg.sender != owner, \u00226\u0022); // error: tx sender must not be the owner\r\n    require(!didSendProposal(msg.sender), \u00227\u0022); // error: proposal was already sent by tx sender\r\n    require(publicKey.length \u003C= 128, \u00228\u0022); // error: public key length is invalid\r\n\r\n    bytes32 publicKeyHash = keccak256(publicKey);\r\n\r\n    // error: public key was already used by another keeper\r\n    require(!proposedPublicKeyHashes[publicKeyHash], \u00229\u0022);\r\n\r\n    keeperProposals.push(KeeperProposal({\r\n      keeperAddress: msg.sender,\r\n      publicKey: publicKey,\r\n      keepingFee: keepingFee\r\n    }));\r\n\r\n    proposedKeeperFlags[msg.sender] = true;\r\n    proposedPublicKeyHashes[publicKeyHash] = true;\r\n  }\r\n\r\n  // Calculates how much would it cost the owner to activate contract with given Keepers.\r\n  //\r\n  function calculateActivationPrice(uint[] memory selectedProposalIndices) public view returns (uint) {\r\n    uint _totalKeepingFee = 0;\r\n\r\n    for (uint i = 0; i \u003C selectedProposalIndices.length; i\u002B\u002B) {\r\n      uint proposalIndex = selectedProposalIndices[i];\r\n      KeeperProposal storage proposal = keeperProposals[proposalIndex];\r\n      _totalKeepingFee = SafeMath.add(_totalKeepingFee, proposal.keepingFee);\r\n    }\r\n\r\n    return _totalKeepingFee;\r\n  }\r\n\r\n  function acceptKeepersAndActivate(\r\n    uint16 shareLength,\r\n    bytes32 dataHash,\r\n    bytes16 aesCounter,\r\n    uint[] calldata selectedProposalIndices,\r\n    bytes32[] calldata keyPartHashes,\r\n    bytes calldata encryptedKeyParts,\r\n    bytes calldata _encryptedData\r\n  ) payable external\r\n  {\r\n    acceptKeepers(selectedProposalIndices, keyPartHashes, encryptedKeyParts);\r\n    activate(shareLength, _encryptedData, dataHash, aesCounter);\r\n  }\r\n\r\n  // Called by owner to accept selected Keeper proposals.\r\n  // May be called multiple times.\r\n  //\r\n  function acceptKeepers(\r\n    uint[] memory selectedProposalIndices,\r\n    bytes32[] memory keyPartHashes,\r\n    bytes memory encryptedKeyParts\r\n  ) public\r\n    ownerOnly()\r\n    atState(States.CallForKeepers)\r\n  {\r\n    // error: you must select an least one proposal to accept\r\n    require(selectedProposalIndices.length \u003E 0, \u002210\u0022);\r\n    // error: lengths of proposal indices and key part hashes don\u0027t match\r\n    require(keyPartHashes.length == selectedProposalIndices.length, \u002211\u0022);\r\n    // error: encrypted key parts data must not be empty\r\n    require(encryptedKeyParts.length \u003E 0, \u002212\u0022);\r\n\r\n    uint timestamp = getBlockTimestamp();\r\n    uint chunkKeepingFee = 0;\r\n\r\n    for (uint i = 0; i \u003C selectedProposalIndices.length; i\u002B\u002B) {\r\n      uint proposalIndex = selectedProposalIndices[i];\r\n      KeeperProposal storage proposal = keeperProposals[proposalIndex];\r\n\r\n      // error: keeper has already been accepted\r\n      require(activeKeepers[proposal.keeperAddress].lastCheckInAt == 0, \u002213\u0022);\r\n\r\n      activeKeepers[proposal.keeperAddress] = ActiveKeeper({\r\n        publicKey: proposal.publicKey,\r\n        keyPartHash: keyPartHashes[i],\r\n        keepingFee: proposal.keepingFee,\r\n        lastCheckInAt: timestamp,\r\n        balance: 0,\r\n        keyPartSupplied: false\r\n      });\r\n\r\n      activeKeepersAddresses.push(proposal.keeperAddress);\r\n      chunkKeepingFee = SafeMath.add(chunkKeepingFee, proposal.keepingFee);\r\n    }\r\n\r\n    totalKeepingFee = SafeMath.add(totalKeepingFee, chunkKeepingFee);\r\n    encryptedKeyPartsChunks.push(encryptedKeyParts);\r\n  }\r\n\r\n  // Called by owner to activate the contract and distribute keys between Keepers\r\n  // accepted previously using \u0060acceptKeepers\u0060 function.\r\n  //\r\n  function activate(\r\n    uint16 shareLength,\r\n    bytes memory _encryptedData,\r\n    bytes32 dataHash,\r\n    bytes16 aesCounter\r\n  ) payable public\r\n    ownerOnly()\r\n    atState(States.CallForKeepers)\r\n  {\r\n    require(activeKeepersAddresses.length \u003E 0, \u002214\u0022); // error: you must accept at least one keeper\r\n\r\n    uint balance = address(this).balance;\r\n    // error: balance is insufficient to pay keeping fee\r\n    require(balance \u003E= totalKeepingFee, \u002215\u0022);\r\n\r\n    uint timestamp = getBlockTimestamp();\r\n    lastOwnerCheckInAt = timestamp;\r\n\r\n    for (uint i = 0; i \u003C activeKeepersAddresses.length; i\u002B\u002B) {\r\n      ActiveKeeper storage keeper = activeKeepers[activeKeepersAddresses[i]];\r\n      keeper.lastCheckInAt = timestamp;\r\n    }\r\n\r\n    encryptedData = EncryptedData({\r\n      encryptedData: _encryptedData,\r\n      aesCounter: aesCounter,\r\n      dataHash: dataHash,\r\n      shareLength: shareLength,\r\n      suppliedKeyParts: new bytes[](0)\r\n    });\r\n\r\n    state = States.Active;\r\n  }\r\n\r\n\r\n  // Updates owner check-in time and credits all active Keepers with keeping fee.\r\n  //\r\n  function ownerCheckIn() payable external\r\n    ownerOnly()\r\n    atState(States.Active)\r\n  {\r\n    uint excessBalance = creditKeepers({prepayOneKeepingPeriodUpfront: true});\r\n\r\n    lastOwnerCheckInAt = getBlockTimestamp();\r\n\r\n    if (excessBalance \u003E 0) {\r\n      msg.sender.transfer(excessBalance);\r\n    }\r\n  }\r\n\r\n\r\n  // Calculates approximate price of a check-in, given that it will be performed right now.\r\n  // Actual price may differ because\r\n  //\r\n  function calculateApproximateCheckInPrice() public view returns (uint) {\r\n    uint keepingFeeMult = calculateKeepingFeeMult();\r\n    uint requiredBalance = 0;\r\n\r\n    for (uint i = 0; i \u003C activeKeepersAddresses.length; i\u002B\u002B) {\r\n      ActiveKeeper storage keeper = activeKeepers[activeKeepersAddresses[i]];\r\n      uint balanceToAdd = SafeMath.mul(keeper.keepingFee, keepingFeeMult) / KEEPING_FEE_ROUNDING_MULT;\r\n      uint newKeeperBalance = SafeMath.add(keeper.balance, balanceToAdd);\r\n      requiredBalance = SafeMath.add(requiredBalance, newKeeperBalance);\r\n    }\r\n\r\n    requiredBalance = SafeMath.add(requiredBalance, totalKeepingFee);\r\n    uint balance = address(this).balance;\r\n\r\n    if (balance \u003E= requiredBalance) {\r\n      return 0;\r\n    } else {\r\n      return requiredBalance - balance;\r\n    }\r\n  }\r\n\r\n\r\n  // Returns: excess balance that can be transferred back to owner.\r\n  //\r\n  function creditKeepers(bool prepayOneKeepingPeriodUpfront) internal returns (uint) {\r\n    uint keepingFeeMult = calculateKeepingFeeMult();\r\n    uint requiredBalance = 0;\r\n\r\n    for (uint i = 0; i \u003C activeKeepersAddresses.length; i\u002B\u002B) {\r\n      ActiveKeeper storage keeper = activeKeepers[activeKeepersAddresses[i]];\r\n      uint balanceToAdd = SafeMath.mul(keeper.keepingFee, keepingFeeMult) / KEEPING_FEE_ROUNDING_MULT;\r\n      keeper.balance = SafeMath.add(keeper.balance, balanceToAdd);\r\n      requiredBalance = SafeMath.add(requiredBalance, keeper.balance);\r\n    }\r\n\r\n    if (prepayOneKeepingPeriodUpfront) {\r\n      requiredBalance = SafeMath.add(requiredBalance, totalKeepingFee);\r\n    }\r\n\r\n    uint balance = address(this).balance;\r\n\r\n    // error: balance is insufficient to pay keeping fee\r\n    require(balance \u003E= requiredBalance, \u002216\u0022);\r\n    return balance - requiredBalance;\r\n  }\r\n\r\n\r\n  function calculateKeepingFeeMult() internal view returns (uint) {\r\n    uint timeSinceLastOwnerCheckIn = SafeMath.sub(getBlockTimestamp(), lastOwnerCheckInAt);\r\n\r\n    // error: owner has missed check-in time\r\n    require(timeSinceLastOwnerCheckIn \u003C= checkInInterval, \u002217\u0022);\r\n\r\n    // ceil to 10 minutes\r\n    if (timeSinceLastOwnerCheckIn == 0) {\r\n      timeSinceLastOwnerCheckIn = 600;\r\n    } else {\r\n      timeSinceLastOwnerCheckIn = ceil(timeSinceLastOwnerCheckIn, 600);\r\n    }\r\n\r\n    if (timeSinceLastOwnerCheckIn \u003E checkInInterval) {\r\n      timeSinceLastOwnerCheckIn = checkInInterval;\r\n    }\r\n\r\n    return SafeMath.mul(KEEPING_FEE_ROUNDING_MULT, timeSinceLastOwnerCheckIn) / checkInInterval;\r\n  }\r\n\r\n\r\n  // Pays the Keeper their balance and updates their check-in time. Verifies that the owner\r\n  // checked in in time and, if not, transfers the contract into CALL_FOR_KEYS state.\r\n  //\r\n  // A Keeper can call this method to get his reward regardless of the contract state.\r\n  //\r\n  function keeperCheckIn() external\r\n    activeKeepersOnly()\r\n  {\r\n    uint timestamp = getBlockTimestamp();\r\n\r\n    ActiveKeeper storage keeper = activeKeepers[msg.sender];\r\n    keeper.lastCheckInAt = timestamp;\r\n\r\n    if (state == States.Active) {\r\n      uint timeSinceLastOwnerCheckIn = SafeMath.sub(timestamp, lastOwnerCheckInAt);\r\n      if (timeSinceLastOwnerCheckIn \u003E checkInInterval) {\r\n        state = States.CallForKeys;\r\n        emit KeysNeeded();\r\n      }\r\n    }\r\n\r\n    uint keeperBalance = keeper.balance;\r\n    if (keeperBalance \u003E 0) {\r\n      keeper.balance = 0;\r\n      msg.sender.transfer(keeperBalance);\r\n    }\r\n  }\r\n\r\n\r\n  // Called by Keepers to supply their decrypted key parts.\r\n  //\r\n  function supplyKey(bytes calldata keyPart) external\r\n    activeKeepersOnly()\r\n    atState(States.CallForKeys)\r\n  {\r\n    ActiveKeeper storage keeper = activeKeepers[msg.sender];\r\n    require(!keeper.keyPartSupplied, \u002218\u0022); // error: this keeper has already supplied a key\r\n\r\n    bytes32 suppliedKeyPartHash = keccak256(keyPart);\r\n    require(suppliedKeyPartHash == keeper.keyPartHash, \u002219\u0022); // error: unexpected key supplied\r\n\r\n    encryptedData.suppliedKeyParts.push(keyPart);\r\n    keeper.keyPartSupplied = true;\r\n\r\n    // Include one-period keeping fee that was held by contract in advance.\r\n    uint toBeTransferred = SafeMath.add(keeper.balance, keeper.keepingFee);\r\n    keeper.balance = 0;\r\n\r\n    if (toBeTransferred \u003E 0) {\r\n      msg.sender.transfer(toBeTransferred);\r\n    }\r\n  }\r\n\r\n\r\n  // Allows owner to announce continuation contract to all active Keepers.\r\n  //\r\n  // Continuation contract is used to elect new set of Keepers, e.g. to replace inactive ones.\r\n  // When the continuation contract gets sufficient number of keeping proposals, owner will\r\n  // cancel this contract and start the continuation one.\r\n  //\r\n  function announceContinuationContract(address _continuationContractAddress) external\r\n    ownerOnly()\r\n    atState(States.Active)\r\n  {\r\n    // error: continuation contract already announced\r\n    require(continuationContractAddress == address(0), \u002220\u0022);\r\n    // error: continuation contract cannot have the same address\r\n    require(_continuationContractAddress != address(this), \u002221\u0022);\r\n\r\n    CryptoLegacyBaseAPI continuationContract = CryptoLegacyBaseAPI(_continuationContractAddress);\r\n\r\n    // error: continuation contract must have the same owner\r\n    require(continuationContract.getOwner() == getOwner(), \u002222\u0022);\r\n    // error: continuation contract must be at least the same version\r\n    require(continuationContract.getVersion() \u003E= getVersion(), \u002223\u0022);\r\n    // error: continuation contract must be accepting keeper proposals\r\n    require(continuationContract.isAcceptingKeeperProposals(), \u002224\u0022);\r\n\r\n    continuationContractAddress = _continuationContractAddress;\r\n    emit ContinuationContractAnnounced(_continuationContractAddress);\r\n  }\r\n\r\n\r\n  // Cancels the contract and notifies the Keepers. Credits all active Keepers with keeping fee,\r\n  // as if this was a check-in.\r\n  //\r\n  function cancel() payable external\r\n    ownerOnly()\r\n    atEitherOfStates(States.CallForKeepers, States.Active)\r\n  {\r\n    uint excessBalance = 0;\r\n\r\n    if (state == States.Active) {\r\n      // We don\u0027t require paying one keeping period upfront as the contract is being cancelled;\r\n      // we just require paying till the present moment.\r\n      excessBalance = creditKeepers({prepayOneKeepingPeriodUpfront: false});\r\n    }\r\n\r\n    state = States.Cancelled;\r\n    emit Cancelled();\r\n\r\n    if (excessBalance \u003E 0) {\r\n      msg.sender.transfer(excessBalance);\r\n    }\r\n  }\r\n\r\n\r\n  // We can rely on the value of now (block.timestamp) for our purposes, as the consensus\r\n  // rule is that a block\u0027s timestamp must be 1) more than the parent\u0027s block timestamp;\r\n  // and 2) less than the current wall clock time. See:\r\n  // https://github.com/ethereum/go-ethereum/blob/885c13c/consensus/ethash/consensus.go#L223\r\n  //\r\n  function getBlockTimestamp() internal view returns (uint) {\r\n    return now;\r\n  }\r\n\r\n\r\n  // See: https://stackoverflow.com/a/2745086/804678\r\n  //\r\n  function ceil(uint x, uint y) internal pure returns (uint) {\r\n    if (x == 0) return 0;\r\n    return SafeMath.mul(1 \u002B SafeMath.div(x - 1, y), y);\r\n  }\r\n\r\n}\r\n\r\n// File: browser/Registry.sol\r\n\r\ncontract Registry {\r\n  event NewContract(string id, address addr, uint totalContracts);\r\n\r\n  struct Contract {\r\n    address initialAddress;\r\n    address currentAddress;\r\n  }\r\n\r\n  mapping(address =\u003E string[]) internal contractsByOwner;\r\n  mapping(string =\u003E Contract) internal contractsById;\r\n  string[] public contracts;\r\n\r\n  function getNumContracts() external view returns (uint) {\r\n    return contracts.length;\r\n  }\r\n\r\n  function getContractAddress(string calldata id) external view returns (address) {\r\n    return contractsById[id].currentAddress;\r\n  }\r\n\r\n  function getContractInitialAddress(string calldata id) external view returns (address) {\r\n    return contractsById[id].initialAddress;\r\n  }\r\n\r\n  function getNumContractsByOwner(address owner) external view returns (uint) {\r\n    return contractsByOwner[owner].length;\r\n  }\r\n\r\n  function getContractByOwner(address owner, uint index) external view returns (string memory) {\r\n    return contractsByOwner[owner][index];\r\n  }\r\n\r\n  function deployAndRegisterContract(string calldata id, uint checkInInterval)\r\n    external\r\n    payable\r\n    returns (CryptoLegacy)\r\n  {\r\n    CryptoLegacy instance = new CryptoLegacy(msg.sender, checkInInterval);\r\n    addContract(id, address(instance));\r\n    return instance;\r\n  }\r\n\r\n  function addContract(string memory id, address addr) public {\r\n    // error: contract with the same id already registered\r\n    require(contractsById[id].initialAddress == address(0), \u0022R1\u0022);\r\n\r\n    CryptoLegacyBaseAPI instance = CryptoLegacyBaseAPI(addr);\r\n    address owner = instance.getOwner();\r\n\r\n    // error: tx sender must be contract owner\r\n    require(msg.sender == owner, \u0022R2\u0022);\r\n\r\n    contracts.push(id);\r\n    contractsByOwner[owner].push(id);\r\n    contractsById[id] = Contract({initialAddress: addr, currentAddress: addr});\r\n\r\n    emit NewContract(id, addr, contracts.length);\r\n  }\r\n\r\n  function updateAddress(string calldata id) external {\r\n    Contract storage ctr = contractsById[id];\r\n    // error: cannot find contract with the supplied id\r\n    require(ctr.currentAddress != address(0), \u0022R3\u0022);\r\n\r\n    CryptoLegacyBaseAPI instance = CryptoLegacyBaseAPI(ctr.currentAddress);\r\n    // error: tx sender must be contract owner\r\n    require(instance.getOwner() == msg.sender, \u0022R4\u0022);\r\n\r\n    address continuationAddress = instance.getContinuationContractAddress();\r\n    if (continuationAddress == address(0)) {\r\n      return;\r\n    }\r\n\r\n    CryptoLegacyBaseAPI continuationInstance = CryptoLegacyBaseAPI(continuationAddress);\r\n    // error: tx sender must be contract owner\r\n    require(continuationInstance.getOwner() == msg.sender, \u0022R5\u0022);\r\n    // error: continuation contract must be at least the same version\r\n    require(continuationInstance.getVersion() \u003E= instance.getVersion(), \u0022R6\u0022);\r\n\r\n    ctr.currentAddress = continuationAddress;\r\n\r\n    // TODO: here we\u0027re adding the same id to the contracts array one more time; this allows Keeper\r\n    // clients that didn\u0027t participate in the contract and that were offline at the moment to later\r\n    // discover the continuation contract and send proposals.\r\n    //\r\n    // Ideally, we need to use logs/events filtering instead of relying on contracts array, but\r\n    // currently filtering works unreliably with light clients.\r\n    //\r\n    contracts.push(id);\r\n    emit NewContract(id, continuationAddress, contracts.length);\r\n  }\r\n\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022updateAddress\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022getContractAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022getNumContractsByOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022owner\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022index\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022getContractByOwner\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022contracts\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022getContractInitialAddress\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022checkInInterval\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022deployAndRegisterContract\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022contract CryptoLegacy\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addContract\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getNumContracts\u0022,\u0022outputs\u0022:[{\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022string\u0022,\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022address\u0022,\u0022name\u0022:\u0022addr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022internalType\u0022:\u0022uint256\u0022,\u0022name\u0022:\u0022totalContracts\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022NewContract\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"Registry","CompilerVersion":"v0.5.11\u002Bcommit.c082d0b4","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://a8df01f831bcf04399502ee221352c53df993b22f73e22f15c552ce656f6eb94"}]