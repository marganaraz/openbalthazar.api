[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\ncontract daoCovenantAgreement {\r\n\r\n/* This DAO Covenant Agreement (\u0022DCA\u0022) is entered into by and among \r\nthe owners of the Ethereum blockchain network (\u0022Ethereum\u0022) addresses that \r\nprovide their authorized digital signatures by \r\ncalling the *signDCA* Solidity function embedded below (\u201CDAO Participants\u201D).\r\n\r\nWHEREAS,\r\n\r\nThe DAO Participants have agreed to enter into this DCA for the purpose of \r\nregulating the exercise of their rights in relation to digital organizations \r\noperating on Ethereum (\u0022DAOs\u0022);\r\n\r\nNOW, THEREFORE in consideration of the premises and the mutual covenants herein contained, \r\nfor good and valuable consideration, the receipt and sufficiency of which are hereby acknowledged, \r\nthe DAO Participants agree as follows: \r\n\r\n1. The DAO Participants shall actively participate in the governance of the DAOs \r\nin which they have a voting or similar stake on Ethereum (\u0022Affiliated DAOs\u0022).\r\n\r\n2. The DAO Participants shall support the stated purposes of Affiliated DAOs,\r\nand refrain from any action that may conflict with or harm such purposes.\r\n\r\n3. The DAO Participants shall comply in all respects with all relevant laws \r\nto which they may be subject, if failure to do so would materially impair their  \r\nperformance under obligations to Affiliated DAOs.\r\n\r\n4. The DAO Participants shall not sell or transfer or otherwise \r\ndispose of in any manner (or purport to do so) all or any part of, \r\nor any interest in, Affiliated DAOs, \r\nunless otherwise authorized and in compliance with applicable law.\r\n\r\n5. The results of proper operation of Affiliated DAOs shall be determinative in \r\nthe rights and obligations of, and shall be final, binding upon and non-appealable by, \r\nthe DAO Participants with regard to such DAOs and their assets.\r\n \r\n6. All claims and disputes arising under or relating to Affiliated DAOs \r\nshall be settled by binding arbitration.\r\n\r\n7. This DCA constitutes legally valid obligations binding and enforceable \r\namong the DAO Participants in accordance with its terms, \r\nand shall be governed by the choice of New York law.\r\n\r\n8. Digital Signatories to this DCA may opt out of the adoption pool \r\nestablished hereby upon calling the *revokeDCA* Solidity function embedded below */\r\n\r\nmapping (address =\u003E Signatory) public signatories; \r\nuint256 public DCAsignatories; \r\n\r\nevent DCAsigned(address indexed signatoryAddress, uint256 signatureDate);\r\nevent DCArevoked(address indexed signatoryAddress);\r\n\r\nstruct Signatory { // callable information about each DCA Digital Signatory\r\n        address signatoryAddress; // Ethereum address for each signatory in adoption pool\r\n        uint256 signatureDate; // blocktime of successful signature function call\r\n        bool signatureRevoked; // status of adoption \r\n    }\r\n\r\nfunction signDCA() public {\r\n    address signatoryAddress = msg.sender;\r\n    uint256 signatureDate = block.timestamp; // \u0022now\u0022\r\n    bool signatureRevoked = false; \r\n    DCAsignatories = DCAsignatories \u002B 1; \r\n    \r\n    signatories[signatoryAddress] = Signatory(\r\n            signatoryAddress,\r\n            signatureDate,\r\n            signatureRevoked);\r\n            \r\n            emit DCAsigned(signatoryAddress, signatureDate);\r\n    }\r\n    \r\nfunction revokeDCA() public {\r\n    Signatory storage signatory = signatories[msg.sender];\r\n    assert(address(msg.sender) == signatory.signatoryAddress);\r\n    signatory.signatureRevoked = true;\r\n    DCAsignatories = DCAsignatories - 1; \r\n    \r\n    emit DCArevoked(msg.sender);\r\n    }\r\n    \r\nfunction tipOpenESQ() public payable { // **tip Open, ESQ LLC/DAO ether (\u039E) for limited liability DAO research**\r\n    0xBBE222Ef97076b786f661246232E41BE0DFf6cc4.transfer(msg.value);\r\n    }\r\n\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022signDCA\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022tipOpenESQ\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022revokeDCA\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022signatories\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022signatoryAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022signatureDate\u0022,\u0022type\u0022:\u0022uint256\u0022},{\u0022name\u0022:\u0022signatureRevoked\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022DCAsignatories\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022signatoryAddress\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022signatureDate\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022DCAsigned\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022signatoryAddress\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022DCArevoked\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"daoCovenantAgreement","CompilerVersion":"v0.5.1\u002Bcommit.c8a2cb62","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://b71dca8df5566f478496745ed17a0b2cfa6114584d4f3a7c2ca18490a5f83998"}]