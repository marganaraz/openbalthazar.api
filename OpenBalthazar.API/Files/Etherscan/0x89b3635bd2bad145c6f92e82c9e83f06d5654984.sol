[{"SourceCode":"pragma solidity ^0.5.0;\r\n\r\n\r\ncontract SavingsLogger {\r\n\r\n        event Deposit(address indexed sender, uint8 protocol, uint amount);\r\n        event Withdraw(address indexed sender, uint8 protocol, uint amount);\r\n        event Swap(address indexed sender, uint8 fromProtocol, uint8 toProtocol, uint amount);\r\n        \r\n        function logDeposit(address _sender, uint8 _protocol, uint _amount) external {\r\n            emit Deposit(_sender, _protocol, _amount);\r\n        }\r\n        \r\n        function logWithdraw(address _sender, uint8 _protocol, uint _amount) external {\r\n            emit Withdraw(_sender, _protocol, _amount);\r\n        }\r\n        \r\n        function logSwap(address _sender, uint8 _protocolFrom, uint8 _protocolTo, uint _amount) external {\r\n            emit Swap(_sender, _protocolFrom, _protocolTo, _amount);\r\n        }\r\n}","ABI":"[{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_protocol\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022logDeposit\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_protocolFrom\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022_protocolTo\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022logSwap\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022constant\u0022:false,\u0022inputs\u0022:[{\u0022name\u0022:\u0022_sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022name\u0022:\u0022_protocol\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022name\u0022:\u0022_amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022logWithdraw\u0022,\u0022outputs\u0022:[],\u0022payable\u0022:false,\u0022stateMutability\u0022:\u0022nonpayable\u0022,\u0022type\u0022:\u0022function\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022protocol\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Deposit\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022protocol\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Withdraw\u0022,\u0022type\u0022:\u0022event\u0022},{\u0022anonymous\u0022:false,\u0022inputs\u0022:[{\u0022indexed\u0022:true,\u0022name\u0022:\u0022sender\u0022,\u0022type\u0022:\u0022address\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022fromProtocol\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022toProtocol\u0022,\u0022type\u0022:\u0022uint8\u0022},{\u0022indexed\u0022:false,\u0022name\u0022:\u0022amount\u0022,\u0022type\u0022:\u0022uint256\u0022}],\u0022name\u0022:\u0022Swap\u0022,\u0022type\u0022:\u0022event\u0022}]","ContractName":"SavingsLogger","CompilerVersion":"v0.5.10\u002Bcommit.5a6ea5b1","OptimizationUsed":"0","Runs":"200","ConstructorArguments":"","Library":"","SwarmSource":"bzzr://1c2c70e1be6ca383396b8cac1aefe5975c96c3c5c519e20fd1ae6970e62f2527"}]