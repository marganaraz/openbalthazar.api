[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\ninterface ISplinterlands {\r\n    function mintCard(string calldata splinterId, address owner) external;\r\n    function unlockCard(uint256 _ethId, address _newHolder) external;\r\n    function tokenIdForCardId(string calldata _splinterId) external view returns (uint256);\r\n    function burnCard(uint256 _ethId) external;\r\n}\r\n\r\ncontract CardMinter {\r\n\r\n    address splinterlandsAddr;\r\n    address signer1;\r\n    address signer2;\r\n    address signer3;\r\n\r\n    struct SubstitutionProposal {\r\n        address proposer;\r\n        address affirmer;\r\n        address retiree;\r\n        address replacement;\r\n    }\r\n\r\n    mapping(address =\u003E SubstitutionProposal) proposals;\r\n\r\n    constructor(address _splinterlandsAddr, address _signer1, address _signer2, address _signer3) public {\r\n        splinterlandsAddr = _splinterlandsAddr;\r\n        signer1 = _signer1;\r\n        signer2 = _signer2;\r\n        signer3 = _signer3;\r\n    }\r\n\r\n    function mintCard(string memory _splinterId, address _cardHolder) public onlySigner {\r\n        ISplinterlands splinterlands = ISplinterlands(splinterlandsAddr);\r\n\r\n        splinterlands.mintCard(_splinterId, _cardHolder);\r\n    }\r\n\r\n    function unlockCard(string memory _splinterId, address _cardHolder) public onlySigner {\r\n        ISplinterlands splinterlands = ISplinterlands(splinterlandsAddr);\r\n\r\n        splinterlands.unlockCard(\r\n                    splinterlands.tokenIdForCardId(_splinterId),\r\n                    _cardHolder\r\n                );\r\n    }\r\n\r\n    function burnCard(string memory _splinterId) public onlySigner {\r\n        ISplinterlands splinterlands = ISplinterlands(splinterlandsAddr);\r\n        splinterlands.burnCard(splinterlands.tokenIdForCardId(_splinterId));\r\n    }\r\n\r\n    function proposeSubstitution(\r\n                address _affirmer,\r\n                address _retiree,\r\n                address _replacement\r\n            )\r\n                public\r\n                onlySigner\r\n                isSigner(_affirmer)\r\n                isSigner(_retiree)\r\n                notSigner(_replacement)\r\n    {\r\n        address _proposer = msg.sender;\r\n\r\n        require(_affirmer != _proposer, \u0022CardMinter: Affirmer Is Proposer\u0022);\r\n        require(_affirmer != _retiree, \u0022CardMinter: Affirmer Is Retiree\u0022);\r\n        require(_proposer != _retiree, \u0022CardMinter: Retiree Is Proposer\u0022);\r\n\r\n        proposals[_proposer] = SubstitutionProposal(_proposer, _affirmer, _retiree, _replacement);\r\n    }\r\n\r\n    function withdrawProposal() public onlySigner {\r\n        delete proposals[msg.sender];\r\n    }\r\n\r\n    function withdrawStaleProposal(address _oldProposer) public onlySigner notSigner(_oldProposer) {\r\n        delete proposals[_oldProposer];\r\n    }\r\n\r\n    function acceptProposal(address _proposer) public onlySigner isSigner(_proposer) {\r\n        SubstitutionProposal storage proposal = proposals[_proposer];\r\n\r\n        require(proposal.affirmer == msg.sender, \u0022CardMinter: Not Affirmer\u0022);\r\n\r\n        if (signer1 == proposal.retiree) {\r\n            signer1 = proposal.replacement;\r\n        } else if (signer2 == proposal.retiree) {\r\n            signer2 = proposal.replacement;\r\n        } else if (signer3 == proposal.retiree) {\r\n            signer3 = proposal.replacement;\r\n        }\r\n\r\n        delete proposals[_proposer];\r\n    }\r\n\r\n    modifier onlySigner() {\r\n        require(msg.sender == signer1 ||\r\n                msg.sender == signer2 ||\r\n                msg.sender == signer3,\r\n                \u0022CardMinter: Not Signer\u0022);\r\n        _;\r\n    }\r\n\r\n    modifier isSigner(address _addr) {\r\n        require(_addr == signer1 ||\r\n                _addr == signer2 ||\r\n                _addr == signer3,\r\n                \u0022CardMinter: Addr Not Signer\u0022);\r\n        _;\r\n    }\r\n\r\n    modifier notSigner(address _addr) {\r\n        require(_addr != signer1 \u0026\u0026\r\n                _addr != signer2 \u0026\u0026\r\n                _addr != signer3,\r\n                \u0022CardMinter: Addr Is Signer\u0022);\r\n        _;\r\n    }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022withdrawProposal\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_proposer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022acceptProposal\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_splinterId\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_cardHolder\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022mintCard\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_affirmer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_retiree\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_replacement\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022proposeSubstitution\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_splinterId\u0022,\u0022type\u0022:\u0022string\u0022},{\u0022name\u0022:\u0022_cardHolder\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022unlockCard\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_oldProposer\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022withdrawStaleProposal\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_splinterId\u0022,\u0022type\u0022:\u0022string\u0022}],\u0022name\u0022:\u0022burnCard\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[{\u0022name\u0022:\u0022_splinterlandsAddr\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_signer1\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_signer2\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_signer3\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022}]","ContractName":"CardMinter","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"000000000000000000000000e3870569f9e1836960bf30b5a45fc743cef0ab0e0000000000000000000000007aec46a3601d9b040dfd2150a612d92a393c90f900000000000000000000000008f8d73bd1d580c1682cc3667640f16a8dd08d2b000000000000000000000000f42fcbe92d0814c352d8c0e2acd3ed17ab17d2b1","Library":"","SwarmSource":"bzzr://d6f6e90159bc25d0943988281c535ac3b9cf73c1758588d31776f7ae4fcc2ab1"}]