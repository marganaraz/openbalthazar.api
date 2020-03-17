[{"SourceCode":"pragma solidity 0.4.26;\r\n\r\n/// @title uniquely identifies deployable (non-abstract) platform contract\r\n/// @notice cheap way of assigning implementations to knownInterfaces which represent system services\r\n///         unfortunatelly ERC165 does not include full public interface (ABI) and does not provide way to list implemented interfaces\r\n///         EIP820 still in the making\r\n/// @dev ids are generated as follows keccak256(\u0022neufund-platform:\u003Ccontract name\u003E\u0022)\r\n///      ids roughly correspond to ABIs\r\ncontract IContractId {\r\n    /// @param id defined as above\r\n    /// @param version implementation version\r\n    function contractId() public pure returns (bytes32 id, uint256 version);\r\n}\r\n\r\ncontract ShareholderRights is IContractId {\r\n\r\n    ////////////////////////\r\n    // Types\r\n    ////////////////////////\r\n\r\n    enum VotingRule {\r\n        // nominee has no voting rights\r\n        NoVotingRights,\r\n        // nominee votes yes if token holders do not say otherwise\r\n        Positive,\r\n        // nominee votes against if token holders do not say otherwise\r\n        Negative,\r\n        // nominee passes the vote as is giving yes/no split\r\n        Proportional\r\n    }\r\n\r\n    ////////////////////////\r\n    // Constants state\r\n    ////////////////////////\r\n\r\n    bytes32 private constant EMPTY_STRING_HASH = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;\r\n\r\n    ////////////////////////\r\n    // Immutable state\r\n    ////////////////////////\r\n\r\n    // todo: split into ShareholderRights and TokenholderRigths where the first one corresponds to rights of real shareholder (nominee, founder)\r\n    // and the second one corresponds to the list of the token holder (which does not own shares but have identical rights (equity token))\r\n    // or has a debt token with very different rights\r\n    // TokenholderRights will be attached to a token via TokenController and will for example say if token participates in dividends or shareholder resolutins\r\n\r\n    // a right to drag along (or be dragged) on exit\r\n    bool public constant HAS_DRAG_ALONG_RIGHTS = true;\r\n    // a right to tag along\r\n    bool public constant HAS_TAG_ALONG_RIGHTS = true;\r\n    // information is fundamental right that cannot be removed\r\n    bool public constant HAS_GENERAL_INFORMATION_RIGHTS = true;\r\n    // voting Right\r\n    VotingRule public GENERAL_VOTING_RULE;\r\n    // voting rights in tag along\r\n    VotingRule public TAG_ALONG_VOTING_RULE;\r\n    // liquidation preference multiplicator as decimal fraction\r\n    uint256 public LIQUIDATION_PREFERENCE_MULTIPLIER_FRAC;\r\n    // founder\u0027s vesting\r\n    bool public HAS_FOUNDERS_VESTING;\r\n    // duration of general voting\r\n    uint256 public GENERAL_VOTING_DURATION;\r\n    // duration of restricted act votings (like exit etc.)\r\n    uint256 public RESTRICTED_ACT_VOTING_DURATION;\r\n    // offchain time to finalize and execute voting;\r\n    uint256 public VOTING_FINALIZATION_DURATION;\r\n    // quorum of shareholders for the vote to count as decimal fraction\r\n    uint256 public SHAREHOLDERS_VOTING_QUORUM_FRAC;\r\n    // number of tokens voting / total supply must be more than this to count the vote\r\n    uint256 public VOTING_MAJORITY_FRAC = 10**17; // 10%\r\n    // url (typically IPFS hash) to investment agreement between nominee and company\r\n    string public INVESTMENT_AGREEMENT_TEMPLATE_URL;\r\n\r\n    ////////////////////////\r\n    // Constructor\r\n    ////////////////////////\r\n\r\n    constructor(\r\n        VotingRule generalVotingRule,\r\n        VotingRule tagAlongVotingRule,\r\n        uint256 liquidationPreferenceMultiplierFrac,\r\n        bool hasFoundersVesting,\r\n        uint256 generalVotingDuration,\r\n        uint256 restrictedActVotingDuration,\r\n        uint256 votingFinalizationDuration,\r\n        uint256 shareholdersVotingQuorumFrac,\r\n        uint256 votingMajorityFrac,\r\n        string investmentAgreementTemplateUrl\r\n    )\r\n        public\r\n    {\r\n        // todo: revise requires\r\n        require(uint(generalVotingRule) \u003C 4);\r\n        require(uint(tagAlongVotingRule) \u003C 4);\r\n        // quorum \u003C 100%\r\n        require(shareholdersVotingQuorumFrac \u003C= 10**18);\r\n        require(keccak256(abi.encodePacked(investmentAgreementTemplateUrl)) != EMPTY_STRING_HASH);\r\n\r\n        GENERAL_VOTING_RULE = generalVotingRule;\r\n        TAG_ALONG_VOTING_RULE = tagAlongVotingRule;\r\n        LIQUIDATION_PREFERENCE_MULTIPLIER_FRAC = liquidationPreferenceMultiplierFrac;\r\n        HAS_FOUNDERS_VESTING = hasFoundersVesting;\r\n        GENERAL_VOTING_DURATION = generalVotingDuration;\r\n        RESTRICTED_ACT_VOTING_DURATION = restrictedActVotingDuration;\r\n        VOTING_FINALIZATION_DURATION = votingFinalizationDuration;\r\n        SHAREHOLDERS_VOTING_QUORUM_FRAC = shareholdersVotingQuorumFrac;\r\n        VOTING_MAJORITY_FRAC = votingMajorityFrac;\r\n        INVESTMENT_AGREEMENT_TEMPLATE_URL = investmentAgreementTemplateUrl;\r\n    }\r\n\r\n    //\r\n    // Implements IContractId\r\n    //\r\n\r\n    function contractId() public pure returns (bytes32 id, uint256 version) {\r\n        return (0x7f46caed28b4e7a90dc4db9bba18d1565e6c4824f0dc1b96b3b88d730da56e57, 0);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022GENERAL_VOTING_DURATION\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022RESTRICTED_ACT_VOTING_DURATION\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022TAG_ALONG_VOTING_RULE\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022HAS_GENERAL_INFORMATION_RIGHTS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022HAS_TAG_ALONG_RIGHTS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022LIQUIDATION_PREFERENCE_MULTIPLIER_FRAC\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022contractId\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022version\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022VOTING_FINALIZATION_DURATION\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022INVESTMENT_AGREEMENT_TEMPLATE_URL\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022HAS_DRAG_ALONG_RIGHTS\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022HAS_FOUNDERS_VESTING\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022VOTING_MAJORITY_FRAC\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022GENERAL_VOTING_RULE\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint8\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022SHAREHOLDERS_VOTING_QUORUM_FRAC\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022generalVotingRule\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022tagAlongVotingRule\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022liquidationPreferenceMultiplierFrac\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022hasFoundersVesting\u0022,\u0022type\u0022:\u0022bool\u0022},{\u0022name\u0022:\u0022generalVotingDuration\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022restrictedActVotingDuration\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022votingFinalizationDuration\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022shareholdersVotingQuorumFrac\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022votingMajorityFrac\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022investmentAgreementTemplateUrl\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"ShareholderRights","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d2f0000000000000000000000000000000000000000000000000000000000001275000000000000000000000000000000000000000000000000000000000000127500000000000000000000000000000000000000000000000000016345785d8a000000000000000000000000000000000000000000000000000006f05b59d3b2000000000000000000000000000000000000000000000000000000000000000001400000000000000000000000000000000000000000000000000000000000000033697066733a516d6571724662526d31387839344b713464766f35706e5772726a71794d5035476e325065486d4a6844704e4c3100000000000000000000000000","Library":"","SwarmSource":"bzzr://e339fc9bd19df010b48b0adf3c7080295a209bfda9f6b11a01f92f3025e98318"}]