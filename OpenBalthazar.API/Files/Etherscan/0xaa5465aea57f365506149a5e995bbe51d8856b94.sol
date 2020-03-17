[{"SourceCode":"pragma solidity 0.4.26;\r\n\r\n/// @title uniquely identifies deployable (non-abstract) platform contract\r\n/// @notice cheap way of assigning implementations to knownInterfaces which represent system services\r\n///         unfortunatelly ERC165 does not include full public interface (ABI) and does not provide way to list implemented interfaces\r\n///         EIP820 still in the making\r\n/// @dev ids are generated as follows keccak256(\u0022neufund-platform:\u003Ccontract name\u003E\u0022)\r\n///      ids roughly correspond to ABIs\r\ncontract IContractId {\r\n    /// @param id defined as above\r\n    /// @param version implementation version\r\n    function contractId() public pure returns (bytes32 id, uint256 version);\r\n}\r\n\r\n/// @title sets duration of states in ETO\r\ncontract ETODurationTerms is IContractId {\r\n\r\n    ////////////////////////\r\n    // Immutable state\r\n    ////////////////////////\r\n\r\n    // duration of Whitelist state\r\n    uint32 public WHITELIST_DURATION;\r\n\r\n    // duration of Public state\r\n    uint32 public PUBLIC_DURATION;\r\n\r\n    // time for Nominee and Company to sign Investment Agreement offchain and present proof on-chain\r\n    uint32 public SIGNING_DURATION;\r\n\r\n    // time for Claim before fee payout from ETO to NEU holders\r\n    uint32 public CLAIM_DURATION;\r\n\r\n    ////////////////////////\r\n    // Constructor\r\n    ////////////////////////\r\n\r\n    constructor(\r\n        uint32 whitelistDuration,\r\n        uint32 publicDuration,\r\n        uint32 signingDuration,\r\n        uint32 claimDuration\r\n    )\r\n        public\r\n    {\r\n        WHITELIST_DURATION = whitelistDuration;\r\n        PUBLIC_DURATION = publicDuration;\r\n        SIGNING_DURATION = signingDuration;\r\n        CLAIM_DURATION = claimDuration;\r\n    }\r\n\r\n    //\r\n    // Implements IContractId\r\n    //\r\n\r\n    function contractId() public pure returns (bytes32 id, uint256 version) {\r\n        return (0x5fb50201b453799d95f8a80291b940f1c543537b95bff2e3c78c2e36070494c0, 0);\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022PUBLIC_DURATION\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022WHITELIST_DURATION\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022SIGNING_DURATION\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022contractId\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022id\u0022,\u0022type\u0022:\u0022bytes32\u0022},{\u0022name\u0022:\u0022version\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022pure\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022CLAIM_DURATION\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022whitelistDuration\u0022,\u0022type\u0022:\u0022uint32\u0022},{\u0022name\u0022:\u0022publicDuration\u0022,\u0022type\u0022:\u0022uint32\u0022},{\u0022name\u0022:\u0022signingDuration\u0022,\u0022type\u0022:\u0022uint32\u0022},{\u0022name\u0022:\u0022claimDuration\u0022,\u0022type\u0022:\u0022uint32\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"ETODurationTerms","CompilerVersion":"v0.4.26\u002Bcommit.4563c3fc","OptimizationUsed":"1","Runs":"200","ConstructorArguments":"00000000000000000000000000000000000000000000000000000000001275000000000000000000000000000000000000000000000000000000000000278d0000000000000000000000000000000000000000000000000000000000004f1a0000000000000000000000000000000000000000000000000000000000000d2f00","Library":"","SwarmSource":"bzzr://21f1ebc20b36bb170d3103ccb850c0957dbc517984b20a2e56eee06facfaa471"}]