[{"SourceCode":"/**\r\n *Submitted for verification at Etherscan.io on 2019-11-03\r\n*/\r\n\r\npragma solidity ^0.5.2;\r\npragma experimental ABIEncoderV2;\r\n\r\n/**\r\n * Copyright (c) 2018-present, Leap DAO (leapdao.org)\r\n *\r\n * This source code is licensed under the Mozilla Public License, version 2,\r\n * found in the LICENSE file in the root directory of this source tree.\r\n */\r\n\r\n\r\n\r\n\r\n/**\r\n * Copyright (c) 2018-present, Leap DAO (leapdao.org)\r\n *\r\n * This source code is licensed under the Mozilla Public License, version 2,\r\n * found in the LICENSE file in the root directory of this source tree.\r\n */\r\n\r\n\r\n\r\n\r\n\r\ninterface IColony {\r\n\r\n  struct Payment {\r\n    address payable recipient;\r\n    bool finalized;\r\n    uint256 fundingPotId;\r\n    uint256 domainId;\r\n    uint256[] skills;\r\n  }\r\n\r\n  // Implemented in ColonyPayment.sol\r\n  /// @notice Add a new payment in the colony. Secured function to authorised members.\r\n  /// @param _permissionDomainId The domainId in which I have the permission to take this action\r\n  /// @param _childSkillIndex The index that the \u0060_domainId\u0060 is relative to \u0060_permissionDomainId\u0060,\r\n  /// (only used if \u0060_permissionDomainId\u0060 is different to \u0060_domainId\u0060)\r\n  /// @param _recipient Address of the payment recipient\r\n  /// @param _token Address of the token, \u00600x0\u0060 value indicates Ether\r\n  /// @param _amount Payout amount\r\n  /// @param _domainId The domain where the payment belongs\r\n  /// @param _skillId The skill associated with the payment\r\n  /// @return paymentId Identifier of the newly created payment\r\n  function addPayment(\r\n    uint256 _permissionDomainId,\r\n    uint256 _childSkillIndex,\r\n    address payable _recipient,\r\n    address _token,\r\n    uint256 _amount,\r\n    uint256 _domainId,\r\n    uint256 _skillId)\r\n    external returns (uint256 paymentId);\r\n\r\n  /// @notice Returns an exiting payment.\r\n  /// @param _id Payment identifier\r\n  /// @return payment The Payment data structure\r\n  function getPayment(uint256 _id) external view returns (Payment memory payment);\r\n\r\n  /// @notice Move a given amount: \u0060_amount\u0060 of \u0060_token\u0060 funds from funding pot with id \u0060_fromPot\u0060 to one with id \u0060_toPot\u0060.\r\n  /// @param _permissionDomainId The domainId in which I have the permission to take this action\r\n  /// @param _fromChildSkillIndex The child index in \u0060_permissionDomainId\u0060 where we can find the domain for \u0060_fromPotId\u0060\r\n  /// @param _toChildSkillIndex The child index in \u0060_permissionDomainId\u0060 where we can find the domain for \u0060_toPotId\u0060\r\n  /// @param _fromPot Funding pot id providing the funds\r\n  /// @param _toPot Funding pot id receiving the funds\r\n  /// @param _amount Amount of funds\r\n  /// @param _token Address of the token, \u00600x0\u0060 value indicates Ether\r\n  function moveFundsBetweenPots(\r\n    uint256 _permissionDomainId,\r\n    uint256 _fromChildSkillIndex,\r\n    uint256 _toChildSkillIndex,\r\n    uint256 _fromPot,\r\n    uint256 _toPot,\r\n    uint256 _amount,\r\n    address _token\r\n    ) external;\r\n\r\n  /// @notice Finalizes the payment and logs the reputation log updates.\r\n  /// Allowed to be called once after payment is fully funded. Secured function to authorised members.\r\n  /// @param _permissionDomainId The domainId in which I have the permission to take this action\r\n  /// @param _childSkillIndex The index that the \u0060_domainId\u0060 is relative to \u0060_permissionDomainId\u0060\r\n  /// @param _id Payment identifier\r\n  function finalizePayment(uint256 _permissionDomainId, uint256 _childSkillIndex, uint256 _id) external;\r\n\r\n  /// @notice Claim the payout in \u0060_token\u0060 denomination for payment \u0060_id\u0060. Here the network receives its fee from each payout.\r\n  /// Same as for tasks, ether fees go straight to the Meta Colony whereas Token fees go to the Network to be auctioned off.\r\n  /// @param _id Payment identifier\r\n  /// @param _token Address of the token, \u00600x0\u0060 value indicates Ether\r\n  function claimPayment(uint256 _id, address _token) external;\r\n}\r\n/**\r\n * @title Roles\r\n * @dev Library for managing addresses assigned to a Role.\r\n */\r\nlibrary Roles {\r\n    struct Role {\r\n        mapping (address =\u003E bool) bearer;\r\n    }\r\n\r\n    /**\r\n     * @dev give an account access to this role\r\n     */\r\n    function add(Role storage role, address account) internal {\r\n        require(account != address(0));\r\n        require(!has(role, account));\r\n\r\n        role.bearer[account] = true;\r\n    }\r\n\r\n    /**\r\n     * @dev remove an account\u0027s access to this role\r\n     */\r\n    function remove(Role storage role, address account) internal {\r\n        require(account != address(0));\r\n        require(has(role, account));\r\n\r\n        role.bearer[account] = false;\r\n    }\r\n\r\n    /**\r\n     * @dev check if an account has this role\r\n     * @return bool\r\n     */\r\n    function has(Role storage role, address account) internal view returns (bool) {\r\n        require(account != address(0));\r\n        return role.bearer[account];\r\n    }\r\n}\r\n\r\n/**\r\n * @title WhitelistAdminRole\r\n * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.\r\n */\r\ncontract WhitelistAdminRole {\r\n    using Roles for Roles.Role;\r\n\r\n    event WhitelistAdminAdded(address indexed account);\r\n    event WhitelistAdminRemoved(address indexed account);\r\n\r\n    Roles.Role private _whitelistAdmins;\r\n\r\n    constructor () internal {\r\n        _addWhitelistAdmin(msg.sender);\r\n    }\r\n\r\n    modifier onlyWhitelistAdmin() {\r\n        require(isWhitelistAdmin(msg.sender));\r\n        _;\r\n    }\r\n\r\n    function isWhitelistAdmin(address account) public view returns (bool) {\r\n        return _whitelistAdmins.has(account);\r\n    }\r\n\r\n    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {\r\n        _addWhitelistAdmin(account);\r\n    }\r\n\r\n    function renounceWhitelistAdmin() public {\r\n        _removeWhitelistAdmin(msg.sender);\r\n    }\r\n\r\n    function _addWhitelistAdmin(address account) internal {\r\n        _whitelistAdmins.add(account);\r\n        emit WhitelistAdminAdded(account);\r\n    }\r\n\r\n    function _removeWhitelistAdmin(address account) internal {\r\n        _whitelistAdmins.remove(account);\r\n        emit WhitelistAdminRemoved(account);\r\n    }\r\n}\r\n\r\n/**\r\n * @title WhitelistedRole\r\n * @dev Whitelisted accounts have been approved by a WhitelistAdmin to perform certain actions (e.g. participate in a\r\n * crowdsale). This role is special in that the only accounts that can add it are WhitelistAdmins (who can also remove\r\n * it), and not Whitelisteds themselves.\r\n */\r\ncontract WhitelistedRole is WhitelistAdminRole {\r\n    using Roles for Roles.Role;\r\n\r\n    event WhitelistedAdded(address indexed account);\r\n    event WhitelistedRemoved(address indexed account);\r\n\r\n    Roles.Role private _whitelisteds;\r\n\r\n    modifier onlyWhitelisted() {\r\n        require(isWhitelisted(msg.sender));\r\n        _;\r\n    }\r\n\r\n    function isWhitelisted(address account) public view returns (bool) {\r\n        return _whitelisteds.has(account);\r\n    }\r\n\r\n    function addWhitelisted(address account) public onlyWhitelistAdmin {\r\n        _addWhitelisted(account);\r\n    }\r\n\r\n    function removeWhitelisted(address account) public onlyWhitelistAdmin {\r\n        _removeWhitelisted(account);\r\n    }\r\n\r\n    function renounceWhitelisted() public {\r\n        _removeWhitelisted(msg.sender);\r\n    }\r\n\r\n    function _addWhitelisted(address account) internal {\r\n        _whitelisteds.add(account);\r\n        emit WhitelistedAdded(account);\r\n    }\r\n\r\n    function _removeWhitelisted(address account) internal {\r\n        _whitelisteds.remove(account);\r\n        emit WhitelistedRemoved(account);\r\n    }\r\n}\r\n/**\r\n * @title ERC20 interface\r\n * @dev see https://github.com/ethereum/EIPs/issues/20\r\n */\r\ninterface IERC20 {\r\n    function transfer(address to, uint256 value) external returns (bool);\r\n\r\n    function approve(address spender, uint256 value) external returns (bool);\r\n\r\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\r\n\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    function balanceOf(address who) external view returns (uint256);\r\n\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}\r\n\r\ncontract BountyPayout is WhitelistedRole {\r\n\r\n  uint256 constant DAI_DECIMALS = 10^18;\r\n  uint256 constant PERMISSION_DOMAIN_ID = 1;\r\n  uint256 constant CHILD_SKILL_INDEX = 0;\r\n  uint256 constant DOMAIN_ID = 1;\r\n  uint256 constant SKILL_ID = 0;\r\n\r\n  address public colonyAddr;\r\n  address public daiAddr;\r\n  address public leapAddr;\r\n\r\n  enum PayoutType { Gardener, Worker, Reviewer }\r\n  event Payout(\r\n    bytes32 indexed bountyId,\r\n    PayoutType indexed payoutType,\r\n    address indexed recipient,\r\n    uint256 amount,\r\n    uint256 paymentId\r\n  );\r\n\r\n  constructor(\r\n    address _colonyAddr,\r\n    address _daiAddr,\r\n    address _leapAddr) public {\r\n    colonyAddr = _colonyAddr;\r\n    daiAddr = _daiAddr;\r\n    leapAddr = _leapAddr;\r\n  }\r\n\r\n  function _isRepOnly(uint256 amount) internal returns (bool) {\r\n    return ((amount \u0026 0x01) == 1);\r\n  }\r\n\r\n  function _makeColonyPayment(address payable _worker, uint256 _amount) internal returns (uint256) {\r\n\r\n    IColony colony = IColony(colonyAddr);\r\n    // Add a new payment\r\n    uint256 paymentId = colony.addPayment(\r\n      PERMISSION_DOMAIN_ID,\r\n      CHILD_SKILL_INDEX,\r\n      _worker,\r\n      leapAddr,\r\n      _amount,\r\n      DOMAIN_ID,\r\n      SKILL_ID\r\n    );\r\n    IColony.Payment memory payment = colony.getPayment(paymentId);\r\n\r\n    // Fund the payment\r\n    colony.moveFundsBetweenPots(\r\n      1, // Root domain always 1\r\n      0, // Not used, this extension contract must have funding permission in the root for this function to work\r\n      CHILD_SKILL_INDEX,\r\n      1, // Root domain funding pot is always 1\r\n      payment.fundingPotId,\r\n      _amount,\r\n      leapAddr\r\n    );\r\n    colony.finalizePayment(PERMISSION_DOMAIN_ID, CHILD_SKILL_INDEX, paymentId);\r\n\r\n    // Claim payout on behalf of the recipient\r\n    colony.claimPayment(paymentId, leapAddr);\r\n    return paymentId;\r\n  }\r\n\r\n  function _payout(\r\n    address payable _gardenerAddr,\r\n    uint256 _gardenerDaiAmount,\r\n    address payable _workerAddr,\r\n    uint256 _workerDaiAmount,\r\n    address payable _reviewerAddr,\r\n    uint256 _reviewerDaiAmount,\r\n    bytes32 _bountyId\r\n  ) internal {\r\n    IERC20 dai = IERC20(daiAddr);\r\n\r\n    // gardener worker\r\n    // Why is a gardener share required?\r\n    // Later we will hold a stake for gardeners, which will be handled here.\r\n    require(_gardenerDaiAmount \u003E DAI_DECIMALS, \u0022gardener amount too small\u0022);\r\n    uint256 paymentId = _makeColonyPayment(_gardenerAddr, _gardenerDaiAmount);\r\n    if (!_isRepOnly(_gardenerDaiAmount)) {\r\n      dai.transferFrom(msg.sender, _gardenerAddr, _gardenerDaiAmount);\r\n    }\r\n    emit Payout(_bountyId, PayoutType.Gardener, _gardenerAddr, _gardenerDaiAmount, paymentId);\r\n\r\n    // handle worker\r\n    if (_workerDaiAmount \u003E 0) {\r\n      paymentId = _makeColonyPayment(_workerAddr, _workerDaiAmount);\r\n      if (!_isRepOnly(_workerDaiAmount)) {\r\n        dai.transferFrom(msg.sender, _workerAddr, _workerDaiAmount);\r\n      }\r\n      emit Payout(_bountyId, PayoutType.Worker, _workerAddr, _workerDaiAmount, paymentId);\r\n    }\r\n\r\n    // handle reviewer\r\n    if (_reviewerDaiAmount \u003E 0) {\r\n      paymentId = _makeColonyPayment(_reviewerAddr, _reviewerDaiAmount);\r\n      if (!_isRepOnly(_reviewerDaiAmount)) {\r\n        dai.transferFrom(msg.sender, _reviewerAddr, _reviewerDaiAmount);\r\n      }\r\n      emit Payout(_bountyId, PayoutType.Reviewer, _reviewerAddr, _reviewerDaiAmount, paymentId);\r\n    }\r\n  }\r\n\r\n /**\r\n  * Pays out a bounty to the different roles of a bounty\r\n  *\r\n  * @dev This contract should have enough allowance of daiAddr from payerAddr\r\n  * @dev This colony contract should have enough LEAP in its funding pot\r\n  * @param _gardener DAI amount to pay gardner and gardener wallet address\r\n  * @param _worker DAI amount to pay worker and worker wallet address\r\n  * @param _reviewer DAI amount to pay reviewer and reviewer wallet address\r\n  */\r\n  function payout(\r\n    bytes32 _gardener,\r\n    bytes32 _worker,\r\n    bytes32 _reviewer,\r\n    bytes32 _bountyId\r\n  ) public onlyWhitelisted {\r\n    _payout(\r\n      address(bytes20(_gardener)),\r\n      uint96(uint256(_gardener)),\r\n      address(bytes20(_worker)),\r\n      uint96(uint256(_worker)),\r\n      address(bytes20(_reviewer)),\r\n      uint96(uint256(_reviewer)),\r\n      _bountyId\r\n    );\r\n  }\r\n\r\n  function payoutReviewedDelivery(\r\n    bytes32 _gardener,\r\n    bytes32 _reviewer,\r\n    bytes32 _bountyId\r\n  ) public onlyWhitelisted {\r\n    _payout(\r\n      address(bytes20(_gardener)),\r\n      uint96(uint256(_gardener)),\r\n      address(bytes20(_gardener)),\r\n      0,\r\n      address(bytes20(_reviewer)),\r\n      uint96(uint256(_reviewer)),\r\n      _bountyId\r\n    );\r\n  }\r\n\r\n  function payoutNoReviewer(\r\n    bytes32 _gardener,\r\n    bytes32 _worker,\r\n    bytes32 _bountyId\r\n  ) public onlyWhitelisted {\r\n    _payout(\r\n      address(bytes20(_gardener)),\r\n      uint96(uint256(_gardener)),\r\n      address(bytes20(_worker)),\r\n      uint96(uint256(_worker)),\r\n      address(bytes20(_gardener)),\r\n      0,\r\n      _bountyId\r\n    );\r\n  }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022colonyAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addWhitelisted\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022removeWhitelisted\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isWhitelisted\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_gardener\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_reviewer\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_bountyId\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022payoutReviewedDelivery\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceWhitelistAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022addWhitelistAdmin\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022daiAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022leapAddr\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022isWhitelistAdmin\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022renounceWhitelisted\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_gardener\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_worker\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_bountyId\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022payoutNoReviewer\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_gardener\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_worker\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_reviewer\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022_bountyId\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022payout\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_colonyAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_daiAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_leapAddr\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022bountyId\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022payoutType\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022indexed\u0022:true,\u0022name\u0022:\u0022recipient\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022paymentId\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Payout\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WhitelistedAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WhitelistedRemoved\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WhitelistAdminAdded\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022account\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022WhitelistAdminRemoved\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"BountyPayout","CompilerVersion":"v0.5.2\u002Bcommit.1df8f40c","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"00000000000000000000000024f861f8356fa8d18b6adea07ac59719f42012b10000000000000000000000006b175474e89094c44da98b954eedeac495271d0f00000000000000000000000078230e69d6e6449db1e11904e0bd81c018454d7a","Library":"","SwarmSource":"bzzr://ae5bcb92329e389f5ecd1a3bf8c639f2a41002c5b888ee6aa0e51e0ce1e1e07c"}]