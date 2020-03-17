[{"SourceCode":"pragma solidity ^0.5.8;\r\n\r\ncontract LoteoPoker {\r\n\r\n    mapping (bytes32 =\u003E bool) private paymentIds;\r\n\r\n    event GameStarted(address _contract);\r\n    event PaymentReceived(address _player, uint _amount);\r\n    event PaymentMade(address _player, address _issuer, uint _amount);\r\n    event UnauthorizedCashoutAttempt(address _bandit, uint _amount);\r\n\r\n    constructor()\r\n        public\r\n    {\r\n        emit GameStarted(address(this));\r\n    }\r\n\r\n    function buyCredit(bytes32 _paymentId)\r\n        public\r\n        payable\r\n        returns (bool success)\r\n    {\r\n        address payable player = msg.sender;\r\n        uint amount = msg.value;\r\n        paymentIds[_paymentId] = true;\r\n        emit PaymentReceived(player, amount);\r\n        return true;\r\n    }\r\n\r\n    function verifyPayment(bytes32 _paymentId)\r\n        public\r\n        view\r\n        returns (bool success)\r\n    {\r\n        return paymentIds[_paymentId];\r\n    }\r\n\r\n    function cashOut(address payable _player, uint _amount)\r\n        public\r\n        payable\r\n        returns (bool success)\r\n    {\r\n        address payable paymentIssuer = msg.sender;\r\n        address permitedIssuer = 0xB3b8D45A26d16Adb41278aa8685538B937487B15;\r\n\r\n        if(paymentIssuer!=permitedIssuer) {\r\n            emit UnauthorizedCashoutAttempt(paymentIssuer, _amount);\r\n            return false;\r\n        }\r\n\r\n        _player.transfer(_amount);\r\n\r\n        emit PaymentMade(_player, paymentIssuer, _amount);\r\n        return true;\r\n    }\r\n\r\n    function payRoyalty()\r\n        public\r\n        payable\r\n        returns (bool success)\r\n    {\r\n        uint royalty = address(this).balance/2;\r\n        address payable trustedParty1 = 0xcdAD2D448583C1d9084F54c0d207b3eBE0398490;\r\n        address payable trustedParty2 = 0xD204C49C66011787EF62d9DFD820Fd32E07AF7F6;\r\n        trustedParty1.transfer((royalty*10)/100);\r\n        trustedParty2.transfer((royalty*90)/100);\r\n        return true;\r\n    }\r\n\r\n    function getContractBalance()\r\n        public\r\n        view\r\n        returns (uint balance)\r\n    {\r\n        return address(this).balance;\r\n    }\r\n\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[],\u0022name\u0022:\u0022payRoyalty\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_player\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022cashOut\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_paymentId\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022verifyPayment\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:true,\u0022inputs\u0022:[],\u0022name\u0022:\u0022getContractBalance\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022balance\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022view\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_paymentId\u0022,\u0022type\u0022:\u0022bytes32\u0022}],\u0022name\u0022:\u0022buyCredit\u0022,\u0022outputs\u0022:[{\u0022name\u0022:\u0022success\u0022,\u0022type\u0022:\u0022bool\u0022}],\u0022payable\u0022:true,\u0022stateMutability\u0022:\u0022payable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022inputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022constructor\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_contract\u0022,\u0022type\u0022:\u0022address\u0022}],\u0022name\u0022:\u0022GameStarted\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_player\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022PaymentReceived\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_player\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_issuer\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022PaymentMade\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_bandit\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022UnauthorizedCashoutAttempt\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"LoteoPoker","CompilerVersion":"v0.5.8\u002Bcommit.23d335f2","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://bcc35b316feb44685f0bc93b2c4e54ddc7de2ede4da8960ea6414e076117cd45"}]